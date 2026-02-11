---
name: x-design
description: Technical architecture and system design with SOLID validation.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---

# /x-design

> Make architectural decisions and create design documents.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | BRAINSTORM |
| **Phase** | action |
| **Position** | 3 of 3 in workflow |

**Flow**: `x-brainstorm` / `x-research` → **`x-design`** → `[EXIT to APEX: x-plan]`

## Intention

**Topic**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Ask user: "What would you like to design?"
{{/if}}

## Behavioral Skills

This skill activates:
- `interview` - Zero-doubt confidence gate (Phase 0)
- `code-quality` - SOLID principles enforcement
- `analysis` - Trade-off analysis

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **codebase explorer** | Pattern discovery | Fast, read-only |

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Architecture decisions |
| `context7` | Reference implementations |

<instructions>

### Phase 0: Confidence Check

Activate `@skills/interview/` if:
- Multiple architectural approaches exist
- Unknown technical constraints
- Breaking change potential

### Phase 0b: Workflow State Check

1. Read `.claude/workflow-state.json` (if exists)
2. If active BRAINSTORM workflow exists → Proceed
3. If active non-BRAINSTORM workflow? → Warn: "Active {type} workflow. Start BRAINSTORM? [Y/n]"
4. If no active workflow → Create new BRAINSTORM workflow state at `design` phase

### Phase 1: Requirements Review

Determine requirements source:
- From brainstorm session
- Direct input from user
- Existing project documentation
- Infer from existing code

Review:
- Functional requirements
- Non-functional requirements
- Constraints

### Phase 2: Architecture Discovery

<agent-delegate role="codebase explorer" subagent="x-explorer" model="haiku">
  <prompt>Find architecture patterns, design patterns, integration patterns, and data flow patterns in the codebase</prompt>
  <context>Discovering existing conventions to inform design decisions</context>
</agent-delegate>

Delegate to a **codebase explorer** agent (fast, read-only):
> "Find architecture patterns in codebase"

Discover:
- Existing architecture layers
- Design patterns in use
- Integration patterns
- Data flow patterns

<doc-query trigger="design-patterns">
  <purpose>Look up reference implementations and best practices for the architecture being designed</purpose>
  <context>Finding authoritative patterns to inform design decisions</context>
</doc-query>

### Phase 3: Design Creation

<deep-think purpose="architecture decisions" context="Evaluating design trade-offs, pattern selection, and SOLID compliance">
  <purpose>Evaluate architectural trade-offs and component design decisions</purpose>
  <context>Multiple valid approaches exist; need systematic analysis of trade-offs, SOLID compliance, and risk assessment</context>
</deep-think>

Create design document:

```markdown
# Design: {Feature Name}

## Overview
{High-level description}

## Architecture

### Component Diagram
[Component A] → [Component B] → [Component C]

### Data Flow
1. Input received at {entry point}
2. Processed by {service}
3. Stored in {storage}
4. Response returned

## Components

### Component A
- **Responsibility**: {SRP description}
- **Interface**: {Public API}
- **Dependencies**: {What it depends on}

## SOLID Validation

- [ ] **Single Responsibility**: Each component has one reason to change
- [ ] **Open/Closed**: Extensible without modification
- [ ] **Liskov Substitution**: Subtypes are substitutable
- [ ] **Interface Segregation**: Specific interfaces
- [ ] **Dependency Inversion**: Depend on abstractions

## Trade-offs

| Decision | Option A | Option B | Choice |
|----------|----------|----------|--------|
| {Decision 1} | {Pros/Cons} | {Pros/Cons} | {Choice + Why} |

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| {Risk 1} | {High/Med/Low} | {Strategy} |

## Implementation Order

1. {First component} - Foundation
2. {Second component} - Depends on first
3. {Third component} - Integration
```

### Phase 4: SOLID Validation

Validate design against all five SOLID principles:

| Principle | Check | Status |
|-----------|-------|--------|
| **S**ingle Responsibility | Each component has one job | |
| **O**pen/Closed | Can extend without modifying | |
| **L**iskov Substitution | Subtypes work | |
| **I**nterface Segregation | No fat interfaces | |
| **D**ependency Inversion | Abstractions, not concretions | |

### Phase 5: Update Workflow State

After design validated:

<state-checkpoint phase="design" status="completed">
  <file path=".claude/workflow-state.json">Mark design complete; if transitioning to APEX, create new APEX workflow at plan phase</file>
  <memory entity="workflow-state">phase: design -> completed; transition: BRAINSTORM -> APEX (if approved)</memory>
</state-checkpoint>

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | Exit to APEX workflow (/x-plan) |
| **High** | ASK IF ABLE | Significant trade-offs, new patterns |
| **Medium** | ASK IF UNCERTAIN | Component boundaries |
| **Low** | PROCEED | Standard design work |

<human-approval-framework>

When approval needed, structure question as:
1. **Context**: Design decision being made
2. **Options**: 2-4 architectural choices with trade-offs
3. **Recommendation**: Suggested approach with rationale
4. **Escape**: "Reconsider requirements" option

</human-approval-framework>

## Agent Delegation

**Recommended Agent**: **codebase explorer** (pattern discovery)

| Delegate When | Keep Inline When |
|---------------|------------------|
| Large codebase pattern search | Architecture decisions |
| Reference implementation lookup | SOLID validation |

## Workflow Chaining

**Next Verb**: `/x-plan` (APEX workflow)

| Trigger | Chain To | Auto? |
|---------|----------|-------|
| "ready to build", "implement" | `/x-plan` | **HUMAN APPROVAL REQUIRED** |
| "need more research" | `/x-research` | No (suggest) |
| "reconsider requirements" | `/x-brainstorm` | No (suggest) |

<chaining-instruction>

**Human approval required**: design → plan (BRAINSTORM → APEX transition)

<workflow-gate type="choice" id="design-exit">
  <question>Design complete. Ready to start planning implementation?</question>
  <header>Next step</header>
  <option key="plan" recommended="true" approval="required">
    <label>Start Planning</label>
    <description>Begin APEX workflow — commits to implementation</description>
  </option>
  <option key="research">
    <label>More Research</label>
    <description>Need more information before deciding</description>
  </option>
  <option key="brainstorm">
    <label>Reconsider</label>
    <description>Go back to requirements discovery</description>
  </option>
  <option key="stop">
    <label>Review First</label>
    <description>Review design document before proceeding</description>
  </option>
</workflow-gate>

<workflow-chain on="plan" skill="x-plan" args="{design summary with components, trade-offs, and implementation order}" />
<workflow-chain on="research" skill="x-research" args="{topics needing investigation}" />
<workflow-chain on="brainstorm" skill="x-brainstorm" args="{requirements to reconsider}" />
<workflow-chain on="stop" action="end" />

**CRITICAL**: Transition to `/x-plan` crosses the BRAINSTORM → APEX boundary and commits to implementation. This always requires human approval.

</chaining-instruction>

## Design Patterns Reference

| Pattern | Use When |
|---------|----------|
| Repository | Data access abstraction |
| Factory | Complex object creation |
| Strategy | Interchangeable algorithms |
| Observer | Event-driven communication |
| Adapter | Interface compatibility |

## Critical Rules

1. **Follow Existing Patterns** - Don't introduce new patterns unnecessarily
2. **SOLID Required** - All five principles must be validated
3. **Document Trade-offs** - Explain why this choice over alternatives
4. **Consider Scale** - Design for expected load

## Navigation

| Direction | Verb | When |
|-----------|------|------|
| Previous | `/x-brainstorm` | Reconsider requirements |
| Research | `/x-research` | Need more information |
| Exit to APEX | `/x-plan` | Ready to build (approval required) |

## Success Criteria

- [ ] Architecture defined
- [ ] Components identified
- [ ] SOLID validated
- [ ] Trade-offs documented
- [ ] Implementation order clear

## References

- @skills/code-code-quality/ - SOLID principles
- @skills/code-design-patterns/ - Design patterns
