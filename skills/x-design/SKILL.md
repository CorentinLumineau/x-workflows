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

Delegate to a **codebase explorer** agent (fast, read-only):
> "Find architecture patterns in codebase"

Discover:
- Existing architecture layers
- Design patterns in use
- Integration patterns
- Data flow patterns

### Phase 3: Design Creation

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

When ready to chain to APEX workflow:
1. Summarize the design decisions made
2. Ask user: "Ready to start planning implementation?"
3. On approval, use Skill tool:
   - skill: "x-plan"
   - args: "{design summary for implementation}"

**CRITICAL**: Transition to `/x-plan` commits to implementation and requires human approval.

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
