# x-workflows Repository Identity

## Repository Identity

| Attribute | Value |
|-----------|-------|
| **Role** | Execution Layer ("HOW" to work) |
| **Content** | Workflow skills (x-plan, x-implement, x-verify, etc.) |
| **Compatibility** | Agent-agnostic (Claude Code, Cursor, Cline, etc.) |

---

## What Belongs Here

| Component | Location | Example |
|-----------|----------|---------|
| Workflow skill | `skills/{name}/SKILL.md` | x-implement, x-verify, x-plan |
| Mode reference | `skills/{name}/references/mode-*.md` | mode-fix.md, mode-refactor.md |
| Playbooks | `skills/{name}/playbooks/` | Initiative guides |
| Templates | `skills/{name}/templates/` | Output templates |

### Workflow Skill Characteristics
- Defines **execution steps** (how to do something)
- Has modes for different contexts (fix, feature, refactor)
- Agent-agnostic (works in any AI coding assistant)
- References knowledge skills from x-devsecops

---

## Skill Types

| Type | Prefix | Trigger | ccsetup Command | Example |
|------|--------|---------|-----------------|---------|
| **Core Workflow** | `x-*` | User invokes via command | Yes (optional) | x-implement, x-verify |
| **Behavioral** | none | Auto-triggered by conditions | **Never** | interview, complexity-detection |

### Core Workflow Skills (`x-*`)
- User-invocable execution workflows
- Named with `x-` prefix (e.g., `x-implement`, `x-plan`)
- May have corresponding `/command` in ccsetup (registered in `commands-registry.yml`)
- Define complete execution steps for a task
- Located in `skills/x-{name}/`

### Behavioral Skills (no prefix)
- Auto-triggered by specific conditions (not user-invoked)
- Named **without** prefix (e.g., `interview`, `complexity-detection`)
- **Never** have command wrappers in ccsetup - **never** added to `commands-registry.yml`
- Act as internal workflow modifiers, gates, or routers
- Typically have `category: behavioral` in SKILL.md metadata
- Located in `skills/{name}/` (no x- prefix)

---

## When to Update This Repo

| Trigger | Action |
|---------|--------|
| New workflow needed | Create skill in `skills/{name}/` with SKILL.md |
| New mode for existing skill | Add `references/mode-{name}.md` |
| Workflow pattern changes | Update SKILL.md + affected references |
| New playbook needed | Add to `skills/{name}/playbooks/` |
| Template update | Update `skills/{name}/templates/` |
