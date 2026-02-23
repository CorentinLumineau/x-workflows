---
name: x-troubleshoot
description: Use when facing an error with unclear root cause requiring investigation.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
user-invocable: true
argument-hint: "<error or symptom>"
metadata:
  author: ccsetup contributors
  version: "2.0.0"
  category: workflow
chains-to:
  - skill: x-fix
    condition: "simple fix found"
  - skill: x-implement
    condition: "complex fix needed"
chains-from: []
---

# /x-troubleshoot

> Investigate issues systematically with hypothesis-driven debugging.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | DEBUG |
| **Phase** | complete |
| **Position** | 1 of 1 (entry point) |

**Flow**: **`x-troubleshoot`** → `x-fix` (simple) OR `x-implement` (complex)

## Intention

**Problem**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Ask user: "What issue are you experiencing?"
{{/if}}

## Behavioral Skills

This skill activates:
- `interview` - Zero-doubt confidence gate (Phase 0)
- `debugging-performance` - Hypothesis-driven debugging methodology

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **debugger** | Complex multi-layer investigation | Runtime investigation |
| **codebase explorer** | Codebase search, dependency tracing | Fast, read-only |

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Complex hypothesis evaluation |

<instructions>

### Phase 0: Confidence Check

Activate `@skills/interview/` if:
- Problem description unclear
- No reproduction steps provided
- Multiple systems potentially involved

### Phase 0b: Workflow State Check

1. Read `.claude/workflow-state.json` (if exists)
2. If active workflow exists:
   - Expected workflow is DEBUG? → Proceed
   - Active non-DEBUG workflow? → Warn: "Active {type} workflow at {phase}. Start DEBUG? [Y/n]"
3. If no active workflow → Create new DEBUG workflow state

### Phase 1: Observe

<agent-delegate role="codebase explorer" subagent="x-explorer" model="haiku">
  <prompt>Search codebase for code related to the reported issue — trace dependencies, find error sources, gather context</prompt>
  <context>Observation phase of DEBUG workflow — gathering symptoms and related code paths</context>
</agent-delegate>

Gather symptoms and context:

1. **Error Messages** - Exact text, stack traces
2. **Environment** - Where does it occur?
3. **Reproducibility** - Always? Sometimes? Specific conditions?
4. **Recent Changes** - What changed before the issue appeared?

### Phase 2: Hypothesize

<deep-think purpose="hypothesis formation" context="Generating and ranking diagnostic hypotheses from symptoms and evidence">
  <purpose>Form and prioritize 2-3 hypotheses for root cause based on observed symptoms</purpose>
  <context>Symptoms gathered in Phase 1; need structured reasoning to evaluate likelihood, testability, and potential impact of each hypothesis</context>
</deep-think>

Form 2-3 potential causes:

```
Hypothesis 1: [Most likely cause based on symptoms]
Evidence for: [What supports this]
Evidence against: [What contradicts this]

Hypothesis 2: [Alternative cause]
Evidence for: [What supports this]
Evidence against: [What contradicts this]
```

**Prioritize by:**
- Likelihood based on evidence
- Ease of testing
- Potential impact

### Phase 3: Test

<agent-delegate role="debugger" subagent="x-debugger" model="sonnet">
  <prompt>Validate hypotheses systematically — test most likely hypothesis first, design minimal reproduction, record results</prompt>
  <context>Hypothesis testing phase of DEBUG workflow — need runtime investigation to confirm or refute root cause</context>
</agent-delegate>

Validate hypotheses systematically:

```
1. Start with most likely hypothesis
2. Design minimal test to confirm/refute
3. Execute test
4. Record results
5. If confirmed → Resolve
6. If refuted → Next hypothesis
```

### Phase 4: Resolve

Based on findings, route to appropriate action:

| Finding | Route To |
|---------|----------|
| Simple, clear fix | `/x-fix` |
| Complex fix needed | `/x-implement` |
| Needs architectural change | `/x-plan` |
| Root cause still unclear | Continue investigation |

### Phase 5: Update Workflow State

After root cause resolution:

1. Read `.claude/workflow-state.json`
2. Mark `troubleshoot` phase as `"completed"` with timestamp
3. Set next phase based on resolution:
   - Simple fix → Set `fix` as next
   - Complex fix → Set `implement` as next
   - Architecture issue → Set `plan` as next
4. Write updated state to `.claude/workflow-state.json`

<state-checkpoint phase="troubleshoot" status="completed">
  <file path=".claude/workflow-state.json">Mark troubleshoot complete, set next phase based on resolution (fix/implement/plan)</file>
</state-checkpoint>

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | Route to x-implement (scope expansion) |
| **High** | ASK IF ABLE | Multiple valid hypotheses |
| **Medium** | ASK IF UNCERTAIN | Hypothesis testing approach |
| **Low** | PROCEED | Continue investigation |

<human-approval-framework>

When approval needed, structure question as:
1. **Context**: What was investigated and found
2. **Options**: Different resolution paths
3. **Recommendation**: Best path based on findings
4. **Escape**: "Continue investigating" option

</human-approval-framework>

## Agent Delegation

**Recommended Agent**: **debugger** (runtime investigation)

| Delegate When | Keep Inline When |
|---------------|------------------|
| Multi-layer issue | Single component |
| Production environment | Local development |

## Workflow Chaining

**Next Verbs**: `/x-fix`, `/x-implement`

| Trigger | Chain To |
|---------|----------|
| Simple fix found | `/x-fix` (suggest) |
| Complex fix needed | `/x-implement` (**approval**) |
| Needs planning | `/x-plan` (suggest) |

<chaining-instruction>

When root cause is found:

<workflow-gate type="choice" id="troubleshoot-resolve">
  <question>Root cause identified. How would you like to proceed?</question>
  <header>Resolution</header>
  <option key="fix" recommended="true">
    <label>Apply fix</label>
    <description>Attempt a targeted fix based on root cause</description>
  </option>
  <option key="implement" approval="required">
    <label>Full implementation</label>
    <description>Start APEX workflow for comprehensive fix (scope expansion)</description>
  </option>
  <option key="plan">
    <label>Plan first</label>
    <description>Create implementation plan before coding</description>
  </option>
  <option key="continue">
    <label>Continue investigating</label>
    <description>Keep debugging for more clarity</description>
  </option>
</workflow-gate>

<workflow-chain on="fix" skill="x-fix" args="{root cause analysis and recommended approach}" />
<workflow-chain on="implement" skill="x-implement" args="{root cause analysis and recommended approach}" />
<workflow-chain on="plan" skill="x-plan" args="{root cause analysis and recommended approach}" />
<workflow-chain on="continue" action="end" />

</chaining-instruction>

## Debugging Methodology

```
1. Observe  - Gather symptoms, error messages
2. Hypothesize - Form 2-3 potential causes
3. Test - Validate hypotheses systematically
4. Resolve - Apply fix, verify solution
```

## Complexity Detection

Use `complexity-detection` skill to route appropriately:

| Signal | Tier | Action |
|--------|------|--------|
| Clear error + line number | Simple | Route to /x-fix |
| "how does", "trace" | Moderate | Stay in troubleshoot |
| "intermittent", "random" | Complex | Full investigation |

## Escalation Rules

| Complexity | Route To |
|------------|----------|
| Clear error, obvious fix | `/x-fix` |
| Need flow understanding | Stay in troubleshoot |
| Intermittent, multi-layer | Full investigation, may need `/x-initiative` |

## Critical Rules

1. **Systematic Approach** - Follow observe → hypothesize → test → resolve
2. **Document Findings** - Record what was tried and learned
3. **Don't Guess** - Test hypotheses, don't assume
4. **Escalate Appropriately** - Complex issues need proper tracking

## Navigation

| Direction | Verb | When |
|-----------|------|------|
| Next (simple) | `/x-fix` | Root cause is simple |
| Next (complex) | `/x-implement` | Needs real implementation (approval) |
| Escalate | `/x-initiative` | Multi-session debugging needed |

## Success Criteria

- [ ] Symptoms clearly documented
- [ ] Hypotheses formed and tested
- [ ] Root cause identified
- [ ] Fix verified
- [ ] Knowledge captured

## When to Load References

- **For troubleshoot workflow**: See `references/mode-troubleshoot.md`
- **For debug patterns**: See `references/mode-debug.md`
- **For explanation mode**: See `references/mode-explain.md`

## References

- @skills/quality-debugging-performance/ - Debugging strategies and methodology
