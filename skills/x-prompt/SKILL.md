---
name: x-prompt
description: Transform raw prompts into well-structured, XML-tagged prompts optimized for LLM execution.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read AskUserQuestion
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---

# x-prompt

Transform raw prompts into well-structured, XML-tagged prompts optimized for LLM execution across different systems.

## Modes

| Mode | Description |
|------|-------------|
| create (default) | Transform raw input into enhanced prompt |
| refine | Iteratively improve existing prompt |

## Mode Detection

| Keywords | Mode |
|----------|------|
| "refine", "improve", "iterate", "update" | refine |
| (default) | create |

## Execution

- **Default mode**: create
- **No-args behavior**: Ask for prompt to enhance

## Behavioral Skills

This workflow activates these behavioral skills:
- `interview` - Zero-doubt confidence gate (Phase 0)

## Output Characteristics

| Property | Description |
|----------|-------------|
| Format | XML-tagged sections in fenced code block |
| Persistence | None (text output only, copy-ready) |
| Target | Universal (LLM-agnostic) |

## Enhancement Techniques

| Technique | Applied When |
|-----------|--------------|
| Intent extraction | Always |
| Structure addition | Always |
| Constraint specification | Always |
| Output format definition | Always |
| Success criteria | Always |
| Context enrichment | When context unclear |
| Chain-of-thought | Reasoning/analysis tasks |
| Role/persona | When specificity helps |
| Few-shot examples | User requests or complex patterns |

## MCP Integration

| Server | Trigger |
|--------|---------|
| `sequential-thinking` | Complex multi-part prompts |

## When to Load References

- **For create mode**: See `references/mode-create.md`
- **For refine mode**: See `references/mode-refine.md`
- **For XML structure**: See `templates/xml-schema.md`

---

**Version**: 1.0.0
