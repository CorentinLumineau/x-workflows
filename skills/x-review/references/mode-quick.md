# Mode: quick

> **Invocation**: `/x-review quick` or `/x-review gates` or `/x-review verify`

## Purpose

<purpose>
Fast quality gate validation. Run lint, type-check, tests, and build with auto-fix loop. Integrated into x-review as the quick path for fast validation before commit.
</purpose>

## Phases (from x-review)

Quick mode runs phases: **0 → 2 → 6 → 7**

| Phase | Name | What Happens |
|-------|------|-------------|
| 0 | Confidence + State | Interview gate, workflow state check |
| 2 | Quality Gates | Lint, type-check, tests, build with evidence protocol |
| 6 | Readiness Report | Pass/warn/block synthesis |
| 7 | Workflow State | Update state, chain to next |

## Quality Gate Execution

### Gate Specifications

| Gate | Command | Pass Criteria |
|------|---------|---------------|
| Lint | `pnpm lint` | No errors |
| Types | `pnpm type-check` | No errors |
| Tests | `pnpm test` | 100% pass |
| Build | `pnpm build` | Success |

### Auto-Fix Loop

If any gate fails:
1. Attempt auto-fix (`pnpm lint --fix`, `pnpm prettier --write .`)
2. Re-run failed gate
3. If still failing: analyze with sequential-thinking, apply manual fix
4. Verify fix worked
5. Max 3 auto-fix attempts per gate

### Verification Evidence Protocol — MANDATORY

Every quality claim MUST have execution evidence. For EACH gate:

| Step | Action |
|------|--------|
| 1. IDENTIFY | Name the gate |
| 2. RUN | Execute the command |
| 3. READ | Read full output |
| 4. VERIFY | State pass/fail with evidence |
| 5. CLAIM | Only NOW make status claim |

**Prohibited**: "Tests should pass", "This probably works", any claim without output evidence → V-TEST-07 CRITICAL.

See `references/verification-protocol.md` for anti-pattern examples.

### Coverage Thresholds — BLOCKING

| Check | Threshold | Violation | Action |
|-------|-----------|-----------|--------|
| Line coverage on changed files | ≥80% | V-TEST-03 (HIGH) | BLOCK |
| Unit test ratio of new tests | ≥60% | V-TEST-04 (MEDIUM) | WARN |
| Tests have assertions | 100% | V-TEST-05 (CRITICAL) | BLOCK |
| No flaky tests | 0 flaky | V-TEST-06 (CRITICAL) | BLOCK |

## Agent Delegation

| Role | Agent | Model |
|------|-------|-------|
| Fast test runner | x-tester-fast | haiku |
| Full test runner (escalation) | x-tester | sonnet |

## Chaining

| Result | Chain To | Auto? |
|--------|----------|-------|
| All gates pass | `/git-commit` (from x-review readiness) | Yes |
| Tests fail | `/x-implement` | No (show failures) |
| Persistent failures | `/x-troubleshoot` | No (ask) |

## References

- `references/verification-protocol.md` - Evidence anti-patterns
- `references/mode-coverage.md` - Coverage improvement guide
- `references/mode-build.md` - Build system guide
- @skills/quality-testing/ - Testing pyramid
- @skills/quality-quality-gates/ - CI quality checks
