# Mode: archive

> **Invocation**: `/x-initiative archive` or `/x-initiative archive "name"`

<purpose>
Initiative archival with comprehensive documentation updates and lessons learned capture.
</purpose>

## Behavioral Skills

This mode activates:
- `initiative` - Tracking patterns

<instructions>

### Phase 1: Completion Verification

Verify initiative is ready for archival:

```markdown
## Archive Checklist

### Completion
- [ ] All milestones complete
- [ ] All tests passing
- [ ] Documentation updated

### Quality
- [ ] Code reviewed
- [ ] No TODOs remaining
- [ ] SOLID compliance verified

### Cleanup
- [ ] Temporary files removed
- [ ] Debug code removed
- [ ] Unused code removed
```

### Phase 2: Lessons Learned

Capture lessons:

```markdown
## Lessons Learned

### What Worked Well
- {lesson}

### What Could Be Better
- {lesson}

### Key Decisions
| Decision | Rationale | Outcome |
|----------|-----------|---------|
| {decision} | {why} | {result} |

### Patterns Discovered
- {pattern}: {when to use}
```

### Phase 3: Archive Operations

1. **Update initiative status**:
   ```markdown
   ## Status: Completed
   **Completed**: {date}
   ```

2. **Move to archive**:
   ```bash
   mv documentation/milestones/_active/{name}/ documentation/milestones/_archived/{name}/
   ```

3. **Update ARCHIVE.md**:
   ```markdown
   | {name} | {date} | {summary} | [Link]({path}) |
   ```

4. **Remove checkpoint**:
   ```bash
   rm .claude/initiative.json
   ```

### Phase 4: Final Report

```markdown
## Initiative Archive Report

**Initiative**: {name}
**Duration**: {start} → {end}
**Status**: Completed

### Summary
{brief summary}

### Milestones Completed
- M1: {name} ✓
- M2: {name} ✓

### Key Deliverables
- {deliverable}

### Lessons Learned
- {key lesson}

### Archive Location
`documentation/milestones/_archived/{name}/`
```

### Phase 5: Workflow Transition

```json
{
  "questions": [{
    "question": "Initiative '{name}' archived. What's next?",
    "header": "Next",
    "options": [
      {"label": "/x-initiative create", "description": "Start new initiative"},
      {"label": "/x-initiative status", "description": "View other initiatives"},
      {"label": "Done", "description": "All done for now"}
    ],
    "multiSelect": false
  }]
}
```

</instructions>

## Archive Checklist

Before archiving:
- [ ] All milestones complete
- [ ] Tests passing
- [ ] Docs updated
- [ ] Lessons captured
- [ ] ARCHIVE.md updated
- [ ] Checkpoint removed

<critical_rules>

## Critical Rules

1. **Complete First** - Don't archive incomplete work
2. **Capture Lessons** - Future value
3. **Update Index** - Maintain ARCHIVE.md
4. **Clear State** - No stale checkpoints

</critical_rules>

<success_criteria>

## Success Criteria

- [ ] Completion verified
- [ ] Lessons captured
- [ ] Files moved to archive
- [ ] Index updated
- [ ] Checkpoint removed

</success_criteria>
