---
name: x-review
description: Pre-merge validation with quality checks and code review.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
user-invocable: true
metadata:
  author: ccsetup contributors
  version: "2.0.0"
  category: workflow
---

# /x-review

> Perform code review with quality checks before merge.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | APEX |
| **Phase** | examine (X) |
| **Position** | 5 of 6 in workflow |

**Flow**: `x-verify` → **`x-review`** → `x-commit`

## Intention

**Target**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Review staged changes.
{{/if}}

## Behavioral Skills

This skill activates:

### Always Active
- `interview` - Zero-doubt confidence gate (Phase 0)
- `code-quality` - SOLID, DRY, KISS enforcement
- `owasp` - Security vulnerability check

### Context-Triggered
| Skill | Trigger Conditions |
|-------|-------------------|
| `authentication` | Auth-related changes |
| `performance` | Performance-critical paths |

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **code reviewer (quick)** | Initial code scan | Fast read-only, escalates on complex issues |
| **code reviewer** | Escalation from quick scanner | Deep SOLID/security analysis |
| **codebase explorer** | Pattern analysis | Fast, read-only |

<instructions>

### Phase 0: Confidence Check

Activate `@skills/interview/` if:
- Review scope unclear
- Multiple review focuses possible
- Security implications unknown

### Phase 0b: Workflow State Check

1. Read `.claude/workflow-state.json` (if exists)
2. If active workflow exists:
   - Expected next phase is `review`? → Proceed
   - Skipping `verify`? → Warn: "Skipping verify phase. Continue? [Y/n]"
   - Active workflow at different phase? → Confirm: "Active workflow at {phase}. Start new? [Y/n]"
3. If no active workflow → Create new workflow state at `review` phase

### Phase 1: Documentation Pre-Check

Before review starts, verify documentation sync:

```
┌─────────────────────────────────────────────────┐
│ Pre-Review Documentation Check                  │
├─────────────────────────────────────────────────┤
│ Check API docs match code signatures            │
│ Check examples are current                      │
│ Check no broken internal links                  │
│ Flag docs that may need attention               │
├─────────────────────────────────────────────────┤
│ Initiative Documentation (if active initiative) │
│ Check milestone file updated with progress      │
│ Check initiative README progress table current  │
│ Check milestones hub reflects latest status     │
│ Flag stale initiative docs as review finding    │
└─────────────────────────────────────────────────┘
```

Detect active initiative:
1. Check `.claude/initiative.json` for `currentMilestone`
2. If not found, check `documentation/milestones/_active/` for initiative directories
3. If no initiative detected, skip initiative documentation checks

Stale initiative documentation is classified as **Warning** severity (should fix before merge, or document reason for deferral).

### Phase 2: Code Review — BLOCKING AUDIT

<agent-delegate role="code reviewer" subagent="x-reviewer-quick" model="haiku">
  <prompt>Review all changed files against SOLID, DRY, security, and test coverage enforcement rules</prompt>
  <context>APEX workflow examine phase — systematic code review with blocking audit</context>
  <escalate to="x-reviewer" model="sonnet" trigger="complex SOLID analysis needed, architecture concerns, or large changeset (>10 files)" />
</agent-delegate>

<agent-delegate role="codebase explorer" subagent="x-explorer" model="haiku">
  <prompt>Analyze patterns in changed files — check for convention violations and architectural consistency</prompt>
  <context>Pattern analysis to support code review</context>
</agent-delegate>

**Parallel review** (when changeset spans 5+ files or multiple domains):

<parallel-delegate strategy="concurrent">
  <agent role="code reviewer" subagent="x-reviewer" model="sonnet">
    <prompt>Review all changed files for code quality — SOLID violations, DRY, complexity, test coverage</prompt>
    <context>Quality domain review for APEX examine phase</context>
  </agent>
  <agent role="security reviewer" subagent="x-security-reviewer" model="sonnet">
    <prompt>Review all changed files for security — OWASP Top 10, input validation, auth, data exposure</prompt>
    <context>Security domain review for APEX examine phase</context>
  </agent>
</parallel-delegate>

For each changed file, audit against enforcement violation definitions.

#### SOLID Audit (BLOCKING)

Check against @skills/code-code-quality/ violations:
- [ ] SRP (V-SOLID-01: CRITICAL → BLOCK)
- [ ] OCP (V-SOLID-02: HIGH → BLOCK)
- [ ] LSP (V-SOLID-03: CRITICAL → BLOCK)
- [ ] ISP (V-SOLID-04: HIGH → BLOCK)
- [ ] DIP (V-SOLID-05: HIGH → BLOCK)

#### DRY Audit (BLOCKING)

- [ ] No >10 line duplication (V-DRY-01: HIGH → BLOCK)
- [ ] Flag 3-10 line duplication (V-DRY-02: MEDIUM → WARN)
- [ ] No repeated magic values (V-DRY-03: MEDIUM → WARN)

#### Design Pattern Review

- [ ] No God Objects (V-PAT-01: CRITICAL → BLOCK)
- [ ] No circular dependencies (V-PAT-02: HIGH → BLOCK)
- [ ] Flag missing obvious patterns (V-PAT-03: MEDIUM → WARN)
- [ ] No pattern misuse (V-PAT-04: HIGH → BLOCK)

#### Security Review

- [ ] Input validation
- [ ] Authentication/Authorization
- [ ] Data exposure
- [ ] OWASP Top 10

#### Test Coverage

- [ ] All new code has tests (V-TEST-01: CRITICAL → BLOCK)
- [ ] Meaningful assertions (V-TEST-05: CRITICAL → BLOCK)
- [ ] Edge cases covered
- [ ] Integration tests if needed

#### Pareto Audit

- [ ] No over-engineered solutions (V-PARETO-01: HIGH → BLOCK)
- [ ] Check for simpler alternatives that deliver comparable value
- [ ] Flag >3x complexity for marginal improvement

### Phase 3: Severity Classification — STRICT

**CRITICAL (BLOCK):** V-SOLID-01, V-SOLID-03, V-TEST-01, V-TEST-05, V-TEST-06, V-DOC-02, V-PAT-01
→ MUST fix before approval. No exceptions.

**HIGH (BLOCK):** V-SOLID-02, V-SOLID-04, V-SOLID-05, V-DRY-01, V-TEST-02, V-TEST-03, V-DOC-01, V-DOC-04, V-PAT-02, V-PAT-04, V-KISS-02, V-YAGNI-01, V-PARETO-01
→ MUST fix OR escalate to user with justification.

**MEDIUM (WARN):** V-DRY-02, V-DRY-03, V-KISS-01, V-YAGNI-02, V-TEST-04, V-TEST-07, V-DOC-03, V-PAT-03, V-PARETO-02, V-PARETO-03
→ Flag to user. Document if deferring.

**LOW (INFO):** Style, minor improvements.
→ Note for awareness.

### Phase 4: Review Summary

Generate review summary:

```markdown
## Review Summary

### Critical Issues
- [ ] Issue 1: Description (file:line)

### Warnings
- [ ] Warning 1: Description (file:line)

### Suggestions
- Info 1: Description

### Overall
- SOLID: [Pass/Fail]
- Security: [Pass/Fail]
- Tests: [Pass/Fail]
- Docs: [Pass/Fail]
- Initiative Docs: [Pass/Fail/N/A]

### Initiative Documentation (if applicable)
- [ ] Milestone file updated
- [ ] Initiative README current
- [ ] Milestones hub current
```

### Phase 4b: Enforcement Summary — MANDATORY

**This phase CANNOT be skipped.** Output compliance report:

```
| Practice       | Status | Violations   | Action           |
|----------------|--------|--------------|------------------|
| SOLID          | ✅/❌  | V-SOLID-XX   | Pass / Fix needed |
| DRY            | ✅/❌  | V-DRY-XX     | Pass / Fix needed |
| Security       | ✅/❌  | OWASP        | Pass / Fix needed |
| Testing        | ✅/⚠️  | V-TEST-XX    | Pass / Flagged    |
| Documentation  | ✅/❌  | V-DOC-XX     | Pass / Fix needed |
| Patterns       | ✅/⚠️  | V-PAT-XX     | Pass / Flagged    |
| Pareto         | ✅/⚠️  | V-PARETO-XX  | Pass / Flagged    |
```

**ANY ❌ = cannot proceed to /x-commit.**

### Phase 5: Update Workflow State

After completing review:

1. Read `.claude/workflow-state.json`
2. Mark `review` phase as `"completed"` with timestamp and `"approved": true/false`
3. Set `commit` phase as `"in_progress"` (only after review approval)
4. Write updated state to `.claude/workflow-state.json`
5. Write to Memory MCP entity `"workflow-state"`:
   - `"phase: review -> completed (approved)"`
   - `"next: commit"`

<state-checkpoint phase="review" status="completed">
  <file path=".claude/workflow-state.json">Mark review complete (approved: true/false), set commit in_progress on approval</file>
  <memory entity="workflow-state">phase: review -> completed (approved); next: commit</memory>
</state-checkpoint>

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | Critical issues found |
| **High** | ASK IF ABLE | Multiple warnings |
| **Medium** | ASK IF UNCERTAIN | Borderline issues |
| **Low** | PROCEED | Clean review |

<human-approval-framework>

When approval needed, structure question as:
1. **Context**: Review findings summary
2. **Options**: Fix issues, merge with warnings, or block
3. **Recommendation**: Fix criticals before merge
4. **Escape**: "Return to /x-implement" option

</human-approval-framework>

## Agent Delegation

**Recommended Agent**: **code reviewer (quick)** → escalates to **code reviewer** on complex issues

| Delegate When | Keep Inline When |
|---------------|------------------|
| Large changeset (escalate) | Small changes |
| Security-sensitive (escalate) | Simple refactors |
| Standard review | Trivial changes |

## Workflow Chaining

**Next Verb**: `/x-commit`

| Trigger | Chain To | Auto? |
|---------|----------|-------|
| Review approved | `/x-commit` | Yes |
| Changes requested | `/x-implement` | No (show feedback) |
| Critical issues | Block | No (require fix) |

<chaining-instruction>

**Auto-chain**: review → commit (on approval, no additional gate)

After review approved:
1. Update `.claude/workflow-state.json` (mark review complete, set commit in_progress)
2. Auto-invoke next skill via Skill tool:
   - skill: "x-commit"
   - args: "commit reviewed changes"

<workflow-chain on="auto" skill="x-commit" args="commit reviewed changes" />

On changes requested (manual — loop back):
"Review found issues to address. Return to /x-implement?"

<workflow-gate type="choice" id="review-changes-requested">
  <question>Review found issues to address. How would you like to proceed?</question>
  <header>Review issues</header>
  <option key="fix" recommended="true">
    <label>Fix issues</label>
    <description>Return to implementation to address review findings</description>
  </option>
  <option key="exception">
    <label>Request exception</label>
    <description>Proceed with justification for deferring fixes</description>
  </option>
</workflow-gate>

<workflow-chain on="fix" skill="x-implement" args="{review findings and issues to address}" />
<workflow-chain on="exception" action="end" />

</chaining-instruction>

## Review Checklist

| Area | Check |
|------|-------|
| SOLID | Principles adherence |
| Security | No vulnerabilities |
| Tests | Adequate coverage |
| Docs | Documentation updated |
| Breaking | Breaking changes documented |
| Initiative | Milestone docs updated (if active) |

## Severity Levels

| Level | Action | Violation IDs |
|-------|--------|---------------|
| CRITICAL (BLOCK) | Must fix before approval | V-SOLID-01/03, V-TEST-01/05/06, V-DOC-02, V-PAT-01 |
| HIGH (BLOCK) | Must fix or escalate with justification | V-SOLID-02/04/05, V-DRY-01, V-TEST-02/03, V-DOC-01/04, V-PAT-02/04, V-PARETO-01 |
| MEDIUM (WARN) | Flag to user, document if deferring | V-DRY-02/03, V-KISS-01, V-TEST-04/07, V-DOC-03, V-PAT-03, V-PARETO-02/03 |
| LOW (INFO) | Note for awareness | Style, minor improvements |

## Critical Rules

1. **No BLOCK violations** — NEVER approve with unresolved CRITICAL/HIGH violations
2. **SOLID is mandatory** — Full audit using V-SOLID-* definitions
3. **DRY is enforced** — V-DRY-01 blocks merge
4. **Security First** — Security issues always CRITICAL
5. **Test Coverage** — New code MUST have tests (V-TEST-01)
6. **Documentation** — Stale docs block merge (V-DOC-01, V-DOC-04)
7. **Initiative Docs** — Flag stale milestone documentation as a review finding
8. **Enforcement summary required** — MUST output compliance table (Phase 4b)

## Navigation

| Direction | Verb | When |
|-----------|------|------|
| Previous | `/x-verify` | Need more verification |
| Previous | `/x-implement` | Need to fix issues |
| Next | `/x-commit` | Review approved |

## Success Criteria

- [ ] All files reviewed
- [ ] SOLID principles checked
- [ ] Security review complete
- [ ] Test coverage adequate
- [ ] Documentation updated
- [ ] No critical issues
- [ ] Enforcement summary produced (Phase 4b)
- [ ] Initiative documentation flagged if stale (if active initiative)

## When to Load References

- **For review checklist**: See `references/mode-review.md`
- **For audit patterns**: See `references/mode-audit.md`
- **For security review**: See `references/mode-security.md`

## References

- @skills/code-code-quality/ - SOLID principles
- @skills/security-owasp/ - Security checklist
