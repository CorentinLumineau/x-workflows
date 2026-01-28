# x-workflows Routing Rules

## What Does NOT Belong Here

| Component | Correct Repository | Why |
|-----------|-------------------|-----|
| Commands (/commit, /verify) | → `ccsetup/commands/` | Commands are Claude Code specific |
| Agents (x-tester, x-reviewer) | → `ccsetup/agents/` | Agents are orchestration layer |
| Knowledge skills (owasp, testing) | → `x-devsecops/skills/` | Domain expertise, not execution |
| Core behavioral rules | → `ccsetup/core-docs/RULES.md` | Global rules, not workflow-specific |
| Plugin configuration | → `ccsetup/.claude-plugin/` | Plugin metadata |

---

## Decision Tree

```
New skill needed?
│
├─ Is it triggered automatically by conditions?
│  └─ YES → Behavioral skill (no x- prefix)
│           Location: skills/{name}/
│           ⚠️  No command wrapper in ccsetup - NEVER add to commands-registry.yml
│           Examples: interview, complexity-detection
│
├─ Is it a user-invocable workflow?
│  └─ YES → Core workflow skill (x-* prefix)
│           Location: skills/x-{name}/
│           May have command wrapper in ccsetup (via commands-registry.yml)
│           Examples: x-implement, x-plan, x-verify
│
├─ Is it domain knowledge (WHAT to know)?
│  └─ YES → x-devsecops/skills/{category}/{name}/
│
├─ Is it a command or agent?
│  └─ YES → ccsetup/commands/ or ccsetup/agents/
│
└─ Is it a core behavioral rule?
   └─ YES → ccsetup/core-docs/RULES.md
```

### Skill Type Quick Reference

| Question | Answer | Skill Type |
|----------|--------|------------|
| User explicitly invokes it? | Yes | Core Workflow (`x-*`) |
| Auto-triggers on conditions? | Yes | Behavioral (no prefix) |
| Needs command in ccsetup? | Maybe | Core Workflow only |
| Acts as gate/router/modifier? | Yes | Behavioral |
