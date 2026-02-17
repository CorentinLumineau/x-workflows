---
type: template
audience: [developers]
scope: skill-development
last-updated: 2026-01-12
status: current
used-by:
  - /x:create-skill
---

# Skill Boilerplate Reference

> **Purpose**: Standardized structure for behavioral skills to ensure consistency and Anthropic compliance

This document defines the canonical structure for skills in the ccsetup plugin.

---

## 1. SKILL.md Structure

### User-Invocable Skills (x-* prefix)

**Minimal frontmatter per Anthropic guidelines:**

```yaml
---
name: x-{skill-name}
description: "{Brief description}. Modes: {mode1}, {mode2}. Use when {triggers}."
---
```

**Body structure:**

```markdown
# /x-{skill-name}

{One-line description}

## Mode Routing

| Mode | File | Legacy Command | Description |
|------|------|----------------|-------------|
| {mode} (default) | `references/mode-{mode}.md` | `/x:{cmd}` | {Description} |

## Execution

1. **Detect mode** from user input
2. **If no valid mode**, use default
3. **Read mode file** from `references/`
4. **Follow instructions** completely

## Mode Detection

| Keywords | Mode |
|----------|------|
| "{keywords}" | {mode} |
| (default) | {default-mode} |

## Behavioral Skills

This skill activates:
- `{skill}` - {Description}

## MCP Servers

| Server | When |
|--------|------|
| `{mcp}` | {Trigger} |

## References

- {Local or @core-docs/ references}

---

**Version**: 5.0.0
```

### Behavioral Skills (non-x-* prefix)

**Extended frontmatter allowed:**

```yaml
---
name: {skill-name}
description: "This skill should be used when {triggers}. {Brief behavior description}."
allowed-tools: [Read, Grep, Glob, Edit, Write, Bash, Task]
mcp:
  - sequential-thinking  # Optional
hooks:
  - PreToolUse  # Optional
version: 1.0.0
---
```

**Body structure:**

```markdown
# {Skill Name} Skill

> {One-liner for sidebar}

<purpose>
{2-3 sentence purpose description}
</purpose>

## Activation

<activation_triggers>
This skill activates when:
- {Trigger 1}
- {Trigger 2}
</activation_triggers>

## Behavioral Rules

<behavioral_rules>

### {Rule Category}
1. **{Rule}** - {Description}

</behavioral_rules>

## Tool Usage Patterns

| Scenario | Tool | Pattern |
|----------|------|---------|
| {Scenario} | {Tool} | {Pattern} |

## References

- @core-docs/{path} - {Description}

---

**Version**: {X.Y.Z}
```

---

## 2. Directory Structure

### User-Invocable Skill

```
skills/x-{name}/
├── SKILL.md              # Main skill file (minimal frontmatter)
└── references/           # Mode files
    ├── mode-{mode1}.md
    ├── mode-{mode2}.md
    └── ...
```

### Behavioral Skill

```
skills/{name}/
├── SKILL.md              # Main skill file (extended frontmatter OK)
└── references/           # Optional supporting docs
    └── {reference}.md
```

---

## 3. Mode File Structure

```markdown
# Mode: {mode-name}

> **Invocation**: `/x-{skill} {mode}` or `/x-{skill}`
> **Legacy Command**: `/x:{command}`

## Purpose

{What this mode does}

## Behavioral Skills

This mode activates:
- `{skill}` - {Description}

## MCP Servers

| Server | When |
|--------|------|
| `{mcp}` | {Trigger} |

## Instructions

### Phase 1: {Phase Name}
{Instructions}

### Phase 2: {Phase Name}
{Instructions}

## Critical Rules

1. **{Rule}** - {Description}

## References

- {References}

## Success Criteria

- [ ] {Criterion 1}
- [ ] {Criterion 2}
```

---

## 4. Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| User-invocable skill | `x-{verb}` | `x-implement`, `x-review` |
| Behavioral skill | `{noun}` or `{noun}-{modifier}` | `code-quality`, `context-awareness` |
| Mode file | `mode-{mode}.md` | `mode-fix.md`, `mode-create.md` |

---

## 5. Validation Checklist

Before creating a skill, verify:

- [ ] Name follows conventions
- [ ] Frontmatter is minimal (x-*) or appropriate (behavioral)
- [ ] Description includes activation triggers
- [ ] Mode files exist for all declared modes
- [ ] References point to existing files
- [ ] No @core-docs/playbooks or @core-docs/templates (use @skills/)

---

**Version**: 5.0.0
**Created**: 2026-01-12
**Purpose**: DRY compliance for skill development
