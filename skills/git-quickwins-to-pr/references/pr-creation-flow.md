# PR Creation Flow

## Phase 4.5: Sequential PR Creation Loop

Present each implementation report for PR creation. Process in original selection order.

### Per-Quickwin Flow

**Progress banner**: `Implementation {current}/{total}: Issue #{number} — {title} | Status: {status}`

Display the full implementation report, then:

**If status is FAILED**: skip PR creation, note failure in summary.

**If status is DONE or PARTIAL**:

1. **Show diff summary**:
```bash
git diff origin/$BASE_BRANCH...feature-branch.$ISSUE_NUMBER --stat
```

2. **Confirm PR creation** via workflow-gate (Create PR / Skip PR).

3. **If "Create PR"**:
   - Push: `git push -u origin feature-branch.$ISSUE_NUMBER`
   - Generate PR description (include `close #$ISSUE_NUMBER`)
   - Create PR via forge CLI using **single-quoted heredoc** for body:

```bash
# Write PR body to tmpfile (both forges use the same file)
BODY_FILE=$(mktemp)
cat > "$BODY_FILE" << 'PR_BODY_EOF'
## Summary
{changes_summary}

## Quick Win Details
- **Category**: {category}
- **Score**: {score}
- **File**: {file}:{line}

Closes #{issue_number}
PR_BODY_EOF

# Gitea (tea lacks --body-file; use tmpfile + cat)
tea pr create --repo {owner}/{repo} \
  --head feature-branch.$ISSUE_NUMBER \
  --base $BASE_BRANCH \
  --title '{pr_title}' \
  --body "$(cat "$BODY_FILE")"

# GitHub (preferred: --body-file avoids shell entirely)
gh pr create \
  --head feature-branch.$ISSUE_NUMBER \
  --base $BASE_BRANCH \
  --title '{pr_title}' \
  --body-file "$BODY_FILE"

rm -f "$BODY_FILE"
```

4. **If "Skip PR"**: note as skipped, branch remains for later manual PR.

## Phase 4.75: Worktree Cleanup (Parallel Mode Only)

Skip if sequential mode was used.

After all PR decisions:

1. `git worktree list` — list all worktrees from the implementation phase
2. **For each worktree where PR was created** → auto-remove: `git worktree remove {path}`
3. **For each worktree where PR was skipped or implementation failed**:

Present a workflow-gate per worktree:

```
Question: "Worktree for issue #{issue_number} was not submitted as a PR. Remove it?"
Options:
  - "Remove worktree" — Delete worktree and working directory (branch preserved)
  - "Keep worktree" — Retain for later manual work
```

4. `git worktree prune` — prune orphaned references
5. `git worktree list` — verify cleanup (only main working tree + explicitly kept worktrees remain)
