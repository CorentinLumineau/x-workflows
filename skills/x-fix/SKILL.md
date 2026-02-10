---
name: x-fix
description: Rapid bug fixing for clear errors with obvious solutions.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---

# /x-fix

> Apply targeted fixes for clear errors with minimal overhead.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | ONESHOT |
| **Phase** | complete |
| **Position** | 1 of 1 (self-contained) |

**Flow**: **`x-fix`** → `[optional: x-verify]` → `x-commit`

## Intention

**Error/Issue**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Ask user: "What error or issue would you like to fix?"
{{/if}}

## Behavioral Skills

This skill activates:
- `debugging` - Debug methodology (lightweight)
- `context-awareness` - Project context

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **test runner** | Post-fix verification | Can edit and run commands |

## MCP Servers

| Server | When |
|--------|------|
| `context7` | Library API lookup |

<instructions>

### Phase 0: Confidence Check (Lightweight)

For ONESHOT workflow, interview check can be bypassed when:
- Error message is specific
- Fix is deterministic
- Single file affected

Activate `@skills/interview/` if:
- Root cause unclear
- Multiple potential causes
- No reproduction steps

### Phase 1: Error Analysis

Parse the error:
1. **Identify error type** - Compile, runtime, test failure
2. **Locate source** - File, line, stack trace
3. **Classify complexity**:
   - **Clear**: Obvious cause → Fix immediately
   - **Ambiguous**: 2-3 possible causes → Quick hypotheses
   - **Complex**: Multi-layer → **Escalate to /x-troubleshoot**

### Phase 2: Quick Fix

**For clear errors:**

| Error Type | Action |
|------------|--------|
| Type error | Add type guard/fix type |
| Import error | Add missing import |
| Test failure | Fix logic OR update expectation |
| Runtime error | Check null/undefined, add validation |
| Typo | Correct spelling |
| Syntax error | Fix syntax |

**For ambiguous errors (2-3 possible causes):**
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

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | Commit without full verify |
| **High** | ASK IF ABLE | Multiple fix approaches |
| **Medium** | ASK IF UNCERTAIN | Escalation to troubleshoot |
| **Low** | PROCEED | Apply obvious fix |

<human-approval-framework>

When approval needed, structure question as:
1. **Context**: Error identified and fix applied
2. **Options**: Verify fully, quick commit, or review
3. **Recommendation**: Appropriate next step
4. **Escape**: "Escalate to /x-troubleshoot" option

</human-approval-framework>

## Agent Delegation

**Recommended Agent**: None (fast inline execution)

| Delegate When | Keep Inline When |
|---------------|------------------|
| Post-fix test run (optional) | Applying the fix |
| Error spans 3+ components | Single file fix |

## Workflow Chaining

**Next Verbs**: `/x-verify` (optional), `/x-commit`

| Trigger | Chain To | Auto? |
|---------|----------|-------|
| "verify first" | `/x-verify` | No (ask) |
| "quick commit" | `/x-commit` | **HUMAN APPROVAL** |
| Complex issue | `/x-troubleshoot` | No (escalate) |
| Needs implementation | `/x-implement` | No (escalate) |

<chaining-instruction>

After fix applied:
"Fix applied and verified. What's next?"
- Option 1: `/x-verify` - Full quality gates
- Option 2: `/x-commit` - Quick commit (requires approval)
- Option 3: Stop - Manual review first

**Escalation**: If fix complexity increases, suggest:
- skill: "x-troubleshoot"
- args: "{error description and attempted fixes}"

</chaining-instruction>

## Escalation Rules

| Situation | Escalate To |
|-----------|-------------|
| Root cause unclear | `/x-troubleshoot` |
| Intermittent failure | `/x-troubleshoot` |
| Multi-layer issue | `/x-troubleshoot` |
| Need flow understanding | `/x-troubleshoot` |
| Needs architectural change | `/x-implement` |

## Critical Rules

1. **Speed First** - Minimal overhead, just fix
2. **Clear Errors Only** - Obvious cause, obvious solution
3. **Verify Immediately** - Run affected tests
4. **Escalate Complexity** - Don't struggle, route appropriately

## Navigation

| Direction | Verb | When |
|-----------|------|------|
| Next (verify) | `/x-verify` | Want full quality gates |
| Next (commit) | `/x-commit` | Ready to commit (approval) |
| Escalate | `/x-troubleshoot` | Issue is more complex |
| Escalate | `/x-implement` | Needs real implementation |

## Success Criteria

- [ ] Error cause identified
- [ ] Minimal fix applied
- [ ] Affected tests pass
- [ ] No regressions
- [ ] Workflow transition presented

## References

- @skills/quality-debugging/ - Debugging strategies and methodology
