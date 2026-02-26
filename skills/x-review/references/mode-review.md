# Mode: review

> **Invocation**: `/x-review` or `/x-review review`
> **Legacy Command**: `/x:review`

<purpose>
Full readiness assessment — the default mode. Runs all 8 phases: change scoping, quality gates, code review (spec compliance + parallel code/security audit), documentation audit, regression detection, and readiness synthesis.
</purpose>

## Phases (from x-review)

Review mode runs ALL phases: **0 → 1 → 2 → 3 → 4 → 5 → 6 → 7**

| Phase | Name | Key Actions |
|-------|------|------------|
| 0 | Confidence + State | Interview gate, workflow state check |
| 1 | **Change Scoping** | git diff analysis, domain categorization, initiative detection |
| 2 | Quality Gates | Lint, type-check, tests, build with evidence protocol |
| 3a | Spec Compliance | Compare implementation against plan/issue/request (BLOCKING) |
| 3b | Parallel Code + Security Review | SOLID/security/pattern audit via dual agents |
| 4 | Documentation Audit | API docs, README, initiative docs |
| 5 | Regression Detection | Coverage delta, removed/disabled tests |
| 6 | Readiness Report | Pass/warn/block synthesis with findings |
| 7 | Workflow State | State update, auto-chain to git-commit |

## Phase 1 Scope-Awareness

Phase 1 output informs all subsequent phases:
- **Phase 2**: Knows which test suites are relevant
- **Phase 3**: Knows which domains need security review
- **Phase 4**: Knows which docs may need updating
- **Phase 5**: Knows baseline for coverage comparison

## Behavioral Skills

This mode activates:
- `code-quality` - Quality enforcement
- `secure-coding` - Security review
- `git-workflow` - Branch management

## Agent Delegation

### Per-Phase Delegation Matrix

| Phase | Role | Agent | Model | When |
|-------|------|-------|-------|------|
| 1 | Codebase explorer | x-explorer | haiku | Change scoping |
| 2 | Fast test runner | x-tester-fast | haiku | Initial gate run |
| 2 | Test runner (escalation) | x-tester | sonnet | Persistent failures (>3) |
| 3b | Code reviewer | x-reviewer | sonnet | **Always** (parallel with security) |
| 3b | Security reviewer | x-security-reviewer | sonnet | **Always** (parallel with code) |
| 4 | Codebase explorer | x-explorer | haiku | Doc link checking |
| 5 | Regression detector | x-tester | sonnet | Coverage analysis |

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Complex review decisions |

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 20%, context 25%, technical 30%, scope 15%, risk 10%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Review focus unclear, severity classification ambiguous, standards reference missing.

---

### Phase 1: Change Scoping

Detect review context and scope all changes:

```bash
# Get current branch and target
CURRENT_BRANCH=$(git branch --show-current)
TARGET_BRANCH=$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null || echo "main")

# Get changed files with stats
git diff --name-only --stat $TARGET_BRANCH...HEAD

# Detect active initiative
cat .claude/initiative.json 2>/dev/null || echo "No active initiative"
```

<agent-delegate role="codebase explorer" subagent="x-explorer" model="haiku">
  <prompt>Analyze git diff (`git diff $TARGET_BRANCH...HEAD`). Categorize each changed file as: production code, test code, documentation, configuration, or infrastructure. Report file count per category and identify the primary change area. List all new public API surfaces.</prompt>
  <context>Phase 1 change scoping for x-review readiness assessment</context>
</agent-delegate>

**Output** — scope summary used by subsequent phases:
- File count and categories (code, test, docs, config)
- Lines added/removed
- Domains affected (auth, API, UI, infra, etc.)
- Active initiative (if any)
- Estimated complexity: LOW (<5 files) | MEDIUM (5-15) | HIGH (>15)

---

### Phase 2: Quality Gates

Check for merge conflicts first:

```bash
git fetch origin
git merge-base HEAD origin/$TARGET_BRANCH
```

If conflicts exist, report and suggest resolution.

Execute all quality gates with **mandatory evidence protocol**:

<agent-delegate role="test runner" subagent="x-tester-fast" model="haiku">
  <prompt>Run full quality gates: lint, type-check, test, build — report pass/fail with evidence for each gate. Use the 5-step verification sequence (IDENTIFY, RUN, READ, VERIFY, CLAIM) for every gate.</prompt>
  <context>APEX workflow examine phase — running all quality gates with evidence protocol</context>
  <escalate to="x-tester" model="sonnet" trigger="persistent test failures (>3), flaky test patterns, or coverage analysis needed" />
</agent-delegate>

#### Verification Evidence Protocol — MANDATORY

**This sub-phase CANNOT be skipped.** Every quality claim MUST have execution evidence following the 5-step sequence (IDENTIFY, RUN, READ, VERIFY, CLAIM). Predictions are not verifications.

For the full protocol, coverage thresholds, and coverage hard gate, see `references/verification-protocol.md`.

#### Handle Failures — READ-ONLY REPORTING

**x-review NEVER modifies code.** When a gate fails, report the failure with actionable detail.

If any gate fails:

```
Gate Failure Detected → Analyze Root Cause → Report with Detailed Fix Suggestions
```

For each failure, provide:
1. **Gate name** and exact error output
2. **Root cause analysis** — what went wrong and why
3. **Suggested fix** — specific code changes, commands, or config edits the user should apply
4. **File and line** — exact location(s) to change

**NEVER run fix commands** (`pnpm lint --fix`, `pnpm prettier --write`, etc.). Only suggest them.

---

### Phase 3a: Spec Compliance Review — BLOCKING

> **This sub-phase runs FIRST. Code quality review (Phase 3b) ONLY runs after spec compliance passes.**

Identify the spec source (in priority order):
1. Plan from `/x-plan` (check `.claude/plan.md` or recent plan output)
2. Issue from `/git-implement-issue` (check branch name for issue number, then fetch from forge)
3. User request (original task description)

**4-Point Spec Compliance Checklist**:
1. [ ] All requirements from spec are implemented in the diff
2. [ ] No scope creep — changes are limited to what the spec describes
3. [ ] Edge cases mentioned in the spec are handled
4. [ ] If spec specifies constraints (performance, compatibility), they are met

Flag unmet criteria as spec violations. See `references/enforcement-audit.md` for severity classification:
- Scope creep: MEDIUM (HIGH if security risk)
- Missing requirement: HIGH (BLOCK)
- Wrong requirement implemented: CRITICAL (BLOCK)

**If spec compliance FAILS → BLOCK.** Return to `/x-implement` with spec violation details. Do NOT proceed to Phase 3b.

---

### Phase 3b: Parallel Code and Security Review

> **Only runs AFTER Phase 3a passes.**

**ALWAYS run both reviewers concurrently**, regardless of changeset size:

<parallel-delegate strategy="concurrent">
  <agent role="code quality reviewer" subagent="x-reviewer" model="sonnet">
    <prompt>Review all changed files for design patterns, SOLID principles, maintainability, readability, performance concerns, test coverage gaps, and documentation completeness. Scope: `git diff $TARGET_BRANCH...HEAD`. Output structured findings with severity (Critical/Warning/Suggestion). **MANDATORY: Include V-code IDs for all quality findings** (V-SOLID-01 through V-SOLID-05, V-DRY-01 through V-DRY-03, V-KISS-01/02, V-YAGNI-01/02, V-PAT-01 through V-PAT-04, V-TEST-*, V-DOC-*). See enforcement-audit.md for V-code definitions.</prompt>
    <context>Code quality review — SOLID, DRY, performance, test coverage, documentation</context>
  </agent>
  <agent role="security reviewer" subagent="x-security-reviewer" model="sonnet">
    <prompt>Review all changed files for OWASP Top 10 vulnerabilities, authentication/authorization flaws, input validation issues, secrets exposure (hardcoded credentials, API keys), and dependency vulnerabilities. Scope: `git diff $TARGET_BRANCH...HEAD`. Output structured security findings with CVE references where applicable. **MANDATORY: Include OWASP category IDs (A01-A10) for all security findings.**</prompt>
    <context>Security review — OWASP, auth, input validation, secrets, dependencies</context>
  </agent>
</parallel-delegate>

**Aggregate findings**:
- Merge findings from both reviewers
- Deduplicate overlapping issues
- Sort by severity: Critical → Warning → Suggestion
- Tag each finding with source (code-quality / security) and V-code/OWASP ID

> **Enforcement reference**: See `references/enforcement-audit.md` for V-code definitions, audit checklists, and severity classification.

---

### Phase 4: Documentation Audit

Check documentation sync with code changes. Uses Phase 1 scoping data.

<agent-delegate role="codebase explorer" subagent="x-explorer" model="haiku">
  <prompt>Check that API docs match code signatures, examples are current, no broken internal links, and initiative docs are updated if active. Flag missing documentation as V-DOC violations.</prompt>
  <context>Documentation audit for x-review readiness assessment</context>
</agent-delegate>

**Checks:**
- [ ] New public APIs have JSDoc/docstrings (V-DOC-01: HIGH)
- [ ] API docs match code signatures (V-DOC-02: CRITICAL)
- [ ] Examples are current (V-DOC-03: MEDIUM)
- [ ] No broken internal links (V-DOC-04: HIGH)
- [ ] README updated if user-facing behavior changed
- [ ] CHANGELOG entry exists for user-visible changes
- [ ] Initiative docs updated (if active initiative from `.claude/initiative.json`)

See `references/mode-docs.md` for detailed documentation audit patterns.

---

### Phase 5: Regression Detection

<agent-delegate role="regression detector" subagent="x-tester" model="sonnet">
  <prompt>Analyze changes for regressions: coverage delta vs base branch, removed/disabled tests, removed assertions, weakened validation, API signature changes without test updates. Scope: `git diff $TARGET_BRANCH...HEAD`. Report findings with severity classification.</prompt>
  <context>Regression detection for x-review Phase 5</context>
</agent-delegate>

**Regression checks:**
- Coverage delta: measure % change on modified files
- Removed tests: count and list deleted test files/functions
- Disabled tests: detect `skip`, `xit`, `xdescribe`, `@pytest.mark.skip` patterns
- Weakened assertions: detect removed `assert`/`expect` calls
- Behavioral changes: API signature modifications without corresponding test updates

See `references/mode-regression.md` for full detection criteria and severity.

---

### Phase 6: Readiness Report

> **All modes** — synthesizes results from all prior phases.

**STOP — Review Approval Hard Gate**: Before generating the verdict, verify all violations against `references/enforcement-audit.md` hard gate checklist:

- [ ] Zero CRITICAL violations
- [ ] Zero HIGH violations without documented user-approved exception
- [ ] All MEDIUM violations flagged in readiness report
- [ ] All test findings backed by execution evidence (see `references/verification-protocol.md`)

**Common Rationalizations** (if you're thinking any of these, STOP):

| Excuse | Reality |
|--------|---------|
| "Overall the code looks good" | Review is checklist-driven, not impression-driven. Run the checklist. |
| "These issues are cosmetic" | Check the severity table. CRITICAL/HIGH are never cosmetic. |
| "The user seems in a hurry" | Quality gates protect users from their own urgency. Hold the line. |
| "It's just a small change" | Small changes with CRITICAL violations are still CRITICAL. |
| "The tests pass so it's fine" | Passing tests don't prove absence of SOLID/DRY/security violations. |

Generate the readiness report using `references/readiness-report-template.md`. The verdict determines workflow chaining:
- APPROVED → chain to `/git-commit`
- CHANGES REQUESTED → chain to `/x-implement`
- BLOCKED → require fix before proceeding

See `@skills/code-code-quality/references/anti-rationalization.md` for the full excuse/reality reference.

---

### Phase 7: Workflow Transition

Present next step based on review verdict.

</instructions>

<critical_rules>

## Critical Rules

1. **Evidence Required** — Every quality claim needs execution proof (V-TEST-07 CRITICAL)
2. **V-codes Mandatory** — Every finding MUST include V-code or OWASP ID. Findings without IDs are incomplete and must be revised.
3. **Security Always Parallel** — Security reviewer ALWAYS runs alongside code reviewer, never skipped
4. **No BLOCK violations** — NEVER approve with unresolved CRITICAL/HIGH violations
5. **Spec compliance first** — Phase 3a BLOCKS Phase 3b; no code review without spec check
6. **Anti-rationalization** — See `@skills/code-code-quality/references/anti-rationalization.md`

</critical_rules>

<decision_making>

## Decision Making

**Approve when**:
- Zero CRITICAL violations
- Zero HIGH violations (or all with documented user exception)
- All MEDIUM violations flagged in report
- Tests pass with evidence
- Coverage >= 80% on changed files (measured)

**Request changes when**:
- HIGH violations without user exception
- Missing tests for critical paths (V-TEST-01)
- Security issues found (any OWASP A01-A10)
- Breaking changes undocumented

**Block when**:
- CRITICAL violations found (V-SOLID-01, V-SOLID-03, V-TEST-01, V-TEST-05, V-TEST-06, V-DOC-02, V-PAT-01)
- Wrong requirement implemented
- Spec compliance fails with CRITICAL severity

</decision_making>

## References

- @core-docs/PRINCIPLES_ENFORCEMENT.md - SOLID principles
- @skills/security-secure-coding/ - Security checklist
- @skills/code-code-quality/ - Quality standards and anti-rationalization
- `references/enforcement-audit.md` - V-code definitions, audit checklists, hard gate
- `references/verification-protocol.md` - 5-step evidence protocol
- `references/mode-regression.md` - Regression detection patterns
- `references/mode-docs.md` - Documentation audit patterns

<success_criteria>

## Success Criteria

- [ ] Branch context detected and changes scoped (Phase 1)
- [ ] All quality gates passed with execution evidence (Phase 2)
- [ ] Spec compliance verified against plan/issue/request (Phase 3a)
- [ ] Parallel code + security review completed with V-code/OWASP IDs (Phase 3b)
- [ ] Documentation audit completed (Phase 4)
- [ ] Regression detection completed (Phase 5)
- [ ] Readiness report generated with findings and verdict (Phase 6)
- [ ] No CRITICAL/HIGH violations in final verdict
- [ ] Next step presented to user (Phase 7)

</success_criteria>
