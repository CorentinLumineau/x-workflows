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
1. Activate `forge-awareness` to detect forge type and validate CLI availability
2. Activate `ci-awareness` to check CI configuration
3. Validate `$ARGUMENTS` contains valid PR number
4. Fetch PR details via forge CLI:
   - GitHub: `gh pr view {PR} --json number,title,state,mergeable,reviews,statusCheckRollup`
   - Gitea: `tea pr show {PR}`

### Phase 1: Validate Merge Readiness

1. Check PR state is "OPEN" - if already merged/closed, inform user and exit
2. Validate CI status via `ci-awareness`:
   - Read `ci_context.merge_ready` state
   - If false, check `ci_context.failing_checks` for details
3. Validate required reviews approved:
   - Parse review status from PR JSON
   - Confirm at least one approval (or per repo settings)
4. Check mergeable status (no conflicts):
   - If `mergeable: false` detected, offer to chain to `git-resolve-conflict`
   <!-- <workflow-chain next="git-resolve-conflict" condition="merge conflicts detected"> -->
5. If any validation fails:
   - Present detailed status report
   - Ask user if they want to force merge (require explicit "force merge" confirmation)
   <workflow-gate type="human-approval" criticality="critical" prompt="CI failing or reviews incomplete. Force merge anyway?">
   </workflow-gate>

### Phase 2: Select Merge Strategy

1. Present merge strategy options with explanations:
   ```
   1. Squash and merge - Combine all commits into one (recommended for feature branches)
   2. Rebase and merge - Replay commits on base branch (clean linear history)
   3. Create merge commit - Preserve all commits with merge commit (full history)
   ```
2. Analyze PR to recommend strategy:
   - Single commit → suggest squash
   - Multiple clean commits → suggest rebase
   - Complex history → suggest merge commit
3. Prompt user for strategy selection
<workflow-gate type="human-approval" criticality="critical" prompt="Select merge strategy (squash/rebase/merge)?">
</workflow-gate>
4. Store selected strategy in `merge_context.strategy`

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

1. Extract issue number from PR body — look for `Closes #N`, `Fixes #N`, `Resolves #N` patterns (case-insensitive)
2. If issue number found, check issue state via forge API:
   - Gitea: `tea issues details $ISSUE_NUMBER` — check state field
   - GitHub: `gh issue view $ISSUE_NUMBER --json state`
3. If issue is already closed: report "Issue #$ISSUE_NUMBER auto-closed by merge" ✓
4. If issue is still open:

<workflow-gate type="choice" id="close-issue">
  <question>Issue #$ISSUE_NUMBER is still open after merge. Close it now?</question>
  <header>Issue closure</header>
  <option key="close" recommended="true">
    <label>Close issue</label>
    <description>Close issue #$ISSUE_NUMBER via forge API</description>
  </option>
  <option key="keep-open">
    <label>Keep open</label>
    <description>Leave issue open (may need further work)</description>
  </option>
</workflow-gate>

If "Close issue":
- Gitea: `tea issues close $ISSUE_NUMBER`
- GitHub: `gh issue close $ISSUE_NUMBER`

5. If no issue number found in PR body: skip (inform user "No linked issue found in PR description")

Update state: `issue_verified_closed: true` (or `false` if kept open/not found)

### Phase 5e: Suggest Next Steps

<!-- <workflow-chain next="git-create-release" condition="merge to main/master"> -->
- If merged to main: "Consider creating release with `/git-create-release`"
<!-- <workflow-chain next="git-cleanup-branches" condition="multiple stale branches exist"> -->
- "Clean up other local branches with `/git-cleanup-branches`"
<!-- <workflow-chain next="git-implement-issue" condition="start next issue"> -->
- "Start next issue with `/git-implement-issue`"

</instructions>

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
