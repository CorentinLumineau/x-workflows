# Merge Strategy Guide

## Phase 2: Select Merge Strategy

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
