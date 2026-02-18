---
name: x-initiative
description: Use when starting, continuing, or archiving a multi-session project initiative.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
user-invocable: true
metadata:
  author: ccsetup contributors
  version: "2.0.0"
  category: workflow
---

# x-initiative

Multi-phase project tracking across sessions using file-based persistence.

## Plan Mode Integration

In `create` mode, x-initiative uses plan mode for initial scoping:

<plan-mode phase="initiative-scoping" trigger="create-mode">
  <enter>Enter read-only mode for initial file discovery and scope assessment</enter>
  <scope>Explore codebase to determine initiative structure (milestones, estimated effort)</scope>
  <exit trigger="scoping-complete">Present initiative structure proposal for user approval before writing files</exit>
</plan-mode>

After approval, initiative files (README.md, milestone-*.md) are written.

## Modes

| Mode | Description |
|------|-------------|
| create (default) | Create new initiative |
| continue | Resume work from last session |
| archive | Archive completed initiative (delegates to `/x-archive`) |
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

## Auto-Activation

x-initiative is **automatically suggested** by `complexity-detection` when:

### Trigger Conditions

| Condition | Example |
|-----------|---------|
| Complexity Tier 3 | Any COMPLEX assessment |
| Migration keywords | "migrate", "upgrade major version" |
| Redesign scope | "refactor entire", "rewrite", "redesign" |
| Multi-phase language | "over several sessions", "multi-day" |
| Large scope | >5 files, multiple modules |

### Auto-Activation Flow

```
User request
    ↓
complexity-detection assesses
    ↓
If COMPLEX detected:
    ↓
┌─────────────────────────────────────────────────┐
│ This task appears complex and may span multiple │
│ sessions. Would you like to create an           │
│ initiative to track progress?                   │
│                                                 │
│ [Yes, create initiative] [No, proceed directly] │
└─────────────────────────────────────────────────┘
```

### When Active Initiative Exists

If an initiative is already active and a new complex task is detected:

```
┌─────────────────────────────────────────────────┐
│ Active initiative: "Project Alpha Migration"   │
│ Progress: Milestone 2/4 (50%)                  │
│                                                 │
│ Options:                                        │
│ [Continue existing] [Start new] [View status]  │
└─────────────────────────────────────────────────┘
```

### Opt-Out

Users can bypass auto-activation by:
- Using explicit `/x-implement` without initiative
- Adding "quick" or "oneshot" to request
- Responding "No" to initiative prompt

## Behavioral Skills

This workflow activates these behavioral skills:
- `interview` - Zero-doubt confidence gate (Phase 0)

## Persistence

See @skills/initiative/SKILL.md for persistence schema and patterns.

Canonical reference for persistence implementation:
- @skills/initiative/references/checkpoint-protocol.md - Checkpoint lifecycle (L1 file + L2 auto-memory)

### Write Order (All State Changes)

<state-checkpoint phase="initiative" status="milestone-progress">
Cross-session initiative persistence via 2-layer write order with sync validation:
file checkpoint (L1), WORKFLOW-STATUS.yaml (L1), MEMORY.md (L2).
**Sync Protocol**: After writes, validate initiative.json matches WORKFLOW-STATUS.yaml.
See @skills/initiative/references/persistence-architecture.md for sync trigger table and conflict resolution.
</state-checkpoint>

1. **initiative.json** (REQUIRED) — Primary checkpoint (L1: file)
2. **WORKFLOW-STATUS.yaml** (REQUIRED) — Rich context (L1: file)
3. **MEMORY.md** — Update if learning discovered (L2: auto-memory)

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
- **For archive mode**: Delegates to `/x-archive` (standalone skill)
- **For status mode**: See `references/mode-status.md`

> **Note**: The `archive` mode delegates to the standalone `/x-archive` skill for backward compatibility. Users can invoke either `/x-initiative archive` or `/x-archive` directly.
