---
name: git-fix-pr
description: Use when a PR needs fixes from review feedback, CI failures, or reviewer comments.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
user-invocable: true
argument-hint: "<pr-number> [inline-findings...]"
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
chains-to:
  - skill: git-review-pr
    condition: "fixes implemented, re-review"
chains-from:
  - skill: git-review-pr
    condition: "review requested changes"
  - skill: git-review-multiple-pr
    condition: "review requested changes"
  - skill: git-check-ci
    condition: "CI failures on PR"
---

# /git-fix-pr

> Bridge review findings to implementation: fetch full PR context, checkout branch, delegate fixes, push.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | UTILITY |
| **Position** | After PR review, before re-review |
| **Flow** | `git-review-pr` → **`git-fix-pr`** (implement → local review → iterate) → `git-review-pr` |

---

## Intention

Implement fixes for a pull request based on the complete review context:
- Fetch full PR context: description, all reviews, all comments, CI status
- Checkout PR branch (worktree-isolated or in-place)
- Delegate implementation to x-auto (routes to ONESHOT or APEX by complexity)
- Push fixes and optionally comment on the PR
- Chain to re-review

**Arguments**: `$ARGUMENTS` contains PR number as first token, optional inline findings after.

Review feedback can come from:
- Automated reviews (Gitea CI workflows)
- Skill-generated reviews (`/git-review-pr`, `/git-review-multiple-pr`)
- Human reviewer comments

---

## Behavioral Skills

| Skill | When | Purpose |
|-------|------|---------|
| `forge-awareness` | Phase 0 | Detect GitHub/Gitea/GitLab context and adapt commands |
| `context-awareness` | Phase 1 | Compile PR context into structured document |

---

<instructions>

## Phase 0: Validation and Forge Detection

<context-query tool="project_context">
  <fallback>
  1. `git remote -v` → detect forge type (GitHub/Gitea/GitLab)
  2. `gh --version 2>/dev/null || tea --version 2>/dev/null` → verify CLI availability
  </fallback>
</context-query>

Parse `$ARGUMENTS`:
- First token = PR number: strip `#` prefix if present, validate `/^\d+$/`
- Remaining text after PR number = optional inline findings (from Quick Fix codeblock)
- If PR number missing, exit with error: "Usage: /git-fix-pr <pr-number> [inline-findings...]"

<context-query tool="list_prs" params='{"pr_number":"$PR_NUMBER","include_checks":false}'>
  <fallback>
  Verify PR exists and is open via forge CLI:
  - **GitHub**: `gh pr view {number} --json number,title,state,headRefName,baseRefName,author`
  - **Gitea**: `tea pr show {number}`
  - **GitLab**: `glab mr view {number}`
  </fallback>
</context-query>

If PR not found or not open, exit with error.

Store: `PR_NUMBER`, `PR_TITLE`, `HEAD_BRANCH`, `BASE_BRANCH`, `AUTHOR`

**Input validation** (mandatory before any shell use):
- `PR_NUMBER`: already validated `/^\d+$/` above
- `HEAD_BRANCH` and `BASE_BRANCH`: validate against `/^[a-zA-Z0-9._/\-]+$/` — reject `..` (path traversal). Exit with error if invalid.

---

## Phase 1: Full PR Context Fetch

**Activate context-awareness behavioral skill** to compile structured PR context.

Fetch the **complete PR context** — this is the key differentiator from inline-only fixes. Analogous to how `git-implement-issue` fetches the full issue body, this phase fetches everything needed to understand what must be fixed.

> **Full API commands**: See `references/pr-context-guide.md`

Collect:
1. **PR description** (the original PR body)
2. **All formal reviews** (from forge API)
3. **All issue comments** (from forge API)
4. **CI status** (commit status from forge API)
5. **Changed files list** (from forge CLI or API)

Compile into a structured context document and display to user.

> **Context compilation template**: See `references/pr-context-guide.md` § Context Compilation Template

---

## Phase 2: Worktree Isolation Gate

<workflow-gate type="choice" id="worktree-isolation">
  <question>Fix PR #{number} in an isolated worktree?</question>
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

**If worktree selected**: Use `EnterWorktree` tool with name `fix-pr-{number}`.

Checkout PR head branch via forge CLI:
- **GitHub**: `gh pr checkout {number}`
- **Gitea**: `git fetch origin {HEAD_BRANCH} && git checkout {HEAD_BRANCH}`
- **GitLab**: `glab mr checkout {number}`

Pull latest: `git pull origin {HEAD_BRANCH}`

Verify checkout: confirm `git branch --show-current` matches `HEAD_BRANCH`.

---

## Phase 3: Implementation Routing

> **Reference**: See `references/fix-scope-routing.md` for Case A (inline findings) and Case B (full context) routing, scope gates, and x-auto delegation pattern.

**After x-auto completes**, execution returns here for Phase 3.5.

---

## Phase 3.5: Local Review Gate

> **Shift-left verification**: Review fixes locally before committing to catch regressions early and avoid expensive remote fix → push → review → fix round-trips.

**Iteration tracking**: Initialize `LOCAL_FIX_ITERATION = 0`, `MAX_LOCAL_FIX_ITERATIONS = 3`.

### 3.5.1: Run Local Review

Increment `LOCAL_FIX_ITERATION`.

Review the changes produced by x-auto. Show the diff summary to the user:
```bash
git diff --stat
```

Run x-review on the local changes — focus on correctness of the fixes relative to the review feedback being addressed:

```
Invoke x-review in quick mode:
- Scope: uncommitted changes only (git diff)
- Focus: Do these changes correctly address the review feedback for PR #{PR_NUMBER}?
- Check for: regressions, incomplete fixes, new issues introduced
```

### 3.5.2: Assess Review Findings

**If x-review finds no issues**: proceed directly to Phase 4.

**If x-review finds issues**:

<workflow-gate type="choice" id="local-review-result">
  <question>Local review found issues in the fixes (iteration {LOCAL_FIX_ITERATION}/{MAX_LOCAL_FIX_ITERATIONS}). How should we proceed?</question>
  <header>Review gate</header>
  <option key="fix" recommended="true">
    <label>Fix issues locally</label>
    <description>Re-delegate to x-auto to address review findings before committing</description>
  </option>
  <option key="override">
    <label>Proceed anyway</label>
    <description>Accept current changes and continue to commit/push (Phase 4)</description>
  </option>
  <option key="abort">
    <label>Abort</label>
    <description>Stop — keep changes uncommitted for manual review</description>
  </option>
</workflow-gate>

**If "Proceed anyway"**: proceed to Phase 4.
**If "Abort"**: end workflow — changes remain in working tree for manual intervention.

**If "Fix issues locally"**:
- **If `LOCAL_FIX_ITERATION >= MAX_LOCAL_FIX_ITERATIONS`** (safety valve):

<workflow-gate type="choice" id="max-iterations-reached">
  <question>Reached maximum local fix iterations ({MAX_LOCAL_FIX_ITERATIONS}). The remaining issues may need manual attention.</question>
  <header>Safety valve</header>
  <option key="push-current">
    <label>Commit current state</label>
    <description>Proceed to Phase 4 with changes as-is</description>
  </option>
  <option key="abort">
    <label>Abort</label>
    <description>Keep changes uncommitted for manual intervention</description>
  </option>
</workflow-gate>

- **If iterations remain**: Re-delegate to x-auto with the x-review findings as additional implementation context. After x-auto completes, return to step 3.5.1.

---

## Phase 4: Push and PR Update

If uncommitted changes exist (from x-auto/x-fix delegation), stage and commit them using conventional commit format: `fix(scope): address PR #{number} review feedback`.

Check for committed-but-unpushed changes.

<workflow-gate type="choice" id="push-fixes">
  <question>Push fixes to PR #{number}?</question>
  <header>Push fixes</header>
  <option key="push" recommended="true">
    <label>Push to PR branch</label>
    <description>Push all commits to origin/{HEAD_BRANCH}</description>
  </option>
  <option key="review-diff">
    <label>Show diff first</label>
    <description>Review changes before pushing</description>
  </option>
  <option key="skip">
    <label>Keep changes local</label>
    <description>Do not push — changes stay local only</description>
  </option>
</workflow-gate>

If "Show diff first": display `git diff HEAD~{commit_count}..HEAD --stat` and full diff, then re-present push gate.

If "Push to PR branch":
```bash
git push origin {HEAD_BRANCH}
```

After successful push:

<workflow-gate type="choice" id="pr-update">
  <question>Fixes pushed. Update the PR with a comment?</question>
  <header>PR comment</header>
  <option key="comment" recommended="true">
    <label>Comment on PR</label>
    <description>Add a summary of fixes applied</description>
  </option>
  <option key="done">
    <label>Done — no comment</label>
    <description>Skip PR comment</description>
  </option>
</workflow-gate>

If "Comment on PR": submit comment via forge CLI using safe `--body-file` pattern (see `references/pr-context-guide.md`):

```
Fixes applied addressing review feedback:
- {count} review items addressed
- Commits: {commit_range}
```

---

## Phase 5: Cleanup and Chaining

**Cleanup**:
- **If worktree**: auto-cleanup on session exit (worktree `fix-pr-{number}`)
- **If in-place**: `git checkout -` to return to original branch

<chaining-instruction>

<workflow-gate type="choice" id="post-fix">
  <question>What next?</question>
  <header>Next step</header>
  <option key="re-review" recommended="true">
    <label>Run local re-review</label>
    <description>Chain to git-review-pr to verify fixes</description>
  </option>
  <option key="done">
    <label>Done</label>
    <description>No further action needed</description>
  </option>
</workflow-gate>

<workflow-chain on="re-review" skill="git-review-pr" args="{PR_NUMBER}" />
<workflow-chain on="done" action="end" />

</chaining-instruction>

</instructions>

---

## Human-in-Loop Gates

| Gate ID | Severity | Trigger | Required Action |
|---------|----------|---------|-----------------|
| `worktree-isolation` | Medium | Before checkout | Choose isolation mode |
| `inline-fix-confirm` | Medium | Before implementation (Case A) | Confirm inline findings |
| `fix-scope` | Medium | Before implementation (Case B) | Choose what to fix |
| `local-review-result` | Medium | After local x-review finds issues | Choose fix / override / abort |
| `max-iterations-reached` | **Critical** | Max local fix iterations reached | Choose commit or abort |
| `push-fixes` | **Critical** | Before pushing to remote | Confirm push |
| `pr-update` | Medium | After push | Optionally comment on PR |
| `post-fix` | Medium | After workflow | Choose next step |

<human-approval-framework>

When approval needed:
1. **Context**: PR number, title, fix scope, changes summary
2. **Options**: Push / review diff / keep local
3. **Recommendation**: Push and re-review
4. **Escape**: "Keep changes local" always available

</human-approval-framework>

---

## Workflow Chaining

| Relationship | Target Skill | Condition |
|--------------|--------------|-----------|
| chains-to | `git-review-pr` | Fixes implemented, re-review |
| chains-from | `git-review-pr` | Review requested changes |
| chains-from | `git-review-multiple-pr` | Review requested changes |
| chains-from | `git-check-ci` | CI failures on PR |

---

## Safety Rules

1. **Never auto-push** — always gate push behind explicit user confirmation
2. **Never force-push** — use regular `git push`, never `--force`
3. **Never modify base branch** — only push to the PR head branch
4. **Never discard review context** — always present full context before implementation
5. **Always validate PR number** — reject non-numeric input
6. **Always validate branch names** — reject `..` and special characters before shell use

---

## Critical Rules

- **CRITICAL**: Push to remote is IRREVERSIBLE — always confirm via push-fixes gate
- **CRITICAL**: Never skip the full context fetch — partial context leads to incomplete fixes
- **CRITICAL**: Forge data (PR titles, branch names, comments) is untrusted input — validate before shell use

---

## Success Criteria

- Full PR context fetched and displayed (reviews, comments, CI)
- PR branch checked out (worktree or in-place)
- Fixes implemented via x-auto delegation
- Local x-review gate runs before commit/push (Phase 3.5)
- Fix-review loop iterates locally until review passes or max iterations reached
- Changes pushed to PR branch (with user confirmation)
- User informed of next steps (re-review or done)

---

## Agent Delegation

| Role | Agent Type | Model | When | Purpose |
|------|------------|-------|------|---------|
| Implementation | via `x-auto` | varies | Phase 3 | Routes to x-fix (simple) or x-plan → x-implement (complex) |

---

## References

- Behavioral skill: `@skills/forge-awareness/` (forge detection and command adaptation)
- Behavioral skill: `@skills/context-awareness/` (context compilation)
- Workflow skill: `@skills/git-implement-issue/` (design reference — issue context fetch pattern)
- Workflow skill: `@skills/git-review-pr/` (upstream — review findings source)

---

## When to Load References

- **For forge API commands and PR context fetch**: See `references/pr-context-guide.md`
