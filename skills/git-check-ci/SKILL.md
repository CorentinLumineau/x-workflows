---
name: git-check-ci
description: Use when you need to check CI pipeline status for a branch or pull request.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
user-invocable: true
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
  argument-hint: "[pr-number|branch]"
chains-to:
  - skill: git-merge-pr
    condition: "CI passes"
    auto: false
  - skill: x-fix
    condition: "CI fails"
    auto: false
chains-from:
  - skill: git-create-pr
    auto: true
---

# /git-check-ci

Check CI pipeline status for a branch or pull request and report results.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Type** | UTILITY |
| **Position** | After PR creation or before merge |
| **Typical Flow** | `git-create-pr` → **`git-check-ci`** → `git-merge-pr` or `x-fix` |
| **Human Gates** | None (read-only operation) |
| **State Tracking** | Updates ci_context with check results |

## Intention

Query CI pipeline status for a branch or pull request and present a detailed status report, offering to chain to `x-fix` if checks are failing or `git-merge-pr` if all checks pass.

**Arguments**: `$ARGUMENTS` (optional) = PR number or branch name (defaults to current branch)

## Behavioral Skills

This workflow activates:
- **forge-awareness** - Detects forge type and uses appropriate CLI
- **ci-awareness** - Queries CI pipeline status and parses results

## Instructions

<instructions>

### Phase 0: Forge Detection and Target Identification

1. Activate `forge-awareness` to detect forge type and validate CLI availability
2. Determine check target:
   - If `$ARGUMENTS` is numeric → treat as PR number
   - If `$ARGUMENTS` is string → treat as branch name
   - If no arguments → use current branch from `git rev-parse --abbrev-ref HEAD`
3. Validate target exists:
   - For PR: verify PR exists via `gh pr view {PR}` or `tea pr show {PR}`
   - For branch: verify branch exists locally or remotely

### Phase 1: Query CI Status via ci-awareness

<!-- <state-checkpoint id="ci-query" phase="git-check-ci" status="ci-query" data="target_type, target_value, ci_provider"> -->
1. Activate `ci-awareness` behavioral skill
2. Query CI status based on target type:
   - For PR: `gh pr checks {PR}` (GitHub) or `tea pr ci {PR}` (Gitea)
   - For branch: `gh run list --branch {branch}` (GitHub) or check Gitea API
3. Store raw CI response in `ci_context.raw_status`
4. Parse CI provider (GitHub Actions, Gitea Actions, CircleCI, etc.)

### Phase 2: Parse and Present Status Report

1. Parse check results into structured format:
   ```json
   {
     "checks": [
       {
         "name": "build",
         "status": "completed",
         "conclusion": "success",
         "duration": "2m 15s",
         "url": "https://..."
       }
     ],
     "overall_status": "success",
     "merge_ready": true
   }
   ```
2. Present status table to user:
   ```
   CI Status for PR #123 (feature-branch)

   Check Name       | Status    | Conclusion | Duration | URL
   -----------------|-----------|------------|----------|-----
   build            | completed | success    | 2m 15s   | https://...
   test             | completed | failure    | 3m 42s   | https://...
   lint             | completed | success    | 1m 5s    | https://...

   Overall: FAILING (1/3 checks failed)
   Merge ready: NO
   ```
3. Update `ci_context.merge_ready` based on overall status
<!-- <state-checkpoint id="ci-results" phase="git-check-ci" status="ci-results" data="overall_status, merge_ready, failing_checks"> -->

### Phase 3: Offer Next Steps

1. If all checks passing:
   - Set `ci_context.merge_ready = true`
   - Suggest: "All checks passed. Ready to merge with `/git-merge-pr {PR}`"
   <!-- <workflow-chain next="git-merge-pr" condition="all checks passing"> -->
2. If any checks failing:
   - Set `ci_context.merge_ready = false`
   - Store failing check names in `ci_context.failing_checks`
   - Offer: "Show logs for failing checks or chain to `/x-fix` to investigate?"
   <!-- <workflow-chain next="x-fix" condition="checks failing"> -->
3. If checks still running:
   - Present estimated completion time if available
   - Suggest: "Checks still running. Re-run `/git-check-ci` in {time} to check status"

</instructions>

## Human-in-Loop Gates

| Gate | Criticality | Trigger Condition | Default Action |
|------|-------------|-------------------|----------------|
| None | N/A | Read-only operation | No gates required |

## Workflow Chaining

<chaining-instruction>
**Chains from**: `git-create-pr`
**Chains to**: `git-merge-pr`, `x-fix`

**Forward chaining**:
- If checks passing → suggest `/git-merge-pr`
- If checks failing → suggest `/x-fix` to investigate
- Always present CI status table first

**Backward compatibility**:
- Works with any PR creation workflow
- Can be called standalone for status checks
</chaining-instruction>

## Safety Rules

1. **Read-only operation** - Never modify CI configuration or re-run checks without approval
2. **Respect rate limits** - Cache results for 30 seconds to avoid repeated API calls
3. **Handle missing CI gracefully** - If no CI configured, inform user (not an error)
4. **Preserve context** - Always update `ci_context` state for downstream workflows

## Critical Rules

1. **State consistency**:
   - Always update `ci_context.merge_ready` based on actual check results
   - Never mark as merge-ready if any required check failed
2. **Provider detection**:
   - Detect CI provider correctly (GitHub Actions, Gitea Actions, etc.)
   - Use appropriate CLI/API for each provider
3. **Timeout handling**:
   - If CI query times out, report timeout (do not assume passing/failing)
4. **Required vs optional checks**:
   - Distinguish required checks from optional
   - `merge_ready` should only consider required checks

## Success Criteria

- [ ] Target (PR/branch) identified and validated
- [ ] CI status queried via `ci-awareness`
- [ ] Check results parsed into structured format
- [ ] Status table presented to user
- [ ] `ci_context.merge_ready` updated accurately
- [ ] Failing checks stored in `ci_context.failing_checks` (if any)
- [ ] Next steps suggested based on status

## References

- GitHub Actions status checks: https://docs.github.com/en/rest/checks
- GitHub CLI checks: https://cli.github.com/manual/gh_pr_checks
- Gitea Actions: https://docs.gitea.com/usage/actions/overview
