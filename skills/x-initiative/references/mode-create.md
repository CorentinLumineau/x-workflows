# Mode: create

> **Invocation**: `/x-initiative` or `/x-initiative create`

<purpose>
Create new initiative documentation with Pareto-optimized milestone breakdown. Set up multi-session project tracking.
</purpose>

## References

Persistence patterns: See `checkpoint-protocol.md` and `memory.md`

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 35%, context 25%, technical 15%, scope 20%, risk 5%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Scope definition unclear, milestone breakdown missing, success metrics undefined.

---

### Phase 1: Initiative Scope

Gather initiative details:

```json
{
  "questions": [{
    "question": "What type of initiative is this?",
    "header": "Type",
    "options": [
      {"label": "Feature", "description": "New functionality"},
      {"label": "Refactor", "description": "Code restructuring"},
      {"label": "Migration", "description": "System upgrade"},
      {"label": "Integration", "description": "External system"}
    ],
    "multiSelect": false
  }]
}
```

### Phase 2: Complexity Estimation

Estimate effort using signals:

| Signal | Small (1-2 days) | Medium (3-7 days) | Large (1-2 weeks) |
|--------|------------------|-------------------|-------------------|
| Files | <10 | 10-30 | 30+ |
| Dependencies | Few | Some | Many |
| Risk | Low | Medium | High |

### Phase 3: Milestone Breakdown (Pareto)

Create Pareto-optimized milestones (80% value from 20% effort):

```markdown
## Milestones

### M1: Foundation (40% value, 20% effort)
Core functionality that enables everything else.

### M2: Core Features (30% value, 30% effort)
Main features building on foundation.

### M3: Polish (20% value, 30% effort)
Error handling, edge cases, documentation.

### M4: Validation (10% value, 20% effort)
Testing, review, final validation.
```

### Phase 4: Create Initiative Structure

```
documentation/milestones/_active/{initiative-name}/
├── README.md           # Overview, status, links
├── milestone-1.md      # M1 details
├── milestone-2.md      # M2 details
└── ...
```

#### README.md Template

```markdown
# Initiative: {Name}

## Status: In Progress

## Overview
{Description}

## Milestones

| Milestone | Status | Progress |
|-----------|--------|----------|
| M1: {Name} | In Progress | 0% |
| M2: {Name} | Not Started | 0% |

## Links
- Related docs: {links}
- Related code: {links}
```

### Phase 5: Save Checkpoint

Create `.claude/initiative.json`:

```json
{
  "name": "initiative-name",
  "status": "in_progress",
  "currentMilestone": "M1",
  "lastUpdated": "2026-01-26T00:00:00Z",
  "progress": { "M1": "in_progress" }
}
```

### Phase 6: Workflow Transition

Present next step:

```json
{
  "questions": [{
    "question": "Initiative '{name}' created with {n} milestones. Start working?",
    "header": "Next",
    "options": [
      {"label": "/x-implement (Recommended)", "description": "Start M1"},
      {"label": "/x-plan", "description": "Plan M1 in detail"},
      {"label": "Stop", "description": "Review structure first"}
    ],
    "multiSelect": false
  }]
}
```

</instructions>

<critical_rules>

## Critical Rules

1. **Pareto Focus** - 80% value from 20% effort
2. **Small Milestones** - Each milestone 1-2 days max
3. **Clear Dependencies** - Know what blocks what
4. **File-Based Persistence** - Enable cross-session tracking

</critical_rules>

<decision_making>

## Decision Making

**Create autonomously when**:
- Clear scope provided
- Standard initiative type
- Reasonable complexity

**Use AskUserQuestion when**:
- Unclear scope
- Complex dependencies
- Multiple valid breakdowns

</decision_making>

<success_criteria>

## Success Criteria

- [ ] Scope defined
- [ ] Complexity estimated
- [ ] Milestones created (Pareto-optimized)
- [ ] File structure in place
- [ ] Checkpoint saved

</success_criteria>
