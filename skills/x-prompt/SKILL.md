---
name: x-prompt
description: Use when a prompt needs structuring and optimization for LLM execution.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read AskUserQuestion
user-invocable: true
argument-hint: "<prompt text>"
metadata:
  author: ccsetup contributors
  version: "1.1.0"
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

<deep-think purpose="prompt optimization" context="Analyzing raw prompt to determine structure, constraints, and enhancement techniques">
Reason about: intent extraction, optimal XML structure, constraint specification, output format, success criteria, and chain-of-thought applicability.
</deep-think>

## Enhancement Techniques

| Technique | Applied When |
|-----------|--------------|
| Intent extraction | Always |
| Structure addition | Always |
| Constraint specification | Always |
| Output format definition | Always |
| Success criteria | Always |
| Skill suggestion | Always (after output) |
| Context enrichment | When context unclear |
| Chain-of-thought | Reasoning/analysis tasks |
| Role/persona | When specificity helps |
| Few-shot examples | User requests or complex patterns |

## Skill Suggestion

After generating the enhanced prompt, x-prompt analyzes the prompt's intent and suggests which x-workflow skills and slash command chains are best suited to **execute** the task described in the prompt.

Suggestions appear **outside** the XML output (not inside the copied prompt) as workflow metadata for the user.

### Intent-to-Skill Routing

| Intent Signals | Primary Skill | Workflow |
|----------------|---------------|----------|
| build, create, implement, add feature, new | `/x-implement` | APEX |
| fix, bug, error, typo, patch, broken | `/x-fix` | ONESHOT |
| debug, diagnose, root cause, investigate error | `/x-troubleshoot` | DEBUG |
| plan, break down, roadmap, estimate | `/x-plan` | APEX |
| analyze, assess, evaluate, audit codebase | `/x-analyze` | APEX |
| design, architect, system design, patterns | `/x-design` | BRAINSTORM |
| research, investigate, compare, evaluate options | `/x-research` | BRAINSTORM |
| brainstorm, ideas, requirements, explore | `/x-brainstorm` | BRAINSTORM |
| refactor, restructure, clean up, reorganize | `/x-refactor` | APEX |
| test, verify, lint, quality, coverage | `/x-review quick` | APEX |
| review, PR, code review, security review | `/x-review` | APEX |
| document, docs, readme, API docs | `/x-docs` | UTILITY |
| release, version, tag, changelog | `/git-create-release` | UTILITY |
| setup, scaffold, initialize, bootstrap | `/x-setup` | UTILITY |

### Workflow Chains

| Workflow | Slash Command Chain |
|----------|---------------------|
| **APEX** | `/x-analyze` → `/x-plan` → `/x-implement` → `/x-review` → `/git-commit` |
| **ONESHOT** | `/x-fix` → `/x-review quick` (optional) → `/git-commit` |
| **DEBUG** | `/x-troubleshoot` → `/x-fix` or `/x-implement` |
| **BRAINSTORM** | `/x-brainstorm` ↔ `/x-research` → `/x-design` → `/x-plan` |

## MCP Integration

| Server | Trigger |
|--------|---------|
| `sequential-thinking` | Complex multi-part prompts |

## When to Load References

- **For create mode**: See `references/mode-create.md`
- **For refine mode**: See `references/mode-refine.md`
- **For XML structure**: See `templates/xml-schema.md`

---

**Version**: 1.1.0
