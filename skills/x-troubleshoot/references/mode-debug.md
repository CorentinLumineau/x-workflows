# Mode: debug

> **Invocation**: `/x-troubleshoot debug` or `/x-troubleshoot debug "description"`
> **Legacy Command**: `/x:debug`

<purpose>
Intermediate debugging to understand code flow, trace execution, and debug moderate complexity issues. Sits between quick fixes and deep troubleshooting.
</purpose>

## Behavioral Skills

This mode activates:
- `debugging-performance` - Debug methodology
- `context-awareness` - Code understanding

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **refactoring agent** | Flow tracing | Safe restructuring |
| **codebase explorer** | Code exploration | Fast, read-only |

## MCP Servers

| Server | When |
|--------|------|
| `context7` | Library behavior lookup |

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 30%, context 25%, technical 30%, scope 5%, risk 10%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Reproduction unclear, debugging scope undefined, multiple potential causes.

---

## Instructions

### Phase 1: Issue Understanding

<user_interaction type="structured_question" required="true" id="error_type">

**Question**: What type of error are you seeing?

| Option | Description |
|--------|-------------|
| Wrong output | Getting results but they're incorrect |
| No output | Expected something but nothing happens |
| Exception | Application crashes or throws errors |
| Performance | Works but is slow or resource-intensive |

**Allow custom input**: Yes
**Multi-select**: No

</user_interaction>

<user_interaction type="freeform" required="true" id="error_details">

**Question**: Describe the error and how to reproduce it:

</user_interaction>

Based on `error_type`, apply the appropriate approach:

| Type | Approach |
|------|----------|
| Wrong output | Trace data transformation |
| No output | Check control flow |
| Exception | Analyze stack trace |
| Performance | Profile hot paths |

<checkpoint id="issue_understood" phase="1">

**Issue Understood**

- Error type: {error_type response}
- Description: {error_details response}
- Approach: {selected approach from table}

**Proceed to execution tracing?**

</checkpoint>

---

### Phase 2: Execution Tracing

Trace the execution path:

1. **Identify entry point** - Where does execution start?
2. **Map the flow** - What functions are called?
3. **Track data** - How does data transform?
4. **Find divergence** - Where does actual differ from expected?

```markdown
## Execution Flow

Entry: {function/endpoint}
  → Call: {function1}({args})
    → Returns: {value}
  → Call: {function2}({args})
    → **ISSUE HERE**: Expected {expected}, got {actual}
```

### Phase 3: Hypothesis Testing

<deep_reasoning topic="hypothesis_formation">

Based on the execution trace, form 2-3 hypotheses:

1. **Primary hypothesis**: Most likely cause based on flow analysis
2. **Secondary hypothesis**: Alternative explanation for the behavior
3. **Edge case hypothesis**: Less common but possible cause

For each hypothesis, determine:
- What evidence would support it?
- What evidence would refute it?
- What test would distinguish between hypotheses?

</deep_reasoning>

<user_interaction type="confirmation" required="true" id="hypothesis_confirmation">

**Proposed Investigation Order**:

1. **Most likely**: {Primary hypothesis}
2. **Alternative**: {Secondary hypothesis}
3. **Edge case**: {Edge case hypothesis}

Investigate in this order?

</user_interaction>

Form focused hypotheses:

1. **Primary hypothesis**: Based on flow analysis
2. **Test**: Add logging, breakpoints, or assertions
3. **Verify**: Does the evidence support the hypothesis?

### Phase 4: Fix Application

<checkpoint id="fix_ready" phase="4">

**Root Cause Identified**

- Location: {file:line where issue occurs}
- Cause: {description of the root cause}
- Proposed fix: {description of the fix}

**Apply this fix?**

</checkpoint>

Once issue found:
1. Apply minimal fix
2. Verify fix works
3. Ensure no regressions

---

### Phase 5: Workflow Transition

<user_interaction type="structured_question" required="true" id="next_step">

**Question**: Debug complete. Issue found in {location}. What's next?

| Option | Description |
|--------|-------------|
| /x-implement fix (Recommended) | Apply the fix |
| /x-review | Run tests to verify |
| Stop | Review first |

**Multi-select**: No

</user_interaction>

</instructions>

## Debugging Techniques

### Console Logging
```typescript
console.log('[DEBUG] functionName:', { input, state });
```

### Conditional Breakpoints
Set breakpoints that only trigger under specific conditions.

### Data Inspection
Check variable values at key points in execution.

### Binary Search
Narrow down issue location by eliminating half the code at a time.

## Common Debug Scenarios

| Scenario | Technique |
|----------|-----------|
| Async timing | Add timestamps, trace promise chains |
| State mutation | Log before/after mutations |
| API response | Inspect network, log responses |
| UI rendering | Check component props/state |

## When to Escalate

Escalate to `/x-troubleshoot` when:
- Issue is intermittent
- Multiple systems involved
- Root cause still unclear after 30 minutes
- Requires deep system knowledge

<critical_rules>

## Critical Rules

1. **Understand Before Fix** - Know why it's broken
2. **Minimal Logging** - Add logs strategically
3. **Clean Up** - Remove debug code after
4. **Document Findings** - For future reference

</critical_rules>

## Decision Making

**Fix inline when**:
- Issue found and clear
- Simple fix
- Low risk

**Escalate when**:
- Multiple potential causes
- Cross-system issue
- Need more investigation

<decision_making>

</decision_making>

<success_criteria>

## Success Criteria

- [ ] Execution traced
- [ ] Issue located
- [ ] Root cause understood
- [ ] Fix identified or escalated

</success_criteria>

## References

- @skills/quality/debugging-performance/ - Debugging techniques and methodology
