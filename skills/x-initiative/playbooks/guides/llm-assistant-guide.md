---
type: guide
audience: [llms]
scope: framework-agnostic
last-updated: 2026-01-28
status: current
---

# LLM Assistant Guide: Managing Initiatives

Guide for AI assistants (Claude Code, Cursor, Cline, etc.) managing multi-phase initiatives.

## Phase 0: Interview Integration

Before creating an initiative, activate the `interview` behavioral skill:

1. **Assess scope** -- Is this truly multi-phase (>40 hours)?
2. **Clarify goals** -- What are the measurable outcomes?
3. **Identify risks** -- What could block progress?
4. **Confirm with user** -- Present the plan before creating files

Single-file changes, bug fixes, and routine maintenance do not need initiatives.

## Session Handoff Protocol

### Starting a New Session

1. Check for `.claude/initiative.json`
2. If found, load and display current status
3. Ask: "Continue from {current milestone}?" or offer to start fresh
4. Read the active milestone file for context

### Ending a Session

1. Update task checkboxes in the milestone file
2. Write a progress note with date
3. Update `.claude/initiative.json` with checkpoint data
4. Summarize what was done and what remains

### Checkpoint Data Format

```json
{
  "name": "initiative-name",
  "status": "in_progress",
  "currentMilestone": "M2",
  "lastUpdated": "2026-01-28T10:00:00Z",
  "progress": {
    "M1": "completed",
    "M2": "in_progress"
  },
  "checkpoints": [
    {
      "milestone": "M1",
      "completedAt": "2026-01-27T16:00:00Z",
      "notes": "All tasks complete, tests passing"
    }
  ]
}
```

## Error Recovery Patterns

### Incomplete Milestone File

If a milestone file has unchecked tasks but the JSON says "completed":
- Trust the file (checkboxes are ground truth)
- Update the JSON to reflect actual state
- Inform the user of the discrepancy

### Missing Initiative JSON

If `.claude/initiative.json` is missing but milestone files exist:
- Reconstruct from milestone file states
- Create a new JSON from the file evidence
- Inform the user

## Documentation Update Workflow

After completing any milestone:

1. Update the milestone file (mark tasks complete)
2. Update the initiative README progress table
3. Update `.claude/initiative.json`

## Checklist for LLM Assistants

- [ ] Read initiative state before starting work
- [ ] Confirm scope with user (interview skill)
- [ ] Update checkboxes as tasks complete
- [ ] Write checkpoint at session end
- [ ] Keep JSON and files in sync
- [ ] Summarize progress to user

---

**See also**: [Quick Start](quick-start.md) | [Templates](../templates/)
