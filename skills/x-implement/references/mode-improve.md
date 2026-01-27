# Mode: improve

> **Invocation**: `/x-implement improve` or `/x-implement improve "description"`
> **Legacy Command**: `/x:improve`

<purpose>
Code quality improvements with Pareto focus. Identify the 20% of changes that deliver 80% of value. Enhance existing code without changing behavior.
</purpose>

## Behavioral Skills

This mode activates:
- `code-quality` - Quality enforcement
- `analysis` - Pareto prioritization
- `context-awareness` - Pattern awareness

## Agents

| Agent | When | Model |
|-------|------|-------|
| `ccsetup:x-reviewer` | Quality assessment | sonnet |
| `ccsetup:x-explorer` | Pattern discovery | haiku |
| `ccsetup:x-tester` | Verification | haiku |

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

```
Task(
  subagent_type: "ccsetup:x-reviewer",
  model: "sonnet",
  prompt: "Assess code quality and identify improvement opportunities"
)
```

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

- @core-docs/principles/pareto-80-20.md - Pareto principle
- @core-docs/principles/solid.md - SOLID principles
- @core-docs/principles/dry-kiss-yagni.md - Code quality

<success_criteria>
- [ ] Quality issues identified
- [ ] P1 improvements applied
- [ ] Tests passing
- [ ] No behavior changes
- [ ] Workflow transition presented
</success_criteria>
