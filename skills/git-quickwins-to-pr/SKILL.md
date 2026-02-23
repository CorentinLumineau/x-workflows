---
name: git-quickwins-to-pr
description: Use when turning quick wins into tracked issues with implementation and PRs in one flow.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
user-invocable: true
argument-hint: "[path] [--focus category,...] [--count N]"
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
chains-to:
  - skill: git-create-issue
    condition: "for each selected quickwin"
  - skill: git-implement-issue
    condition: "after issue created"
  - skill: git-create-pr
    condition: "after implementation complete"
chains-from:
  - skill: x-quickwins
---

# /git-quickwins-to-pr

> End-to-end orchestrator: scan for quick wins, create issues, implement, and open PRs — one command for the full lifecycle.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | META (lifecycle orchestrator) |
| **Phase** | complete |
| **Position** | 1 of 1 (self-contained orchestrator) |

**Flow**: **`git-quickwins-to-pr`** = `x-quickwins` → (for each selected) → `git-create-issue` → `git-implement-issue` → `git-create-pr`

## Intention

**Target**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Ask user: "What path or module would you like to scan for quick wins?"
{{/if}}

Arguments are passed through to `x-quickwins` (path, --focus, --count).

## Behavioral Skills

This workflow activates:
- `forge-awareness` - Detects forge type for label discovery and CLI usage
- `context-awareness` - Project context for accurate scanning
- `interview` (via x-quickwins) - Confidence gate on scan scope

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Label-to-quickwin mapping (Phase 3) |

<instructions>

### Phase 0: Validation

1. Activate `forge-awareness` to detect forge type (GitHub/Gitea) and validate CLI availability
2. Verify git repository: `git rev-parse --is-inside-work-tree`
3. Parse `$ARGUMENTS` — all arguments pass through to x-quickwins in Phase 1
4. Store forge type for Phase 3 label discovery

### Phase 1: Quick Wins Scan

Invoke the `x-quickwins` skill to scan the codebase and produce the ranked report.

Invoke via Skill tool:
```
skill: "x-quickwins"
args: "$ARGUMENTS"
```

**Capture the output**: The quick wins report (top N scored findings with category, file, impact, effort, and suggested fix) is the input for Phase 2.

**IMPORTANT**: x-quickwins will present its own action gate (fix/implement/fix all/stop). When that gate appears, select **"Stop here"** — this orchestrator handles the downstream workflow differently.

### Phase 2: Selection Gate

Present all surfaced quick wins to the user for multi-selection.

<workflow-gate type="multi-select" id="quickwin-selection">
  <question>Which quick wins would you like to turn into tracked issues with implementation and PR?</question>
  <header>Select wins</header>
  <context>Each selected quick win will go through: create issue → implement → create PR. Select the ones worth the full lifecycle.</context>
  <options>
    <!-- Dynamically generated from x-quickwins report -->
    <!-- Each option = one quick win with its score, category, and file -->
  </options>
</workflow-gate>

Present the quick wins as a numbered list with scores:
```
Which quick wins do you want to implement? (multi-select)

  [1] (Score: 96) [security] Hardcoded secret in config.js:42
  [2] (Score: 88) [dry] Duplicated validation in auth.js:15, auth.js:89
  [3] (Score: 80) [solid] God class UserService.js (412 lines)
  [4] (Score: 72) [testing] No tests for PaymentController
  ...

Select by number (e.g., 1,2,4) or "all":
```

If user selects none or cancels, end the workflow.

Store the selected quick wins as an ordered list for the loop.

### Phase 3: Label Discovery

Fetch existing labels from the forge **once** before the loop.

```bash
# GitHub
gh label list --json name,description --limit 100

# Gitea
tea labels ls
```

<deep-think purpose="label-mapping" context="Map each selected quick win's category to the best-matching existing label from the forge">
  <purpose>For each selected quick win, determine which existing forge label(s) best match the quickwin category and nature</purpose>
  <context>Available labels from forge: {labels}. Quick win categories: testing, solid, dry, kiss, security, dead-code, docs. Map each quickwin to 1-2 existing labels. NEVER suggest labels that don't exist on the forge.</context>
</deep-think>

**Label mapping rules**:
- Only use labels that exist on the forge (fetched above)
- Map quickwin categories to closest existing labels (e.g., `security` → "security" or "bug", `dry` → "refactor" or "enhancement")
- If no reasonable match exists, use no labels (don't force a bad match)
- Store the mapping: `{quickwin_index → [label1, label2]}`

### Phase 4: Sequential Execution Loop

For each selected quick win (in order of score, highest first):

#### Phase 4.0: Progress Banner

```
═══════════════════════════════════════════════════
  Quick Win {current}/{total}: {quickwin_title}
  Score: {score} | Category: {category}
═══════════════════════════════════════════════════
```

#### Phase 4a: Create Issue — `git-create-issue`

Invoke `git-create-issue` with pre-filled context from the quick win:

```
skill: "git-create-issue"
args: "{quickwin_suggested_fix_title}"
```

**Context to carry forward** into the issue:
- **Title**: Derived from the quick win finding (e.g., "fix: remove hardcoded secret in config.js")
- **Description**: Include the quick win details — category, file:line, impact/effort scores, and suggested fix
- **Labels**: Use the mapped labels from Phase 3 (existing labels only)
- **Type**: Infer from category (security → bug, dry/solid/kiss → enhancement, testing → enhancement, docs → documentation)

**IMPORTANT**: When `git-create-issue` asks for labels, suggest ONLY labels from the Phase 3 mapping. When it asks for issue type, use the inferred type above.

Capture the created issue number and URL from the output.

#### Phase 4b: Implement Issue — `git-implement-issue`

Invoke `git-implement-issue` with the created issue number:

```
skill: "git-implement-issue"
args: "{issue_number}"
```

**IMPORTANT**: When `git-implement-issue` reaches its PR creation gate (Phase 4), select **"Skip PR"** — `git-create-pr` will handle PR creation in the next step.

Capture the feature branch name from the output.

#### Phase 4c: Create PR — `git-create-pr`

Invoke `git-create-pr` from the feature branch:

```
skill: "git-create-pr"
args: "{feature_branch_name}"
```

The PR will automatically:
- Link to the issue via `Closes #{issue_number}` (git-create-pr Phase 4 handles this)
- Use conventional commit-style title
- Include structured description

Capture the PR number and URL.

#### Phase 4d: Iteration Checkpoint

<state-checkpoint id="quickwin-loop-progress" phase="git-quickwins-to-pr" status="iteration-complete" data="current_index, total, issue_number, pr_number, pr_url">
Checkpoint captures: loop progress, issue and PR metadata
</state-checkpoint>

Store iteration result:
```json
{
  "quickwin_index": N,
  "quickwin_title": "...",
  "issue_number": 456,
  "issue_url": "https://...",
  "pr_number": 123,
  "pr_url": "https://...",
  "status": "completed"
}
```

Present iteration summary:
```
  Completed {current}/{total}: #{issue_number} → PR #{pr_number}
  {pr_url}
```

If more quickwins remain, ask:

<workflow-gate type="choice" id="continue-loop">
  <question>Quick win {current}/{total} complete. Continue to the next one?</question>
  <header>Continue?</header>
  <option key="continue" recommended="true">
    <label>Next quick win</label>
    <description>Proceed to quick win {current+1}: {next_title}</description>
  </option>
  <option key="stop">
    <label>Stop here</label>
    <description>End the loop — remaining quick wins stay as-is</description>
  </option>
</workflow-gate>

If user stops, proceed directly to Phase 5.

### Phase 5: Summary Report

Generate the final orchestration summary:

```markdown
# Quick Wins to PR — Summary

## Scan
- Path: {path}
- Quick wins found: {total_found}
- Quick wins selected: {total_selected}
- Quick wins completed: {completed_count}

## Results

| # | Quick Win | Issue | PR | Status |
|---|-----------|-------|----|--------|
| 1 | {title} | #{issue} | #{pr} ({url}) | completed |
| 2 | {title} | #{issue} | #{pr} ({url}) | completed |
| 3 | {title} | — | — | skipped |

## Next Steps
- Review open PRs for merge readiness
- Run `/git-review-pr {pr_number}` for local review
- Run `/git-check-ci {pr_number}` to verify CI status
```

<state-cleanup phase="git-quickwins-to-pr">
Clean up any workflow state files created during the loop
</state-cleanup>

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | Quick win selection (Phase 2), each issue creation (via git-create-issue) |
| **High** | ALWAYS ASK | Continue/stop between iterations (Phase 4d) |
| **Medium** | ASK IF UNCERTAIN | Label mapping ambiguity, PR description review |
| **Low** | PROCEED | Label fetching, scan execution, progress banners |

<human-approval-framework>

When approval needed, structure question as:
1. **Context**: Current quickwin being processed (N/M), score, category
2. **Options**: Continue / Stop / Skip this one
3. **Recommendation**: Continue with next highest-scored quickwin
4. **Escape**: "Stop here" option always available at every gate

</human-approval-framework>

## Workflow Chaining

<chaining-instruction>

**Chains from**: x-quickwins (enhanced action path)
**Chains to**: git-create-issue → git-implement-issue → git-create-pr (sequential per quickwin)

**Orchestration pattern**:
This skill is a **loop orchestrator** — it invokes a chain of 3 skills sequentially for each selected quickwin. The chain within each iteration is:

```
git-create-issue(quickwin_title)
    → git-implement-issue(issue_number)  [skip PR at its gate]
        → git-create-pr(feature_branch)
```

**Forward chaining**:
- After all quickwins processed → suggest `/git-review-pr` or `/git-check-ci`
- If stopped early → suggest resuming with remaining quickwins

**Skill invocation**: Each chained skill is invoked via the Skill tool sequentially. Context (issue number, branch name, PR URL) flows forward through captured outputs.

</chaining-instruction>

## Safety Rules

**NEVER:**
- Create issues without user selection and confirmation
- Create labels that don't exist on the forge
- Skip the selection gate (Phase 2) — user must choose which quickwins to implement
- Run iterations in parallel (would cause branch conflicts)
- Force-push or modify base branch

**ALWAYS:**
- Fetch existing labels before the loop (Phase 3)
- Present progress banners between iterations
- Offer escape hatch (stop) between iterations
- Capture and report all created issues and PRs
- Clean up workflow state on completion

## Critical Rules

1. **Existing Labels Only** — Never suggest or create labels not present on the forge. Phase 3 label discovery is mandatory.
2. **Sequential Iteration** — Each quickwin goes through the full create-issue → implement → PR cycle before the next starts.
3. **Human Gates at Every Level** — Selection (Phase 2), each issue (via git-create-issue), continue/stop (Phase 4d).
4. **Context Forwarding** — Each skill in the chain receives context from the previous: quickwin details → issue number → branch name.
5. **Skip PR in git-implement-issue** — When git-implement-issue reaches its PR gate, skip it since git-create-pr handles PR creation.
6. **Graceful Early Stop** — If user stops mid-loop, Phase 5 shows partial results (completed + skipped).

## Navigation

| Direction | Verb | When |
|-----------|------|------|
| Scan only | `/x-quickwins` | Just want the report without lifecycle |
| Review PRs | `/git-review-pr` | After PRs created |
| Check CI | `/git-check-ci` | After PRs created |
| Single issue | `/git-create-issue` | Create one issue manually |

## Success Criteria

- [ ] x-quickwins scan completed and report captured
- [ ] User selected quickwins to implement (multi-select gate)
- [ ] Existing forge labels fetched and mapped to quickwins
- [ ] For each selected quickwin:
  - [ ] Issue created via git-create-issue with existing labels
  - [ ] Implementation completed via git-implement-issue
  - [ ] PR created via git-create-pr linking to issue
- [ ] Summary report generated with all issues and PRs
- [ ] Workflow state cleaned up

## References

- @skills/x-quickwins/ - Pareto-scored quick win scanning
- @skills/git-create-issue/ - Issue creation with forge awareness
- @skills/git-implement-issue/ - Issue-driven implementation
- @skills/git-create-pr/ - Pull request creation
- @skills/forge-awareness/ - Forge detection behavioral skill
