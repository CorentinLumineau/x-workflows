---
name: git-merge-pr
description: Use when a pull request has passed review and CI checks and is ready to merge.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
user-invocable: true
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
  argument-hint: "<pr-number>"
chains-to:
  - skill: git-create-release
    condition: "milestone complete"
    auto: false
  - skill: git-resolve-conflict
    condition: "merge conflict detected"
    auto: true
  - skill: git-cleanup-branches
    condition: "after successful merge"
    auto: false
chains-from:
  - skill: git-check-ci
    auto: false
  - skill: git-review-pr
    auto: false
  - skill: git-resolve-conflict
    auto: true
---

# /git-merge-pr

Merge a pull request after validating CI status, reviews, and selecting merge strategy.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Type** | UTILITY |
| **Position** | End of PR lifecycle |
| **Typical Flow** | `git-check-ci` or `git-review-pr` → **`git-merge-pr`** → `git-create-release` or `git-cleanup-branches` |
| **Human Gates** | Merge strategy selection (Critical), force merge if CI failing (Critical) |
| **State Tracking** | Updates workflow state with merge commit SHA |

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

1. Activate `forge-awareness` to detect forge type and validate CLI availability
2. Activate `ci-awareness` to check CI configuration
3. Validate `$ARGUMENTS` contains valid PR number
4. Fetch PR details via forge CLI:
   - GitHub: `gh pr view {PR} --json number,title,state,mergeable,reviews,statusCheckRollup`
   - Gitea: `tea pr show {PR}`

### Phase 1: Validate Merge Readiness

<!-- <state-checkpoint id="merge-validation" phase="git-merge-pr" status="merge-validation" data="pr_number, ci_status, review_status, mergeable"> -->
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
   <!-- <workflow-gate type="human-approval" criticality="critical" prompt="CI failing or reviews incomplete. Force merge anyway?"> -->

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
<!-- <workflow-gate type="human-approval" criticality="critical" prompt="Select merge strategy (squash/rebase/merge)?"> -->
4. Store selected strategy in `merge_context.strategy`

### Phase 3: Execute Merge

1. Construct merge command based on strategy:
   - Squash: `gh pr merge {PR} --squash` or `tea pr merge {PR} --squash`
   - Rebase: `gh pr merge {PR} --rebase` or `tea pr merge {PR} --rebase`
   - Merge: `gh pr merge {PR} --merge` or `tea pr merge {PR} --merge`
2. If squash selected, allow user to edit commit message
   <!-- <workflow-gate type="human-approval" criticality="medium" prompt="Edit squash commit message?"> -->
3. Execute merge command
4. Capture merge commit SHA from output
5. If merge fails:
   - Check if conflict occurred mid-merge
   - If yes, offer to chain to `git-resolve-conflict`
   <!-- <workflow-chain next="git-resolve-conflict" condition="merge conflict during execution"> -->
   - Otherwise, display error and exit

### Phase 4: Cleanup Remote Branch

1. Ask user if remote branch should be deleted
   <!-- <workflow-gate type="human-approval" criticality="medium" prompt="Delete remote branch after merge?"> -->
2. If approved, delete via:
   - GitHub: `gh pr merge` with `--delete-branch` flag (can add to phase 3 command)
   - Gitea: `git push origin --delete {branch-name}`
3. Update PR labels to include "merged"

### Phase 5: Update State and Suggest Next Steps

<!-- <state-checkpoint id="merge-complete" phase="git-merge-pr" status="merge-complete" data="merge_sha, merged_at, deleted_branch"> -->
1. Update workflow state:
   ```json
   {
     "pr_number": 123,
     "merge_sha": "abc123...",
     "merge_strategy": "squash",
     "merged_at": "ISO-8601",
     "remote_branch_deleted": true
   }
   ```
2. Present success message with merge commit SHA
3. Suggest next steps:
   <!-- <workflow-chain next="git-create-release" condition="merge to main/master"> -->
   - If merged to main: "Consider creating release with `/git-create-release`"
   <!-- <workflow-chain next="git-cleanup-branches" condition="multiple stale branches exist"> -->
   - "Clean up local branches with `/git-cleanup-branches`"

</instructions>

## Human-in-Loop Gates

| Gate | Criticality | Trigger Condition | Default Action |
|------|-------------|-------------------|----------------|
| Force merge | Critical | CI failing or reviews incomplete | Reject unless explicit "force merge" |
| Merge strategy | Critical | Always before merge | Wait for selection (suggest based on analysis) |
| Squash message edit | Medium | Squash strategy selected | Use default PR title |
| Branch deletion | Medium | After successful merge | Keep branch (safer default) |

## Workflow Chaining

<chaining-instruction>
**Chains from**: `git-check-ci`, `git-review-pr`, `git-resolve-conflict`
**Chains to**: `git-create-release`, `git-resolve-conflict`, `git-cleanup-branches`

**Forward chaining**:
- If merged to default branch → suggest `git-create-release`
- If local branches exist → suggest `git-cleanup-branches`

**Backward chaining**:
- If merge conflicts → chain to `git-resolve-conflict` and return here after resolution
- Accepts input from any PR validation workflow
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
- [ ] Workflow state updated with merge metadata
- [ ] Next steps suggested (sync, release, cleanup)

## References

- GitHub PR merge docs: https://cli.github.com/manual/gh_pr_merge
- Gitea Tea merge: https://gitea.com/gitea/tea
- Git merge strategies: https://git-scm.com/docs/git-merge
