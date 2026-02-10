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

Gather:
- **Functional Requirements** - What should it do?
- **Non-Functional Requirements** - What qualities matter?
- **Constraints** - What limitations exist?

### Phase 3: Prioritization (Pareto 80/20)

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
1. Update `.claude/workflow-state.json` (mark brainstorm complete, set next in_progress)
2. Auto-invoke next skill via Skill tool:
   - skill: "x-research" or "x-design"
   - args: "{derived requirements summary}"

**Human approval required**: brainstorm → plan (BRAINSTORM → APEX transition)

If user wants to skip design and go directly to implementation:
1. Present approval gate:
   "Ready to start planning implementation?"
   - Option 1: `/x-design` (Recommended) - Architecture decisions first
   - Option 2: `/x-plan` - Start APEX workflow (requires approval)
   - Option 3: `/x-research` - Deep investigation
2. **CRITICAL**: Transition to `/x-plan` crosses the BRAINSTORM → APEX boundary and always requires human approval.

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
