---
type: template
audience: [developers]
scope: agent-development
last-updated: 2026-01-12
status: current
used-by:
  - /x:create-agent
---

# Agent Boilerplate Reference

> **Purpose**: Standardized structure for subagents to ensure consistency and optimal Task tool usage

This document defines the canonical structure for agents in the ccsetup plugin.

---

## 1. Agent File Structure

### Frontmatter (Required + Optional)

```yaml
---
name: x-{agent-name}
description: "{Purpose} specialist. Use when {triggers}. {Capabilities}."
model: haiku | sonnet | opus | inherit
tools: [Read, Grep, Glob, Edit, Write, Bash, LSP, Task]
# --- Optional fields (add only when needed) ---
# color: blue                                 # Visual: blue, cyan, green, yellow, magenta, red
# disallowedTools: [Bash, Write]             # Deny-list (overrides tools)
# memory: user                               # Persistent memory: user, project, or local
# permissionMode: default                    # default, acceptEdits, dontAsk, bypassPermissions, plan
# maxTurns: 25                               # Limit agentic turns
# skills: [x-review, x-implement]            # Skills preloaded into agent context
# mcpServers: [sequential-thinking, context7] # MCP servers to connect
# hooks:
#   PreToolUse:                               # Agent-scoped hooks (same format as settings.json)
#     - matcher: "Write|Edit"
#       hooks: [{ type: command, command: "..." }]
---
```

> **Field reference**: See `references/claude-code-platform.md` for complete field descriptions and types.

### Model Selection Guidelines

| Model | Use For | Examples |
|-------|---------|----------|
| `haiku` | Fast, read-only exploration | x-explorer |
| `sonnet` | Complex reasoning, debugging | x-refactorer, x-refactorer |
| `opus` | Critical decisions, architecture | (rare, inherit from parent) |

### Tool Selection Guidelines

| Agent Type | Typical Tools |
|------------|---------------|
| Explorer | Read, Grep, Glob, LSP |
| Debugger | Read, Edit, Bash, Grep, Glob, LSP |
| Reviewer | Read, Grep, Glob, Bash, LSP |
| Tester | Read, Edit, Bash, Grep, Glob, LSP |
| Doc Writer | Read, Write, Edit, Grep, Glob, LSP |
| Refactorer | Read, Edit, Bash, Grep, Glob, LSP |

---

## 2. Agent Body Structure

```markdown
# x-{agent-name} - {Title}

> {One-line description for Task tool display}

<purpose>
{2-3 sentence detailed purpose}
</purpose>

## Capabilities

- {Capability 1}
- {Capability 2}
- {Capability 3}

## When to Use

Use this agent when:
- {Trigger 1}
- {Trigger 2}

Do NOT use when:
- {Anti-pattern 1}
- {Anti-pattern 2}

## Behavioral Rules

<behavioral_rules>

### Core Behaviors
1. **{Behavior}** - {Description}

### Quality Standards
1. **{Standard}** - {Description}

### Output Format
{How agent should format its output}

</behavioral_rules>

## Execution Patterns

### Pattern 1: {Name}
```
{Tool sequence or approach}
```

### Pattern 2: {Name}
```
{Tool sequence or approach}
```

## Integration

### Used By Commands
| Command | Role | When |
|---------|------|------|
| `/x:{cmd}` | {Primary/Secondary} | {Trigger} |

### Skill Activation
This agent activates:
- `{skill}` - {Description}

## Documentation & References

See @templates/optional/agent-patterns.md for shared patterns (optional reference).

Additional:
- {Specific references}

---

**Version**: 4.12.0
```

---

## 3. Naming Conventions

| Pattern | Example | Use |
|---------|---------|-----|
| `x-{role}er` | x-explorer, x-refactorer | Role-based agents |
| `x-{role}-{modifier}` | x-reviewer | Compound roles |

---

## 4. Color Palette

Standard colors for visual distinction:

| Agent | Color | Hex |
|-------|-------|-----|
| Explorer | Blue | `#4A90D9` |
| Debugger | Red | `#D94A4A` |
| Reviewer | Purple | `#9B4AD9` |
| Tester | Green | `#4AD94A` |
| Doc Writer | Cyan | `#4AD9D9` |
| Refactorer | Orange | `#D9944A` |

---

## 5. Task Tool Invocation

### Basic Delegation
Delegate to a **x-{agent-name}** agent:
> "Detailed instructions for the agent"

### With Characteristics
Delegate to a **x-{agent-name}** agent (read-only analysis):
> "Detailed instructions"

### Background Delegation
Delegate to a **x-{agent-name}** agent in background:
> "Long-running task instructions"

---

## 6. Validation Checklist

Before creating an agent, verify:

- [ ] Name follows `x-{role}` pattern
- [ ] Model selection is appropriate for task complexity
- [ ] Tools list includes only needed tools (least privilege)
- [ ] Description includes clear triggers
- [ ] Behavioral rules are specific and actionable
- [ ] Integration section lists using commands
- [ ] References point to existing files

---

## 7. Existing Agents Reference

| Agent | Model | Purpose |
|-------|-------|---------|
| `x-explorer` | haiku | Fast codebase exploration |
| `x-refactorer` | sonnet | Root cause analysis |
| `x-reviewer` | sonnet | Code review and quality |
| `x-tester` | sonnet | Test execution and validation |
| `x-reviewer` | sonnet | Documentation generation |
| `x-refactorer` | sonnet | Safe SOLID refactoring |

---

**Version**: 5.0.0
**Created**: 2026-01-12
**Purpose**: DRY compliance for agent development
