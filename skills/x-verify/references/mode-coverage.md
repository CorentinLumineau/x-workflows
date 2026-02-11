# Mode: coverage

> **Invocation**: `/x-verify coverage` or `/x-verify coverage "description"`
> **Legacy Command**: `/x:improve-coverage`

## Purpose

<purpose>
Test coverage improvement using Pareto prioritization. Analyze coverage gaps, identify high-impact areas, and write tests to improve coverage systematically.
</purpose>

## Behavioral Skills

This mode activates:
- `testing` - Testing pyramid enforcement
- `analysis` - Pareto prioritization
- `code-quality` - Quality targets

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **test runner** | Test writing, coverage analysis | Can edit and run commands |
| **codebase explorer** | Pattern discovery | Fast, read-only |

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Prioritization decisions |

## Instructions

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 25%, context 20%, technical 30%, scope 15%, risk 10%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Coverage threshold undefined, target scope unclear.

---

### Phase 1: Coverage Analysis

Generate current coverage report:
```bash
pnpm test -- --coverage
```

Analyze:
- Overall coverage percentage
- Per-file coverage
- Uncovered lines/branches

### Phase 2: Gap Identification

Identify coverage gaps with Pareto focus:

| Priority | Criteria |
|----------|----------|
| **P1** | Critical paths (auth, payments, data) with <80% coverage |
| **P2** | Public APIs with <90% coverage |
| **P3** | Utility functions with <95% coverage |
| **P4** | Edge cases, error paths |

### Phase 3: Test Planning

For each gap, plan tests following the testing pyramid (70/20/10):

> **Canonical source**: See `@quality-testing` skill for detailed testing pyramid definitions.
> Quick reference: 70% unit (pure functions), 20% integration (APIs), 10% E2E (user flows).

### Phase 4: Test Implementation

Delegate to a **test runner** agent (can edit and run commands):
> "Write tests to cover {gap} following testing pyramid"

For each test:
1. Write test (following TDD)
2. Verify it fails initially (red)
3. Ensure implementation passes (green)
4. Check coverage increased

### Phase 5: Coverage Verification

Re-run coverage:
```bash
pnpm test -- --coverage
```

Verify:
- [ ] Target coverage met (95%+)
- [ ] All new tests passing
- [ ] No regression in existing tests

### Phase 6: Workflow Transition

Present next step:
```json
{
  "questions": [{
    "question": "Coverage improved to {new_coverage}% (from {old_coverage}%). Continue?",
    "header": "Next",
    "options": [
      {"label": "/x-verify (Recommended)", "description": "Full quality gates"},
      {"label": "/x-commit", "description": "Commit tests"},
      {"label": "Continue improving", "description": "Add more tests"}
    ],
    "multiSelect": false
  }]
}
```

## Coverage Targets

| Category | Target |
|----------|--------|
| Overall | 95%+ |
| Critical paths | 100% |
| Public APIs | 95%+ |
| Utilities | 90%+ |

## Test Patterns

### Unit Test Pattern
```typescript
describe('functionName', () => {
  it('should handle normal case', () => {
    expect(fn(input)).toBe(expected);
  });

  it('should handle edge case', () => {
    expect(fn(edgeInput)).toBe(edgeExpected);
  });

  it('should throw on invalid input', () => {
    expect(() => fn(invalid)).toThrow();
  });
});
```

### Integration Test Pattern
```typescript
describe('API endpoint', () => {
  it('should return expected response', async () => {
    const response = await request(app).get('/endpoint');
    expect(response.status).toBe(200);
  });
});
```


</instructions>

## Critical Rules

<critical_rules>
1. **Pareto Focus** - High-impact gaps first
2. **Pyramid Distribution** - 70/20/10 ratio
3. **TDD Approach** - Red → green → refactor
4. **Use Test Utils** - Shared utilities from tests/utils/
</critical_rules>

## Decision Making

<decision_making>
**Write tests autonomously when**:
- Clear gap identified
- Pattern exists to follow
- Pure function testing

**Use AskUserQuestion when**:
- Multiple test approaches
- Mock vs real dependency decision
- Coverage vs maintenance trade-off
</decision_making>

## References

- @skills/quality-testing/ - Testing pyramid, coverage strategies, and TDD methodology

## Success Criteria

<success_criteria>
- [ ] Coverage gaps identified
- [ ] P1 gaps addressed
- [ ] Target coverage met
- [ ] All tests passing
- [ ] Pyramid distribution maintained
</success_criteria>
