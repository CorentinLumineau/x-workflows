# Memory MCP Entity Catalog

> All Memory MCP entity types used by the workflow ecosystem.

## Entity Types

| Entity Type | Name | Purpose | Created By | Read By |
|------------|------|---------|-----------|---------|
| InitiativeCheckpoint | `initiative-checkpoint` | Initiative state | x-initiative | context-awareness, x-help |
| WorkflowState | `workflow-state` | Active workflow position | verb skills | verb skills, x-auto, x-help |
| InterviewState | `interview-state` | Confidence history | interview | interview, x-help |
| DelegationRecord | `delegation-log` | Agent delegation history | orchestration, agent-awareness | agent-awareness (future), x-help |

---

## Entity Details

### InitiativeCheckpoint

```
create_entities:
  name: "initiative-checkpoint"
  entityType: "InitiativeCheckpoint"
  observations:
    - "initiative: {name}"
    - "milestone: {M1|M2|...}"
    - "status: {in_progress|completed|blocked}"
    - "progress: {json}"
    - "updated: {timestamp}"
```

**Relations**:
- `initiative-checkpoint` → `tracks` → `workflow-state`

### WorkflowState

```
create_entities:
  name: "workflow-state"
  entityType: "WorkflowState"
  observations:
    - "type: {APEX|ONESHOT|DEBUG|BRAINSTORM}"
    - "phase: {current_phase}"
    - "phase_index: {n}/{total}"
    - "started: {timestamp}"
    - "context: {request_summary}"
```

**Lifecycle**: Created on first verb skill invocation, updated after each phase, cleared on workflow completion.

### InterviewState

```
create_entities:
  name: "interview-state"
  entityType: "InterviewState"
  observations:
    - "skill: {skill_name}"
    - "confidence: {composite_score}"
    - "dimensions: {json_scores}"
    - "questions_asked: {count}"
    - "timestamp: {timestamp}"
```

**Lifecycle**: Created after first interview, updated with each new interview session.

### DelegationRecord

```
create_entities:
  name: "delegation-log"
  entityType: "DelegationRecord"
  observations:
    - "delegation: {agent} ({model}) for {task_type} [{complexity}] -> {outcome} ({duration_ms}ms) at {timestamp}"
    - "escalated: {from_agent} -> {to_agent}, reason: {trigger}"
    - "user_override: suggested {agent}, user chose {other_agent}"
```

**Lifecycle**: Observations appended on each delegation event; never cleared (grows as history).

---

## Operations Reference

### Write Operations

| Operation | When | MCP Tool |
|-----------|------|----------|
| Create new entity | First time state written | `create_entities` |
| Add observations | State update | `add_observations` |
| Create relation | Link entities | `create_relations` |

### Read Operations

| Operation | When | MCP Tool |
|-----------|------|----------|
| Search by name | Session start | `search_nodes` |
| Read specific entity | Known entity name | `open_nodes` |
| Read full graph | Debug/audit | `read_graph` |

### Cleanup Operations

| Operation | When | MCP Tool |
|-----------|------|----------|
| Remove stale entity | After initiative archive | `delete_entities` |
| Remove old observations | After workflow completion | `delete_observations` |

---

## Naming Conventions

- Entity names use **kebab-case**: `initiative-checkpoint`, `workflow-state`
- Entity types use **PascalCase**: `InitiativeCheckpoint`, `WorkflowState`
- Observations are **colon-separated key-value strings**: `"key: value"`
- Timestamps use **ISO 8601**: `"2026-02-10T14:30:00Z"`
