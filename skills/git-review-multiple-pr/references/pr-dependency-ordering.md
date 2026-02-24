# PR Dependency Ordering

## Phase 0.5: Dependency Ordering

**Stacked PR detection** — build a dependency DAG from base/head branch relationships.

For each PR, check if `baseRefName` matches another PR's `headRefName` → dependency edge.

<deep-think trigger="dependency-ordering" context="Build dependency DAG from PR base/head branches to detect stacked PRs and determine safe review order">
  <purpose>Analyze base/head branch relationships across all candidate PRs. Build a directed dependency graph. Perform topological sort. Identify any PRs that cannot be safely reviewed because their base PR is still open.</purpose>
  <context>PR metadata with headRefName and baseRefName for each PR. A PR is "blocked" if its baseRefName matches another open PR's headRefName. The topological sort determines safe review order — dependencies first.</context>
</deep-think>

**Filtering rules**:
1. Build dependency edges: `PR_A → PR_B` means "B depends on A" (B's base = A's head)
2. Topological sort: order so dependencies come first
3. **Exclude blocked PRs**: any PR whose base PR is open (unmerged) is excluded
4. Report excluded PRs: `"PR #15 (title) — depends on unmerged PR #12"`

Present the **dependency-safe, ordered list** and any excluded PRs to user.
