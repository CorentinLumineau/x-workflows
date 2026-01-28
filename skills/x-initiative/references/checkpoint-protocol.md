# Memory Checkpoint Protocol

> **Version**: 1.0.0
> **Purpose**: Cross-session state persistence via Memory MCP

## Overview

Memory checkpoints enable seamless continuation of work across sessions by persisting initiative state in the Memory MCP knowledge graph.

## Entity Schema

### Checkpoint Entity

```yaml
Entity:
  name: "initiative-checkpoint"
  entityType: "checkpoint"
  observations:
    - "initiative:{initiative_name}"
    - "milestone:{current_milestone}"
    - "phase:{current_phase}"
    - "last_action:{description}"
    - "next_action:{suggested_next}"
    - "context_files:{comma_separated_paths}"
    - "timestamp:{ISO8601}"
```

### Example Checkpoint

```yaml
name: "initiative-checkpoint"
entityType: "checkpoint"
observations:
  - "initiative:plugin-perfect-alignment-2026"
  - "milestone:M1-skill-centralization"
  - "phase:implementation"
  - "last_action:Created PHASE-0-PROTOCOL.md reference document"
  - "next_action:Create QUALITY-GATES.md and CHECKPOINT-PROTOCOL.md"
  - "context_files:skills/context-awareness/references/PHASE-0-PROTOCOL.md"
  - "timestamp:2026-01-09T10:30:00Z"
```

## Lifecycle Operations

### Create Checkpoint

**When**: Milestone completion, significant progress, session end

**MCP Call**:
```typescript
mcp__plugin_ccsetup_memory__create_entities({
  entities: [{
    name: "initiative-checkpoint",
    entityType: "checkpoint",
    observations: [
      "initiative:plugin-perfect-alignment-2026",
      "milestone:M1-skill-centralization",
      "phase:complete",
      "last_action:All M1 deliverables completed",
      "next_action:Begin M2 command slimming",
      "context_files:skills/*/SKILL.md,skills/*/references/*.md",
      "timestamp:2026-01-09T12:00:00Z"
    ]
  }]
})
```

### Update Checkpoint

**When**: Phase completion, progress update, context change

**MCP Call**:
```typescript
mcp__plugin_ccsetup_memory__add_observations({
  observations: [{
    entityName: "initiative-checkpoint",
    contents: [
      "phase:validation",
      "last_action:Running coherence validators",
      "timestamp:2026-01-09T11:00:00Z"
    ]
  }]
})
```

### Load Checkpoint

**When**: Session start, /x:continue invocation

**MCP Call**:
```typescript
mcp__plugin_ccsetup_memory__open_nodes({
  names: ["initiative-checkpoint"]
})
```

**Response Handling**:
```typescript
if (checkpoint.exists) {
  // Display context summary
  // Suggest next action
  // Offer resume options
} else {
  // Normal session start
}
```

### Clear Checkpoint

**When**: Initiative archived, user requests fresh start

**MCP Call**:
```typescript
mcp__plugin_ccsetup_memory__delete_entities({
  entityNames: ["initiative-checkpoint"]
})
```

## Cross-Session Recovery Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    SESSION START                             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│ context-awareness: Load checkpoint                           │
│ Memory MCP: open_nodes(["initiative-checkpoint"])            │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              │                               │
        Checkpoint                       No Checkpoint
          EXISTS                           EXISTS
              │                               │
              ▼                               ▼
┌─────────────────────────┐     ┌─────────────────────────┐
│ Display Last Context:   │     │ Normal Session Start    │
│                         │     │                         │
│ "Last session you were  │     │ No initiative context   │
│  working on M1 of       │     │ loaded                  │
│  plugin-perfect-        │     │                         │
│  alignment-2026"        │     │                         │
│                         │     │                         │
│ Last: Created protocol  │     │                         │
│ Next: Quality gates doc │     │                         │
└─────────────────────────┘     └─────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────┐
│ AskUserQuestion:                                             │
│                                                              │
│ "Resume from checkpoint?"                                    │
│                                                              │
│ Options:                                                     │
│   - Resume where I left off (Recommended)                   │
│   - Start fresh (clear checkpoint)                          │
│   - Show details (display full context)                     │
└─────────────────────────────────────────────────────────────┘
```

## Checkpoint Triggers

### Automatic Checkpoints

| Event | Checkpoint Content |
|-------|-------------------|
| Milestone complete | Full milestone summary, next milestone |
| Phase complete | Phase summary, next phase |
| Session timeout (30 min idle) | Current state, interrupted action |
| /x:commit success | Commit hash, files changed |

### Manual Checkpoints

| Command | Creates Checkpoint |
|---------|-------------------|
| `/x:continue` | Updates with resume context |
| `/x:archive` | Final checkpoint before deletion |
| User explicit save | Current state snapshot |

## Checkpoint Data Structure

### Minimal Checkpoint (Phase Change)
```yaml
observations:
  - "milestone:M1"
  - "phase:complete"
  - "timestamp:2026-01-09T10:00:00Z"
```

### Standard Checkpoint (Milestone Change)
```yaml
observations:
  - "initiative:plugin-perfect-alignment-2026"
  - "milestone:M1-skill-centralization"
  - "phase:complete"
  - "last_action:Created 4 skill reference documents"
  - "next_action:Begin M2 command slimming"
  - "timestamp:2026-01-09T12:00:00Z"
```

### Full Checkpoint (Session End)
```yaml
observations:
  - "initiative:plugin-perfect-alignment-2026"
  - "milestone:M1-skill-centralization"
  - "phase:implementation"
  - "last_action:Created CHECKPOINT-PROTOCOL.md"
  - "next_action:Create TRANSITION-PROTOCOL.md"
  - "context_files:skills/x-initiative/references/checkpoint-protocol.md"
  - "session_duration:2h15m"
  - "files_modified:12"
  - "timestamp:2026-01-09T11:30:00Z"
```

## Invocation from Commands

Commands should NOT implement checkpoint logic inline. Instead, invoke initiative skill:

### Before (Inline - BAD)
```markdown
Memory MCP checkpoint:
create_entities([{name: "initiative-checkpoint", entityType: "checkpoint",
observations: [initiative, last_milestone, next_action, timestamp]}])
```

### After (Reference - GOOD)
```markdown
5. **Checkpoint Update** (via initiative skill)
   - Update checkpoint with milestone progress
   - See `checkpoint-protocol.md` in this directory
```

## Synchronization with WORKFLOW-STATUS.yaml

Checkpoints should stay synchronized with WORKFLOW-STATUS.yaml:

| Checkpoint Field | WORKFLOW-STATUS.yaml Field |
|------------------|---------------------------|
| initiative | active.initiative |
| milestone | active.milestone |
| phase | active.phase |
| last_action | sessions[-1].completed |
| next_action | resume.next_action |
| context_files | resume.context_files |

## Error Handling

| Error | Recovery |
|-------|----------|
| Memory MCP unavailable | Log warning, continue without checkpoint |
| Checkpoint corrupted | Clear and create fresh |
| Checkpoint outdated (>7 days) | Warn user, suggest fresh start |
| Checkpoint mismatch with docs | Prefer documentation state |

## References

- @skills/x-initiative/SKILL.md - Full skill documentation
- @core-docs/mcp/memory.md - Memory MCP documentation
- @skills/x-initiative/playbooks/README.md - Initiative methodology

---

**Version**: 1.0.0
**Created**: 2026-01-09
