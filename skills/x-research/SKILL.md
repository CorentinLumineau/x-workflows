---
name: x-research
description: |
  Intelligent Q&A and comprehensive research with evidence-based methodology.
  Activate when researching topics, answering questions, or doing deep analysis.
  Triggers: research, ask, question, investigate, deep dive, analyze, find out.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---

# x-research

Intelligent Q&A and comprehensive research with evidence-based methodology.

## Modes

| Mode | Description |
|------|-------------|
| ask (default) | Quick Q&A |
| deep | Comprehensive research |

## Mode Detection

Scan user input for keywords:

| Keywords | Mode |
|----------|------|
| "deep research", "comprehensive", "thorough", "prd", "competitive analysis" | deep |
| (default) | ask |

## Execution

1. **Detect mode** from user input
2. **If no valid mode detected**, use default (ask)
3. **If no arguments provided**, ask for question
4. **Load mode instructions** from `references/`
5. **Follow instructions** completely

## Agent Suggestions

If your agent supports subagents, consider using:
- An exploration agent for codebase investigation
- A web search tool for external research

## Research Approaches

| Mode | Depth | Output |
|------|-------|--------|
| ask | Quick answer | Direct response |
| deep | Comprehensive | PRD, analysis document |

## Research Methodology

### Quick (ask mode)

```
1. Understand question
2. Search codebase/docs
3. Provide direct answer
4. Cite sources
```

### Deep (deep mode)

```
1. Define research scope
2. Gather information from multiple sources
3. Analyze and synthesize
4. Create structured output (PRD/report)
5. Include recommendations
```

## Evidence-Based Principles

| Principle | Description |
|-----------|-------------|
| Cite sources | Reference documentation and code |
| Verify claims | Test assumptions against code |
| Multiple sources | Cross-reference information |
| Clear uncertainty | State when unsure |

## Output Formats

### Ask Mode Output
```
**Answer**: [Direct answer]

**Sources**:
- [file/doc reference]
- [code reference]
```

### Deep Mode Output
```
# Research: [Topic]

## Executive Summary
## Findings
## Analysis
## Recommendations
## Sources
```

## Checklist

- [ ] Question clearly understood
- [ ] Sources identified
- [ ] Answer evidence-based
- [ ] Uncertainty noted
- [ ] Appropriate depth

## When to Load References

- **For ask mode**: See `references/mode-ask.md`
- **For deep mode**: See `references/mode-deep.md`
