---
name: x-review
description: "Use after implementation to perform quality gates, code review, documentation audit, and regression detection."
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
user-invocable: true
argument-hint: "[scope or path]"
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
  - skill: x-analyze
  - skill: x-create
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
| `spec-compliance` | "spec", "specification", "compliance" | 0→1→SC→6→7 | Verify implementation matches spec |

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

**Always**: `interview`, `code-quality`, `secure-coding`
**Context-triggered**: `identity-access` (auth), `performance` (perf paths), `testing` (test changes)

## Agent Delegation

> See [references/mode-review.md](references/mode-review.md) for full agent delegation matrix by phase.

<instructions>

<hook-trigger event="PostToolUse" tool="Bash" condition="After quality gate execution (lint, test, build)">
  <action>Capture gate results and update readiness report with pass/fail evidence per the Verification Evidence Protocol</action>
</hook-trigger>

### Phase 0: Confidence + State Check

#### 0a: Confidence Check

Activate `@skills/interview/` if:
- Review scope unclear
- Multiple review focuses possible
- Security implications unknown

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

**This sub-phase CANNOT be skipped.** Every quality claim MUST have execution evidence following the 5-step sequence (IDENTIFY, RUN, READ, VERIFY, CLAIM). Predictions are not verifications.

For the full protocol, coverage thresholds, and coverage hard gate, see `references/verification-protocol.md`.

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

**If spec compliance FAILS → BLOCK.** Return to `/x-implement` with spec violation details. Do NOT proceed to Phase 3b. See [references/enforcement-audit.md](references/enforcement-audit.md) for spec violation severity classification.

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

For enforcement audit checklists (SOLID, DRY, Design Patterns, Security, Test Coverage, Pareto), severity classification, and the review approval hard gate, see `references/enforcement-audit.md`.

---

### Phase 4: Documentation Audit

> **Modes**: review, docs

Check documentation sync with code changes. Uses Phase 1 scoping data.

<agent-delegate role="codebase explorer" subagent="x-explorer" model="haiku">
  <prompt>Check that API docs match code signatures, examples are current, no broken internal links, and initiative docs are updated</prompt>
  <context>Documentation audit for x-review readiness assessment</context>
</agent-delegate>

**Checks:**
- [ ] API docs match code signatures
- [ ] Examples are current
- [ ] No broken internal links
- [ ] Initiative docs updated (if active initiative from `.claude/initiative.json`)

See `references/mode-docs.md` for detailed documentation audit patterns.

---

### Phase 5: Regression Detection

> **Modes**: review only (full mode)

<agent-delegate role="test runner" subagent="x-tester" model="sonnet">
  <prompt>Analyze coverage delta on changed files, identify removed tests, disabled assertions, and behavioral regression indicators</prompt>
  <context>Regression detection for x-review Phase 5</context>
</agent-delegate>

See `references/mode-regression.md` for regression checks and detailed detection patterns.

---

### Phase 6: Readiness Report

> **All modes** — synthesizes results from all prior phases.

Generate the readiness report using the template in `references/readiness-report-template.md`. The verdict determines workflow chaining (APPROVED/CHANGES REQUESTED/BLOCKED).

### Phase 6b: Enforcement Results

Collect V-* violations, determine blocking status (CRITICAL/HIGH → blocking). If blocking, verdict MUST be BLOCKED.

> See [references/enforcement-audit.md](references/enforcement-audit.md) for enforcement result format and violation severity rules.

</instructions>

## When to Load References

- **For enforcement audit checklists, violation codes, and severity classification**: See `references/enforcement-audit.md`
- **For full review mode with agent delegation matrix by phase**: See `references/mode-review.md`
- **For fast quality gate validation workflow**: See `references/mode-quick.md`
- **For deep code and security audit patterns**: See `references/mode-audit.md`
- **For documentation completeness audit patterns**: See `references/mode-docs.md`
- **For regression detection checks and coverage delta analysis**: See `references/mode-regression.md`
- **For coverage threshold rules and hard gate**: See `references/mode-coverage.md`
- **For build gate configuration and CI integration**: See `references/mode-build.md`
- **For security-focused review checklist (OWASP, injection, auth)**: See `references/mode-security.md`
- **For readiness report output template with verdict format**: See `references/readiness-report-template.md`
- **For 5-step evidence protocol and coverage hard gate**: See `references/verification-protocol.md`
- **For spec-compliance checklist and requirement tracing patterns**: See `references/mode-spec-compliance.md`

## Human-in-Loop Gates

| **Critical**: ALWAYS ASK | **High**: ASK IF ABLE | **Medium**: ASK IF UNCERTAIN | **Low**: PROCEED |

## Workflow Chaining

<chaining-instruction>

<workflow-gate type="choice" id="review-next">
  <question>Review complete. How would you like to proceed?</question>
  <header>Next step</header>
  <option key="commit" recommended="true"><label>Commit changes</label></option>
  <option key="fix"><label>Request changes</label></option>
  <option key="done"><label>Done</label></option>
</workflow-gate>

<workflow-chain on="commit" skill="git-commit" args="commit reviewed changes" />
<workflow-chain on="fix" skill="x-implement" args="{review findings and issues to address}" />
<workflow-chain on="done" action="end" />

</chaining-instruction>

## Critical Rules

1. **No BLOCK violations** — NEVER approve with unresolved CRITICAL/HIGH violations
2. **Evidence Required** — Every quality claim needs execution proof (V-TEST-07)
3. **Security First** — Security issues always CRITICAL
4. **Readiness report required** — MUST output Phase 6 report
5. **Anti-rationalization** — See `@skills/code-code-quality/references/anti-rationalization.md`

For full enforcement rules (SOLID, DRY, test coverage, documentation), see `references/enforcement-audit.md`.

## Navigation

| Previous | `/x-implement` or `/x-refactor` | Next | `/git-commit` | Shortcut | `/x-review quick` |

## Success Criteria

- [ ] All phases completed for selected mode
- [ ] Quality gates passed, code review clean, docs current
- [ ] Readiness report produced, no CRITICAL/HIGH violations
- [ ] Workflow state updated

## References

- `references/` — mode-specific guidance (review, quick, audit, security, docs, regression, coverage, build)
- `references/verification-protocol.md` — evidence protocol
- `references/enforcement-audit.md` — enforcement rules and violation codes
- `references/readiness-report-template.md` — readiness report template
- @skills/code-code-quality/ - SOLID principles, anti-rationalization
- @skills/security-secure-coding/ - Security checklist
- @skills/quality-testing/ - Testing pyramid and CI quality checks
