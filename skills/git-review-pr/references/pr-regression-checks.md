# PR Regression Checks — Reference

> Loaded on demand by git-review-pr Phase 3b. Tailored for PR diff context — detects regressions introduced by a pull request relative to the base branch.

## Coverage Delta Analysis

1. Run coverage on PR branch and compare against base branch
2. Flag any file where coverage decreased by >5%
3. Flag any file where line count increased but coverage stayed flat
4. Report overall coverage delta

```bash
# Coverage on PR diff (framework-agnostic patterns)
# Jest/Vitest
pnpm test -- --coverage --changedSince=origin/$BASE

# Go
go test -coverprofile=cover.out ./... && go tool cover -func=cover.out

# Python
pytest --cov --cov-report=term-missing

# Compare changed files
git diff --name-only origin/$BASE...HEAD
```

## Removed/Disabled Tests

- [ ] No test files deleted without replacement (`git diff --name-only --diff-filter=D -- "*.test.*" "*.spec.*"`)
- [ ] No `describe.skip()` or `it.skip()` added
- [ ] No `@Disabled` or `@Ignore` annotations added
- [ ] No commented-out test blocks
- [ ] No assertions removed from existing tests (`git diff origin/$BASE...HEAD -- "*.test.*" | grep "^-.*expect\|^-.*assert"`)

## Behavioral Regression Indicators

- [ ] No public API signatures changed without test updates
- [ ] No error handling paths removed
- [ ] No validation rules weakened
- [ ] No default values changed without tests
- [ ] No environment-dependent behavior introduced

## Performance Regression Signals

- [ ] No O(n^2) patterns introduced where O(n) existed
- [ ] No synchronous I/O replacing async
- [ ] No unbounded loops or recursion added
- [ ] No missing pagination on data queries

## Severity Classification

| Finding | Severity | Action |
|---------|----------|--------|
| Coverage decreased >10% | HIGH | BLOCK |
| Coverage decreased 5-10% | MEDIUM | WARN |
| Test removed without replacement | CRITICAL | BLOCK |
| Test disabled (skip/ignore) | HIGH | BLOCK unless justified |
| Assertion removed | CRITICAL | BLOCK |
| Public API change without test | HIGH | BLOCK |

## Agent Delegation

| Role | Agent | Model |
|------|-------|-------|
| Test runner | x-tester | sonnet |
| Codebase explorer | x-explorer | haiku |

## References

- @skills/quality-testing/ - Testing pyramid and coverage strategies
- `references/verification-protocol.md` - Evidence requirements for all test claims
