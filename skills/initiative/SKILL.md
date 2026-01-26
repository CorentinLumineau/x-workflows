---
name: initiative
description: |
  Track multi-phase projects across sessions with file-based persistence.
  Activate when initiative context exists (milestones path, checkpoint file).
  Triggers: initiative, milestone, phase, checkpoint, continue, resume.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: behavioral
---

# Initiative

Track multi-phase projects across sessions with file-based persistence.

## Critical Rules

| Rule | Reason |
|------|--------|
| Read state at session start | Load context before any work |
| Checkpoint after each milestone | Write progress immediately |
| Update summary at end | Document accomplishments for handoff |
| Use consistent naming | Clear entity identification |
| Sync documentation | Keep milestone docs in sync |

## Activation Triggers

Activate this skill when **initiative context exists**:
- `documentation/milestones/` path in command input
- `.claude/initiative.json` file exists
- Keywords: "initiative", "milestone", "phase"

**NOT activated for regular work** (no milestones/ path, no checkpoint):
- Simple feature implementation → skill inactive
- Quick bug fix → skill inactive

## Persistence

### Primary Storage: .claude/initiative.json

```json
{
  "name": "initiative-name",
  "status": "in_progress",
  "currentMilestone": "M1",
  "lastUpdated": "2026-01-23T16:00:00Z",
  "progress": {
    "M0": "completed",
    "M1": "in_progress"
  },
  "checkpoints": [
    {
      "milestone": "M0",
      "completedAt": "2026-01-22T14:00:00Z",
      "notes": "Standards complete"
    }
  ],
  "nextAction": "Continue with M1 Phase 1"
}
```

### Session Start

```
1. Check for .claude/initiative.json
2. If exists:
   a. Load and parse state
   b. Display current status
   c. Show next suggested action
3. Ask user: continue or start fresh?
```

### During Work

```
1. Update task status as completed
2. Update initiative.json progress
3. Checkpoint every major milestone
```

### Session End

```
1. Update checkpoint with final state
2. Write session summary
3. Note next steps for continuation
4. Update milestone documentation
```

## Checkpoint Schema

```json
{
  "milestone": "M1",
  "phase": "2.3",
  "lastAction": "Created 14 workflow skills",
  "nextAction": "Create behavioral skills",
  "contextFiles": [
    "skills/x-plan/SKILL.md",
    "skills/x-implement/SKILL.md"
  ],
  "timestamp": "2026-01-23T16:30:00Z"
}
```

## Status Values

| Status | Meaning |
|--------|---------|
| planned | Not yet started |
| in_progress | Active work |
| blocked | Waiting on dependency |
| completed | Finished successfully |
| archived | Closed and documented |

## Integration with x-initiative

This behavioral skill provides patterns that the `x-initiative` workflow skill uses:
- x-initiative create → uses this skill to set up tracking
- x-initiative continue → uses this skill to load state
- x-initiative archive → uses this skill to finalize

## Checklist

- [ ] Initiative file exists
- [ ] Progress tracked accurately
- [ ] Checkpoints saved regularly
- [ ] Documentation synced
- [ ] Next action documented
