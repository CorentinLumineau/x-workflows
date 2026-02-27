---
name: x-plan
description: Use when a task needs an implementation plan before coding begins.
version: "2.0.0"
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
user-invocable: true
argument-hint: "<task description>"
metadata:
  author: ccsetup contributors
  category: workflow
chains-to:
  - skill: x-implement
    condition: "plan approved"
chains-from:
  - skill: x-analyze
  - skill: git-implement-issue
  - skill: x-design
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
- `analysis-architecture` - Pareto prioritization

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **codebase explorer** | Codebase analysis | Fast, read-only |

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Complex planning decisions |

<instructions>

<hook-trigger event="PreToolUse" tool="Edit" condition="Before any file modification during planning">
  <action>Enforce read-only plan mode: block Write and Edit tools until plan is approved via ExitPlanMode</action>
</hook-trigger>

<permission-scope mode="plan">
  <allowed>Read, Grep, Glob (codebase exploration); Bash (read-only commands for scope assessment)</allowed>
  <denied>Write, Edit (until plan approved via ExitPlanMode); destructive git operations</denied>
</permission-scope>

### Phase 0: Confidence Check

Activate `@skills/interview/` if:
- Scope unclear
- Multiple valid approaches
- Dependencies unknown

<plan-mode phase="exploration" trigger="after-interview">
  <enter>After confidence gate passes and workflow state is checked, enter read-only exploration mode</enter>
  <scope>Phases 1-3: scope assessment, track selection, plan design (read-only: Glob, Grep, Read only)</scope>
  <exit trigger="plan-complete">Present plan for user approval via ExitPlanMode before any writes</exit>
</plan-mode>

<team name="plan-team" pattern="research">
  <lead role="planner" model="sonnet" />
  <teammate role="codebase explorer" subagent="x-explorer" model="haiku" />
  <task-template>
    <task owner="codebase explorer" subject="Explore codebase structure, dependencies, and patterns for planning context" />
  </task-template>
  <activation>When planning scope is Enterprise-level (10+ files, 4+ layers) and parallel exploration would accelerate scope assessment</activation>
</team>

### Phase 1: Scope Assessment

<agent-delegate role="codebase explorer" subagent="x-explorer" model="haiku">
  <prompt>Analyze codebase for task scope: count affected files, identify layers, map dependencies for {task description}</prompt>
  <context>Gathering scope signals for complexity assessment and track selection</context>
</agent-delegate>

<deep-think purpose="scope assessment" context="Breaking down task scope, dependencies, and risk for implementation planning">
  <purpose>Assess task complexity to select the appropriate planning track (Quick/Standard/Enterprise)</purpose>
  <context>Need to evaluate files affected, layers involved, dependencies, and breaking change potential</context>
</deep-think>

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
- State persistence

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

### Phase 4: Plan Approval & Deferred Writes

**Plan mode exits here** — ExitPlanMode presents the plan for user approval. All writes are deferred to after approval.

After user approves the plan:

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

**Recommended Agent**: **codebase explorer** (for codebase analysis)

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
<!-- V-CHAIN-01: AskUserQuestion MUST be called. V-CHAIN-02: Use interactive gate, not prose. -->

**Human approval required**: plan → implement

<workflow-gate type="approval" id="plan-approval">
  <question>Plan created. Ready to start implementation?</question>
  <header>Approve plan</header>
  <option key="implement" recommended="true" approval="required">
    <label>Start Implementing</label>
    <description>Begin TDD implementation of the plan</description>
  </option>
  <option key="design">
    <label>Design First</label>
    <description>Need architecture decisions before implementing</description>
  </option>
  <option key="stop">
    <label>Review Plan</label>
    <description>Review the plan before proceeding</description>
  </option>
</workflow-gate>

<workflow-chain on="implement" skill="x-implement" args="{plan summary with task list}" />
<workflow-chain on="design" skill="x-design" args="{areas needing architecture decisions}" />
<workflow-chain on="stop" action="end" />

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

- **For detailed planning workflow with track-specific steps**: See `references/mode-plan.md`
- **For comprehensive code analysis across quality, security, performance, and architecture**: See `references/mode-analyze.md`

## References

- @skills/meta-analysis-architecture/ - Pareto prioritization and analysis patterns
- @skills/x-initiative/ - Initiative methodology
