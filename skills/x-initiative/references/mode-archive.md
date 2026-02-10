# Mode: archive

> **Invocation**: `/x-initiative archive` or `/x-initiative archive "name"`

<purpose>
Initiative archival with comprehensive documentation updates and lessons learned capture.
</purpose>

## References

Archive checkpoint patterns: See @skills/initiative/references/checkpoint-protocol.md and @skills/initiative/references/memory.md

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 20%, context 25%, technical 15%, scope 25%, risk 15%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Completion criteria unclear, which initiative to archive unclear.

---

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

### Phase 3: Generate Executive Summary

Read the initiative folder (`_active/{name}/`) and distill into a **single** archive file.
Do NOT copy the folder — generate a summary then delete the source.

Write `documentation/milestones/_archived/{name}.md`:

```markdown
# Archive: {Name}

**Status**: Completed
**Duration**: {start_date} → {end_date}
**Milestones**: {count} completed

## Summary

{2-3 sentence overview of what the initiative accomplished and why it mattered}

## Milestones

| # | Name | Outcome |
|---|------|---------|
| M1 | {name} | {one-line result} |
| M2 | {name} | {one-line result} |

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| {decision} | {why} | {result} |

## Lessons Learned

- **What worked**: {lesson}
- **What to improve**: {lesson}

## Key Deliverables

- {deliverable with file path if relevant}
```

Keep it **under 80 lines**. This is a reference document, not a copy of the initiative.

### Phase 4: Archive Operations

1. **Write executive summary**:
   ```bash
   # Single file, not a folder
   documentation/milestones/_archived/{name}.md
   ```

2. **Delete active initiative folder**:
   ```bash
   rm -rf documentation/milestones/_active/{name}/
   ```

3. **Remove file checkpoint**:
   ```bash
   rm .claude/initiative.json
   ```

4. **Clear Memory MCP checkpoint** (OPTIONAL — graceful degradation):
   Delete the `initiative-checkpoint` entity from persistent cross-session storage.
   If persistent storage is unavailable, skip — file is the primary SSoT.

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
- [ ] Lessons captured
- [ ] Executive summary written to `_archived/{name}.md`
- [ ] Active folder deleted
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
- [ ] Executive summary generated (single file, <80 lines)
- [ ] Active folder deleted
- [ ] Checkpoint removed

</success_criteria>
