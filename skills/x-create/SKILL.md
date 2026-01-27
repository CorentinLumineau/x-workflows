---
name: x-create
description: |
  Generate best-practice-compliant plugin components through interactive wizards.
  Activate when creating new skills, commands, or agents for plugins.
  Triggers: create skill, create command, create agent, add skill, add command.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---

# x-create

Generate best-practice-compliant plugin components through interactive wizards.

## Modes

| Mode | Description |
|------|-------------|
| skill (default) | Create behavioral skill |
| command | Create slash command |
| agent | Create subagent |

## Mode Detection
| Keywords | Mode |
|----------|------|
| "command", "slash command" | command |
| "agent", "subagent", "worker" | agent |
| (default) | skill |

## Execution
- **Default mode**: skill
- **No-args behavior**: Ask what to create

## Behavioral Skills

This workflow activates these behavioral skills:
- `interview` - Zero-doubt confidence gate (Phase 0)

## Component Types

### Skills

Behavioral rules that guide AI behavior:

```
skills/{name}/
├── SKILL.md        # Main skill file
└── references/     # Supporting docs
```

### Commands

User-invocable slash commands:

```
commands/{name}.md
```

### Agents

Specialized subagent definitions:

```
agents/{name}.md
```

## Skill Template

```markdown
---
name: skill-name
description: |
  Brief description of what this skill does.
  Activation triggers and use cases.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob
metadata:
  author: your-name
  version: "1.0.0"
  category: category
---

# Skill Name

[Content]
```

## Validation

All created components must pass:

| Check | Requirement |
|-------|-------------|
| Frontmatter | Valid YAML with required fields |
| Description | 1-1024 characters |
| Body | <500 lines, <5000 tokens |
| Naming | Lowercase, kebab-case |

## Checklist

- [ ] Clear single responsibility
- [ ] Valid frontmatter
- [ ] Agent-agnostic (no tool-specific refs)
- [ ] Examples included
- [ ] References linked

## When to Load References

- **For skill mode**: See `references/mode-skill.md`
- **For command mode**: See `references/mode-command.md`
- **For agent mode**: See `references/mode-agent.md`
