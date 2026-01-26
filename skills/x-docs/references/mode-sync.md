# Mode: sync

> **Invocation**: `/x-docs sync` or `/x-docs sync "target"`
> **Legacy Command**: `/x:sync-docs`

<purpose>
Synchronize documentation with code changes. Detect staleness and update docs to match current implementation.
</purpose>

## Behavioral Skills

This mode activates:
- `documentation` - Doc sync patterns

## Agents

| Agent | When | Model |
|-------|------|-------|
| `ccsetup:x-reviewer` | Doc updates | haiku |
| `ccsetup:x-explorer` | Code analysis | haiku |

<instructions>

### Phase 1: Change Detection

Find code changes that need doc updates:

```bash
# Recent code changes
git diff --name-only HEAD~10 -- '*.ts' '*.tsx' '*.js'

# Compare doc timestamps vs code timestamps
# Doc file older than related code = stale
```

### Phase 2: Staleness Analysis

For each changed code file:
1. Find related documentation
2. Compare timestamps
3. Analyze if doc content matches code

**Staleness indicators**:
- Function signature changed but JSDoc unchanged
- New parameters not documented
- Removed features still documented
- Examples don't compile

### Phase 3: Documentation Update

For each stale doc:

1. **Read current code** - Understand actual behavior
2. **Read current doc** - Identify discrepancies
3. **Update doc** - Match code behavior
4. **Verify** - Examples still work

### Phase 4: Sync Report

```markdown
## Documentation Sync Report

### Files Synced
| File | Changes |
|------|---------|
| {doc_path} | {what changed} |

### Still Out of Sync
| File | Reason |
|------|--------|
| {doc_path} | {reason} |

### Verification
- [ ] Examples compile
- [ ] Links valid
- [ ] Content accurate
```

### Phase 5: Workflow Transition

```json
{
  "questions": [{
    "question": "Documentation synced. {count} files updated. Continue?",
    "header": "Next",
    "options": [
      {"label": "/x-verify (Recommended)", "description": "Full quality gates"},
      {"label": "/x-git commit", "description": "Commit doc updates"},
      {"label": "Stop", "description": "Review updates first"}
    ],
    "multiSelect": false
  }]
}
```

</instructions>

## Sync Rules

| Code Change | Doc Action |
|-------------|------------|
| New parameter | Add @param |
| Removed parameter | Remove @param |
| Changed return | Update @returns |
| New error case | Add @throws |
| Behavior change | Update description |

<critical_rules>

1. **Doc Follows Code** - Code is source of truth
2. **Verify Examples** - Must compile/run
3. **Check Links** - No broken references
4. **Atomic Updates** - One doc per commit

</critical_rules>

## References

- @skills/documentation/SKILL.md - Doc patterns
- @core-docs/DOCUMENTATION-FRAMEWORK.md - Standards

<success_criteria>

- [ ] Changes detected
- [ ] Stale docs identified
- [ ] Updates applied
- [ ] Sync verified

</success_criteria>
