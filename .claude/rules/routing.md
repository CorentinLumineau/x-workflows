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
New component needed?
│
├─ Is it workflow execution (HOW to do something)?
│  ├─ YES → Create in x-workflows/skills/{name}/
│  │        └─ Includes: steps, modes, playbooks, templates
│  │
│  └─ NO → Continue below
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
