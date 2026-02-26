---
name: x-archive
description: Use when an initiative is fully complete and needs to be archived.
version: "1.0.0"
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
user-invocable: true
argument-hint: "[initiative-name]"
metadata:
  author: ccsetup contributors
  category: workflow
---

# /x-archive

> Archive completed initiatives with lessons learned capture.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | UTILITY |
| **Phase** | N/A |
| **Position** | End of initiative lifecycle |

**Flow**: `/x-initiative create` → `[work]` → `/x-initiative continue` → **`/x-archive`**

## Intention

**Initiative**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Auto-detect from `.claude/initiative.json` or ask user to specify which initiative to archive.
{{/if}}

## Behavioral Skills

This skill activates:
- `interview` - Zero-doubt confidence gate (when completion unclear)
- `initiative` - Checkpoint/memory protocol

## References

Archive checkpoint patterns: See @skills/initiative/references/checkpoint-protocol.md

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

**Triggers for interview**: Completion criteria unclear, which initiative to archive unclear.

---

### Phase 1: Completion Verification

<workflow-gate options="archive,defer,cancel" default="archive">
Confirm initiative is ready for archival — verify all milestones complete, tests passing, documentation updated.
</workflow-gate>

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

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | Incomplete milestones detected |
| **High** | ASK IF ABLE | Tests failing |
| **Medium** | ASK IF UNCERTAIN | Lessons unclear |
| **Low** | PROCEED | Standard archive |

## Agent Delegation

**Recommended Agent**: None (file operations)

| Delegate When | Keep Inline When |
|---------------|------------------|
| Never | Always inline |

## Workflow Chaining

**Next Verbs**: `/x-initiative create`, `/x-initiative status`

| Trigger | Chain To | Auto? |
|---------|----------|-------|
| "new initiative" | `/x-initiative create` | No (suggest) |
| "status" | `/x-initiative status` | No (suggest) |
| "done" | Stop | Yes |

## Archive Checklist

Before archiving:
- [ ] All milestones complete
- [ ] Tests passing
- [ ] Lessons captured
- [ ] Executive summary written to `_archived/{name}.md`
- [ ] Active folder deleted
- [ ] Checkpoint removed

## Critical Rules

1. **Complete First** - Don't archive incomplete work
2. **Capture Lessons** - Future value
3. **Clean State** - No stale checkpoints
4. **Single File** - Archive is one file, not a folder copy

## Output Format

After successful archive:
```
Initiative archived:
- Name: {name}
- Duration: {start} → {end}
- Milestones: {count} completed
- Archive: documentation/milestones/_archived/{name}.md
- Lessons: {count} lessons captured

Next: /x-initiative create | /x-initiative status | Done
```

## Navigation

| Direction | Verb | When |
|-----------|------|------|
| Next (new) | `/x-initiative create` | Start new initiative |
| Next (view) | `/x-initiative status` | Check other initiatives |
| Done | Stop | Archive complete |

## Success Criteria

- [ ] Completion verified
- [ ] Lessons captured
- [ ] Executive summary generated (single file, <80 lines)
- [ ] Active folder deleted
- [ ] Checkpoint removed

## References

- @skills/initiative/references/checkpoint-protocol.md - Checkpoint lifecycle
