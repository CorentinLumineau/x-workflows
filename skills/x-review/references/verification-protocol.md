# Verification Evidence Protocol — Reference

> Loaded on demand by x-review quick Phase 1b. Provides anti-pattern examples and violation definitions.

## Why This Protocol Exists

LLM agents commonly claim "tests pass" without executing them. Research shows that:
- Naming the shortcut prevents it (anti-rationalization)
- Requiring step-by-step evidence doubles actual verification compliance
- Predictions ("should pass") feel correct but skip execution

This protocol ensures every quality claim is backed by execution evidence.

## Anti-Pattern Examples

### BAD: Prediction-Based Verification

```
Agent: "I've reviewed the code changes and the tests should pass
because the logic follows the same pattern as the existing tests."

→ VIOLATION: V-TEST-07 (CRITICAL)
→ Reason: Code review is not test execution. Steps 2-4 skipped.
```

### BAD: Partial Verification

```
Agent: "I ran the lint check and it passed. The tests and build
should also pass since I only changed documentation."

→ VIOLATION: V-TEST-07 (CRITICAL)
→ Reason: Only lint was verified. Tests and build are predictions.
→ "Only changed documentation" is rationalization — run the gates.
```

### BAD: Implicit Verification

```
Agent: "All quality gates pass." [no command output shown]

→ VIOLATION: V-TEST-07 (CRITICAL)
→ Reason: No evidence provided. Claim without proof.
```

### GOOD: Complete Verification

```
Gate: Lint
Command: pnpm lint
Result: PASS
Evidence: "✔ No ESLint warnings or errors"

Gate: Type Check
Command: pnpm type-check
Result: PASS
Evidence: "Found 0 errors in 47 files"

Gate: Tests
Command: pnpm test
Result: PASS
Evidence: "Tests: 82 passed, 82 total — Time: 3.2s"

Gate: Build
Command: pnpm build
Result: PASS
Evidence: "Build completed in 4.1s — output: dist/"
```

### GOOD: Honest Failure Reporting

```
Gate: Tests
Command: pnpm test
Result: FAIL
Evidence: "Tests: 80 passed, 2 failed — FAIL transform-skills.test.js >
marker compilation > should handle parallel-delegate"

→ Correct: Actual execution, actual output, actual failure reported.
→ Next: Proceed to Phase 2 (Handle Failures).
```

## Evidence Format Template

Use this format for each gate:

```
Gate: {gate name}
Command: {exact command executed}
Result: {PASS | FAIL}
Evidence: {quoted output — key summary line}
```

When a gate has no standard command (e.g., custom project):
1. IDENTIFY — Name what you're checking
2. RUN — Execute the closest available command
3. READ — Read the output completely
4. VERIFY — State what the output shows
5. CLAIM — Make your status claim

## V-TEST Violation Definitions

| ID | Severity | Description |
|----|----------|-------------|
| V-TEST-01 | CRITICAL | No tests exist for new production code |
| V-TEST-02 | CRITICAL | Production code written before tests (TDD violation) |
| V-TEST-03 | HIGH | Line coverage below 80% on changed files |
| V-TEST-04 | MEDIUM | Unit test ratio below 60% of new tests |
| V-TEST-05 | CRITICAL | Tests without assertions (false confidence) |
| V-TEST-06 | CRITICAL | Flaky tests detected |
| V-TEST-07 | CRITICAL | Quality claim without execution evidence |

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "I only changed a comment" | Comments can break parsers, YAML, JSDoc. Run the gates. |
| "This is a documentation-only change" | Doc changes can break builds (imports, links). Run the gates. |
| "The same pattern works elsewhere" | Patterns have edge cases. Run the gates. |
| "I'll verify after the next change" | Deferred verification = skipped verification. Verify NOW. |
| "Running tests would take too long" | Skipping tests costs more than running them. Run the gates. |

## Integration with x-review Phases

```
Phase 1: Run Quality Gates (execute commands)
    ↓
Phase 1b: Verification Evidence Protocol (THIS FILE)
    ↓ evidence collected for each gate
Phase 2: Handle Failures (if any gate failed)
    ↓
Phase 3: Coverage & Compliance (thresholds)
    ↓
Phase 4b: Enforcement Summary (report)
```

Phase 1b runs AFTER Phase 1 executes the commands, ensuring that:
1. Commands were actually executed (not just planned)
2. Output was actually read (not just assumed)
3. Pass/fail was determined from evidence (not predicted)
4. Claims match reality (not wishes)
