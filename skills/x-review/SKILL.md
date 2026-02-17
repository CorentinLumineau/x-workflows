---
name: x-review
description: "Use after implementation to perform quality gates, code review, documentation audit, and regression detection."
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
user-invocable: true
metadata:
  author: ccsetup contributors
  version: "3.0.0"
  category: workflow
chains-to:
  - skill: git-commit
    condition: "review approved"
  - skill: x-implement
    condition: "changes requested"
chains-from:
  - skill: x-implement
  - skill: x-refactor
  - skill: x-fix
---

# /x-review

> Comprehensive readiness assessment — quality gates, code review, documentation audit, and regression detection.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | APEX |
| **Phase** | examine (X) |
| **Position** | 4 of 5 in workflow |

**Flow**: `x-implement` → **`x-review`** → `git-commit`

## Intention

**Target**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Review all changes in default (full review) mode.
{{/if}}

## Mode Detection

Detect mode from `$ARGUMENTS` keywords:

| Mode | Keywords | Phases | Use Case |
|------|----------|--------|----------|
| `review` (default) | none, "review", "ready" | 0→1→2→3→4→5→6→7 | Full readiness assessment |
| `quick` | "quick", "gates", "verify" | 0→2→6→7 | Fast quality gate validation |
| `audit` | "audit", "security", "deep" | 0→1→3→6→7 | Deep code + security review |
| `docs` | "docs", "documentation" | 0→1→4→6→7 | Documentation completeness |

## Phase Architecture

| Phase | Name | Purpose | Source |
|-------|------|---------|--------|
| 0 | Confidence + State | Interview gate, workflow state | Standard |
| 1 | Change Scoping | git diff, initiative context | NEW |
| 2 | Quality Gates | Lint, types, tests, build | Quality gates |
| 3 | Code Review | SOLID, security, patterns | From x-review |
| 4 | Documentation Audit | Docs freshness, API sync | NEW |
| 5 | Regression Detection | Coverage delta, removed tests | NEW |
| 6 | Readiness Report | Pass/warn/block synthesis | NEW |
| 7 | Workflow State | State update, chaining | Standard |

## Behavioral Skills

This skill activates:

### Always Active
- `interview` - Zero-doubt confidence gate (Phase 0)
- `code-quality` - SOLID, DRY, KISS enforcement
- `secure-coding` - Security vulnerability check

### Context-Triggered
| Skill | Trigger Conditions |
|-------|-------------------|
| `identity-access` | Auth-related changes |
| `performance` | Performance-critical paths |
| `testing` | Test files changed or coverage analysis |

## Agent Delegation

| Phase | Role | Agent | Model | When |
|-------|------|-------|-------|------|
| 1 | Codebase explorer | x-explorer | haiku | Change scoping |
| 2 | Fast test runner | x-tester-fast | haiku | Initial gate run |
| 2 | Test runner (escalation) | x-tester | sonnet | Persistent failures (>3) |
| 3 | Quick reviewer | x-reviewer-quick | haiku | Small changeset (<5 files) |
| 3 | Code reviewer | x-reviewer | sonnet | Large changeset or escalation |
| 3 | Security reviewer | x-security-reviewer | sonnet | Parallel with code reviewer |
| 4 | Codebase explorer | x-explorer | haiku | Doc link checking |
| 5 | Test runner | x-tester | sonnet | Coverage analysis |

<instructions>

### Phase 0: Confidence + State Check

#### 0a: Confidence Check

Activate `@skills/interview/` if:
- Review scope unclear
- Multiple review focuses possible
- Security implications unknown

#### 0b: Workflow State Check

1. Read `.claude/workflow-state.json` (if exists)
2. If active workflow exists:
   - Expected next phase is `review`? → Proceed
   - Skipping prior phases? → Warn: "Skipping {phase}. Continue? [Y/n]"
   - Active workflow at different phase? → Confirm: "Active workflow at {phase}. Start new? [Y/n]"
3. If no active workflow → Create new workflow state at `review` phase

---

### Phase 1: Change Scoping

> **Modes**: review, audit, docs (skipped in quick)

Scope the changes under review:

<agent-delegate role="codebase explorer" subagent="x-explorer" model="haiku">
  <prompt>Analyze git diff to identify all changed files, categorize by domain (code, tests, docs, config), and detect active initiative context</prompt>
  <context>Phase 1 change scoping for x-review readiness assessment</context>
</agent-delegate>

```bash
# Changed files since branch point
git diff --name-only --stat main...HEAD

# Detect active initiative
cat .claude/initiative.json 2>/dev/null || echo "No active initiative"
```

**Output** — scope summary used by subsequent phases:
- File count and categories (code, test, docs, config)
- Lines added/removed
- Domains affected (auth, API, UI, infra, etc.)
- Active initiative (if any)
- Estimated complexity: LOW (<5 files) | MEDIUM (5-15) | HIGH (>15)

---

### Phase 2: Quality Gates

> **Modes**: review, quick

<agent-delegate role="test runner" subagent="x-tester-fast" model="haiku">
  <prompt>Run full quality gates: lint, type-check, test, build — report pass/fail with evidence for each gate</prompt>
  <context>APEX workflow examine phase — running all quality gates</context>
  <escalate to="x-tester" model="sonnet" trigger="persistent test failures (>3), flaky test patterns, or coverage analysis needed" />
</agent-delegate>

**Parallel verification** (when project has multiple test suites):

<parallel-delegate strategy="concurrent">
  <agent role="test runner" subagent="x-tester" model="sonnet">
    <prompt>Run full test suite with coverage analysis — report failures, coverage gaps, and flaky tests</prompt>
    <context>Comprehensive test execution for APEX examine phase</context>
  </agent>
  <agent role="fast tester" subagent="x-tester-fast" model="haiku">
    <prompt>Run lint, type-check, and build gates — report pass/fail quickly</prompt>
    <context>Fast quality gates for APEX examine phase</context>
  </agent>
</parallel-delegate>

Execute all gates:

```bash
pnpm lint
pnpm type-check
pnpm test
pnpm build
```

#### Verification Evidence Protocol — MANDATORY

**This sub-phase CANNOT be skipped. Every quality claim MUST have execution evidence.**

> **Foundational principle**: "Tests should pass" is a PREDICTION. "Tests pass" after reading output is a VERIFICATION. Only verifications are accepted.

For EACH quality gate, follow this 5-step sequence:

| Step | Action | What You Do |
|------|--------|-------------|
| 1. IDENTIFY | Name the gate | "Running lint gate" |
| 2. RUN | Execute the command | `pnpm lint` (actual execution) |
| 3. READ | Read full output | Read the complete command output |
| 4. VERIFY | State pass/fail with evidence | "Lint passed: 0 errors, 0 warnings" |
| 5. CLAIM | Make status claim | Only NOW can you say "lint gate passes" |

**Prohibited Language** (V-TEST-07 CRITICAL violation):

| Prohibited | Correct Alternative |
|------------|---------------------|
| "Tests should pass" | Run tests, read output, report result |
| "This probably works" | Execute and verify |
| "Based on the code, tests will pass" | Run the tests |
| Any claim without output evidence | Complete all 5 steps |

See `references/verification-protocol.md` for anti-pattern examples.

#### Coverage Thresholds — BLOCKING

| Check | Threshold | Violation | Action |
|-------|-----------|-----------|--------|
| Line coverage on changed files | ≥80% | V-TEST-03 (HIGH) | BLOCK |
| Unit test ratio of new tests | ≥60% | V-TEST-04 (MEDIUM) | WARN |
| Tests have assertions | 100% | V-TEST-05 (CRITICAL) | BLOCK |
| No flaky tests | 0 flaky | V-TEST-06 (CRITICAL) | BLOCK |

#### STOP — Coverage Hard Gate

> **You MUST stop here and verify coverage numbers before proceeding.**

**Checklist** (ALL must be true to proceed):
- [ ] Line coverage on changed files ≥ 80% (MEASURED, not estimated)
- [ ] All tests have assertions (no empty test bodies)
- [ ] Zero flaky tests (run twice if unsure)

**Common Rationalizations** (if you're thinking any of these, STOP):

| Excuse | Reality |
|--------|---------|
| "Coverage is probably fine" | Measure it. "Probably" is not a number. (V-TEST-03) |
| "The important paths are covered" | 80% threshold on changed files. Measure it. (V-TEST-03) |
| "Adding more tests would be diminishing returns" | You haven't measured yet. Measure first, then argue. (V-TEST-03) |

> **Foundational principle**: Violating the letter of this gate IS violating its spirit. There is no "technically compliant" shortcut.

See `@skills/code-code-quality/references/anti-rationalization.md` for the full excuse/reality reference.

#### Handle Failures

If any gate fails:

```
Gate Failure Detected → Attempt Auto-Fix → Re-run Gate → Still Failing? → Report and suggest fix
```

Auto-fix capabilities: `pnpm lint --fix`, type error suggestions, test failure analysis.

---

### Phase 3: Code Review

> **Modes**: review, audit

#### Phase 3a: Spec Compliance Review — BLOCKING

> **This sub-phase runs FIRST. Code quality review (Phase 3b) ONLY runs after spec compliance passes.**

Compare implementation against the plan, issue, or user request:

1. **Identify the spec source**: plan from `/x-plan`, issue from `/git-implement-issue`, or user request
2. **Check implementation completeness**:
   - [ ] All requirements from spec are implemented
   - [ ] No scope creep (code not in requirements)
   - [ ] No missing requirements (requirements not in code)
   - [ ] Correct requirement implemented (not a different interpretation)

**Spec Violation Severity:**

| Violation | Severity | Action |
|-----------|----------|--------|
| Scope creep (extra code not in requirements) | MEDIUM | WARN (HIGH if security risk) |
| Missing requirement (functional gap) | HIGH | BLOCK |
| Wrong requirement implemented | CRITICAL | BLOCK |

**If FAIL → BLOCK.** Return to `/x-implement` with spec violation details. Do NOT proceed to Phase 3b.

#### Phase 3b: Code Quality Review — BLOCKING AUDIT

> **Only runs AFTER Phase 3a passes.**

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

For each changed file, audit against enforcement violation definitions:

**SOLID Audit (BLOCKING)**:
- [ ] SRP (V-SOLID-01: CRITICAL → BLOCK)
- [ ] OCP (V-SOLID-02: HIGH → BLOCK)
- [ ] LSP (V-SOLID-03: CRITICAL → BLOCK)
- [ ] ISP (V-SOLID-04: HIGH → BLOCK)
- [ ] DIP (V-SOLID-05: HIGH → BLOCK)

**DRY Audit (BLOCKING)**:
- [ ] No >10 line duplication (V-DRY-01: HIGH → BLOCK)
- [ ] Flag 3-10 line duplication (V-DRY-02: MEDIUM → WARN)
- [ ] No repeated magic values (V-DRY-03: MEDIUM → WARN)

**Design Pattern Review**:
- [ ] No God Objects (V-PAT-01: CRITICAL → BLOCK)
- [ ] No circular dependencies (V-PAT-02: HIGH → BLOCK)
- [ ] Flag missing obvious patterns (V-PAT-03: MEDIUM → WARN)
- [ ] No pattern misuse (V-PAT-04: HIGH → BLOCK)

**Security Review**:
- [ ] Input validation
- [ ] Authentication/Authorization
- [ ] Data exposure
- [ ] OWASP Top 10

**Test Coverage**:
- [ ] All new code has tests (V-TEST-01: CRITICAL → BLOCK)
- [ ] Meaningful assertions (V-TEST-05: CRITICAL → BLOCK)
- [ ] Edge cases covered
- [ ] Integration tests if needed

**Pareto Audit**:
- [ ] No over-engineered solutions (V-PARETO-01: HIGH → BLOCK)
- [ ] Check for simpler alternatives
- [ ] Flag >3x complexity for marginal improvement

#### Phase 3c: Severity Classification — STRICT

**CRITICAL (BLOCK):** V-SOLID-01, V-SOLID-03, V-TEST-01, V-TEST-05, V-TEST-06, V-DOC-02, V-PAT-01
→ MUST fix before approval. No exceptions.

**HIGH (BLOCK):** V-SOLID-02, V-SOLID-04, V-SOLID-05, V-DRY-01, V-TEST-02, V-TEST-03, V-DOC-01, V-DOC-04, V-PAT-02, V-PAT-04, V-KISS-02, V-YAGNI-01, V-PARETO-01
→ MUST fix OR escalate to user with justification.

**MEDIUM (WARN):** V-DRY-02, V-DRY-03, V-KISS-01, V-YAGNI-02, V-TEST-04, V-TEST-07, V-DOC-03, V-PAT-03, V-PARETO-02, V-PARETO-03
→ Flag to user. Document if deferring.

**LOW (INFO):** Style, minor improvements.

#### STOP — Review Approval Hard Gate

> **You MUST stop here and verify violations before generating the readiness report.**

**Checklist** (ALL must be true to proceed):
- [ ] Zero CRITICAL violations
- [ ] Zero HIGH violations without documented user-approved exception
- [ ] All MEDIUM violations flagged in readiness report

**Common Rationalizations** (if you're thinking any of these, STOP):

| Excuse | Reality |
|--------|---------|
| "Overall the code looks good" | Review is checklist-driven, not impression-driven. Run the checklist. |
| "These issues are cosmetic" | Check the severity table. CRITICAL/HIGH are never cosmetic. |
| "The user seems in a hurry" | Quality gates protect users from their own urgency. Hold the line. |
| "It's just a small change" | Small changes with CRITICAL violations are still CRITICAL. |

> **Foundational principle**: Violating the letter of this gate IS violating its spirit. There is no "technically compliant" shortcut.

See `@skills/code-code-quality/references/anti-rationalization.md` for the full excuse/reality reference.

---

### Phase 4: Documentation Audit

> **Modes**: review, docs

Check documentation sync with code changes. Uses Phase 1 scoping data.

<agent-delegate role="codebase explorer" subagent="x-explorer" model="haiku">
  <prompt>Check that API docs match code signatures, examples are current, no broken internal links, and initiative docs are updated</prompt>
  <context>Documentation audit for x-review readiness assessment</context>
</agent-delegate>

```
┌─────────────────────────────────────────────────┐
│ Documentation Check                             │
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

See `references/mode-docs.md` for detailed documentation audit patterns.

---

### Phase 5: Regression Detection

> **Modes**: review only (full mode)

Detect regressions introduced by code changes. Uses Phase 1 scoping data.

<agent-delegate role="test runner" subagent="x-tester" model="sonnet">
  <prompt>Analyze coverage delta on changed files, identify removed tests, disabled assertions, and behavioral regression indicators</prompt>
  <context>Regression detection for x-review Phase 5</context>
</agent-delegate>

**Checks:**
- [ ] No test files deleted without replacement
- [ ] No `describe.skip()` / `it.skip()` / `@Disabled` added
- [ ] No assertions removed from existing tests
- [ ] Coverage not decreased >5% on any changed file
- [ ] No public API changes without test updates

See `references/mode-regression.md` for detailed regression detection patterns.

---

### Phase 6: Readiness Report

> **All modes** — synthesizes results from all prior phases.

Generate comprehensive readiness report:

```markdown
## Readiness Report

### Mode: {mode}
### Scope: {file_count} files, {lines_added}+ / {lines_removed}-

### Quality Gates (Phase 2)
| Gate | Status | Evidence |
|------|--------|----------|
| Lint | ✅/❌ | {summary} |
| Types | ✅/❌ | {summary} |
| Tests | ✅/❌ | {summary} |
| Build | ✅/❌ | {summary} |
| Coverage | ✅/⚠️/❌ | {percentage}% |

### Code Review (Phase 3)
| Practice | Status | Violations | Action |
|----------|--------|------------|--------|
| Spec Compliance | ✅/❌ | — | Pass / Fix needed |
| SOLID | ✅/❌ | V-SOLID-XX | Pass / Fix needed |
| DRY | ✅/❌ | V-DRY-XX | Pass / Fix needed |
| Security | ✅/❌ | OWASP | Pass / Fix needed |
| Testing | ✅/⚠️ | V-TEST-XX | Pass / Flagged |
| Documentation | ✅/❌ | V-DOC-XX | Pass / Fix needed |
| Patterns | ✅/⚠️ | V-PAT-XX | Pass / Flagged |
| Pareto | ✅/⚠️ | V-PARETO-XX | Pass / Flagged |

### Documentation (Phase 4)
- Code docs: ✅/⚠️/❌
- Project docs: ✅/⚠️/❌
- Initiative docs: ✅/⚠️/N/A

### Regression (Phase 5)
- Coverage delta: {+/-}%
- Removed tests: {count}
- Disabled tests: {count}

### Verdict: {APPROVED / CHANGES REQUESTED / BLOCKED}

**ANY ❌ = cannot proceed to /git-commit.**
```

---

### Phase 7: Workflow State

After completing review:

1. Read `.claude/workflow-state.json`
2. Mark `review` phase as `"completed"` with timestamp and `"approved": true/false`
3. If approved: set `commit` phase as `"in_progress"`
4. Write updated state to `.claude/workflow-state.json`
5. Write to Memory MCP entity `"workflow-state"`:
   - `"phase: review -> completed (approved/rejected)"`
   - `"next: commit"` (if approved)

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
1. **Context**: Readiness report summary
2. **Options**: Fix issues, merge with warnings, or block
3. **Recommendation**: Fix criticals before merge
4. **Escape**: "Return to /x-implement" option

</human-approval-framework>

## Workflow Chaining

**Next Verb**: `/git-commit`

| Trigger | Chain To |
|---------|----------|
| Review approved | `/git-commit` (suggest) |
| Changes requested | `/x-implement` (suggest) |
| Critical issues | Block (require fix) |

<chaining-instruction>

After review complete:

<workflow-gate type="choice" id="review-next">
  <question>Review complete. How would you like to proceed?</question>
  <header>Next step</header>
  <option key="commit" recommended="true">
    <label>Commit changes</label>
    <description>Proceed to commit reviewed changes</description>
  </option>
  <option key="fix">
    <label>Request changes</label>
    <description>Return to implementation to address review findings</description>
  </option>
  <option key="done">
    <label>Done</label>
    <description>Review complete, no further action</description>
  </option>
</workflow-gate>

<workflow-chain on="commit" skill="git-commit" args="commit reviewed changes" />
<workflow-chain on="fix" skill="x-implement" args="{review findings and issues to address}" />
<workflow-chain on="done" action="end" />

</chaining-instruction>

## Severity Levels

| Level | Action | Violation IDs |
|-------|--------|---------------|
| CRITICAL (BLOCK) | Must fix before approval | V-SOLID-01/03, V-TEST-01/05/06/07, V-DOC-02, V-PAT-01 |
| HIGH (BLOCK) | Must fix or escalate | V-SOLID-02/04/05, V-DRY-01, V-TEST-02/03, V-DOC-01/04, V-PAT-02/04, V-PARETO-01 |
| MEDIUM (WARN) | Flag, document if deferring | V-DRY-02/03, V-KISS-01, V-YAGNI-02, V-TEST-04, V-DOC-03, V-PAT-03, V-PARETO-02/03 |
| LOW (INFO) | Note for awareness | Style, minor improvements |

## Critical Rules

1. **No BLOCK violations** — NEVER approve with unresolved CRITICAL/HIGH violations
2. **SOLID is mandatory** — Full audit using V-SOLID-* definitions
3. **DRY is enforced** — V-DRY-01 blocks merge
4. **Security First** — Security issues always CRITICAL
5. **Test Coverage** — New code MUST have tests (V-TEST-01)
6. **Evidence Required** — Every quality claim needs execution proof (V-TEST-07)
7. **Documentation** — Stale docs block merge (V-DOC-01, V-DOC-04)
8. **Initiative Docs** — Flag stale milestone documentation as a review finding
9. **Readiness report required** — MUST output Phase 6 report
10. **Anti-rationalization** — See `@skills/code-code-quality/references/anti-rationalization.md`

## Navigation

| Direction | Verb | When |
|-----------|------|------|
| Previous | `/x-implement` | Need to fix issues |
| Previous | `/x-refactor` | Need structural changes |
| Next | `/git-commit` | Review approved |
| Shortcut | `/x-review quick` | Runs quick mode |

## Success Criteria

- [ ] All phases completed for selected mode
- [ ] Quality gates passed (Phase 2)
- [ ] Code review clean (Phase 3)
- [ ] Documentation current (Phase 4)
- [ ] No regressions detected (Phase 5)
- [ ] Readiness report produced (Phase 6)
- [ ] Workflow state updated (Phase 7)
- [ ] No CRITICAL or HIGH violations

## When to Load References

- **For quick mode details**: See `references/mode-quick.md`
- **For review checklist**: See `references/mode-review.md`
- **For audit patterns**: See `references/mode-audit.md`
- **For security review**: See `references/mode-security.md`
- **For documentation audit**: See `references/mode-docs.md`
- **For regression detection**: See `references/mode-regression.md`
- **For coverage improvement**: See `references/mode-coverage.md`
- **For build guidance**: See `references/mode-build.md`
- **For evidence protocol**: See `references/verification-protocol.md`

## References

- @skills/code-code-quality/ - SOLID principles, anti-rationalization
- @skills/security-secure-coding/ - Security checklist
- @skills/quality-testing/ - Testing pyramid and CI quality checks
