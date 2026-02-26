# Review Delegation Reference

> This reference documents the delegation strategy used in x-review phases 2 and 3b.

## Phase 2: Parallel Quality Gate Verification

When the project has multiple test suites, Phase 2 uses concurrent parallel delegation:
- **Test runner** (x-tester, sonnet): Full test suite with coverage analysis
- **Fast tester** (x-tester-fast, haiku): Lint, type-check, and build gates

Both agents run concurrently. Results are merged before proceeding.

## Phase 3b: Team Code Review

When changeset spans 5+ files or touches multiple domains (auth, API, UI, infra):

- **Lead** (code reviewer, sonnet): Coordinates quality review
- **Teammate** (security reviewer, x-security-reviewer, sonnet): Reviews OWASP Top 10, input validation, auth flows, data exposure risks

Activation: coordinated review with shared state when domain breadth warrants it.

## Phase 3b: Parallel Code Review (fallback when teams unavailable)

Two agents run concurrently:
- **Code reviewer** (x-reviewer, sonnet): SOLID violations, DRY, complexity, test coverage
- **Security reviewer** (x-security-reviewer, sonnet): OWASP Top 10, input validation, auth, data exposure

Results are merged in Phase 6 Readiness Report.
