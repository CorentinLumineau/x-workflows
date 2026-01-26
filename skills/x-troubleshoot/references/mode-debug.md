# Mode: debug

> **Invocation**: `/x-troubleshoot debug` or `/x-troubleshoot debug "description"`
> **Legacy Command**: `/x:debug`

<purpose>
Intermediate debugging to understand code flow, trace execution, and debug moderate complexity issues. Sits between quick fixes and deep troubleshooting.
</purpose>

## Behavioral Skills

This mode activates:
- `debugging` - Debug methodology
- `context-awareness` - Code understanding

## Agents

| Agent | When | Model |
|-------|------|-------|
| `ccsetup:x-refactorer` | Flow tracing | sonnet |
| `ccsetup:x-explorer` | Code exploration | haiku |

## MCP Servers

| Server | When |
|--------|------|
| `context7` | Library behavior lookup |

<instructions>

## Instructions

### Phase 1: Issue Understanding

Understand what needs debugging:

| Type | Approach |
|------|----------|
| Wrong output | Trace data transformation |
| No output | Check control flow |
| Exception | Analyze stack trace |
| Performance | Profile hot paths |

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

Form focused hypotheses:

1. **Primary hypothesis**: Based on flow analysis
2. **Test**: Add logging, breakpoints, or assertions
3. **Verify**: Does the evidence support the hypothesis?

### Phase 4: Fix Application

Once issue found:
1. Apply minimal fix
2. Verify fix works
3. Ensure no regressions

### Phase 5: Workflow Transition

Present next step:
```json
{
  "questions": [{
    "question": "Debug complete. Issue found in {location}. Continue?",
    "header": "Next",
    "options": [
      {"label": "/x-implement fix (Recommended)", "description": "Apply the fix"},
      {"label": "/x-verify", "description": "Run tests"},
      {"label": "Stop", "description": "Review first"}
    ],
    "multiSelect": false
  }]
}
```

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

- @core-docs/error-handling/debugging-strategies.md - Techniques
- @skills/debugging/SKILL.md - Methodology
