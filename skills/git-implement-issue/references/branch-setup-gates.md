# Branch Setup Gates

## Phase 2: Branch Setup

Select branch strategy and create or switch to the working branch.

### 1. Branch strategy selection

<workflow-gate type="choice" id="branch-strategy">
  <question>How should changes be organized for issue #$ISSUE_NUMBER?</question>
  <header>Strategy</header>
  <option key="feature" recommended="true">
    <label>Feature branch (recommended)</label>
    <description>Create feature-branch.$ISSUE_NUMBER from a base branch</description>
  </option>
  <option key="direct">
    <label>Directly on current branch</label>
    <description>Implement on $CURRENT_BRANCH without creating a feature branch (skips PR)</description>
  </option>
</workflow-gate>

**If "direct" is chosen:**
   - Check for uncommitted changes:
```bash
git status --porcelain
```
   - If dirty working tree, offer stash/proceed/cancel
   - Capture current branch and default branch for later reference:
```bash
CURRENT_BRANCH=$(git branch --show-current)
BASE_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
PRE_IMPLEMENT_SHA=$(git rev-parse HEAD)
```
   - Store `branch_strategy = "direct"`, `feature_branch = null`, `pr_pending = false`, `BASE_BRANCH`, `PRE_IMPLEMENT_SHA`
   - Skip to Phase 3

**If "feature" is chosen** (default):

### 2. Detect base branch — find the closest release branch

```bash
# List remote release branches
git fetch --prune
git branch -r --list 'origin/release-branch.*'
```

If release branches exist, determine the best base via merge-base distance (closest wins). If no release branches exist, fall back to `main` or `master`.

### 3. Present branch options

<workflow-gate type="choice" id="branch-setup">
  <question>Which base branch should the feature branch target?</question>
  <header>Base branch</header>
  <option key="auto">
    <label>$DETECTED_BASE (auto-detected)</label>
    <description>Closest release branch by merge-base distance</description>
  </option>
  <option key="main">
    <label>main</label>
    <description>Use main branch as base</description>
  </option>
  <option key="custom">
    <label>Other</label>
    <description>Specify a different base branch</description>
  </option>
</workflow-gate>

### 4. Create and switch to feature branch

```bash
# Ensure we have latest
git fetch origin $BASE_BRANCH

# Create feature branch from the chosen base
git checkout -b feature-branch.$ISSUE_NUMBER origin/$BASE_BRANCH
```

If `feature-branch.$ISSUE_NUMBER` already exists, ask the user:

<workflow-gate type="choice" id="existing-branch">
  <question>Branch feature-branch.$ISSUE_NUMBER already exists. What should we do?</question>
  <header>Branch exists</header>
  <option key="switch">
    <label>Switch to it</label>
    <description>Continue working on the existing branch</description>
  </option>
  <option key="recreate">
    <label>Recreate it</label>
    <description>Delete and recreate from the base branch (loses uncommitted work)</description>
  </option>
  <option key="cancel">
    <label>Cancel</label>
    <description>Abort the workflow</description>
  </option>
</workflow-gate>
