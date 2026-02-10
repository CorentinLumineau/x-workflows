# Mode: plan

> **Invocation**: `/x-plan` or `/x-plan plan`
> **Legacy Command**: `/x:plan`

<purpose>
Scale-adaptive implementation planning with automatic complexity detection. Routes to appropriate planning track based on estimated effort.
</purpose>

## Behavioral Skills

This mode activates:
- `analysis` - Pareto prioritization
- `context-awareness` - Project context

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **codebase explorer** | Codebase analysis | Fast, read-only |

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Complex planning decisions |
| `memory` | Cross-session persistence |

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

**Triggers for this mode**: Scope unclear, multiple valid approaches, dependencies unknown.

---

### Phase 1: Scope Assessment

Analyze the task to estimate complexity:

| Signal | Quick (1-2h) | Standard (3-8h) | Enterprise (8h+) |
|--------|--------------|-----------------|------------------|
| Files | 1-3 | 4-10 | 10+ |
| Layers | 1-2 | 2-3 | 4+ |
| Dependencies | None | Some | Many |
| Breaking changes | None | Minor | Significant |

### Phase 2: Track Selection

Based on assessment, select track:

**Quick Track** (1-2 hours):
- Inline planning
- Simple task list
- No formal document

**Standard Track** (3-8 hours):
- Story file in `milestones/_active/stories/`
- Checkpoint tracking
- Memory persistence

**Enterprise Track** (8+ hours):
- Full initiative structure
- Multiple milestones
- Cross-session tracking

### Phase 3: Plan Creation

#### Quick Track
Output simple task list:
```markdown
## Tasks
1. Task one
2. Task two
3. Task three
```

#### Standard Track
Create story file:
```markdown
# STORY-{ID}: {Title}

## Context
{Background, related files, patterns}

## Tasks
- [ ] Task 1
- [ ] Task 2

## Success Criteria
- [ ] Criterion 1
```

#### Enterprise Track
Create initiative structure using `/x-initiative create`.

### Phase 4: Workflow Transition

Present next step:
```json
{
  "questions": [{
    "question": "Plan created ({track} track). Ready to implement?",
    "header": "Next",
    "options": [
      {"label": "/x-implement (Recommended)", "description": "Start implementation"},
      {"label": "/x-plan design", "description": "Design architecture first"},
      {"label": "Stop", "description": "Review plan first"}
    ],
    "multiSelect": false
  }]
}
```

</instructions>

## Planning Principles

1. **Pareto Focus** - 20% of features deliver 80% value
2. **Incremental** - Break into small, deliverable chunks
3. **Dependencies First** - Map dependencies before starting
4. **Risk Aware** - Identify risks early

<critical_rules>

## Critical Rules

1. **Match Scope to Track** - Don't over-plan simple tasks
2. **Be Concrete** - Specific tasks, not vague goals
3. **Include Success Criteria** - How do we know it's done?
4. **Consider Dependencies** - What must happen first?

</critical_rules>

<decision_making>

## Decision Making

**Use Quick Track when**:
- Clear requirements
- Simple change
- 1-2 hour effort

**Use Standard Track when**:
- Multiple steps
- Need to track progress
- 3-8 hour effort

**Use Enterprise Track when**:
- Multi-day effort
- Multiple milestones
- Cross-session work

</decision_making>

## References

- @skills/meta-analysis/ - Pareto prioritization and analysis patterns
- @skills/x-initiative/ - Initiative methodology

<success_criteria>

## Success Criteria

- [ ] Complexity assessed
- [ ] Appropriate track selected
- [ ] Plan created
- [ ] Next step presented

</success_criteria>
