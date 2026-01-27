# Mode: status

> **Invocation**: `/x-initiative status`

<purpose>
Display and manage workflow state for cross-session context. Show progress on active initiatives.
</purpose>

## Behavioral Skills

This mode activates:
- `initiative` - Tracking patterns

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 20%, context 40%, technical 15%, scope 20%, risk 5%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Which initiative's status unclear.

**Note**: Status mode is typically low-risk - bypass often appropriate.

---

### Phase 1: Gather Status

Collect status from all sources:

```bash
# Check checkpoint
cat .claude/initiative.json 2>/dev/null

# Active initiatives
ls documentation/milestones/_active/

# Check each initiative's README
cat documentation/milestones/_active/*/README.md
```

### Phase 2: Generate Status Report

```markdown
## Workflow Status Report

### Active Initiatives

| Initiative | Milestone | Progress | Last Activity |
|------------|-----------|----------|---------------|
| {name} | M{n} | {%}% | {date} |

### Current Focus
**Initiative**: {name}
**Milestone**: {milestone}
**Status**: {status}

### Recent Activity
- {activity_1}
- {activity_2}

### Next Steps
1. {step_1}
2. {step_2}

### Blockers
- {blocker if any}
```

### Phase 3: Detailed Breakdown

For each active initiative:

```markdown
### {Initiative Name}

**Status**: In Progress
**Progress**: {X}%

#### Milestones
- [x] M1: {name} (Complete)
- [ ] M2: {name} (In Progress - 60%)
- [ ] M3: {name} (Not Started)

#### Current Tasks
- [ ] {task_1}
- [ ] {task_2}
```

### Phase 4: Options

```json
{
  "questions": [{
    "question": "Status displayed. What would you like to do?",
    "header": "Action",
    "options": [
      {"label": "/x-initiative continue (Recommended)", "description": "Resume work"},
      {"label": "/x-initiative archive", "description": "Archive if complete"},
      {"label": "Done", "description": "Just viewing"}
    ],
    "multiSelect": false
  }]
}
```

</instructions>

## Status Sources

| Source | Information |
|--------|-------------|
| `.claude/initiative.json` | Current checkpoint |
| `_active/*/README.md` | Initiative overview |
| `_active/*/milestone-*.md` | Milestone details |

## Status Indicators

| Symbol | Meaning |
|--------|---------|
| [x] | Complete |
| [ ] | In Progress or Not Started |

<critical_rules>

## Critical Rules

1. **Comprehensive** - Show all active work
2. **Current** - Reflect actual state
3. **Actionable** - Show next steps
4. **Clear** - Easy to understand

</critical_rules>

<success_criteria>

## Success Criteria

- [ ] All sources checked
- [ ] Status displayed
- [ ] Progress clear
- [ ] Options provided

</success_criteria>
