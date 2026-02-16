---
name: x-quickwins
description: Use when looking for low-effort high-impact improvements in a codebase.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
  user-invocable: true
  argument-hint: "[path] [--focus category,...] [--count N]"
---

# /x-quickwins

> Scan a codebase and surface the top Pareto-scored quick wins for immediate improvement.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | UTILITY (standalone) |
| **Phase** | complete |
| **Position** | 1 of 1 (self-contained) |

**Flow**: **`x-quickwins`** → `[optional: x-fix or x-implement]`

## Intention

**Target**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Ask user: "What path or module would you like to scan for quick wins?"
{{/if}}

## Behavioral Skills

This skill activates:
- `analysis` - Pareto 80/20 prioritization
- `code-quality` - SOLID, DRY, KISS assessment

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **codebase explorer** | Structure scan (Phase 1) | Fast, read-only |
| **quick reviewer** | Quality scan (Phase 2) | Fast, read-only |

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Pareto scoring (Phase 3) |

<instructions>

### Phase 0: Parse Arguments

Parse `$ARGUMENTS` for optional parameters:

| Parameter | Default | Description |
|-----------|---------|-------------|
| `path` | `.` (project root) | Directory or file to scan |
| `--focus` | all | Comma-separated scan categories to include |
| `--count` | 10 | Number of top quick wins to surface |

Valid focus categories: `testing`, `solid`, `dry`, `kiss`, `security`, `dead-code`, `docs`

### Phase 1: Structure Scan (PARALLEL with Phase 2)

Delegate to a **codebase explorer** agent for fast structure discovery:

<agent-delegate role="codebase explorer" subagent="x-explorer" model="haiku">
  <prompt>Scan {path} for structural quick wins: dead code (unused exports, unreachable branches), missing tests (files without test counterparts), large files (>300 lines), deep nesting (>4 levels), and documentation gaps (public APIs without docstrings).</prompt>
  <context>Quick structural scan for Pareto-scored quick wins — focus on items that are easy to fix with high impact.</context>
</agent-delegate>

Scan domains covered:
- **dead-code**: Unused exports, unreachable branches, commented-out code
- **testing**: Files without test counterparts, low coverage areas
- **docs**: Public APIs without docstrings, stale README sections

### Phase 2: Quality Scan (PARALLEL with Phase 1)

Delegate to a **quick reviewer** agent for fast quality analysis:

<agent-delegate role="quick reviewer" subagent="x-reviewer-quick" model="haiku">
  <prompt>Scan {path} for quality quick wins: SOLID violations (god classes, missing interfaces), DRY violations (duplicated logic blocks >5 lines), KISS violations (over-engineered abstractions, unnecessary complexity), and security red flags (hardcoded secrets, missing input validation).</prompt>
  <context>Quick quality scan for Pareto-scored quick wins — focus on items that are easy to fix with high impact.</context>
</agent-delegate>

Scan domains covered:
- **solid**: God classes, missing interfaces, SRP violations
- **dry**: Duplicated logic blocks (>5 lines)
- **kiss**: Over-engineered abstractions, unnecessary complexity
- **security**: Hardcoded secrets, missing input validation, unsafe patterns

### Phase 3: Pareto Scoring

<deep-think purpose="prioritization" context="Scoring quick wins by impact and effort using Pareto analysis">
  <purpose>Score each finding from Phase 1 and Phase 2 using the Pareto formula, then rank and select top N</purpose>
  <context>Combining structural scan and quality scan results into a unified ranked list of quick wins</context>
</deep-think>

Score each finding using:

```
Score = (Impact / 5) * ((6 - Effort) / 5) * 100
```

| Dimension | Scale | Description |
|-----------|-------|-------------|
| **Impact** | 1-5 | How much improvement this fix brings (5 = major quality/security gain) |
| **Effort** | 1-5 | How much work to fix (1 = trivial, 5 = significant refactor) |

Score interpretation:
- **80-100**: Top priority (high impact, trivial effort)
- **60-79**: Strong candidate (good ROI)
- **40-59**: Moderate value (consider in next sprint)
- **20-39**: Low priority (effort may not justify)
- **1-19**: Skip (too much effort for too little gain)

Apply `--focus` filter: if focus categories were specified, exclude findings outside those categories.

Rank all findings by score descending, select top `--count` items.

### Phase 4: Report Generation

Generate the quick wins report:

```markdown
# Quick Wins Report

## Summary
- Path scanned: {path}
- Findings evaluated: {total_findings}
- Quick wins surfaced: {count}
- Focus: {categories or "all"}

## Top Quick Wins

| # | Score | Category | Finding | File | Effort |
|---|-------|----------|---------|------|--------|
| 1 | {score} | {category} | {description} | {file:line} | {effort_label} |
| 2 | {score} | {category} | {description} | {file:line} | {effort_label} |
| ... |

## Quick Win Details

### 1. {Finding title} (Score: {score})
- **Category**: {category}
- **File**: {file:line}
- **Impact**: {impact}/5 — {impact_rationale}
- **Effort**: {effort}/5 — {effort_rationale}
- **Suggested fix**: {brief fix description}

### 2. ...
```

### Phase 5: Action Gate

Present options for next steps:

<workflow-gate type="choice" id="quickwins-action">
  <question>Quick wins report generated. What would you like to do?</question>
  <header>Next step</header>
  <option key="fix" recommended="true">
    <label>Fix a quick win</label>
    <description>Pick a quick win and apply the fix immediately</description>
  </option>
  <option key="implement">
    <label>Implement with TDD</label>
    <description>Pick a quick win that needs tests and implement properly</description>
  </option>
  <option key="all">
    <label>Fix all top wins</label>
    <description>Sequentially fix all surfaced quick wins</description>
  </option>
  <option key="stop">
    <label>Stop here</label>
    <description>Review the report manually</description>
  </option>
</workflow-gate>

<workflow-chain on="fix" skill="x-fix" args="{selected quick win details}" />
<workflow-chain on="implement" skill="x-implement" args="{selected quick win details with test requirements}" />
<workflow-chain on="all" skill="x-fix" args="Fix quick win #1: {details}. Then continue with remaining quick wins." />
<workflow-chain on="stop" action="end" />

<chaining-instruction>

**Human approval required**: quickwins → fix/implement

After report generated:
1. Present the action gate with options
2. Wait for user selection
3. On selection, invoke via Skill tool:
   - "Fix a quick win": skill: "x-fix", args: "{quick win details}"
   - "Implement with TDD": skill: "x-implement", args: "{quick win details with test needs}"
   - "Fix all": skill: "x-fix", args: "Fix quick win #1: {details}. Continue with remaining."
   - "Stop here": End workflow

</chaining-instruction>

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | Action selection (fix/implement/stop) |
| **High** | ASK IF ABLE | Ambiguous scoring between findings |
| **Medium** | ASK IF UNCERTAIN | Focus category selection |
| **Low** | PROCEED | Scanning and scoring |

<human-approval-framework>

When approval needed, structure question as:
1. **Context**: Quick wins report summary
2. **Options**: Fix one / Implement with TDD / Fix all / Stop
3. **Recommendation**: Start with the highest-scored quick win
4. **Escape**: "Stop here" option always available

</human-approval-framework>

## Agent Delegation

**Recommended Agents**: codebase explorer (structure) + quick reviewer (quality)

| Delegate When | Keep Inline When |
|---------------|------------------|
| Always (Phase 1) | Never — structure scan needs exploration |
| Always (Phase 2) | Never — quality scan needs review patterns |

**IMPORTANT**: Phase 1 and Phase 2 run in **parallel** for speed. Both are read-only haiku agents.

## Workflow Chaining

**Next Verbs**: `/x-fix` (simple quick win), `/x-implement` (needs TDD)

| Trigger | Chain To | Auto? |
|---------|----------|-------|
| User picks "fix" | `/x-fix` | **HUMAN APPROVAL** |
| User picks "implement" | `/x-implement` | **HUMAN APPROVAL** |
| User picks "fix all" | `/x-fix` (sequential) | **HUMAN APPROVAL** |
| User picks "stop" | End | N/A |

## Scan Domains

| Domain | Category | What It Finds |
|--------|----------|---------------|
| Test coverage | `testing` | Files without test counterparts, low coverage |
| SOLID violations | `solid` | God classes, SRP violations, missing interfaces |
| DRY violations | `dry` | Duplicated logic blocks (>5 lines) |
| KISS violations | `kiss` | Over-engineering, unnecessary complexity |
| Security flags | `security` | Hardcoded secrets, missing validation |
| Dead code | `dead-code` | Unused exports, unreachable branches |
| Documentation | `docs` | Missing docstrings, stale README |

## Critical Rules

1. **Read-Only Scanning** - Never modify code during scan phases
2. **Pareto Discipline** - Score every finding, surface only top N
3. **Speed First** - Use haiku agents in parallel for fast scans
4. **Actionable Output** - Every quick win must include a suggested fix
5. **No False Positives** - Verify findings before scoring (grep for actual usage before flagging "dead code")

## Navigation

| Direction | Verb | When |
|-----------|------|------|
| Fix one | `/x-fix` | Simple quick win selected |
| Implement | `/x-implement` | Quick win needs TDD |
| Full analysis | `/x-analyze` | Want comprehensive assessment instead |

## Success Criteria

- [ ] Path scanned with both structure and quality agents
- [ ] All findings scored with Pareto formula
- [ ] Top N quick wins presented in ranked report
- [ ] Each quick win has file location, impact, effort, and suggested fix
- [ ] Action gate presented for next steps

## References

- @skills/meta-analysis/ - Pareto 80/20 prioritization
- @skills/code-code-quality/ - SOLID, DRY, KISS principles
- @skills/quality-testing/ - Test coverage patterns
