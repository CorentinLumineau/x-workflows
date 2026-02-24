---
name: git-merge-pr
description: Use when a pull request has passed review and CI checks and is ready to merge.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
user-invocable: true
argument-hint: "<pr-number>"
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
chains-to:
  - skill: git-create-release
    condition: "milestone complete"
  - skill: git-resolve-conflict
    condition: "merge conflict detected"
  - skill: git-cleanup-branches
    condition: "after successful merge"
  - skill: git-implement-issue
    condition: "start next issue after merge"
chains-from:
  - skill: git-check-ci
  - skill: git-review-pr
  - skill: git-resolve-conflict
  - skill: git-review-multiple-pr
---

# /git-merge-pr

Merge a pull request after validating CI status, reviews, and selecting merge strategy.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Type** | UTILITY |
| **Position** | End of PR lifecycle |
| **Typical Flow** | `git-check-ci` or `git-review-pr` → **`git-merge-pr`** → `git-create-release` or `git-cleanup-branches` |
| **Human Gates** | Merge strategy (Critical), force merge (Critical), local branch cleanup (Medium), issue closure (Medium) |
| **State Tracking** | Updates workflow state with merge commit SHA, clears stale implement-issue state |

## Intention

Merge a pull request on the detected forge (GitHub/Gitea) after validating:
- CI pipeline status (all checks passing)
- Required reviews approved
- No merge conflicts
- User-selected merge strategy (squash/rebase/merge)

**Arguments**: `$ARGUMENTS` (required) = PR number to merge

## Behavioral Skills

This workflow activates:
- **forge-awareness** - Detects forge type and uses appropriate CLI
- **ci-awareness** - Validates CI pipeline status and merge readiness

## Instructions

<instructions>

### Phase 0: Forge and CI Detection

**Conflict recovery check**: If `resume_from_conflict: true` exists in workflow state (set by `git-resolve-conflict` after successful resolution):
- Read preserved context: `pr_number`, `merge_strategy`, `feature_branch`, `base_branch` from workflow state
- Clear `resume_from_conflict` flag
- Skip Phase 0 and Phase 1 entirely — conflicts are resolved, PR was already validated
- Jump directly to **Phase 2** (if merge strategy needs re-confirmation) or **Phase 3** (if strategy was preserved)

**Normal flow**:

<context-query tool="project_context">
  <fallback>
  1. Activate `forge-awareness` to detect forge type and validate CLI availability
  </fallback>
</context-query>

<context-query tool="ci_status" params='{"target":"pr","ref":"$PR_NUMBER"}'>
  <fallback>
  2. Activate `ci-awareness` to check CI configuration and merge readiness
  </fallback>
</context-query>

3. Validate `$ARGUMENTS` contains valid PR number

<context-query tool="list_prs" params='{"pr_number":"$PR_NUMBER","include_checks":true}'>
  <fallback>
  4. Fetch PR details via forge CLI:
   - GitHub: `gh pr view {PR} --json number,title,state,mergeable,reviews,statusCheckRollup`
   - Gitea: `tea pr show {PR}`
  </fallback>
</context-query>

### Phase 1: Validate Merge Readiness

> **Reference**: See `references/merge-readiness-checklist.md` for full validation matrix (PR state, CI, reviews, mergeable, force-merge gate).

### Phase 2: Select Merge Strategy

> **Reference**: See `references/merge-strategy-guide.md` for strategy options (squash/rebase/merge), recommendation heuristics, and strategy gate.

### Phase 3: Execute Merge

1. Construct merge command based on strategy:
   - Squash: `gh pr merge {PR} --squash` or `tea pr merge {PR} --squash`
   - Rebase: `gh pr merge {PR} --rebase` or `tea pr merge {PR} --rebase`
   - Merge: `gh pr merge {PR} --merge` or `tea pr merge {PR} --merge`
2. If squash selected, allow user to edit commit message
   <workflow-gate type="human-approval" criticality="medium" prompt="Edit squash commit message?">
   </workflow-gate>
3. Execute merge command
4. Capture merge commit SHA from output
5. If merge fails:
   - Check if conflict occurred mid-merge
   - If yes, offer to chain to `git-resolve-conflict`
   <!-- <workflow-chain next="git-resolve-conflict" condition="merge conflict during execution"> -->
   - Otherwise, display error and exit

### Phase 4: Cleanup Remote Branch

1. Ask user if remote branch should be deleted
   <workflow-gate type="human-approval" criticality="medium" prompt="Delete remote branch after merge?">
   </workflow-gate>
2. If approved, delete via:
   - GitHub: `gh pr merge` with `--delete-branch` flag (can add to phase 3 command)
   - Gitea: `git push origin --delete {branch-name}`
3. Update PR labels to include "merged"

### Phase 5: Update State and Complete Post-Merge Lifecycle

1. **Clear stale workflow state** — If previous `git-implement-issue` state exists, clear stale fields:
   - Read existing workflow state
   - Preserve merge metadata (this phase)
   - Clear: `active_workflow`, `issue_number`, `feature_branch`, `branch_strategy`, `pr_pending` (from implement-issue)
   - Write cleaned state

2. **Update workflow state** with merge metadata:
   ```json
   {
     "pr_number": 123,
     "merge_sha": "abc123...",
     "merge_strategy": "squash",
     "merged_at": "ISO-8601",
     "remote_branch_deleted": true,
     "returned_to_base": false,
     "local_branch_deleted": false,
     "issue_verified_closed": false
   }
   ```

3. Present success message with merge commit SHA

### Phase 5b: Return to Base Branch

After successful merge, return to the base branch and pull latest:

```bash
# Switch back to the base branch (target of the merged PR)
git switch $BASE_BRANCH

# Pull latest to include the merge commit
git pull origin $BASE_BRANCH
```

Update state: `returned_to_base: true`

This step is deterministic and safe — no gate required.

### Phase 5c: Clean Local Feature Branch

<workflow-gate type="choice" id="clean-local-branch">
  <question>Delete local feature branch `$FEATURE_BRANCH`? It has been merged into $BASE_BRANCH.</question>
  <header>Local cleanup</header>
  <option key="delete" recommended="true">
    <label>Delete local branch</label>
    <description>Remove the merged feature branch locally via `git branch -d`</description>
  </option>
  <option key="keep">
    <label>Keep branch</label>
    <description>Retain the local branch for reference</description>
  </option>
</workflow-gate>

If "Delete local branch":
```bash
# Safe delete — only works if branch is fully merged
git branch -d $FEATURE_BRANCH
```

If delete fails (branch not fully merged), inform user and suggest `git branch -D` with explicit warning. Do NOT auto-force-delete.

Update state: `local_branch_deleted: true` (or `false` if kept/failed)

### Phase 5d: Verify Issue Closure

> **Reference**: See `references/issue-closure-verification.md` for issue extraction patterns,
> forge API closure commands (Gitea `tea` / GitHub `gh`), and closure choice gate.

Check that linked issues were closed by the merge. If direct-mode (no PR), manually close via forge API.

### Phase 5e: Suggest Next Steps

<!-- <workflow-chain next="git-create-release" condition="merge to main/master"> -->
- If merged to main: "Consider creating release with `/git-create-release`"
<!-- <workflow-chain next="git-cleanup-branches" condition="multiple stale branches exist"> -->
- "Clean up other local branches with `/git-cleanup-branches`"
<!-- <workflow-chain next="git-implement-issue" condition="start next issue"> -->
- "Start next issue with `/git-implement-issue`"

</instructions>

## When to Load References

- **For PR state, CI, review, and mergeable validation matrix**: See `references/merge-readiness-checklist.md`
- **For merge strategy options (squash/rebase/merge) and recommendation heuristics**: See `references/merge-strategy-guide.md`
- **For issue extraction from PR, forge API closure, and closure gate**: See `references/issue-closure-verification.md`

## Human-in-Loop Gates

| Gate | Criticality | Trigger Condition | Default Action |
|------|-------------|-------------------|----------------|
| Force merge | Critical | CI failing or reviews incomplete | Reject unless explicit "force merge" |
| Merge strategy | Critical | Always before merge | Wait for selection (suggest based on analysis) |
| Squash message edit | Medium | Squash strategy selected | Use default PR title |
| Branch deletion | Medium | After successful merge | Keep branch (safer default) |
| Local branch cleanup | Medium | After return to base branch | Delete merged branch |
| Issue closure | Medium | Issue still open after merge | Close issue via forge API |

## Workflow Chaining

<chaining-instruction>
**Chains from**: `git-check-ci`, `git-review-pr`, `git-resolve-conflict`
**Chains to**: `git-create-release`, `git-resolve-conflict`, `git-cleanup-branches`, `git-implement-issue`

**Forward chaining**:
- If merged to default branch → suggest `git-create-release`
- If local branches exist → suggest `git-cleanup-branches`
- After merge complete → suggest `git-implement-issue` for next issue

**Backward chaining**:
- If merge conflicts → chain to `git-resolve-conflict` and return here after resolution
- Accepts input from any PR validation workflow

**Conflict recovery mode**:
- If `resume_from_conflict: true` in workflow state → skip Phase 0–1 validation, resume at Phase 2 (merge strategy) or Phase 3 (execute merge)
- Set by `git-resolve-conflict` when chaining back after conflict resolution

<workflow-chain on="clean-local-branch" action="phase5c" />
<workflow-chain on="close-issue" action="phase5d" />
<workflow-chain on="suggest-next" skill="git-implement-issue" args="" condition="start next issue" />
</chaining-instruction>

## Safety Rules

1. **Never merge without CI check** - Always validate CI status before merge
2. **Never delete branches without confirmation** - Branch deletion requires explicit approval
3. **Never force merge silently** - Force merge requires explicit "force merge" confirmation phrase
4. **Preserve merge history** - Never use `--no-ff` flag without user request
5. **Validate PR state** - Never attempt to merge already-merged or closed PRs

## Critical Rules

1. **Validation order is mandatory**:
   - Check PR state (open)
   - Check CI status (passing)
   - Check reviews (approved)
   - Check mergeable (no conflicts)
   - THEN allow merge strategy selection
2. **Merge strategy must be user-selected**:
   - Never auto-select strategy
   - Provide recommendation but require confirmation
3. **Atomic merge operations**:
   - If merge fails, do not proceed to branch deletion
   - Do not update labels if merge failed
4. **Conflict resolution chaining**:
   - Detect conflicts early (mergeable: false)
   - Detect conflicts during merge (command failure)
   - Always offer `git-resolve-conflict` chain option

## Success Criteria

- [ ] PR validated (open, CI passing, reviews approved, no conflicts)
- [ ] Merge strategy selected by user
- [ ] Merge executed successfully via forge CLI
- [ ] Merge commit SHA captured
- [ ] Remote branch deleted (if user approved)
- [ ] PR labels updated to include "merged"
- [ ] Stale implement-issue state cleared
- [ ] Workflow state updated with merge metadata
- [ ] Returned to base branch with latest changes pulled
- [ ] Local feature branch cleaned up (if user approved)
- [ ] Linked issue verified closed (or manually closed)
- [ ] Next steps suggested (release, cleanup, next issue)

## References

- GitHub PR merge docs: https://cli.github.com/manual/gh_pr_merge
- Gitea Tea merge: https://gitea.com/gitea/tea
- Git merge strategies: https://git-scm.com/docs/git-merge
