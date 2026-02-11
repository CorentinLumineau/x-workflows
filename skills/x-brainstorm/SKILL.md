---
name: x-brainstorm
description: Transform vague ideas into structured requirements through guided discovery.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
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
- `analysis` - Pareto prioritization

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Idea structuring |
| `context7` | Reference implementations |

<instructions>

### Phase 0: Confidence Check

Activate `@skills/interview/` if:
- Problem space is undefined
- No success criteria exist
- Multiple stakeholders unspecified

### Phase 1: Idea Capture

Start with open exploration:

1. **Problem Type**: What problem are you trying to solve?
   - New feature, Improvement, Integration, Performance

2. **Details**: Describe the problem. What would success look like?

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

**Auto-chain**: brainstorm → research/design (within BRAINSTORM, no approval needed)

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

- @skills/meta-analysis/ - Pareto prioritization and analysis patterns
