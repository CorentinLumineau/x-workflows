---
name: x-research
description: |
  Intelligent Q&A and comprehensive research with evidence-based methodology.
  Activate when researching topics, answering questions, or doing deep analysis.
  Triggers: research, ask, question, investigate, deep dive, analyze, find out.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash WebFetch WebSearch
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
| assess | Integration pattern assessment |
| lessons | Knowledge base sync |

## Mode Detection
| Keywords | Mode |
|----------|------|
| "deep research", "comprehensive", "thorough", "prd", "competitive analysis" | deep |
| "assess", "integration", "pertinence", "evaluate pattern" | assess |
| "lessons", "best practices", "knowledge sync", "update knowledge" | lessons |
| (default) | ask |

## Execution
- **Default mode**: ask
- **No-args behavior**: Ask for question

## Behavioral Skills

This workflow activates these behavioral skills:
- `interview` - Zero-doubt confidence gate (Phase 0)

## Agent Suggestions

Consider delegating to specialized agents:
- **Exploration**: Codebase investigation, file discovery
- **Web Search**: External research, documentation lookup

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
- **For assess mode**: See `references/mode-assess.md`
- **For lessons mode**: See `references/mode-lessons.md`
