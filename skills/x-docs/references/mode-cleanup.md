# Mode: cleanup

> **Invocation**: `/x-docs cleanup` or `/x-docs cleanup "scope"`
> **Legacy Command**: `/x:cleanup-docs`

<purpose>
Documentation cleanup - identify and fix stale, broken, or outdated documentation. Remove dead docs, fix broken links.
</purpose>

## References

See `doc-sync-patterns.md` for documentation patterns.

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **codebase explorer** | Doc analysis | Fast, read-only |

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 20%, context 25%, technical 20%, scope 20%, risk 15%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Deletion criteria unclear, cleanup scope undefined.

---

### Phase 1: Issue Detection

Find documentation issues:

#### Broken Links
```bash
# Find markdown links
grep -r '\[.*\](.*\.md)' documentation/

# Check each link exists
```

#### Dead References
- Docs referencing deleted code
- Docs for removed features
- Orphaned documentation files

#### Stale Content
- Outdated instructions
- Old screenshots
- Deprecated API references

### Phase 2: Issue Classification

| Issue Type | Action |
|------------|--------|
| Broken internal link | Fix or remove |
| Broken external link | Update or remove |
| Dead doc (no code) | Remove |
| Stale content | Update or remove |
| Orphaned file | Archive or remove |

### Phase 3: Cleanup Execution

For each issue:

1. **Verify it's truly dead** - No references, no use
2. **Remove or update** - Based on classification
3. **Verify no breakage** - Links still work

### Phase 4: Cleanup Report

```markdown
## Documentation Cleanup Report

### Removed
| File | Reason |
|------|--------|
| {path} | {reason} |

### Fixed
| Issue | Fix |
|-------|-----|
| Broken link in {file} | Updated to {new_link} |

### Remaining Issues
| Issue | Reason Not Fixed |
|-------|------------------|
| {issue} | {reason} |
```

### Phase 5: Workflow Transition

```json
{
  "questions": [{
    "question": "Cleanup complete. Removed {removed}, fixed {fixed}. Continue?",
    "header": "Next",
    "options": [
      {"label": "/x-verify (Recommended)", "description": "Verify changes"},
      {"label": "/git-create-commit", "description": "Commit cleanup"},
      {"label": "Stop", "description": "Review first"}
    ],
    "multiSelect": false
  }]
}
```

</instructions>

## What NOT to Remove

- Documentation with `@deprecated` tag (keep until replacement ready)
- Historical documentation (archive instead)
- Documentation referenced in code comments
- Integration documentation (may be external)

<critical_rules>

1. **Verify Before Delete** - Confirm no references
2. **Archive Not Delete** - For significant docs
3. **Fix Links First** - Try to fix before removing
4. **Document Removals** - Track what was removed

</critical_rules>

## Additional References

- @core-docs/DOCUMENTATION-FRAMEWORK.md - Structure
- `doc-sync-patterns.md` - Patterns

<success_criteria>

- [ ] Issues identified
- [ ] Dead docs removed
- [ ] Broken links fixed
- [ ] Report generated

</success_criteria>
