# Mode: troubleshoot

> **Invocation**: `/x-troubleshoot` or `/x-troubleshoot troubleshoot`
> **Legacy Command**: `/x:troubleshoot`

<purpose>
Deep diagnostic analysis for complex, intermittent, or multi-layer issues. Systematic root cause investigation using hypothesis testing methodology.
</purpose>

## Behavioral Skills

This mode activates:
- `debugging` - Hypothesis testing methodology
- `context-awareness` - System understanding

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **refactoring agent** | Deep investigation | Safe restructuring |
| **codebase explorer** | System exploration | Fast, read-only |

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Hypothesis formation |
| `context7` | Library documentation |

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 30%, context 30%, technical 25%, scope 5%, risk 10%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Vague problem description, multiple hypotheses valid, no error message provided, environment unspecified.

---

## Instructions

### Phase 1: Symptom Collection

Gather all available information:

**Error Information**:
- Error message (exact text)
- Stack trace
- Error codes
- Affected users/requests

**Context**:
- When did it start?
- What changed recently?
- Frequency (always, sometimes, rarely)
- Affected systems/components

**Environment**:
- Production vs development
- Browser/OS/device
- Network conditions
- Recent deployments

### Phase 2: Hypothesis Formation

Using Sequential Thinking, form 2-5 hypotheses:

```
Symptom: {observed behavior}

Hypothesis 1 (Most Likely): {cause}
- Evidence for: {supporting facts}
- Evidence against: {contradicting facts}
- Test: {how to verify}

Hypothesis 2: {cause}
- Evidence for: {supporting facts}
- Evidence against: {contradicting facts}
- Test: {how to verify}

...
```

### Phase 3: Systematic Testing

For each hypothesis (starting with most likely):

1. **Design test** - Minimal, isolated test
2. **Predict outcome** - What will happen if hypothesis is true?
3. **Execute test** - Run the test
4. **Analyze result**:
   - Confirmed → Move to fix
   - Refuted → Next hypothesis
   - Inconclusive → Gather more data

### Phase 4: Root Cause Identification

When root cause found:

```markdown
## Root Cause Analysis

**Problem**: {symptom description}

**Root Cause**: {actual cause}

**Contributing Factors**:
- Factor 1
- Factor 2

**Evidence**:
- Evidence 1 confirming this
- Evidence 2 confirming this

**Why It Wasn't Caught**:
- Missing test coverage for {scenario}
- Edge case not considered
```

### Phase 5: Resolution & Prevention

1. **Immediate Fix**: Apply minimal fix
2. **Verify**: Confirm issue resolved
3. **Prevent Recurrence**:
   - Add test case
   - Update documentation
   - Add monitoring if needed

### Phase 6: Workflow Transition

Present next step:
```json
{
  "questions": [{
    "question": "Root cause identified: {cause}. How to proceed?",
    "header": "Next",
    "options": [
      {"label": "/x-implement fix (Recommended)", "description": "Apply the fix"},
      {"label": "/x-troubleshoot debug", "description": "Investigate more"},
      {"label": "Stop", "description": "Document findings first"}
    ],
    "multiSelect": false
  }]
}
```

</instructions>

## Debugging Markers

Use these markers for thinking transparency:

```
[ANALYZING] Examining {component}
[HYPOTHESIS] Suspecting {cause} because {evidence}
[TESTING] Verifying hypothesis by {method}
[DATA] Found: {finding}
[INSIGHT] This suggests {conclusion}
```

## Common Root Causes

| Pattern | Symptoms | Likely Cause |
|---------|----------|--------------|
| Intermittent | Random failures | Race condition, timing |
| After deploy | Worked before | Config change, env diff |
| Under load | Fine at low traffic | Resource exhaustion |
| Specific user | Others unaffected | Data-specific issue |
| Specific time | Pattern in timing | Scheduled job, timeout |

<critical_rules>

## Critical Rules

1. **Don't Guess** - Form and test hypotheses
2. **Document Everything** - Track what you tried
3. **One Variable** - Change one thing at a time
4. **Verify Fix** - Confirm resolution

</critical_rules>

## Decision Making

**Continue investigating when**:
- Root cause unclear
- Multiple potential causes
- Fix didn't work

**Move to fix when**:
- Root cause confirmed
- Evidence is clear
- Fix is obvious

<decision_making>

</decision_making>

<success_criteria>

## Success Criteria

- [ ] Symptoms documented
- [ ] Hypotheses formed
- [ ] Root cause identified
- [ ] Evidence documented
- [ ] Next step presented

</success_criteria>

## References

- @skills/quality-debugging/ - Debugging patterns and methodology
