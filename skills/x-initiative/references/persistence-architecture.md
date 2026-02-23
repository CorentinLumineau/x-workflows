# Persistence Architecture

> Reference document for cross-session state management across the workflow ecosystem.

## Overview

Workflow state uses a 2-layer persistence model to ensure data survives session boundaries.

| Layer | Storage | Purpose | Availability |
|-------|---------|---------|-------------|
| **L1: File** | `.claude/*.json` | Fast checkpoint, primary state | REQUIRED |
| **L2: Auto-memory** | `MEMORY.md` | Cross-session learnings, patterns | REQUIRED (built-in) |

---

## Write Protocol

On every state change, write in this order:

```
State Change Event
    │
    ▼
1. L1: Write to .claude/{file}.json
   ├── initiative.json (initiative state)
   └── interview-state.json (confidence history)
   → REQUIRED, always available, fastest
    │
    ▼
2. L2: Update MEMORY.md (if learning discovered)
   → Only for learnings, patterns, preferences
   → Claude Code auto-memory (built-in)
   → NOT for transient state
```

### Write Rules

- L1 writes are **synchronous** — always complete before proceeding
- L2 writes are **conditional** — only when a learning/pattern is discovered

### Workflow Completion Write Protocol

When a workflow reaches a TERMINAL phase (git-commit, x-archive), MEMORY.md
receives a mandatory completion write:

| Layer | Write | Content | Mandatory? |
|-------|-------|---------|------------|
| L2 | WRITE to MEMORY.md | `"Completed {workflow_type} for {context_summary}: {outcome}"` | **YES** (not conditional) |

**Note**: L2 writes at workflow completion are MANDATORY, unlike per-checkpoint L2 writes which remain conditional. This ensures cross-session awareness. Write 1-2 lines only.

---

## Read Protocol

On state recovery (session start, resume), read in this priority order:

```
Session Start / Resume
    │
    ▼
1. Conversation context (if same session)
   → HIGHEST priority, already in memory
    │
    ▼
2. L1: Read .claude/*.json (primary file state)
   → initiative.json, interview-state.json
    │
    ▼
3. L2: MEMORY.md (learnings and checkpoint state summaries)
   → Provides patterns, preferences, and last known workflow position
    │
    ▼
4. Directory scan (last resort)
   → Scan documentation/milestones/_active/ for initiative files
   → Reconstruct state from file structure
```

### Read Rules

- Use highest-priority available source as authoritative
- Enrich with lower-priority sources if available
- L2 contains checkpoint state summaries and patterns/learnings

---

## L2 Checkpoint State Writes

In addition to the existing conditional L2 writes (learnings only) and mandatory completion writes, **major phase transitions** trigger a 1-line state summary to MEMORY.md. This ensures cross-session awareness of active workflow position.

### When to Write

Write an L2 state summary at these phase boundaries:

| Transition | L2 State Write |
|------------|---------------|
| analyze → plan | `"Active APEX workflow: analyze completed, planning {context}"` |
| plan → implement | `"Active APEX workflow: plan approved, implementing {context}"` |
| implement → review | `"Active APEX workflow: implementation done, reviewing {context}"` |
| troubleshoot → fix/implement | `"Active DEBUG workflow: root cause found, fixing {context}"` |
| brainstorm → design | `"Active BRAINSTORM workflow: exploring → designing {context}"` |

### Write Format

```
"Active {workflow_type} workflow: {completed_phase} completed, {next_phase_verb} {context_summary}"
```

### Relationship to L2 Writes

| L2 Write Type | Trigger | Content | Mandatory? |
|---------------|---------|---------|------------|
| **Learning** (existing) | Pattern/preference discovered | Learning content | Conditional |
| **Completion** (existing) | Terminal phase reached | Outcome summary | **YES** |
| **Checkpoint state** | Major phase transition | 1-line position summary | **YES** |

**Note**: Checkpoint state writes are intentionally brief (1 line). They exist solely so that a new session reading MEMORY.md can detect an active workflow.

---

## Initiative Sync Protocol

### Sync Trigger Table

| Event | initiative.json | WORKFLOW-STATUS.yaml |
|-------|----------------|---------------------|
| Milestone started | UPDATE | UPDATE |
| Task completed | UPDATE (progress) | NO-OP |
| Milestone completed | UPDATE (next) | UPDATE (status) |
| Status change | UPDATE | UPDATE |
| Session resume | READ (primary) | READ (secondary) |

### Conflict Resolution Protocol

When sources disagree on session resume:
1. Compare `lastUpdated` timestamps across all sources
2. Most recent timestamp wins (authoritative source)
3. If timestamps differ by > 5 minutes: WARN user ("Initiative state may be stale — last updated {time_ago}")
4. Update stale sources to match authoritative source

### Status State Machine

Valid transitions (enforced before writing state):

```
created → in_progress → blocked → in_progress → completed → archived
```

Invalid transitions (REJECT with warning):
- completed → in_progress (must create new initiative)
- archived → any (archived is terminal)

---

## Degradation Behavior

### L2 (Auto-memory) Unavailable

| Behavior | Action |
|----------|--------|
| **Detection** | MEMORY.md file not writable or directory missing |
| **Warning** | Log: "Auto-memory unavailable — learnings will not persist" |
| **Continuation** | All operations continue; learnings lost between sessions |
| **Impact** | Low — L2 only stores patterns, not critical state |

### L1 (File) Unavailable

| Behavior | Action |
|----------|--------|
| **Detection** | `.claude/` directory not writable |
| **Warning** | ERROR: "Cannot write state files — workflow state will not persist" |
| **Continuation** | Warn user prominently; state will not persist |
| **Impact** | HIGH — primary state storage unavailable |

---

## Integration Points

| Component | Writes | Reads | Layers Used |
|-----------|--------|-------|-------------|
| x-initiative | Initiative state | Initiative state | L1 + L2 |
| Interview | Confidence scores | Historical confidence | L1 + L2 |
| Orchestration | Delegation records | Delegation history | L2 |
| Context-awareness | — | All state (read-only) | L1 + L2 |
| /x-help context | — | All state (display) | L1 + L2 |
