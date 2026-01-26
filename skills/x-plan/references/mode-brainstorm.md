# Mode: brainstorm

> **Invocation**: `/x-plan brainstorm` or `/x-plan brainstorm "topic"`
> **Legacy Command**: `/x:brainstorm`

<purpose>
Transform vague ideas into structured requirements through guided discovery. Extract requirements, identify constraints, and prioritize with Pareto focus.
</purpose>

## Behavioral Skills

This mode activates:
- `analysis` - Pareto prioritization
- `context-awareness` - Project context

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Idea structuring |
| `context7` | Reference implementations |

<instructions>

### Phase 1: Idea Capture

Start with open exploration:

```json
{
  "questions": [{
    "question": "What problem are you trying to solve?",
    "header": "Problem",
    "options": [
      {"label": "New feature", "description": "Add new functionality"},
      {"label": "Improvement", "description": "Enhance existing feature"},
      {"label": "Integration", "description": "Connect systems"},
      {"label": "Performance", "description": "Make things faster"}
    ],
    "multiSelect": false
  }]
}
```

### Phase 2: Requirements Discovery

For each idea, ask structured questions:

**Functional Requirements**:
- What should it do?
- Who will use it?
- What inputs/outputs?

**Non-Functional Requirements**:
- Performance needs?
- Security requirements?
- Scalability concerns?

**Constraints**:
- Time constraints?
- Technology constraints?
- Budget constraints?

### Phase 3: Prioritization

Use Pareto principle to prioritize:

| Priority | Criteria |
|----------|----------|
| **Must Have** | Core functionality, no workarounds |
| **Should Have** | Important but not critical |
| **Could Have** | Nice to have |
| **Won't Have** | Out of scope |

### Phase 4: Structure Output

Create structured requirements:

```markdown
## Problem Statement
{Clear description of the problem}

## Requirements

### Must Have
- [ ] Requirement 1
- [ ] Requirement 2

### Should Have
- [ ] Requirement 3

### Could Have
- [ ] Requirement 4

## Constraints
- Constraint 1
- Constraint 2

## Success Metrics
- Metric 1: Target
- Metric 2: Target
```

### Phase 5: Workflow Transition

Present next step:
```json
{
  "questions": [{
    "question": "Requirements captured. What's next?",
    "header": "Next",
    "options": [
      {"label": "/x-plan design (Recommended)", "description": "Design the solution"},
      {"label": "/x-plan", "description": "Create implementation plan"},
      {"label": "/x-implement", "description": "Start implementing"},
      {"label": "Stop", "description": "Review requirements first"}
    ],
    "multiSelect": false
  }]
}
```

</instructions>

## Brainstorming Techniques

### 5 Whys
Ask "why?" five times to find root cause.

### User Stories
"As a [user], I want to [action] so that [benefit]"

### Impact Mapping
Goal → Actors → Impacts → Deliverables

<critical_rules>

## Critical Rules

1. **No Judgement** - Capture all ideas first
2. **Ask Why** - Understand the real problem
3. **Be Specific** - Vague requirements fail
4. **Prioritize Ruthlessly** - 20% delivers 80% value

</critical_rules>

<decision_making>

## Decision Making

**Explore more when**:
- Requirements unclear
- Multiple stakeholders
- Complex domain

**Move to planning when**:
- Core requirements clear
- Priorities established
- Constraints understood

</decision_making>

## References

- @core-docs/principles/pareto-80-20.md - Pareto prioritization
- @skills/analysis/SKILL.md - Analysis patterns

<success_criteria>

## Success Criteria

- [ ] Problem clearly defined
- [ ] Requirements captured
- [ ] Priorities established
- [ ] Next step presented

</success_criteria>
