# Multi-Issue Selection Gates

## Phase 1: Selection Gate

<workflow-gate type="multi-select" id="issue-selection">
  <question>Which issues would you like to implement? Each will get a parallel worktree agent running x-auto for complexity-based routing.</question>
  <header>Select issues</header>
  <option key="all" recommended="true">
    <label>All eligible issues</label>
    <description>Implement all issues without active PRs</description>
  </option>
  <option key="select">
    <label>Select specific issues</label>
    <description>Choose which issues to include</description>
  </option>
</workflow-gate>

If user selects "Select specific issues": use **interview** skill to ask which issue numbers to include from the eligible list. Validate selections are a subset of the eligible list.

**Hard cap**: Maximum 5 concurrent implementation agents. If selection exceeds 5, split into sequential batches of 5.

If more than 3 selected:

<workflow-gate type="choice" id="confirm-batch-size">
  <question>You selected {count} issues. Each spawns a full implementation agent (~sonnet session in worktree). Proceed?</question>
  <header>Confirm batch</header>
  <option key="proceed" recommended="true">
    <label>Proceed</label>
    <description>Implement all {count} issues (batched in groups of 5 max)</description>
  </option>
  <option key="reduce">
    <label>Reduce selection</label>
    <description>Go back and select fewer issues</description>
  </option>
</workflow-gate>

**Detect base branch** — find the closest release branch once (shared across all issues). Use the same merge-base distance algorithm as `git-implement-issue` Phase 2 (`git branch -r --list 'origin/release-branch.*'`, closest wins, fall back to `main`/`master`).

<workflow-gate type="choice" id="base-branch">
  <question>Which base branch should all feature branches target?</question>
  <header>Base branch</header>
  <option key="auto" recommended="true">
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

<workflow-gate type="choice" id="isolation-mode">
  <question>Use worktree isolation for parallel implementation?</question>
  <header>Isolation</header>
  <option key="worktree" recommended="true">
    <label>Worktree isolation (recommended)</label>
    <description>Each issue gets its own worktree — enables true parallel execution</description>
  </option>
  <option key="direct">
    <label>Direct on branch (serial)</label>
    <description>Implement sequentially on the current working tree — no worktree overhead</description>
  </option>
</workflow-gate>
