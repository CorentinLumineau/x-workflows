# Mode: fix

> **Invocation**: `/x-implement fix` or `/x-implement fix "description"`
> **Legacy Command**: `/x:fix`

<purpose>
Rapid bug fixing for clear errors with obvious solutions. Parse error, identify cause, apply minimal fix, verify immediately. Escalate unclear issues to debug or troubleshoot modes.
</purpose>

## Behavioral Skills

This mode activates:
- `debugging` - Debug methodology
- `context-awareness` - Project context

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **refactoring agent** | Error spans 3+ components | Safe restructuring |
| **test runner** | Post-fix verification | Can edit and run commands |

## MCP Servers

| Server | When |
|--------|------|
| `context7` | Library API lookup |

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 30%, context 25%, technical 25%, scope 10%, risk 10%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Root cause unclear, multiple potential causes, no reproduction steps.

**Bypass allowed**: If error message is specific and fix is deterministic (trivial action).

---

### Phase 1: Error Analysis

Parse the error:
1. **Identify error type** - Compile, runtime, test failure
2. **Locate source** - File, line, stack trace
3. **Classify complexity**:
   - **Clear**: Obvious cause → Fix immediately
   - **Ambiguous**: 2-3 possible causes → Quick hypotheses
   - **Complex**: Multi-layer → Escalate

### Phase 2: Quick Fix

**For clear errors**:

| Error Type | Action |
|------------|--------|
| Type error | Add type guard/fix type |
| Import error | Add missing import |
| Test failure | Fix logic OR update expectation |
| Runtime error | Check null/undefined, add validation |

**For ambiguous errors** (2-3 possible causes):
1. Form quick hypotheses (max 3)
2. Test most likely first
3. Apply first working fix

### Phase 3: Verification

Run affected tests immediately:
```bash
pnpm test -- --testPathPattern="{affected_file}"
```

Requirements:
- All affected tests pass
- No regressions introduced

### Phase 4: Workflow Transition

Present next step:
```json
{
  "questions": [{
    "question": "Fix applied and verified. Continue?",
    "header": "Next",
    "options": [
      {"label": "/x-verify (Recommended)", "description": "Full quality gates"},
      {"label": "/x-git commit", "description": "Commit the fix"},
      {"label": "Stop", "description": "Manual review first"}
    ],
    "multiSelect": false
  }]
}
```
</instructions>

## Escalation Rules

| Situation | Escalate To |
|-----------|-------------|
| Root cause unclear | `/x-troubleshoot debug` |
| Intermittent failure | `/x-troubleshoot` |
| Multi-layer issue | `/x-troubleshoot` |
| Need flow understanding | `/x-troubleshoot debug` |

<critical_rules>
1. **Speed First** - Minimal overhead, just fix
2. **Clear Errors Only** - Obvious cause, obvious solution
3. **Verify Immediately** - Run affected tests
4. **Escalate Complexity** - Don't struggle, route appropriately
</critical_rules>

<decision_making>
**Execute immediately when**:
- Error message is clear
- Root cause is obvious
- Fix is straightforward

**Use lightweight hypotheses when**:
- 2-3 potential root causes
- Generic error message
- Can test in <30 seconds each

**Escalate when**:
- Intermittent failure
- Unclear root cause after 2-3 attempts
- Multi-layer issue
</decision_making>

## References

- @skills/quality-debugging/ - Debugging strategies and methodology

<success_criteria>
- [ ] Error cause identified
- [ ] Minimal fix applied
- [ ] Affected tests pass
- [ ] No regressions
- [ ] Workflow transition presented
</success_criteria>
