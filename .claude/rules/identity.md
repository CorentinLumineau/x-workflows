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

## When to Update This Repo

| Trigger | Action |
|---------|--------|
| New workflow needed | Create skill in `skills/{name}/` with SKILL.md |
| New mode for existing skill | Add `references/mode-{name}.md` |
| Workflow pattern changes | Update SKILL.md + affected references |
| New playbook needed | Add to `skills/{name}/playbooks/` |
| Template update | Update `skills/{name}/templates/` |
