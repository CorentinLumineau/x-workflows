# Mode: audit

> **Invocation**: `/x-review audit` or `/x-review audit "scope"`
> **Legacy Command**: `/x:best-practices`

<purpose>
Systematic audit of codebase adherence to SOLID, DRY, KISS, and YAGNI principles. Comprehensive best practices assessment.
</purpose>

## Behavioral Skills

This mode activates:
- `code-quality` - Quality enforcement
- `analysis` - Pareto prioritization

## Agents

| Agent | When | Model |
|-------|------|-------|
| `ccsetup:x-reviewer` | Quality assessment | sonnet |
| `ccsetup:x-explorer` | Pattern analysis | haiku |

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Principle analysis |

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 20%, context 30%, technical 25%, scope 15%, risk 10%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Audit scope undefined, compliance requirements unclear.

---

## Instructions

### Phase 1: Scope Definition

Determine audit scope:

| Scope | Target |
|-------|--------|
| File | Single file |
| Module | Directory |
| Feature | Related code |
| Full | Entire codebase |

### Phase 2: SOLID Audit

For each principle:

#### Single Responsibility (S)
- Does each class/function have one reason to change?
- Check: File size, method count, responsibility mixing

#### Open/Closed (O)
- Can behavior be extended without modification?
- Check: Use of abstractions, plugin patterns

#### Liskov Substitution (L)
- Are subtypes truly substitutable?
- Check: Interface implementations, inheritance

#### Interface Segregation (I)
- Are interfaces specific and focused?
- Check: Interface size, unused methods

#### Dependency Inversion (D)
- Do high-level modules depend on abstractions?
- Check: Direct dependencies, injection patterns

### Phase 3: Quality Principles Audit

#### DRY (Don't Repeat Yourself)
- Check for duplicated code
- Look for copy-paste patterns
- Identify extraction opportunities

#### KISS (Keep It Simple, Stupid)
- Identify over-engineered code
- Find unnecessary abstractions
- Check for premature optimization

#### YAGNI (You Aren't Gonna Need It)
- Find unused code
- Identify speculative features
- Check for over-generalization

### Phase 4: Generate Audit Report

```markdown
## Best Practices Audit Report

**Scope**: {scope}
**Date**: {date}

### SOLID Compliance

| Principle | Score | Issues | Notes |
|-----------|-------|--------|-------|
| Single Responsibility | {0-100}% | {count} | {notes} |
| Open/Closed | {0-100}% | {count} | {notes} |
| Liskov Substitution | {0-100}% | {count} | {notes} |
| Interface Segregation | {0-100}% | {count} | {notes} |
| Dependency Inversion | {0-100}% | {count} | {notes} |

**Overall SOLID Score**: {average}%

### Quality Principles

| Principle | Score | Issues |
|-----------|-------|--------|
| DRY | {0-100}% | {count} |
| KISS | {0-100}% | {count} |
| YAGNI | {0-100}% | {count} |

### Top Issues (Pareto)

1. **{Issue}**: {description}
   - Files affected: {count}
   - Impact: {high/medium/low}
   - Fix: {recommendation}

### Recommendations

#### Quick Wins
- {Recommendation with low effort, high impact}

#### Planned Improvements
- {Recommendation with medium effort}
```

### Phase 5: Workflow Transition

```json
{
  "questions": [{
    "question": "Audit complete. SOLID score: {score}%. Continue?",
    "header": "Next",
    "options": [
      {"label": "/x-review improve (Recommended)", "description": "Fix top issues"},
      {"label": "/x-implement refactor", "description": "Refactor code"},
      {"label": "Stop", "description": "Review report first"}
    ],
    "multiSelect": false
  }]
}
```

</instructions>

## Scoring Guidelines

| Score | Rating |
|-------|--------|
| 90-100% | Excellent |
| 75-89% | Good |
| 60-74% | Fair |
| <60% | Needs improvement |

<critical_rules>

## Critical Rules

1. **Be Specific** - Point to exact violations
2. **Prioritize** - Focus on high-impact issues
3. **Recommend** - Provide actionable fixes
4. **Context Matters** - Not all violations need fixing

</critical_rules>

## References

- @core-docs/PRINCIPLES.md - SOLID, DRY, KISS, YAGNI details
- @skills/code-quality/SKILL.md - Quality enforcement

<success_criteria>

## Success Criteria

- [ ] Scope analyzed
- [ ] All principles checked
- [ ] Report generated
- [ ] Recommendations provided

</success_criteria>
