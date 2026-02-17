# Mode Reference: Regression Detection

> Used by x-review Phase 5 in full review mode.

## Purpose

<purpose>
Detect regressions introduced by code changes. Compare coverage deltas, identify removed tests, check for disabled assertions, and verify no existing functionality was broken.
</purpose>

## Regression Detection Checklist

### Coverage Delta Analysis
1. Run coverage before and after (or compare against baseline)
2. Flag any file where coverage decreased by >5%
3. Flag any file where line count increased but coverage stayed flat
4. Report overall coverage delta

### Removed/Disabled Tests
- [ ] No test files deleted without replacement
- [ ] No `describe.skip()` or `it.skip()` added
- [ ] No `@Disabled` or `@Ignore` annotations added
- [ ] No commented-out test blocks
- [ ] No assertions removed from existing tests

### Behavioral Regression Indicators
- [ ] No public API signatures changed without test updates
- [ ] No error handling paths removed
- [ ] No validation rules weakened
- [ ] No default values changed without tests
- [ ] No environment-dependent behavior introduced

### Performance Regression Signals
- [ ] No O(n²) patterns introduced where O(n) existed
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

## Detection Commands

```bash
# Coverage delta (if baseline exists)
pnpm test -- --coverage --changedSince=main

# Find skipped tests
grep -rn "\.skip\|@Disabled\|@Ignore\|xit\|xdescribe" tests/ src/

# Find removed test files
git diff --name-only --diff-filter=D -- "*.test.*" "*.spec.*"

# Find removed assertions
git diff main -- "*.test.*" | grep "^-.*expect\|^-.*assert"
```

## Integration with x-review

Phase 5 (Regression Detection) runs AFTER Phase 3 (Code Review):
- Uses Phase 1 scoping data to know which files changed
- Delegates to x-tester (sonnet) for coverage analysis
- Results feed into Phase 6 readiness report

## References

- @skills/quality-testing/ - Testing pyramid and coverage strategies
- `references/verification-protocol.md` - Evidence requirements
