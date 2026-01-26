# Mode: cleanup

> **Invocation**: `/x-docs cleanup` or `/x-docs cleanup "scope"`
> **Legacy Command**: `/x:cleanup-docs`

<purpose>
Documentation cleanup - identify and fix stale, broken, or outdated documentation. Remove dead docs, fix broken links.
</purpose>

## Behavioral Skills

This mode activates:
- `documentation` - Doc patterns

## Agents

| Agent | When | Model |
|-------|------|-------|
| `ccsetup:x-explorer` | Doc analysis | haiku |

<instructions>

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
      {"label": "/x-git commit", "description": "Commit cleanup"},
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

## References

- @core-docs/DOCUMENTATION-FRAMEWORK.md - Structure
- @skills/documentation/SKILL.md - Patterns

<success_criteria>

- [ ] Issues identified
- [ ] Dead docs removed
- [ ] Broken links fixed
- [ ] Report generated

</success_criteria>
