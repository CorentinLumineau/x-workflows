# PR Creation Flow

## Phase 4: PR Creation (Conditional)

After implementation is complete, create a pull request or show completion summary.

### Direct Mode (`branch_strategy == "direct"`)

1. Check if commits were made during implementation:
```bash
# Compare HEAD before and after implementation
git log --oneline $PRE_IMPLEMENT_SHA..HEAD
```

2. **If commits were made** — offer PR recovery path:

<workflow-gate type="choice" id="direct-mode-pr">
  <question>Implementation committed directly to $CURRENT_BRANCH. Create a PR from these commits?</question>
  <header>Create PR?</header>
  <option key="create-pr">
    <label>Create PR</label>
    <description>Create a feature branch from HEAD, push, and chain to git-create-pr</description>
  </option>
  <option key="return-base">
    <label>Return to base branch</label>
    <description>Switch back to $BASE_BRANCH (if on a non-default branch)</description>
  </option>
  <option key="done">
    <label>Done</label>
    <description>Keep commits on $CURRENT_BRANCH as-is</description>
  </option>
</workflow-gate>

- If "Create PR":
  ```bash
  git switch -c feature-branch.$ISSUE_NUMBER
  git push -u origin feature-branch.$ISSUE_NUMBER
  ```
  Chain to `/git-create-pr` with base `$CURRENT_BRANCH`
  <!-- <workflow-chain next="git-create-pr" condition="direct mode PR recovery"> -->
- If "Return to base branch": `git switch $BASE_BRANCH`
- If "Done": show completion summary and exit

3. **If no commits were made** — show completion summary:
```
## Issue #$ISSUE_NUMBER Complete (Direct Mode)

| Step | Status |
|------|--------|
| Issue fetched | Done |
| Branch strategy | Direct (on $CURRENT_BRANCH) |
| Implementation | Completed via x-auto |
| PR | Skipped (no commits detected) |
```

### Feature Mode (`branch_strategy == "feature"`)

1. **Confirm PR creation**:

<workflow-gate type="choice" id="pr-creation">
  <question>Implementation complete. Ready to create a pull request?</question>
  <header>Create PR</header>
  <option key="create" recommended="true">
    <label>Create PR</label>
    <description>Push branch and create a pull request on Gitea</description>
  </option>
  <option key="skip">
    <label>Skip PR</label>
    <description>Skip PR creation — branch is ready for manual PR</description>
  </option>
  <option key="cancel">
    <label>Cancel</label>
    <description>Abort — no PR created</description>
  </option>
</workflow-gate>

2. **Push the branch**:
```bash
git push -u origin feature-branch.$ISSUE_NUMBER
```

3. **Analyze the diff** for PR description:
```bash
# Summary of changes
git diff origin/$BASE_BRANCH...HEAD --stat

# Full diff for understanding
git diff origin/$BASE_BRANCH...HEAD
```

For large diffs, focus on the most impactful files. Read modified source files if needed.

4. **Write PR description** (LLM-generated):

> See [references/pr-description-guide.md](pr-description-guide.md) for PR description template and guidelines.

5. **Create the PR**:
```bash
tea pulls create \
  --title "$ISSUE_TITLE" \
  --description "$(cat <<'EOF'
$PR_DESCRIPTION
EOF
)" \
  --base "$BASE_BRANCH" \
  --head "feature-branch.$ISSUE_NUMBER"
```

6. **Post-PR action**:

<workflow-gate type="choice" id="post-pr-action">
  <question>PR created for issue #$ISSUE_NUMBER. What would you like to do next?</question>
  <header>Next step</header>
  <option key="check-ci" recommended="true">
    <label>Check CI status</label>
    <description>Chain to git-check-ci to monitor pipeline for the new PR</description>
  </option>
  <option key="return-base">
    <label>Return to base branch</label>
    <description>Switch back to $BASE_BRANCH</description>
  </option>
  <option key="stay">
    <label>Stay on feature branch</label>
    <description>Remain on feature-branch.$ISSUE_NUMBER</description>
  </option>
</workflow-gate>

- If "Check CI status": chain to `/git-check-ci $PR_NUMBER`
  <!-- <workflow-chain next="git-check-ci" condition="after PR created"> -->
- If "Return to base branch": `git switch $BASE_BRANCH`
- If "Stay on feature branch": done
