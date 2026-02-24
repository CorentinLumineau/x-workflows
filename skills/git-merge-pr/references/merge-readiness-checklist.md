# Merge Readiness Checklist

## Phase 1: Validate Merge Readiness

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
