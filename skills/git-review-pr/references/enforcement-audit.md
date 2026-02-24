# Enforcement Audit Reference (PR Context)

> Adapted from x-review's enforcement audit for forge PR review context. Loaded on demand by git-review-pr Phase 2b and Phase 4b. Contains spec violation severity, audit checklists, severity classification, and the review approval hard gate.

## Spec Violation Severity

| Violation | Severity | Action |
|-----------|----------|--------|
| Scope creep (extra code not in requirements) | MEDIUM | WARN (HIGH if security risk) |
| Missing requirement (functional gap) | HIGH | BLOCK |
| Wrong requirement implemented | CRITICAL | BLOCK |

## Code Quality Audit Checklists

For each changed file in the PR diff, audit against enforcement violation definitions:

### SOLID Audit (BLOCKING)

- [ ] SRP (V-SOLID-01: CRITICAL -> BLOCK)
- [ ] OCP (V-SOLID-02: HIGH -> BLOCK)
- [ ] LSP (V-SOLID-03: CRITICAL -> BLOCK)
- [ ] ISP (V-SOLID-04: HIGH -> BLOCK)
- [ ] DIP (V-SOLID-05: HIGH -> BLOCK)

### DRY Audit (BLOCKING)

- [ ] No >10 line duplication (V-DRY-01: HIGH -> BLOCK)
- [ ] Flag 3-10 line duplication (V-DRY-02: MEDIUM -> WARN)
- [ ] No repeated magic values (V-DRY-03: MEDIUM -> WARN)

### Design Pattern Review

- [ ] No God Objects (V-PAT-01: CRITICAL -> BLOCK)
- [ ] No circular dependencies (V-PAT-02: HIGH -> BLOCK)
- [ ] Flag missing obvious patterns (V-PAT-03: MEDIUM -> WARN)
- [ ] No pattern misuse (V-PAT-04: HIGH -> BLOCK)

### Security Review

- [ ] Input validation
- [ ] Authentication/Authorization
- [ ] Data exposure
- [ ] OWASP Top 10

### Test Coverage

- [ ] All new code has tests (V-TEST-01: CRITICAL -> BLOCK)
- [ ] Meaningful assertions (V-TEST-05: CRITICAL -> BLOCK)
- [ ] Edge cases covered
- [ ] Integration tests if needed

### Pareto Audit

- [ ] No over-engineered solutions (V-PARETO-01: HIGH -> BLOCK)
- [ ] Check for simpler alternatives
- [ ] Flag >3x complexity for marginal improvement

## Severity Classification — STRICT

**CRITICAL (BLOCK):** V-SOLID-01, V-SOLID-03, V-TEST-01, V-TEST-05, V-TEST-06, V-DOC-02, V-PAT-01
-> MUST fix before approval. No exceptions.

**HIGH (BLOCK):** V-SOLID-02, V-SOLID-04, V-SOLID-05, V-DRY-01, V-TEST-02, V-TEST-03, V-DOC-01, V-DOC-04, V-PAT-02, V-PAT-04, V-KISS-02, V-YAGNI-01, V-PARETO-01
-> MUST fix OR escalate to user with justification.

**MEDIUM (WARN):** V-DRY-02, V-DRY-03, V-KISS-01, V-YAGNI-02, V-TEST-04, V-TEST-07, V-DOC-03, V-PAT-03, V-PARETO-02, V-PARETO-03
-> Flag to user. Document if deferring.

**LOW (INFO):** Style, minor improvements.

## STOP — Review Approval Hard Gate

> **You MUST stop here and verify violations before generating the review report.**

**Checklist** (ALL must be true to proceed):
- [ ] Zero CRITICAL violations
- [ ] Zero HIGH violations without documented user-approved exception
- [ ] All MEDIUM violations flagged in review report

**Common Rationalizations** (if you're thinking any of these, STOP):

| Excuse | Reality |
|--------|---------|
| "Overall the code looks good" | Review is checklist-driven, not impression-driven. Run the checklist. |
| "These issues are cosmetic" | Check the severity table. CRITICAL/HIGH are never cosmetic. |
| "The user seems in a hurry" | Quality gates protect users from their own urgency. Hold the line. |
| "It's just a small change" | Small changes with CRITICAL violations are still CRITICAL. |

> **Foundational principle**: Violating the letter of this gate IS violating its spirit. There is no "technically compliant" shortcut.

See `@skills/code-code-quality/references/anti-rationalization.md` for the full excuse/reality reference.
