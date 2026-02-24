# Post-Review Chaining

## Phase 6: Cleanup and Chaining

### Cleanup Local State

- **If worktree was used**: The worktree (`review-pr-{number}`) is automatically cleaned up on session exit. No branch switching needed — the user's original branch was never changed.
- **If in-place checkout**: Return to original branch (`git checkout -`) and optionally delete PR branch locally (`git branch -d pr-{number}`).

### Approve Path

<chaining-instruction id="approve-path">

**If verdict is APPROVE** and user wants to proceed with merge:

<workflow-gate type="choice" id="post-review-action">
  <question>Review approved. How would you like to proceed?</question>
  <header>Post-review action</header>
  <option key="merge" recommended="true">
    <label>Proceed to merge</label>
    <description>Chain to git-merge-pr to merge the approved PR</description>
  </option>
  <option key="done">
    <label>Done</label>
    <description>Review submitted, no further action needed</description>
  </option>
</workflow-gate>

<workflow-chain on="merge" skill="git-merge-pr" args="{pr-number}" />
<workflow-chain on="done" action="end" />

</chaining-instruction>

### Request Changes Path

<chaining-instruction id="request-changes-path">

**If verdict is REQUEST_CHANGES**:

<workflow-gate type="choice" id="post-request-changes">
  <question>Review submitted with REQUEST_CHANGES. Implement fixes now?</question>
  <header>Fix findings</header>
  <option key="fix" recommended="true">
    <label>Fix findings now</label>
    <description>Chain to git-fix-pr to implement fixes on the PR branch</description>
  </option>
  <option key="done">
    <label>Done — wait for author</label>
    <description>Leave for the PR author to address</description>
  </option>
</workflow-gate>

<workflow-chain on="fix" skill="git-fix-pr" args="{pr-number}" />
<workflow-chain on="done" action="end" />

</chaining-instruction>
