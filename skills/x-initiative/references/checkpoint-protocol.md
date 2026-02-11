# Checkpoint Protocol

> Memory MCP checkpoint lifecycle for initiative state persistence.

## Write Checkpoint (after milestone completion or significant progress)

### Step 1: Create/Update Entity

```
Memory MCP: create_entities or add_observations

Entity:
  name: "initiative-checkpoint"
  entityType: "InitiativeCheckpoint"
  observations:
    - "initiative: {name}"
    - "milestone: {current_milestone}"
    - "status: {in_progress|completed|blocked}"
    - "progress: {json_encoded_progress}"
    - "updated: {ISO_timestamp}"
```

### Step 2: Create Relation (if workflow state exists)

```
Memory MCP: create_relations

Relation:
  from: "initiative-checkpoint"
  to: "workflow-state"
  relationType: "tracks"
```

### Step 3: Update Auto-Memory (if learning discovered)

Only write to MEMORY.md when:
- A new pattern is confirmed across multiple interactions
- A user preference is explicitly stated
- A debugging insight is discovered

Example MEMORY.md entry:
```markdown
## Initiative Patterns
- {initiative_name}: Milestone structure works well for {pattern}
- User prefers: {preference discovered during initiative}
```

---

## Read Checkpoint (on session start or resume)

### Priority Order

1. **Conversation context** (if same session) — highest priority
2. **File: `.claude/initiative.json`** — primary checkpoint
3. **Memory MCP: `search_nodes("initiative-checkpoint")`** — enrichment
4. **File: `documentation/milestones/_active/*/README.md`** — reconstruction
5. **MEMORY.md** — patterns only, not state

### Recovery Protocol

```
1. search_nodes("initiative-checkpoint")
2. If found:
   - Parse observations
   - Validate against .claude/initiative.json (if exists)
   - Use most recent timestamp as authoritative
   - Restore state to conversation context
3. If not found:
   - Fall back to .claude/initiative.json
   - If that's also missing, scan _active/ directory
   - Offer to create fresh checkpoint
```

### Step 4: Sync Validation (after any checkpoint write)

After writing initiative state to any layer:
1. Read initiative.json → extract milestone + status + timestamp
2. Read WORKFLOW-STATUS.yaml → extract milestone + status + timestamp
3. If MISMATCH detected (milestone or status differ):
   a. Determine authoritative source (most recent timestamp)
   b. Update the stale source to match
   c. Log: "Sync corrected: {stale_source} updated to match {authoritative_source}"
4. If both match → no action needed

---

## Checkpoint Lifecycle

```
Initiative Created
    ↓
Checkpoint: "status: in_progress, milestone: M1"
    ↓
Work Progresses
    ↓
Checkpoint: "progress: {updated_json}, milestone: M1"
    ↓
Milestone Completed
    ↓
Checkpoint: "milestone: M2, status: in_progress"
    ↓
...repeat for each milestone...
    ↓
All Milestones Complete
    ↓
Checkpoint: "status: completed"
    ↓
Archive (optional cleanup)
```

---

## Error Handling

| Scenario | Action |
|----------|--------|
| Memory MCP unavailable | Warn user, continue with file-based (L1) |
| Entity already exists | Use `add_observations` to append, not overwrite |
| Conflicting timestamps | Prefer most recent; log discrepancy |
| Corrupted JSON in observations | Fall back to file-based state |
