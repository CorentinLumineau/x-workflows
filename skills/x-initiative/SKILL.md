---
name: x-initiative
description: |
  Multi-phase project tracking across sessions. Create, continue, archive initiatives.
  Activate when managing multi-session projects, tracking milestones, or resuming work.
  Triggers: initiative, milestone, project, continue, resume, archive, status.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---

# x-initiative

Multi-phase project tracking across sessions using file-based persistence.

## Modes

| Mode | Description |
|------|-------------|
| create (default) | Create new initiative |
| continue | Resume work from last session |
| archive | Archive completed initiative |
| status | Display progress status |

## Mode Detection
| Keywords | Mode |
|----------|------|
| "continue", "resume", "pick up", "where was I" | continue |
| "archive", "complete", "finish", "close" | archive |
| "status", "progress", "where am I", "what's active" | status |
| (default) | create |

## Execution
- **Default mode**: create
- **No-args behavior**: Check for active initiatives

## Behavioral Skills

This workflow activates these behavioral skills:
- `interview` - Zero-doubt confidence gate (Phase 0)

## Persistence Patterns

See references for persistence implementation:
- `references/checkpoint-protocol.md` - Memory MCP checkpoint patterns
- `references/memory.md` - Entity naming and Memory operations

## Persistence

Store initiative state in project files for cross-session persistence.

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
      "notes": "Standards and setup complete"
    }
  ]
}
```

### Session Start Recovery

1. Check for `.claude/initiative.json`
2. If exists, load and display current status
3. Ask user if they want to continue or start fresh

## Initiative Structure

```
documentation/milestones/_active/{initiative-name}/
├── README.md           # Initiative overview
├── milestone-0.md      # First milestone
├── milestone-1.md      # Second milestone
└── ...
```

## Status Tracking

Each milestone tracks:
- [ ] Tasks with checkboxes
- Progress percentage
- Dependencies
- Blockers

## Checklist

- [ ] Initiative file created/updated
- [ ] Milestone progress tracked
- [ ] Checkpoints saved
- [ ] Documentation synced

## When to Load References

- **For create mode**: See `references/mode-create.md`
- **For continue mode**: See `references/mode-continue.md`
- **For archive mode**: See `references/mode-archive.md`
- **For status mode**: See `references/mode-status.md`
