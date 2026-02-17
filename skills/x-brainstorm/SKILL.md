---
name: x-brainstorm
description: Use when starting from a vague idea that needs structured exploration.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
user-invocable: true
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
chains-to:
  - skill: x-research
    condition: "dig deeper"
  - skill: x-design
    condition: "ready to decide"
chains-from:
  - skill: x-research
---

# /x-brainstorm

> Capture ideas and discover requirements through structured exploration.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | BRAINSTORM |
| **Phase** | explore |
| **Position** | 1 of 3 in workflow |

**Flow**: `[start]` → **`x-brainstorm`** → `x-research` / `x-design`

## Intention

**Topic**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Ask user: "What would you like to brainstorm?"
{{/if}}

## Behavioral Skills

This skill activates:
- `interview` - Zero-doubt confidence gate (Phase 0)
- `analysis-architecture` - Pareto prioritization

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Idea structuring |
| `context7` | Reference implementations |

<instructions>

### Phase 0: Confidence Check (REQUIRED)

**ALWAYS activate** `@skills/interview/` — brainstorming is inherently exploratory and benefits from user interaction regardless of apparent clarity.

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 40%, context 30%, technical 10%, scope 15%, risk 5%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Ask clarifying question (use reformulation if > 80%)
   - Loop until 100%
4. **If confidence = 100% without questions** (context already sufficient):
   - MUST print what was understood and why no questions are needed
   - MUST offer escape hatch: "Say 'ask me more' if I missed anything"
   - Never silently skip — always communicate context sufficiency

**Bypass prohibition**: Do NOT skip Phase 0 based on apparent clarity. The "if" conditions below are interview *triggers*, not bypass gates:
- Problem space is undefined
- No success criteria exist
- Multiple stakeholders unspecified
- Vague topic with no constraints

<plan-mode phase="exploration" trigger="after-interview">
  <enter>After confidence gate passes, enter read-only exploration mode for discovery</enter>
  <scope>Phases 1-2: idea capture and requirements discovery (read-only: Glob, Grep, Read only)</scope>
  <exit trigger="requirements-gathered">Present structured requirements and priorities for user approval before committing to direction</exit>
</plan-mode>

### Phase 1: Idea Capture (MUST ASK)

Start with open exploration. **Wait for user response after each question.**

<workflow-gate type="choice" id="brainstorm-problem-type">
  <question>What problem are you trying to solve?</question>
  <header>Problem type</header>
  <option key="new-feature">
    <label>New feature</label>
    <description>Add new functionality to the system</description>
  </option>
  <option key="improvement">
    <label>Improvement</label>
    <description>Enhance an existing feature</description>
  </option>
  <option key="integration">
    <label>Integration</label>
    <description>Connect with external systems</description>
  </option>
  <option key="performance">
    <label>Performance</label>
    <description>Optimize for speed or efficiency</description>
  </option>
</workflow-gate>

After receiving problem type, ask the **Success Vision** question (freeform):

> **Describe the problem or idea in more detail. What would success look like?**

Wait for user response before proceeding to Phase 2.

### Phase 2: Requirements Discovery

Explore in parallel:
1. **Existing Patterns** - Search codebase for similar implementations
2. **Best Practices** - Look up recommended approaches via Context7

<doc-query trigger="requirements-discovery">
  <purpose>Look up recommended approaches and patterns for the problem domain</purpose>
  <context>Gathering best practices to inform requirements discovery</context>
</doc-query>

Gather:
- **Functional Requirements** - What should it do?
- **Non-Functional Requirements** - What qualities matter?
- **Constraints** - What limitations exist?

#### Requirements Validation Gate

Before prioritization, confirm understanding with the user:

<workflow-gate type="choice" id="brainstorm-requirements-check">
  <question>Here's what I gathered. Confirm understanding before prioritization?</question>
  <header>Requirements</header>
  <option key="proceed" recommended="true">
    <label>Looks good, proceed</label>
    <description>Move to Pareto prioritization</description>
  </option>
  <option key="add-more">
    <label>Add more requirements</label>
    <description>I have additional requirements to capture</description>
  </option>
  <option key="wrong-direction">
    <label>Wrong direction</label>
    <description>Let me re-explain the problem</description>
  </option>
</workflow-gate>

Present the gathered requirements summary before this gate. If user selects "add more", loop back to requirements gathering. If "wrong direction", loop back to Phase 1.

### Phase 3: Prioritization (Pareto 80/20)

<deep-think purpose="prioritization" context="Evaluating brainstormed ideas by feasibility, impact, and alignment">
  <purpose>Apply Pareto 80/20 analysis to prioritize requirements by impact</purpose>
  <context>Multiple requirements gathered; need structured reasoning to identify the 20% that delivers 80% value</context>
</deep-think>

Apply Pareto principle to prioritize:

| Priority | Criteria |
|----------|----------|
| **Must Have** | Core functionality, no workarounds exist |
| **Should Have** | Important but not critical for MVP |
| **Could Have** | Nice to have, enhances experience |
| **Won't Have** | Out of scope for this iteration |

#### Priority Confirmation Gate

Present the Must Have / Should Have / Could Have / Won't Have classification to the user for validation:

<workflow-gate type="choice" id="brainstorm-priority-check">
  <question>Does this prioritization look correct?</question>
  <header>Priorities</header>
  <option key="confirm" recommended="true">
    <label>Yes, looks correct</label>
    <description>Proceed to structured output</description>
  </option>
  <option key="adjust">
    <label>Adjust priorities</label>
    <description>Some items need to be re-prioritized</description>
  </option>
  <option key="redo">
    <label>Re-prioritize completely</label>
    <description>Start prioritization over with different criteria</description>
  </option>
</workflow-gate>

If user selects "adjust", ask which items to move and re-present. If "redo", loop back to top of Phase 3.

### Phase 4: Structure Output

Create structured requirements document:

```markdown
## Problem Statement
{Clear description of the problem}

## Requirements

### Must Have
- [ ] Requirement 1
- [ ] Requirement 2

### Should Have
- [ ] Requirement 3

### Could Have
- [ ] Requirement 4

## Constraints
- Constraint 1
- Constraint 2

## Success Metrics
- Metric 1: Target
- Metric 2: Target
```

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | Exit to APEX workflow |
| **High** | ASK IF ABLE | Major scope changes |
| **Medium** | ASK IF UNCERTAIN | Priority decisions |
| **Low** | PROCEED | Continue exploration |

<human-approval-framework>

When approval needed, structure question as:
1. **Context**: What was discovered
2. **Options**: 2-4 choices with trade-offs
3. **Recommendation**: Suggested option with rationale
4. **Escape**: "Do something else" option

</human-approval-framework>

## Agent Delegation

**Recommended Agent**: None (human-interactive skill)

| Delegate When | Keep Inline When |
|---------------|------------------|
| Deep codebase search needed | Requirements gathering |
| Pattern discovery | Prioritization decisions |

## Workflow Chaining

**Next Verbs**: `/x-research`, `/x-design`

| Trigger | Chain To | Auto? |
|---------|----------|-------|
| "dig deeper", "need more info" | `/x-research` | No (suggest) |
| "ready to decide", "architecture" | `/x-design` | No (suggest) |
| "ready to build" | `/x-plan` | **HUMAN APPROVAL** |

<chaining-instruction>

**Suggest-chain**: brainstorm → research/design (within BRAINSTORM, **user selects** via gate below)

After brainstorm session complete:

<state-checkpoint phase="brainstorm" status="completed">
  <file path=".claude/workflow-state.json">Mark brainstorm complete, set next phase in_progress</file>
  <memory entity="workflow-state">phase: brainstorm -> completed; next: design or research</memory>
</state-checkpoint>

<workflow-gate type="choice" id="brainstorm-next">
  <question>Brainstorming complete. What would you like to do next?</question>
  <header>Next step</header>
  <option key="design" recommended="true">
    <label>Continue to Design</label>
    <description>Make architectural decisions before implementation</description>
  </option>
  <option key="research">
    <label>Deep Research</label>
    <description>Investigate further before deciding</description>
  </option>
  <option key="plan" approval="required">
    <label>Skip to Planning</label>
    <description>Start APEX workflow — commits to implementation</description>
  </option>
  <option key="stop">
    <label>Stop here</label>
    <description>Review brainstorm output first</description>
  </option>
</workflow-gate>

<workflow-chain on="design" skill="x-design" args="{requirements summary}" />
<workflow-chain on="research" skill="x-research" args="{topics to investigate}" />
<workflow-chain on="plan" skill="x-plan" args="{requirements summary}" />
<workflow-chain on="stop" action="end" />

**CRITICAL**: Transition to `/x-plan` crosses the BRAINSTORM → APEX boundary and always requires human approval.

</chaining-instruction>

## Brainstorming Techniques

### 5 Whys
Ask "why?" five times to find root cause.

### User Stories
"As a [user], I want to [action] so that [benefit]"

### Impact Mapping
Goal → Actors → Impacts → Deliverables

## Critical Rules

1. **No Judgement** - Capture all ideas first
2. **Ask Why** - Understand the real problem
3. **Be Specific** - Vague requirements fail
4. **Prioritize Ruthlessly** - 20% delivers 80% value

## Navigation

| Direction | Verb | When |
|-----------|------|------|
| Next (research) | `/x-research` | Need more information |
| Next (decide) | `/x-design` | Ready for architecture |
| Exit | `/x-plan` | Ready to build (approval required) |

## Success Criteria

- [ ] Problem clearly defined
- [ ] Requirements captured
- [ ] Priorities established
- [ ] Next step presented

## References

- @skills/meta/analysis-architecture/ - Pareto prioritization and analysis patterns
