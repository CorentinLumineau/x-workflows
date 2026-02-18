# Checkpoint Protocol

> Checkpoint lifecycle for initiative state persistence using file-based (L1) and auto-memory (L2) layers.

## Write Checkpoint (after milestone completion or significant progress)

### Step 1: Write File Checkpoint

Write or update `.claude/initiative.json`:

```json
{
  "name": "{initiative_name}",
  "status": "{in_progress|completed|blocked}",
  "currentMilestone": "{current_milestone}",
  "lastUpdated": "{ISO_timestamp}",
  "progress": {
    "M1": "completed",
    "M2": "in_progress"
  }
}
```

### Step 2: Update Auto-Memory (if learning discovered)

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
3. **File: `documentation/milestones/_active/*/README.md`** — reconstruction
4. **MEMORY.md** — patterns and last known position hints

### Recovery Protocol

```
1. Read .claude/initiative.json
2. If found:
   - Parse initiative name, milestone, status
   - Validate against milestone files on disk
   - Restore state to conversation context
3. If not found:
   - Scan _active/ directory for initiative folders
   - Reconstruct state from milestone file checkboxes
   - Offer to create fresh checkpoint
```

### Step 3: Sync Validation (after any checkpoint write)

After writing initiative state:
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
| initiative.json missing | Reconstruct from milestone files on disk |
| initiative.json corrupted | Fall back to directory scan of _active/ |
| Conflicting timestamps | Prefer most recent; log discrepancy |
| MEMORY.md unavailable | Continue with file-based state only (L1) |
