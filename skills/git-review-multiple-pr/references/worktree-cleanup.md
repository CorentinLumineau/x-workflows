# Worktree Cleanup

## Phase 3.5: Worktree Cleanup

After all review approvals are submitted, explicitly clean up worktrees created in Phase 2.

1. **List all worktrees** from the review phase:
```bash
git worktree list
```

2. **For each review worktree**:
   - If review was **submitted** → remove worktree:
     ```bash
     git worktree remove {worktree_path}
     ```
   - If review was **skipped**:

<workflow-gate type="choice" id="cleanup-worktree-pr-{pr_number}">
  <question>Worktree for PR #{pr_number} review was skipped. Remove it?</question>
  <header>Worktree PR #{pr_number}</header>
  <option key="remove" recommended="true">
    <label>Remove worktree</label>
    <description>Delete the worktree and its working directory</description>
  </option>
  <option key="keep">
    <label>Keep worktree</label>
    <description>Retain for later manual review</description>
  </option>
</workflow-gate>

3. **Prune orphaned worktree references**:
```bash
git worktree prune
```

4. **Verify cleanup**:
```bash
git worktree list
```
Report remaining worktrees (should only be main working tree + any user chose to keep).
