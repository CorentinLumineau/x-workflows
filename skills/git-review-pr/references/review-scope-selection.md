# Review Scope Selection

## Phase 0: Scope Selection and Worktree Decision

### Review Scope Gate

<workflow-gate type="choice" id="confirm-review-scope">
  <question>Proceed with comprehensive review of PR #{number} (code quality, security, tests)?</question>
  <header>Review scope confirmation</header>
  <option key="proceed" recommended="true">
    <label>Full review</label>
    <description>Code quality + security + tests + enforcement audit + regression detection</description>
  </option>
  <option key="quick">
    <label>Quick review</label>
    <description>Code quality only — skip security, tests, enforcement audit, regression detection</description>
  </option>
  <option key="deep">
    <label>Deep review</label>
    <description>Full review + spec compliance check against linked issue + documentation audit</description>
  </option>
  <option key="cancel">
    <label>Cancel</label>
    <description>Abort review</description>
  </option>
</workflow-gate>

Present PR details to user before gate:
- Title and description
- Author and branch
- File change count
- Review scope (full review with security + tests)

### Worktree Decision (skip if `USE_WORKTREE` already set by `--worktree` flag)

<workflow-gate type="choice" id="worktree-isolation">
  <question>Review in an isolated worktree? This avoids switching your current branch.</question>
  <header>Isolation mode</header>
  <option key="worktree" recommended="true">
    <label>Use worktree</label>
    <description>Isolated copy — your working tree stays untouched</description>
  </option>
  <option key="in-place">
    <label>In-place checkout</label>
    <description>Checkout PR branch directly (will switch your current branch)</description>
  </option>
</workflow-gate>

Set `USE_WORKTREE=true` if user selects "Use worktree".

### Review Depth Routing

| Scope | Phases Executed | When |
|-------|----------------|------|
| **Quick** | 0, 1, 2b (code only), 4b | Fast feedback on code quality |
| **Full** (default) | 0, 1, 1b, 2a, 2b, 3a, 3b, 4a, 4b | Standard comprehensive review |
| **Deep** | All phases at maximum depth | Linked issue spec compliance + full audit |
