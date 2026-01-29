# Mode: design

> **Invocation**: `/x-plan design` or `/x-plan design "description"`
> **Legacy Command**: `/x:design`

<purpose>
Technical architecture and system design with SOLID validation. Create design documents that guide implementation.
</purpose>

## Behavioral Skills

This mode activates:
- `code-quality` - SOLID principles
- `analysis` - Trade-off analysis
- `context-awareness` - Existing patterns

## Agents

| Agent | When | Model |
|-------|------|-------|
| `ccsetup:x-explorer` | Pattern discovery | haiku |

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Architecture decisions |
| `context7` | Reference implementations |

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 20%, context 15%, technical 40%, scope 10%, risk 15%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Multiple architectural approaches, unknown technical constraints, breaking change potential.

---

### Phase 1: Requirements Review

Review requirements (from brainstorm or direct input):
- Functional requirements
- Non-functional requirements
- Constraints

### Phase 2: Architecture Discovery

Use x-explorer to find existing patterns:

```
Task(
  subagent_type: "ccsetup:x-explorer",
  model: "haiku",
  prompt: "Find architecture patterns in codebase"
)
```

Discover:
- Existing architecture layers
- Design patterns in use
- Integration patterns
- Data flow patterns

### Phase 3: Design Creation

Create design document:

```markdown
# Design: {Feature Name}

## Overview
{High-level description}

## Architecture

### Component Diagram
```
[Component A] → [Component B] → [Component C]
```

### Data Flow
1. Input received at {entry point}
2. Processed by {service}
3. Stored in {storage}
4. Response returned

## Components

### Component A
- **Responsibility**: {SRP description}
- **Interface**: {Public API}
- **Dependencies**: {What it depends on}

### Component B
...

## SOLID Validation

- [ ] **Single Responsibility**: Each component has one reason to change
- [ ] **Open/Closed**: Extensible without modification
- [ ] **Liskov Substitution**: Subtypes are substitutable
- [ ] **Interface Segregation**: Specific interfaces
- [ ] **Dependency Inversion**: Depend on abstractions

## Trade-offs

| Decision | Option A | Option B | Choice |
|----------|----------|----------|--------|
| {Decision 1} | {Pros/Cons} | {Pros/Cons} | {Choice + Why} |

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| {Risk 1} | {High/Med/Low} | {Strategy} |

## Implementation Order

1. {First component} - Foundation
2. {Second component} - Depends on first
3. {Third component} - Integration
```

### Phase 4: SOLID Validation

Validate design against SOLID:

| Principle | Check | Status |
|-----------|-------|--------|
| **S**ingle Responsibility | Each component has one job | ✓/✗ |
| **O**pen/Closed | Can extend without modifying | ✓/✗ |
| **L**iskov Substitution | Subtypes work | ✓/✗ |
| **I**nterface Segregation | No fat interfaces | ✓/✗ |
| **D**ependency Inversion | Abstractions, not concretions | ✓/✗ |

### Phase 5: Workflow Transition

Present next step:
```json
{
  "questions": [{
    "question": "Design complete. Ready to implement?",
    "header": "Next",
    "options": [
      {"label": "/x-implement (Recommended)", "description": "Start implementation"},
      {"label": "/x-plan", "description": "Create detailed plan"},
      {"label": "Stop", "description": "Review design first"}
    ],
    "multiSelect": false
  }]
}
```

</instructions>

## Design Patterns Reference

| Pattern | Use When |
|---------|----------|
| Repository | Data access abstraction |
| Factory | Complex object creation |
| Strategy | Interchangeable algorithms |
| Observer | Event-driven communication |
| Adapter | Interface compatibility |

<critical_rules>

## Critical Rules

1. **Follow Existing Patterns** - Don't introduce new patterns unnecessarily
2. **SOLID Required** - All five principles
3. **Document Trade-offs** - Why this choice
4. **Consider Scale** - Design for expected load

</critical_rules>

<decision_making>

## Decision Making

**Design autonomously when**:
- Clear requirements
- Existing patterns apply
- Standard architecture

**Use AskUserQuestion when**:
- Multiple valid approaches
- Significant trade-offs
- New patterns needed

</decision_making>

## References

- @skills/code-code-quality/ - SOLID principles
- @skills/code-design-patterns/ - Design patterns

<success_criteria>

## Success Criteria

- [ ] Architecture defined
- [ ] Components identified
- [ ] SOLID validated
- [ ] Trade-offs documented
- [ ] Implementation order clear

</success_criteria>
