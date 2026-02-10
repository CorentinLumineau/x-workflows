# Mode: enhance

> **Invocation**: `/x-implement enhance` or `/x-implement enhance "description"`

<purpose>
Targeted code quality improvements with Pareto focus. Identify the 20% of changes that deliver 80% of value. Enhance specific code without changing behavior.
</purpose>

## Behavioral Skills

This mode activates:
- `code-quality` - Quality enforcement
- `analysis` - Pareto prioritization
- `context-awareness` - Pattern awareness

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **code reviewer** | Quality assessment | Read-only analysis |
| **codebase explorer** | Pattern discovery | Fast, read-only |
| **test runner** | Verification | Can edit and run commands |

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Prioritization decisions |

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 25%, context 25%, technical 25%, scope 15%, risk 10%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: "Better" not defined, Pareto assumptions unclear, quick-win selection ambiguous, scope boundaries undefined.

---

> **Tip**: For comprehensive holistic analysis with health scores, consider using `/x-improve` instead. This mode focuses on targeted improvements to specific code.

### Phase 1: Quality Assessment

Analyze current code quality:

Delegate to a **code reviewer** agent (read-only analysis):
> "Assess code quality and identify improvement opportunities"

Check for:
- [ ] SOLID violations
- [ ] DRY violations (duplicate code)
- [ ] KISS violations (over-complexity)
- [ ] Missing error handling
- [ ] Poor naming
- [ ] Missing documentation
- [ ] Security concerns

### Phase 2: Pareto Prioritization

Rank improvements by impact/effort:

| Impact | Effort | Priority |
|--------|--------|----------|
| High | Low | **P1 - Do First** |
| High | High | P2 - Plan carefully |
| Low | Low | P3 - Quick wins |
| Low | High | P4 - Skip |

Focus on P1 items first.

### Phase 3: Apply Improvements

For each improvement:
1. **Make change** - One improvement at a time
2. **Verify** - Tests pass, no regressions
3. **Document** - Update docs if needed

### Phase 4: Verification

Run quality gates:
```bash
pnpm test
pnpm lint
pnpm type-check
```

### Phase 5: Workflow Transition

Present next step:
```json
{
  "questions": [{
    "question": "Improvements applied. Continue?",
    "header": "Next",
    "options": [
      {"label": "/x-verify (Recommended)", "description": "Full quality gates"},
      {"label": "/x-git commit", "description": "Commit improvements"},
      {"label": "Stop", "description": "Review manually"}
    ],
    "multiSelect": false
  }]
}
```
</instructions>

## Improvement Categories

### Code Quality
- Extract duplicated code
- Simplify complex conditions
- Add missing error handling
- Improve variable names

### Performance
- Remove unnecessary iterations
- Add caching where beneficial
- Optimize database queries

### Security
- Validate inputs
- Sanitize outputs
- Use secure defaults

### Documentation
- Add JSDoc to public APIs
- Update README for changes
- Add inline comments for complex logic

<critical_rules>
1. **Pareto Focus** - 20% effort, 80% value
2. **No Behavior Change** - Preserve existing functionality
3. **Verify Always** - Tests must pass
4. **Incremental** - One improvement at a time
</critical_rules>

<decision_making>
**Improve autonomously when**:
- Clear improvement opportunity
- Low risk change
- Tests provide coverage

**Use AskUserQuestion when**:
- Multiple improvement options
- Trade-off decisions
- Potentially breaking changes
</decision_making>

## References

- @skills/meta-analysis/ - Pareto 80/20 principle
- @skills/code-code-quality/ - SOLID, DRY, KISS principles

<success_criteria>
- [ ] Quality issues identified
- [ ] P1 improvements applied
- [ ] Tests passing
- [ ] No behavior changes
- [ ] Workflow transition presented
</success_criteria>
