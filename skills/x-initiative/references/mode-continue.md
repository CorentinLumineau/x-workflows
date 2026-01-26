# Mode: continue

> **Invocation**: `/x-initiative continue`

<purpose>
Context-aware continuation - prioritizes conversation context, then file checkpoints, then active initiatives.
</purpose>

## Behavioral Skills

This mode activates:
- `initiative` - Multi-session tracking patterns

<instructions>

### Phase 1: Context Priority Check

Check for context in priority order:

1. **Conversation context** - Recent messages in this session
2. **File checkpoint** - `.claude/initiative.json`
3. **Active initiatives** - Files in `documentation/milestones/_active/`

### Phase 2: Load Checkpoint

Read `.claude/initiative.json`:

```json
{
  "name": "initiative-name",
  "status": "in_progress",
  "currentMilestone": "M1",
  "lastUpdated": "2026-01-26T00:00:00Z",
  "progress": { "M1": "in_progress" }
}
```

If checkpoint found:
- Extract initiative name
- Extract current milestone
- Extract last status

### Phase 3: State Display

```markdown
## Continuation Context

### Initiative: {name}
**Current Milestone**: {milestone}
**Status**: {status}
**Last Activity**: {lastUpdated}

### Progress
{progress_summary from milestone files}

### Next Steps
1. {next_task from current milestone}
2. {next_task}

### Blockers (if any)
- {blocker}
```

### Phase 4: Resume Work

Offer options based on state:

```json
{
  "questions": [{
    "question": "Ready to continue '{initiative}' at {milestone}. What to do?",
    "header": "Action",
    "options": [
      {"label": "/x-implement (Recommended)", "description": "Continue implementation"},
      {"label": "/x-initiative status", "description": "View full status"},
      {"label": "Different task", "description": "Work on something else"}
    ],
    "multiSelect": false
  }]
}
```

</instructions>

## Context Sources

| Source | Data |
|--------|------|
| `.claude/initiative.json` | Initiative, milestone, status |
| `_active/` | Active initiatives on disk |
| Conversation | Recent context |

## No Context Found

If no context:

```json
{
  "questions": [{
    "question": "No active context found. What would you like to do?",
    "header": "Action",
    "options": [
      {"label": "/x-initiative create", "description": "Start new initiative"},
      {"label": "/x-implement", "description": "Quick implementation"},
      {"label": "Describe task", "description": "Tell me what you need"}
    ],
    "multiSelect": false
  }]
}
```

<critical_rules>

## Critical Rules

1. **Preserve Context** - Don't lose cross-session state
2. **Priority Order** - Conversation > File > Directory scan
3. **Show State** - Always display current state
4. **Easy Resume** - One-click continuation

</critical_rules>

<success_criteria>

## Success Criteria

- [ ] Context retrieved
- [ ] State displayed
- [ ] Next steps identified
- [ ] Easy continuation offered

</success_criteria>
