# 2-Layer Persistence Architecture

> Reference document for cross-session state management across the workflow ecosystem.

## Overview

All workflow state uses a 2-layer persistence model to ensure data survives session boundaries.

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
   ├── workflow-state.json (workflow position)
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

When a workflow reaches a TERMINAL phase (git-commit, x-archive), both layers
receive a mandatory completion write:

| Layer | Write | Content | Mandatory? |
|-------|-------|---------|------------|
| L1 | UPDATE workflow-state.json | `"status": "completed", "completedAt": "{ISO_timestamp}"` | YES |
| L2 | WRITE to MEMORY.md | `"Completed {workflow_type} for {context_summary}: {outcome}"` | **YES** (not conditional) |

**Note**: L2 writes at workflow completion are MANDATORY, unlike per-checkpoint L2 writes which remain conditional. This ensures cross-session awareness. Write 1-2 lines only.

### Workflow State TTL

workflow-state.json includes a TTL field for automatic expiry:

```json
{
  "type": "APEX",
  "phase": "implement",
  "lastUpdated": "2026-02-11T14:00:00Z",
  "ttl": "24h",
  "context": "...",
  "enforcement": {
    "violations": [
      { "code": "V-TEST-03", "severity": "HIGH", "details": "..." }
    ],
    "blocking": true,
    "summary": "1 HIGH violation (blocking)"
  }
}
```

**Enforcement Field** (optional, backward compatible):
- Written by x-review (Phase 6b) and x-implement (Phase 4b)
- `blocking: true` when any CRITICAL or HIGH violation exists
- Missing field treated as no violations (safe default)

**TTL Expiry Protocol** (checked by context-awareness at Phase 0):

1. Read workflow-state.json
2. Parse `lastUpdated` + `ttl` (default: 24h if field missing)
3. If expired (`now > lastUpdated + ttl`):
   a. Write summary to MEMORY.md: `"Expired workflow: {type} at {phase} for {context}"`
   b. Clear workflow-state.json (reset to `{}`)
   c. Log: `"Workflow state expired (inactive > {ttl})"`
4. If NOT expired → proceed normally

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
   → initiative.json, workflow-state.json, interview-state.json
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

## L1 Self-Sufficiency

L1 (`workflow-state.json`) is the **sole required layer** for workflow resume. No external dependencies are needed to recover workflow position and continue execution.

### What L1 Contains

The workflow-state.json file holds the complete state schema:
- Workflow type (APEX, ONESHOT, DEBUG, BRAINSTORM)
- Current phase and phase history with timestamps
- Start time, TTL, and context summary
- Phase approval status (e.g., plan approved)

### Layer Roles

| Layer | Role in Resume | Required? |
|-------|---------------|-----------|
| **L1** | Full workflow state — position, phases, context | **YES** (self-sufficient) |
| **L2** | Cross-session learnings, patterns, state awareness summaries | No — adds cross-session context |

### Key Guarantee

A fresh session with only `.claude/workflow-state.json` present can:
1. Detect the active workflow type and phase
2. Offer resume at the correct position
3. Continue execution without loss of workflow integrity

L2 (MEMORY.md) provides cross-session learnings and pattern awareness. It improves the resume experience but is **not essential** for workflow continuity.

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

### Relationship to Existing L2 Writes

| L2 Write Type | Trigger | Content | Mandatory? |
|---------------|---------|---------|------------|
| **Learning** (existing) | Pattern/preference discovered | Learning content | Conditional |
| **Completion** (existing) | Terminal phase reached | Outcome summary | **YES** |
| **Checkpoint state** (new) | Major phase transition | 1-line position summary | **YES** |

**Note**: Checkpoint state writes are intentionally brief (1 line). They exist solely so that a new session reading MEMORY.md can detect an active workflow even if L1 is unavailable.

---

## Graceful Degradation Matrix

The persistence architecture degrades predictably based on which layers are available at session resume.

| Available Layers | Tier | Resume? | Behavior |
|-----------------|------|---------|----------|
| **L1 + L2** | Full | Yes | Complete resume — cross-session learnings from L2, complete state from L1 |
| **L1 only** | Minimal | Yes | Fully functional — workflow position and phase state intact, can resume without loss of integrity |
| **L2 only** | — | No | MEMORY.md may contain checkpoint state summaries — can inform user of last known position, but cannot auto-resume |
| **None** | — | No | Fresh start — no prior context, workflow begins from scratch |

### Degradation Principle

The architecture follows a **self-sufficiency gradient**: L1 alone is fully sufficient (Minimal tier), and L1 + L2 is the Full tier covering all workflows. A resume from L1-only produces the same workflow position as a resume from both layers — the difference is context depth, not state accuracy.

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
| Verb skills | Workflow position | Workflow position | L1 |
| Interview | Confidence scores | Historical confidence | L1 + L2 |
| Orchestration | Delegation records | Delegation history | L2 |
| Context-awareness | — | All state (read-only) | L1 + L2 |
| /x-help context | — | All state (display) | L1 + L2 |
