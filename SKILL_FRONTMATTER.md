# Skill Frontmatter Reference (x-workflows)

> Definitive guide for skill frontmatter in x-workflows repository.

## Overview

x-workflows contains two types of skills:
1. **Workflow skills** (`x-*` prefix) - User-invocable execution verbs
2. **Behavioral skills** (no `x-*` prefix) - Auto-triggered workflow patterns

## Skill Types

### Workflow Skills (x-* prefix)

**Definition**: Skills that users can trigger via `/x-skillname` command. Claude can also auto-trigger them when relevant.

| Attribute | Value |
|-----------|-------|
| **Naming** | `x-{verb}` (e.g., `x-implement`, `x-fix`, `x-plan`) |
| **Frontmatter** | `user-invocable: true` (required) |
| **User trigger** | ✅ Yes, via `/x-skillname` |
| **Claude trigger** | ✅ Yes, auto-triggered when relevant |
| **File location** | `skills/x-{verb}/SKILL.md` |

**Examples**: `x-implement`, `x-fix`, `x-plan`, `x-verify`, `x-commit`, `x-troubleshoot`

**Use for**: Workflow verbs that users explicitly invoke to perform actions.

**Frontmatter template**:

```yaml
---
name: x-{verb}
description: {What this skill does}
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
user-invocable: true
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---
```

**Key fields**:
- `name`: Must match directory name
- `user-invocable: true`: **Required** for all x-* skills
- `category: workflow`: Standard for workflow skills
- `allowed-tools`: List of permitted Claude Code tools

---

### Behavioral Skills (no x-* prefix)

**Definition**: Skills that ONLY Claude can trigger automatically. Users cannot invoke them directly.

| Attribute | Value |
|-----------|-------|
| **Naming** | `{noun}` or `{pattern-name}` (no `x-` prefix) |
| **Frontmatter** | `user-invocable: false` (required) |
| **User trigger** | ❌ No, not accessible via `/command` |
| **Claude trigger** | ✅ Yes, auto-triggered based on conditions |
| **File location** | `skills/{name}/SKILL.md` |

**Examples**: `interview`, `complexity-detection`, `orchestration`, `agent-awareness`, `context-awareness`

**Use for**: Background workflow patterns, auto-triggered gates, system context.

**Frontmatter template**:

```yaml
---
name: {skill-name}
description: {What this skill does}
category: behavioral
user-invocable: false
triggers:
  - {trigger_condition_1}
  - {trigger_condition_2}
  - {trigger_condition_3}
---
```

**Key fields**:
- `name`: Must match directory name (no `x-` prefix)
- `user-invocable: false`: **Required** to prevent user invocation
- `category: behavioral`: Standard for behavioral skills
- `triggers:`: Array documenting auto-activation conditions

---

## Invocation Patterns

| Skill Type | User Command | Claude Trigger | Skill Tool |
|------------|--------------|----------------|------------|
| Workflow (x-*) | `/x-plan` | ✅ Auto | ✅ Yes |
| Behavioral | ❌ None | ✅ Auto-only | ❌ N/A |

**Examples**:

```markdown
# User invokes workflow skill
/x-plan "Implement user authentication"

# Claude auto-triggers behavioral skill
[User asks ambiguous question]
→ interview skill auto-activates
→ Claude asks clarifying questions

# Claude auto-triggers workflow skill
[Claude detects need for planning]
→ Invokes x-plan via Skill tool
```

---

## Examples from Repository

### Example: x-plan (Workflow Skill)

```yaml
---
name: x-plan
description: Scale-adaptive implementation planning with automatic complexity detection.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
user-invocable: true
metadata:
  author: ccsetup contributors
  version: "2.0.0"
  category: workflow
---
```

**File location**: `skills/x-plan/SKILL.md`

---

### Example: interview (Behavioral Skill)

```yaml
---
name: interview
description: Universal confidence gate ensuring human-in-the-loop before any significant action.
category: behavioral
user-invocable: false
triggers:
  - ambiguity_detected
  - missing_information
  - high_risk_action
  - confidence_below_100
---
```

**File location**: `skills/interview/SKILL.md`

---

## Validation Rules

### Naming Validation

| Rule | Valid | Invalid |
|------|-------|---------|
| Workflow must have `x-` prefix | `x-implement` | `implement` |
| Behavioral must NOT have `x-` prefix | `interview` | `x-interview` |
| Use kebab-case | `complexity-detection` | `ComplexityDetection` |

### Frontmatter Validation

| Skill Type | Required Fields | Forbidden Fields |
|------------|-----------------|------------------|
| Workflow (x-*) | `name`, `description`, `user-invocable: true` | `triggers` |
| Behavioral | `name`, `description`, `user-invocable: false`, `triggers` | N/A |

### Common Mistakes

❌ **Wrong**: Workflow skill without `user-invocable: true`

```yaml
---
name: x-implement
description: Implementation skill
# Missing user-invocable: true
---
```

❌ **Wrong**: Behavioral skill missing `user-invocable: false`

```yaml
---
name: interview
description: Confidence gate
# Missing user-invocable: false
---
```

✅ **Correct**: Workflow skill with proper frontmatter

```yaml
---
name: x-implement
description: Implementation skill
user-invocable: true
metadata:
  category: workflow
---
```

✅ **Correct**: Behavioral skill with proper frontmatter

```yaml
---
name: interview
description: Confidence gate
category: behavioral
user-invocable: false
triggers:
  - ambiguity_detected
---
```

---

## Creating New Skills

### Create Workflow Skill (x-*)

```bash
cd x-workflows
make new-skill NAME=x-myverb
```

This scaffolds:
- `skills/x-myverb/SKILL.md` with proper frontmatter template
- `skills/x-myverb/references/` directory
- Validates name matches `^x-[a-z][-a-z]*$`

**Template location**: `.templates/workflow-skill/SKILL.md`

### Create Behavioral Skill

```bash
cd x-workflows/skills
mkdir my-pattern
cd my-pattern
# Manually create SKILL.md with behavioral frontmatter
```

**Template**: Use existing behavioral skills (interview, complexity-detection) as reference.

---

## Validation

Run validation to check frontmatter:

```bash
make validate
```

**Check 5 validates**:
- `name` matches directory name
- `user-invocable` is correctly set for skill type
- `category` is valid
- `description` exists and is single-line
- `allowed-tools` present (workflow skills)
- `triggers` present (behavioral skills)

---

## References

- [Claude Code Skills Documentation](https://docs.anthropic.com/claude-code/skills)
- @core-docs/SKILL_TYPES.md (ccsetup) - Full skill type taxonomy
- .templates/workflow-skill/SKILL.md - Workflow skill template
- skills/interview/SKILL.md - Behavioral skill example
- skills/x-plan/SKILL.md - Workflow skill example

---

**Version**: 1.0.0
**Last Updated**: 2026-02-12
