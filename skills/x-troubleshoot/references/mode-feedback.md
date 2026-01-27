# Mode: feedback

> **Invocation**: `/x-troubleshoot feedback` or `/x-troubleshoot feedback "issue"`
> **Legacy Command**: `/x:feedback`

<purpose>
Post-implementation feedback intake. Captures bugs, adjustments, or refinements discovered after implementation, categorizes them, and routes to appropriate action using hybrid approach: quick fixes auto-route, complex issues queue for review.
</purpose>

## Behavioral Skills

This mode activates:
- `complexity-detection` - Determines fix vs debug vs troubleshoot
- `context-awareness` - Project context

## When to Use

- Bug discovered during testing
- User/QA feedback received
- Self-review found issues
- Iterative refinement needed

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 35%, context 25%, technical 20%, scope 15%, risk 5%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Feedback type unclear, severity unclear, affected areas unknown.

---

## Instructions

### Phase 1: Intake

Capture the feedback with structured questions:

```json
{
  "questions": [{
    "question": "What type of issue is this?",
    "header": "Type",
    "options": [
      {"label": "Bug", "description": "Something is broken or not working as expected"},
      {"label": "Adjustment", "description": "Works but needs tweaking or refinement"},
      {"label": "Enhancement", "description": "Works but could be better"},
      {"label": "Regression", "description": "Something that worked before is now broken"}
    ],
    "multiSelect": false
  }]
}
```

### Phase 2: Gather Details

For each type, gather specific information:

**For Bugs/Regressions:**
- What is the expected behavior?
- What is the actual behavior?
- Steps to reproduce?
- Error message (if any)?

**For Adjustments/Enhancements:**
- What needs to change?
- Why is this needed?
- What's the impact if not addressed?

### Phase 3: Locate

Identify affected code:

```json
{
  "questions": [{
    "question": "Do you know where the issue is?",
    "header": "Location",
    "options": [
      {"label": "Yes, specific file", "description": "I know exactly which file(s)"},
      {"label": "Yes, general area", "description": "I know the feature/component"},
      {"label": "No idea", "description": "Need to investigate"}
    ],
    "multiSelect": false
  }]
}
```

If location unknown, use x-explorer agent to find affected code.

### Phase 4: Complexity Assessment

Use complexity-detection behavioral skill criteria:

| Complexity | Criteria | Indicators |
|------------|----------|------------|
| **Quick** | 1-2 files, obvious fix, <30 min | Clear error, single cause |
| **Medium** | 3-5 files, some investigation, <2 hours | Multiple symptoms, unclear root |
| **Complex** | 6+ files, deep investigation, >2 hours | Intermittent, multi-layer, architectural |

### Phase 5: Route (Hybrid Approach)

Based on complexity, route automatically or queue:

#### Quick Issues (Auto-Route)
```markdown
**Routing Decision**: Quick fix detected
- Type: {bug/adjustment}
- Location: {file(s)}
- Estimated effort: <30 min

**Auto-routing to**: `/x:fix`
```

Then invoke: `/x-implement fix {description}`

#### Medium Issues (Route with Confirmation)
```json
{
  "questions": [{
    "question": "Medium complexity detected. How should I proceed?",
    "header": "Action",
    "options": [
      {"label": "Debug now (Recommended)", "description": "Investigate and fix immediately"},
      {"label": "Queue for later", "description": "Add to backlog, continue current work"},
      {"label": "Create initiative", "description": "This is bigger than expected"}
    ],
    "multiSelect": false
  }]
}
```

#### Complex Issues (Queue + Create Tracking)

```markdown
**Routing Decision**: Complex issue detected
- Type: {bug/adjustment/enhancement}
- Scope: {affected areas}
- Estimated effort: >2 hours

**Action**: Creating tracking entry

## Issue: {Title}

**Source**: Post-implementation feedback
**Discovered**: {date}
**Severity**: {critical/high/medium/low}

### Description
{User's description}

### Affected Areas
- {file/component 1}
- {file/component 2}

### Suggested Approach
{Brief recommendation}

**Next Step**: Use `/x:troubleshoot` or `/x:initiative create` when ready to address.
```

Add to TodoWrite for tracking.

</instructions>

## Feedback Categories

| Category | Typical Route | Urgency |
|----------|---------------|---------|
| Bug - Critical | `/x:fix` immediately | High |
| Bug - Non-critical | `/x:fix` or queue | Medium |
| Adjustment | `/x:fix` or `/x:refactor` | Low |
| Enhancement | Queue or `/x:initiative` | Low |
| Regression | `/x:troubleshoot` | High |

## Integration with Other Commands

| Scenario | Handoff To |
|----------|------------|
| Quick bug fix | `/x-implement fix` |
| Code flow issue | `/x-troubleshoot debug` |
| Deep investigation needed | `/x-troubleshoot` |
| Architectural issue | `/x:initiative create` |
| Code quality issue | `/x-implement refactor` |

<critical_rules>

## Critical Rules

1. **Always Categorize First** - Type determines routing
2. **Assess Complexity** - Don't underestimate scope
3. **Quick Fixes Go Fast** - Auto-route simple issues
4. **Complex Gets Tracked** - Never lose complex feedback
5. **User Decides Timing** - Medium issues ask for confirmation

</critical_rules>

<success_criteria>

## Success Criteria

- [ ] Feedback captured with clear description
- [ ] Type categorized (bug/adjustment/enhancement/regression)
- [ ] Complexity assessed (quick/medium/complex)
- [ ] Appropriate routing applied
- [ ] Complex issues tracked in TodoWrite

</success_criteria>

## References

- @skills/complexity-detection/SKILL.md - Complexity assessment
- @skills/x-implement/references/mode-fix.md - Fix mode
- @skills/x-initiative/references/mode-create.md - Initiative creation

---

**Version**: 5.1.2
