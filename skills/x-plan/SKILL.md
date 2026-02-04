---
name: x-plan
description: |
  Scale-adaptive implementation planning with automatic complexity detection.
  APEX workflow, plan phase. Triggers: plan, implementation plan, task breakdown.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "2.0.0"
  category: workflow
---

# /x-plan

> Create implementation plans with appropriate complexity tracking.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | APEX |
| **Phase** | plan (P) |
| **Position** | 2 of 6 in workflow |

**Flow**: `x-analyze` → **`x-plan`** → `x-implement`

## Intention

**Task**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Ask user: "What would you like to plan?"
{{/if}}

## Behavioral Skills

This skill activates:
- `interview` - Zero-doubt confidence gate (Phase 0)
- `analysis` - Pareto prioritization

## Agents

| Agent | When | Model |
|-------|------|-------|
| `ccsetup:x-explorer` | Codebase analysis | haiku |

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Complex planning decisions |
| `memory` | Cross-session persistence |

<instructions>

### Phase 0: Confidence Check

Activate `@skills/interview/` if:
- Scope unclear
- Multiple valid approaches
- Dependencies unknown

### Phase 1: Scope Assessment

Analyze the task to estimate complexity:

| Signal | Quick (1-2h) | Standard (3-8h) | Enterprise (8h+) |
|--------|--------------|-----------------|------------------|
| Files | 1-3 | 4-10 | 10+ |
| Layers | 1-2 | 2-3 | 4+ |
| Dependencies | None | Some | Many |
| Breaking changes | None | Minor | Significant |

### Phase 2: Track Selection

Based on assessment, select track:

**Quick Track** (1-2 hours):
- Inline planning
- Simple task list
- No formal document

**Standard Track** (3-8 hours):
- Story file in `milestones/_active/stories/`
- Checkpoint tracking
- Memory persistence

**Enterprise Track** (8+ hours):
- Full initiative structure via `/x-initiative`
- Multiple milestones
- Cross-session tracking

### Phase 3: Plan Creation

#### Quick Track
Output simple task list:
```markdown
## Tasks
1. Task one
2. Task two
3. Task three
```

#### Standard Track
Create story file:
```markdown
# STORY-{ID}: {Title}

## Context
{Background, related files, patterns}

## Tasks
- [ ] Task 1
- [ ] Task 2

## Success Criteria
- [ ] Criterion 1
```

#### Enterprise Track
Create initiative structure using `/x-initiative create`.

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | Approve plan before implementation |
| **High** | ASK IF ABLE | Track selection (enterprise vs standard) |
| **Medium** | ASK IF UNCERTAIN | Task breakdown approach |
| **Low** | PROCEED | Continue planning |

<human-approval-framework>

When approval needed, structure question as:
1. **Context**: Plan summary and track selected
2. **Options**: Start implementing, refine plan, or review first
3. **Recommendation**: Proceed to implementation
4. **Escape**: "Refine plan" option

**CRITICAL**: Plan approval is required before transitioning to `/x-implement`.

</human-approval-framework>

## Agent Delegation

**Recommended Agent**: `ccsetup:x-explorer` (for codebase analysis)

| Delegate When | Keep Inline When |
|---------------|------------------|
| Large codebase discovery | Simple task breakdown |
| Dependency mapping | Clear requirements |

## Workflow Chaining

**Next Verb**: `/x-implement`

| Trigger | Chain To | Auto? |
|---------|----------|-------|
| **Plan approved** | `/x-implement` | **HUMAN APPROVAL REQUIRED** |
| Needs design | `/x-design` | No (suggest) |
| Large scope | `/x-initiative` | No (suggest) |

<chaining-instruction>

When plan is complete:
"Plan created ({track} track). Ready to implement?"
- Option 1: `/x-implement` (Recommended) - Start implementation
- Option 2: `/x-design` - Design architecture first
- Option 3: Stop - Review plan first

On approval, use Skill tool:
- skill: "x-implement"
- args: "{plan summary with task list}"

</chaining-instruction>

## Planning Principles

1. **Pareto Focus** - 20% of features deliver 80% value
2. **Incremental** - Break into small, deliverable chunks
3. **Dependencies First** - Map dependencies before starting
4. **Risk Aware** - Identify risks early

## Complexity Tracks

| Track | Complexity | Approach |
|-------|------------|----------|
| Quick | 1-2 hours | Inline planning |
| Standard | 3-8 hours | Story file + milestones |
| Enterprise | 8+ hours | Full initiative structure |

## Critical Rules

1. **Match Scope to Track** - Don't over-plan simple tasks
2. **Be Concrete** - Specific tasks, not vague goals
3. **Include Success Criteria** - How do we know it's done?
4. **Consider Dependencies** - What must happen first?

## Navigation

| Direction | Verb | When |
|-----------|------|------|
| Previous | `/x-analyze` | Need more analysis |
| Next | `/x-implement` | Ready to implement (approval required) |
| Branch | `/x-design` | Need architecture first |
| Escalate | `/x-initiative` | Enterprise track needed |

## Related Verbs

For exploration before planning:
- `/x-brainstorm` - Requirements discovery
- `/x-research` - Deep investigation
- `/x-design` - Architecture decisions
- `/x-analyze` - Code analysis

## Success Criteria

- [ ] Complexity assessed
- [ ] Appropriate track selected
- [ ] Plan created with tasks
- [ ] Human approval received
- [ ] Next step presented

## When to Load References

- **For detailed planning workflow**: See `references/mode-plan.md`

## References

- @skills/meta-analysis/ - Pareto prioritization and analysis patterns
- @skills/x-initiative/ - Initiative methodology
