# PR Description Guide

> Extracted from git-implement-issue SKILL.md — PR description format and guidelines.

## PR Description Template

```markdown
## Summary
<2-3 sentences: what this PR does and why, referencing the issue context>

## Changes
<grouped bullet points by theme, NOT 1:1 with commits>

## Impact
<optional: breaking changes, migration notes, testing considerations>

close #$ISSUE_NUMBER
```

## Guidelines

- Be specific: mention component names, file counts, patterns used
- Group by theme, not by commit
- Highlight reviewer concerns: breaking changes, config changes, new dependencies
- Include metrics when relevant: line counts, component counts
- Skip trivial details
- The `Impact` section is optional — omit for straightforward PRs

## Output Format

After successful PR creation:
```
## Issue #$ISSUE_NUMBER Complete

| Step | Status |
|------|--------|
| Issue fetched | Done |
| Branch created | feature-branch.$ISSUE_NUMBER |
| Implementation | Completed via x-auto |
| PR created | $PR_URL |

PR links to issue #$ISSUE_NUMBER and will auto-close on merge.
```

## Examples

**Standard feature** — `/git-implement-issue 42`:
Fetches issue #42 -> creates `feature-branch.42` -> routes through x-auto (likely APEX) -> creates PR with `close #42`.

**Bug fix** — `/git-implement-issue 108`:
Fetches issue #108 -> creates `feature-branch.108` -> x-auto routes to ONESHOT/DEBUG -> creates PR with `close #108`.

**Existing branch** — `/git-implement-issue 42` (branch exists):
Detects existing `feature-branch.42` -> asks user to switch or recreate -> continues from current state.

**Interactive selection** — `/git-implement-issue` (no arguments):
Fetches open issues -> filters out those with PRs -> groups by milestone -> presents numbered list -> user picks.

**Direct-on-branch** — `/git-implement-issue 5` (direct strategy):
Fetches issue #5 -> user chooses "directly on current branch" -> implements on main/release -> skips PR creation -> shows recovery instructions for later PR.

### Direct-Mode Completion Output

When `branch_strategy == "direct"`, skip the PR table and show:
```
## Issue #$ISSUE_NUMBER Complete (Direct Mode)

| Step | Status |
|------|--------|
| Issue fetched | Done |
| Branch strategy | Direct (on $CURRENT_BRANCH) |
| Implementation | Completed via x-auto |
| PR | Skipped (direct mode) |

Changes committed directly to $CURRENT_BRANCH.
To create a PR later: `git checkout -b feature-branch.$ISSUE_NUMBER` + `/git-create-pr`
```
