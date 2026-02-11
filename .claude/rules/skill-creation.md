# x-workflows Skill Creation Rules

## Frontmatter Contract

All skills MUST have a YAML frontmatter block between `---` markers.

### Workflow Skills (x-*)

| Field | Required | Constraint |
|-------|----------|------------|
| `name` | Yes | Must match directory name, must start with `x-` |
| `description` | Yes | Single-line string (no YAML `|` or `>`) |
| `license` | Yes | `Apache-2.0` |
| `compatibility` | Yes | `Works with Claude Code, Cursor, Cline, and any skills.sh agent.` |
| `allowed-tools` | Yes | Space-separated tool list (e.g., `Read Write Edit Grep Glob Bash`) |
| `metadata.author` | Yes | `ccsetup contributors` |
| `metadata.version` | Yes | Semver string (e.g., `"1.0.0"`) |
| `metadata.category` | Yes | `workflow` |

```yaml
---
name: x-example
description: Brief single-line description of what this skill does.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---
```

### Behavioral Skills (no x- prefix)

| Field | Required | Constraint |
|-------|----------|------------|
| `name` | Yes | Must match directory name, must NOT start with `x-` |
| `description` | Yes | Single-line string |
| `category` | Yes | `behavioral` |
| `user-invocable` | Yes | `false` |
| `triggers` | Yes | Array of trigger conditions |

```yaml
---
name: example-behavior
description: Brief single-line description.
category: behavioral
user-invocable: false
triggers:
  - trigger_condition_1
  - trigger_condition_2
---
```

---

## Naming Convention

| Type | Pattern | Directory | Regex |
|------|---------|-----------|-------|
| Workflow | `x-{verb}` | `skills/x-{verb}/` | `^x-[a-z][-a-z]*$` |
| Behavioral | `{noun}` or `{noun}-{modifier}` | `skills/{name}/` | `^[a-z][-a-z]*$` |

- Workflow skills use verb names (implement, fix, verify, plan)
- Behavioral skills use noun names (interview, orchestration, complexity-detection)

---

## Required Sections

### Workflow Skills MUST have:

1. **Title**: `# /x-{verb}` (with leading slash)
2. **Workflow Context**: Table with Workflow type, Phase, Position
3. **Intention**: What the skill does, with `$ARGUMENTS` pattern
4. **Behavioral Skills**: Which behavioral skills activate
5. **`<instructions>` block**: Implementation phases
6. **Success Criteria**: Checklist of exit conditions

### Behavioral Skills MUST have:

1. **Title**: `# {Name}`
2. **Activation Triggers**: Table of when the skill activates
3. **Core Loop/Rules**: The behavioral pattern
4. **References**: Related skills (if applicable)

---

## Template Usage

### Workflow Skills

Always scaffold with the template:

```bash
make new-skill NAME=x-my-verb
```

Then:
1. Replace `__DESCRIPTION__` with actual description
2. Fill in all TODO markers
3. Add mode references in `references/` if needed
4. Run `make validate` before committing

### Behavioral Skills

Behavioral skills are created manually (no template). Follow the frontmatter contract above.

---

## Cross-Reference Rules

| Action | Allowed |
|--------|---------|
| Reference x-devsecops knowledge | YES — `@skills/{category}/{skill}/` |
| Reference other x-workflows skills | YES — `@skills/{skill}/` |
| Reference ccsetup commands/agents | NO — never reference directly |
| Use semantic compilation markers | YES — `<!-- COMPILED: pattern → tool -->` |
