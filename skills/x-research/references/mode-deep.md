# Mode: deep

> **Invocation**: `/x-research deep` or `/x-research deep "topic"`
> **Legacy Command**: `/x:deep-research`

<purpose>
Transform ideas into complete PRDs through comprehensive web research, competitive analysis, and technical feasibility assessment.
</purpose>

## Behavioral Skills

This mode activates:
- `context-awareness` - Project context loading

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **codebase explorer** | Codebase analysis | Fast, read-only |

## MCP Servers

| Server | When |
|--------|------|
| `context7` | Library documentation |
| `sequential-thinking` | Analysis structuring |

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 35%, context 30%, technical 20%, scope 10%, risk 5%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Research type unclear, scope undefined, expected deliverable unclear.

---

## Instructions

### Phase 1: Research Scope

Define research scope:

```json
{
  "questions": [{
    "question": "What type of research do you need?",
    "header": "Type",
    "options": [
      {"label": "Feature PRD", "description": "Full product requirements"},
      {"label": "Technical assessment", "description": "Feasibility analysis"},
      {"label": "Competitive analysis", "description": "Market research"},
      {"label": "Library comparison", "description": "Tool selection"}
    ],
    "multiSelect": false
  }]
}
```

### Phase 2: Information Gathering

#### Technical Research
- Context7 for library docs
- Codebase analysis
- Architecture patterns

#### Market Research
- WebSearch for competitors
- Feature comparisons
- Pricing analysis

### Phase 3: Analysis

Use structured step-by-step reasoning to analyze the topic. Break the analysis into sequential thoughts, building on each step and revising as understanding deepens. Target ~5 reasoning steps, adjusting as needed.

### Phase 4: Document Generation

#### PRD Template
```markdown
# Product Requirements Document: {Feature}

## Executive Summary
{Brief overview}

## Problem Statement
{What problem this solves}

## Goals
- Goal 1
- Goal 2

## Non-Goals
- Non-goal 1

## User Stories
- As a {user}, I want {action} so that {benefit}

## Technical Requirements
### Functional
- Requirement 1

### Non-Functional
- Performance: {requirement}
- Security: {requirement}

## Design
{High-level design}

## Dependencies
- Dependency 1

## Timeline
| Phase | Duration | Deliverable |
|-------|----------|-------------|
| {Phase} | {Time} | {What} |

## Success Metrics
- Metric 1: Target

## Risks
| Risk | Impact | Mitigation |
|------|--------|------------|
| {Risk} | {Level} | {Strategy} |

## Open Questions
- Question 1

## References
- {Source 1}
```

#### Competitive Analysis Template
```markdown
# Competitive Analysis: {Category}

## Overview
{Market overview}

## Competitors

### {Competitor 1}
- **Strengths**: {list}
- **Weaknesses**: {list}
- **Pricing**: {info}
- **Key Features**: {list}

## Comparison Matrix
| Feature | Us | Comp 1 | Comp 2 |
|---------|----|----|--------|
| {Feature} | {✓/✗} | {✓/✗} | {✓/✗} |

## Recommendations
1. {Recommendation}
```

### Phase 5: Workflow Transition

```json
{
  "questions": [{
    "question": "Research document complete. What's next?",
    "header": "Next",
    "options": [
      {"label": "/x-plan design (Recommended)", "description": "Design the solution"},
      {"label": "/x-initiative create", "description": "Create initiative"},
      {"label": "Stop", "description": "Review document first"}
    ],
    "multiSelect": false
  }]
}
```

</instructions>

## Research Quality

- **Multiple Sources**: Don't rely on single source
- **Recent Data**: Prefer recent information
- **Verified**: Cross-check facts
- **Cited**: Reference all sources

<critical_rules>

1. **Evidence-Based** - Facts, not opinions
2. **Structured Output** - Use templates
3. **Cite Sources** - Track where info came from
4. **Be Thorough** - Comprehensive research

</critical_rules>

## References

- Context7 MCP server - Documentation lookup (built-in)

<success_criteria>

- [ ] Scope defined
- [ ] Research conducted
- [ ] Analysis completed
- [ ] Document generated

</success_criteria>
