---
name: git-quickwins-to-pr
description: Use when turning quick wins into tracked issues with implementation and PRs in one flow.
version: "2.0.0"
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
user-invocable: true
argument-hint: "[path] [--focus category,...] [--count N]"
metadata:
  author: ccsetup contributors
  category: workflow
chains-to:
  - skill: git-create-issue
    condition: "batch issue creation (Phase 3.5)"
  - skill: git-implement-issue
    condition: "sequential fallback only"
  - skill: git-create-pr
    condition: "after implementation complete"
  - skill: git-review-multiple-pr
    condition: "all PRs created (user choice)"
chains-from:
  - skill: x-quickwins
---

# /git-quickwins-to-pr

> End-to-end orchestrator: scan for quick wins, create issues, implement (with optional parallelization), and open PRs.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | META (lifecycle orchestrator) |
| **Phase** | complete |
| **Position** | 1 of 1 (self-contained orchestrator) |

**Flow**: `x-quickwins` → select → analyze parallelization → batch create issues → parallel implement (worktree) OR sequential → PR creation loop → summary

## Intention

**Target**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Ask user: "What path or module would you like to scan for quick wins?"
{{/if}}

Arguments pass through to `x-quickwins` (path, --focus, --count).

## Behavioral Skills

- `forge-awareness` - Forge type detection
- `context-awareness` - Project context
- `interview` (via x-quickwins) - Confidence gate on scan scope

<instructions>

### Phase 0: Validation

<context-query tool="project_context">
  <fallback>
  1. `git remote -v` → detect forge type and CLI availability
  2. `git rev-parse --is-inside-work-tree` → verify git repository
  </fallback>
</context-query>

If no forge CLI found, stop: "Neither `tea` nor `gh` CLI found. Install one to use this workflow."

3. Parse `$ARGUMENTS` — pass through to x-quickwins
4. Store forge type for Phase 3

### Phase 1: Quick Wins Scan

Invoke `x-quickwins` via Skill tool: `skill: "x-quickwins", args: "$ARGUMENTS"`

Capture the ranked report (scored findings with category, file, impact, effort, suggested fix).

**IMPORTANT**: When x-quickwins presents its action gate, select **"Stop here"** — this orchestrator handles downstream.

### Phase 2: Selection Gate

<workflow-gate type="multi-select" id="quickwin-selection">
  <question>Which quick wins would you like to turn into tracked issues with implementation and PR?</question>
  <header>Select wins</header>
  <context>Each selected quick win gets: issue → implement → PR. Select the ones worth the full lifecycle.</context>
  <options>
    <!-- Dynamically generated from x-quickwins report -->
  </options>
</workflow-gate>

Present numbered list with scores. If none selected, end workflow.

**Batch-size confirmation** (if >3 selected):

<workflow-gate type="choice" id="confirm-batch-size">
  <question>You selected {count} quick wins. Each gets an issue, implementation, and PR. Proceed?</question>
  <header>Confirm batch</header>
  <option key="proceed" recommended="true">
    <label>Proceed</label>
    <description>Implement all {count} quick wins (parallel groups of 5 max)</description>
  </option>
  <option key="reduce">
    <label>Reduce selection</label>
    <description>Go back and select fewer</description>
  </option>
</workflow-gate>

### Phase 2.5: Parallelization Analysis

> **Reference**: See `references/parallelization-analysis.md` for algorithm, display format, limitation caveat, and edge cases.

Skip if ≤2 quick wins selected.

For 3+ selected: extract primary file per quickwin, build conflict graph (edges = shared files), partition into independent groups, present parallelization plan.

> **Limitation**: Uses primary file only — quick wins with broad scope (e.g., `solid` decomposition) may modify secondary files not captured. See reference for full caveat.

### Phase 3: Label Discovery

Fetch existing labels from the forge once (GitHub: `gh label list`, Gitea: `tea labels ls`).

<deep-think purpose="label-mapping" context="Map each quickwin category to existing forge labels">
  <purpose>Map quickwin categories to existing forge labels. NEVER suggest labels not on the forge.</purpose>
  <context>Categories: testing, solid, dry, kiss, security, dead-code, docs.</context>
</deep-think>

Store mapping: `{quickwin_index → [label1, label2]}`.

### Phase 3.5: Execution Mode & Batch Issue Creation

#### 3.5a: Execution Mode

<workflow-gate type="choice" id="execution-mode">
  <question>How should the quick wins be implemented?</question>
  <header>Exec mode</header>
  <option key="parallel" recommended="true">
    <label>Parallel (worktree isolation)</label>
    <description>Each in its own worktree — true parallel. Best for 3+ independent wins.</description>
  </option>
  <option key="sequential">
    <label>Sequential (current branch)</label>
    <description>One at a time. Simpler, lower resource cost.</description>
  </option>
</workflow-gate>

#### 3.5b: Base Branch

Detect shared base branch: `git branch -r --list 'origin/release-branch.*'` (closest by merge-base, fallback `main`).

<workflow-gate type="choice" id="base-branch">
  <question>Which base branch for all feature branches?</question>
  <header>Base branch</header>
  <option key="auto" recommended="true">
    <label>$DETECTED_BASE (auto-detected)</label>
    <description>Default or closest release branch</description>
  </option>
  <option key="custom">
    <label>Other</label>
    <description>Specify a different base branch</description>
  </option>
</workflow-gate>

#### 3.5c: Batch Issue Creation

> **Reference**: See `references/batch-issue-creation.md` for CLI templates, input sanitization, type inference, and error handling.

Create all issues upfront via direct CLI calls. Write body to tmpfile (never double-quoted interpolation). Sanitize both title AND body. Capture `{quickwin_index → issue_number}` mapping.

### Phase 4: Implementation Dispatch

#### Parallel Mode (worktree)

> **Agent prompt**: See `references/quickwin-agent-prompt.md` — UNTRUSTED-DATA wrapping, branch naming (`feature-branch.{issue_number}`), focused fix, structured report.

**Pre-dispatch**: If >5 quickwins, split into sequential batches of 5.

Per parallelization group (Phase 2.5), spawn agents in a single message:

<parallel-delegate strategy="concurrent">
  <agent role="general-purpose" subagent="general-purpose" model="sonnet" isolation="worktree">
    <prompt>See references/quickwin-agent-prompt.md. Create branch feature-branch.{issue_number}, implement quickwin fix, commit with close #{issue_number}. Do NOT push or create PR. Return Status/Branch/Category/Files/Tests/Changes/Notes.</prompt>
    <context>Quick win implementation in isolated worktree.</context>
  </agent>
</parallel-delegate>

Wait for group completion before starting next group. Collect all reports.

#### Sequential Mode (direct)

For each quickwin (highest score first): show progress banner, invoke `git-implement-issue` via Skill tool with the issue number. When `git-implement-issue` reaches its branch strategy gate, select **"Feature branch"**. When it reaches its PR creation gate, select **"Skip PR"** (this orchestrator handles PR creation in Phase 4.5). Offer continue/stop checkpoint after each iteration.

<workflow-gate type="choice" id="continue-loop">
  <question>Quick win {current}/{total} complete. Continue?</question>
  <header>Continue?</header>
  <option key="continue" recommended="true">
    <label>Next quick win</label>
    <description>Proceed to {current+1}: {next_title}</description>
  </option>
  <option key="stop">
    <label>Stop here</label>
    <description>Remaining stay as issues only</description>
  </option>
</workflow-gate>

### Phase 4.5: PR Creation Loop

> **Reference**: See `references/pr-creation-flow.md` for diff display, PR heredoc template, and worktree cleanup.

For each implemented quickwin (in order): display report, show diff, confirm PR via gate.

<workflow-gate type="choice" id="per-quickwin-pr">
  <question>Create PR for #{number} ({title})? Status: {status}</question>
  <header>PR #{number}</header>
  <option key="create" recommended="true">
    <label>Create PR</label>
    <description>Push and create PR with close #{number}</description>
  </option>
  <option key="skip">
    <label>Skip PR</label>
    <description>Keep branch, no PR now</description>
  </option>
</workflow-gate>

Use single-quoted heredoc for PR body — see reference for full template.

### Phase 4.75: Worktree Cleanup (Parallel Mode Only)

> See `references/pr-creation-flow.md` Phase 4.75 section.

For PR-created: auto-remove worktree. For skipped/failed: ask remove or keep. Prune orphans.

### Phase 5: Summary Report

> **Template**: See `references/quickwin-batch-summary.md` for full format.

Generate batch summary: scan overview, aggregate table (quickwin/score/category/issue/implementation/PR), per-quickwin details.

<chaining-instruction>

<workflow-gate type="choice" id="post-batch-action">
  <question>All {count} quick wins processed. How to proceed?</question>
  <header>Next step</header>
  <option key="review" recommended="true">
    <label>Batch review PRs</label>
    <description>Chain to git-review-multiple-pr</description>
  </option>
  <option key="done">
    <label>Done</label>
    <description>No further action</description>
  </option>
</workflow-gate>

<workflow-chain on="review" skill="git-review-multiple-pr" args="{pr_numbers}" />
<workflow-chain on="done" action="end" />

</chaining-instruction>

</instructions>

## Human-in-Loop Gates

| Level | Action | Example |
|-------|--------|---------|
| **Critical** | ALWAYS ASK | Selection, exec mode, each PR |
| **High** | ALWAYS ASK | Continue/stop, batch-size, base branch |
| **Medium** | ASK IF UNCERTAIN | Label mapping, worktree cleanup |

## Safety Rules

**NEVER:** Create issues without selection. Create non-existent labels. Spawn >5 concurrent agents. Force-push. Use double-quoted interpolation for issue/PR body.

**ALWAYS:** Sanitize title AND body via tmpfile/heredoc. Offer escape between iterations. Execute worktree cleanup (parallel mode).

**PARALLEL WHEN SAFE:** Disjoint primary files → parallel. Shared files → sequential. User can always opt for sequential.

## Critical Rules

1. **Existing Labels Only** — Phase 3 mandatory
2. **Batch Issues First** — Upfront before implementation
3. **Human Gates** — Selection, exec mode, each PR, continue/stop
4. **Input Sanitization** — Body via tmpfile. Never interpolation.
5. **5-Agent Cap** — Batches of 5
6. **Parallelization Advisory** — Primary-file-only. User chooses.

## When to Load References

- **For file overlap algorithm and grouping**: See `references/parallelization-analysis.md`
- **For parallel agent prompt**: See `references/quickwin-agent-prompt.md`
- **For batch issue creation**: See `references/batch-issue-creation.md`
- **For PR creation and worktree cleanup**: See `references/pr-creation-flow.md`
- **For batch summary template**: See `references/quickwin-batch-summary.md`

## References

- @skills/x-quickwins/ - Quick win scanning
- @skills/git-implement-multiple-issue/ - Parallel batch precedent
- @skills/forge-awareness/ - Forge detection
