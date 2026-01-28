---
type: guide
audience: [developers, project-managers]
scope: framework-agnostic
last-updated: 2026-01-28
status: current
---

# Quick Start: Initiative Management

Get started with multi-phase project tracking using the x-initiative workflow.

## Creating an Initiative

```bash
# Via command
/x:initiative "My Feature Name"

# Or with explicit mode
/x:initiative create "My Feature Name"
```

This creates:
```
documentation/milestones/_active/{initiative-name}/
├── README.md              # Overview, goals, progress table
├── M1-first-milestone.md  # First milestone details
├── M2-second-milestone.md # Second milestone details
└── ...
```

## Milestone Structure

Each milestone file contains:

1. **Status header** -- current state (Not Started / In Progress / Complete)
2. **Tasks** -- checkboxes for individual work items
3. **Acceptance criteria** -- measurable completion conditions
4. **Dependencies** -- what must finish before this milestone

### Ordering by ROI

Milestones are ordered by value/effort ratio (Pareto principle):
- High ROI milestones first (quick wins, critical path)
- Each milestone is independently shippable
- Target 2-5 days per milestone

## Status Tracking

Check initiative progress at any time:

```bash
/x:initiative status
```

This reads `.claude/initiative.json` and the milestone directory to display:
- Current milestone
- Completed vs remaining tasks
- Blockers or risks

## Continuing Work

Resume from a previous session:

```bash
/x:initiative continue
```

The workflow:
1. Reads `.claude/initiative.json` for last checkpoint
2. Loads the active milestone file
3. Displays what was completed and what remains
4. Resumes from the next incomplete task

## Archiving

When all milestones are complete:

```bash
/x:initiative archive
```

This moves the initiative from `_active/` to `_archived/` and updates tracking files.

## Common Workflows

| Scenario | Command |
|----------|---------|
| Start new project | `/x:initiative create "Name"` |
| Check progress | `/x:initiative status` |
| Resume after break | `/x:initiative continue` |
| Finish and archive | `/x:initiative archive` |

## Tips

- Keep milestones small (2-5 days each)
- Update task checkboxes as you complete work
- Use the status command before starting each session
- Archive promptly when done to keep the active list clean

---

**See also**: [LLM Assistant Guide](llm-assistant-guide.md) | [Templates](../templates/)
