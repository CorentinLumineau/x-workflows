# 3-Layer Persistence Architecture

> Reference document for cross-session state management across the workflow ecosystem.

## Overview

All workflow state uses a 3-layer persistence model to ensure data survives session boundaries through redundant storage.

| Layer | Storage | Purpose | Availability |
|-------|---------|---------|-------------|
| **L1: File** | `.claude/*.json` | Fast checkpoint, primary state | REQUIRED |
| **L2: Auto-memory** | `MEMORY.md` | Cross-session learnings, patterns | REQUIRED (built-in) |
| **L3: MCP Memory** | Entities | Structured storage, queryable | REQUIRED (warn on fail) |

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
    │
    ▼
3. L3: Write to Memory MCP entity
   ├── create_entities or add_observations
   └── Structured, queryable, cross-session
   → REQUIRED (warn on unavailable, continue with L1)
```

### Write Rules

- L1 writes are **synchronous** — always complete before proceeding
- L2 writes are **conditional** — only when a learning/pattern is discovered
- L3 writes are **best-effort** — warn if unavailable, never block on failure

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
3. L3: Memory MCP search_nodes (structured query)
   → search_nodes("initiative-checkpoint")
   → search_nodes("workflow-state")
   → Enriches L1 data with cross-session context
    │
    ▼
4. L2: MEMORY.md (learnings, not state)
   → Provides patterns, preferences, not checkpoint data
    │
    ▼
5. Directory scan (last resort)
   → Scan documentation/milestones/_active/ for initiative files
   → Reconstruct state from file structure
```

### Read Rules

- Use highest-priority available source as authoritative
- Enrich with lower-priority sources if available
- If L1 and L3 conflict, prefer L1 (most recent write wins via timestamp)
- L2 never contains transient state — only patterns and learnings

---

## Entity Type Catalog

### InitiativeCheckpoint

| Field | Type | Description |
|-------|------|-------------|
| name | string | Entity name: `"initiative-checkpoint"` |
| entityType | string | `"InitiativeCheckpoint"` |
| observations | string[] | Key-value pairs as strings |

**Observations format**:
- `"initiative: {name}"` — Initiative name
- `"milestone: {current}"` — Current milestone (e.g., "M2")
- `"status: {status}"` — Overall status
- `"progress: {json}"` — JSON-encoded progress data
- `"updated: {timestamp}"` — Last update timestamp

### WorkflowState

| Field | Type | Description |
|-------|------|-------------|
| name | string | Entity name: `"workflow-state"` |
| entityType | string | `"WorkflowState"` |
| observations | string[] | Workflow position data |

**Observations format**:
- `"type: {APEX|ONESHOT|DEBUG|BRAINSTORM}"` — Workflow type
- `"phase: {current_phase}"` — Current phase name
- `"phase_index: {n}/{total}"` — Position in workflow
- `"started: {timestamp}"` — Workflow start time
- `"context: {summary}"` — Original request summary

### InterviewState

| Field | Type | Description |
|-------|------|-------------|
| name | string | Entity name: `"interview-state"` |
| entityType | string | `"InterviewState"` |
| observations | string[] | Confidence history |

**Observations format**:
- `"skill: {name}"` — Which skill was interviewed for
- `"confidence: {composite_score}"` — Final composite score
- `"dimensions: {json}"` — Per-dimension scores
- `"questions_asked: {n}"` — Number of questions
- `"timestamp: {timestamp}"` — When interview occurred

### DelegationRecord

| Field | Type | Description |
|-------|------|-------------|
| name | string | Entity name: `"delegation-log"` |
| entityType | string | `"DelegationRecord"` |
| observations | string[] | Delegation history entries |

**Observations format**:
- `"delegation: {agent} ({model}) for {task_type} [{complexity}] -> {outcome} ({duration_ms}ms) at {timestamp}"`
- `"escalated: {from_agent} -> {to_agent}, reason: {trigger}"`
- `"user_override: suggested {agent}, user chose {other_agent}"`

---

## Degradation Behavior

### L3 (Memory MCP) Unavailable

| Behavior | Action |
|----------|--------|
| **Detection** | Memory MCP tool call returns error or times out |
| **Warning** | Log: "Memory MCP unavailable — operating in degraded mode (L1 only)" |
| **Continuation** | All operations continue with L1 file-based state |
| **Context indicator** | `/x-help context` shows: "MCP Memory: ✗ (degraded mode)" |
| **Recovery** | On next successful MCP call, sync L1 state to L3 |

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
| **Continuation** | Attempt L3 write as primary; warn user prominently |
| **Impact** | HIGH — primary state storage unavailable |

---

## Integration Points

| Component | Writes | Reads | Layers Used |
|-----------|--------|-------|-------------|
| x-initiative | Initiative state | Initiative state | L1 + L2 + L3 |
| Verb skills | Workflow position | Workflow position | L1 + L3 |
| Interview | Confidence scores | Historical confidence | L1 + L2 + L3 |
| Orchestration | Delegation records | Delegation history | L2 + L3 |
| Context-awareness | — | All state (read-only) | L1 + L3 + L2 |
| /x-help context | — | All state (display) | L1 + L3 + L2 |
