---
name: x-fix
description: Use when you have a clear bug with an obvious fix that doesn't need full planning.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
user-invocable: true
argument-hint: "<bug description>"
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
chains-to:
  - skill: git-commit
    condition: "quick commit"
  - skill: x-review
    condition: "verify first"
chains-from:
  - skill: git-check-ci
  - skill: x-troubleshoot
  - skill: x-analyze
---

# /x-fix

> Apply targeted fixes for clear errors with minimal overhead.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | ONESHOT |
| **Phase** | complete |
| **Position** | 1 of 1 (self-contained) |

**Flow**: **`x-fix`** → `[optional: x-review quick]` → `git-commit`

## Intention

**Error/Issue**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Ask user: "What error or issue would you like to fix?"
{{/if}}

## Behavioral Skills

This skill activates:
- `debugging-performance` - Debug methodology (lightweight)
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

### Phase 0b: Workflow State Check

1. Read `.claude/workflow-state.json` (if exists)
2. If active APEX workflow exists with `troubleshoot` completed → This is a DEBUG→FIX transition, proceed
3. If active ONESHOT workflow exists → Continue ONESHOT
4. If no active workflow → Create new ONESHOT workflow state

### Phase 1: Error Analysis

<doc-query trigger="error-lookup">
  <purpose>Look up library API documentation relevant to the error type and affected code</purpose>
  <context>Quick API lookup to inform fix approach — ONESHOT workflow needs fast resolution</context>
</doc-query>

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

<agent-delegate role="test runner" subagent="x-tester" model="sonnet">
  <prompt>Run affected tests for {affected_file} — verify fix works and no regressions introduced</prompt>
  <context>Post-fix verification in ONESHOT workflow — quick targeted test run</context>
</agent-delegate>

Run affected tests immediately:
```bash
pnpm test -- --testPathPattern="{affected_file}"
```

Requirements:
- All affected tests pass
- No regressions introduced

### Phase 4: Update Workflow State

After fix applied and verified:

1. Read `.claude/workflow-state.json`
2. Mark `fix` phase as `"completed"` with timestamp
3. Set next phase based on workflow type:
   - ONESHOT: Set `commit` as next (or `verify` if requested)
   - DEBUG: Set `verify` or `commit` as next
4. Write updated state to `.claude/workflow-state.json`

<state-checkpoint phase="fix" status="completed">
  <file path=".claude/workflow-state.json">Mark fix complete, set next phase (verify or commit) pending approval</file>
</state-checkpoint>

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

**Next Verbs**: `/x-review` (optional), `/git-commit`

| Trigger | Chain To | Auto? |
|---------|----------|-------|
| "verify first" | `/x-review` | No (ask) |
| "quick commit" | `/git-commit` | **HUMAN APPROVAL** |
| Complex issue | `/x-troubleshoot` | No (escalate) |
| Needs implementation | `/x-implement` | No (escalate) |

<chaining-instruction>

**Human approval required**: fix → commit (or verify)

After fix applied and verified:
1. Update `.claude/workflow-state.json` (mark fix complete, set next phase pending approval)
2. Present options (requires human selection):
   "Fix applied and verified. What's next?"
3. On selection, invoke via Skill tool:
   - skill: "x-review" or "git-commit"
   - args: "{fix summary and affected files}"

<workflow-gate type="choice" id="fix-next">
  <question>Fix applied and verified. What's next?</question>
  <header>After fix</header>
  <option key="verify">
    <label>Full verification</label>
    <description>Run all quality gates before committing</description>
  </option>
  <option key="commit" recommended="true" approval="required">
    <label>Quick commit</label>
    <description>Commit the fix directly (requires approval)</description>
  </option>
  <option key="stop">
    <label>Stop here</label>
    <description>Manual review first</description>
  </option>
</workflow-gate>

<workflow-chain on="verify" skill="x-review" args="{fix summary and affected files}" />
<workflow-chain on="commit" skill="git-commit" args="{fix summary and affected files}" />
<workflow-chain on="stop" action="end" />

**Escalation**: If fix complexity increases, suggest:
"Fix is more complex than expected. Escalate?"
- Option 1: `/x-troubleshoot` - Deep investigation
- Option 2: `/x-implement` - Full implementation
- Option 3: Continue fixing

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
| Next (verify) | `/x-review` | Want full quality gates |
| Next (commit) | `/git-commit` | Ready to commit (approval) |
| Escalate | `/x-troubleshoot` | Issue is more complex |
| Escalate | `/x-implement` | Needs real implementation |

## Success Criteria

- [ ] Error cause identified
- [ ] Minimal fix applied
- [ ] Affected tests pass
- [ ] No regressions
- [ ] Workflow transition presented

## References

- @skills/quality-debugging-performance/ - Debugging strategies and methodology
