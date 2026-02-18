# Conflict Detection Scripts

## Check Git Status

```bash
git status --porcelain
```

Parse output to identify:
- **Merge conflict**: Both modified (UU), both added (AA), both deleted (DD)
- **Rebase conflict**: Look for `.git/rebase-merge/` or `.git/rebase-apply/` directory
- **Cherry-pick conflict**: Look for `.git/CHERRY_PICK_HEAD`

## Determine Operation Type

```bash
# Check for merge
if [ -f .git/MERGE_HEAD ]; then
  OPERATION="merge"
  SOURCE_BRANCH=$(git rev-parse --abbrev-ref MERGE_HEAD)
fi

# Check for rebase
if [ -d .git/rebase-merge ]; then
  OPERATION="rebase"
  SOURCE_BRANCH=$(cat .git/rebase-merge/head-name | sed 's#refs/heads/##')
fi

# Check for cherry-pick
if [ -f .git/CHERRY_PICK_HEAD ]; then
  OPERATION="cherry-pick"
  COMMIT_SHA=$(cat .git/CHERRY_PICK_HEAD)
fi
```

## Display Context

```
Conflict detected during: {merge|rebase|cherry-pick}
Source: {branch or commit}
Target: {current branch}
Files affected: {count}
```
