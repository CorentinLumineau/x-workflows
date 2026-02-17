# Mode: sync

> **Invocation**: `/x-docs sync` or `/x-docs sync "target"`
> **Legacy Command**: `/x:sync-docs`

<purpose>
Synchronize documentation with code changes. Detect staleness and update docs to match current implementation.
</purpose>

## References

See `doc-sync-patterns.md` for detailed sync patterns and staleness detection.

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **code reviewer** | Doc updates | Read-only analysis |
| **codebase explorer** | Code analysis | Fast, read-only |

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 20%, context 35%, technical 20%, scope 20%, risk 5%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Source of truth unclear, sync scope undefined.

---

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
      {"label": "/git-commit", "description": "Commit doc updates"},
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

## Additional References

- `doc-sync-patterns.md` - Doc patterns
- @core-docs/DOCUMENTATION-FRAMEWORK.md - Standards

<success_criteria>

- [ ] Changes detected
- [ ] Stale docs identified
- [ ] Updates applied
- [ ] Sync verified

</success_criteria>
