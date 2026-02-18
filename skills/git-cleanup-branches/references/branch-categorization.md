# Branch Categorization Logic

Detailed categorization rules and detection scripts for classifying branches.

## Protected Branches

Match against `PROTECTED_BRANCHES` patterns:
```bash
for pattern in "${PROTECTED_BRANCHES[@]}"; do
  if [[ "$branch" == $pattern ]]; then
    CATEGORY="protected"
  fi
done
```

## Safe to Delete

Criteria:
1. Merged into main branch: `git branch --merged $MAIN_BRANCH | grep -q "^  $branch$"`
2. AND remote branch deleted (upstream status shows "gone")
3. AND NOT protected
4. AND NOT current branch

Example detection:
```bash
MERGED=$(git branch --merged $MAIN_BRANCH | grep -q "^  $branch$" && echo "yes" || echo "no")
UPSTREAM_STATUS=$(git for-each-ref --format='%(upstream:track)' refs/heads/$branch)
if [[ "$MERGED" == "yes" && "$UPSTREAM_STATUS" == "[gone]" ]]; then
  CATEGORY="safe-to-delete"
fi
```

## Stale Branches

Criteria:
1. No commits in 30+ days
2. NOT merged into main
3. NOT protected
4. NOT current branch

Calculate days since last commit:
```bash
LAST_COMMIT_DATE=$(git log -1 --format=%ci $branch)
DAYS_AGO=$(( ($(date +%s) - $(date -d "$LAST_COMMIT_DATE" +%s)) / 86400 ))
if [[ $DAYS_AGO -gt 30 && "$MERGED" == "no" ]]; then
  CATEGORY="stale"
fi
```

## Orphaned Branches

Criteria:
1. Local branch exists
2. No upstream tracking branch configured
3. NOT merged
4. NOT protected

Detection:
```bash
UPSTREAM=$(git for-each-ref --format='%(upstream)' refs/heads/$branch)
if [[ -z "$UPSTREAM" && "$MERGED" == "no" ]]; then
  CATEGORY="orphaned"
fi
```

## Active Branches

Criteria:
1. Commits in last 30 days
2. OR currently checked out
3. OR has active upstream tracking

Anything not matching other categories is "active".
