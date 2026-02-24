# Issue Closure Verification

## Phase 5d: Verify Issue Closure

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
