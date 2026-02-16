# Routing Rules Reference

> Used by Phase 0.7 (Smart Routing) to determine correct repository and path.

## Decision Tree

```
Creating...
├─ Workflow skill (x-*) → x-workflows/skills/x-{name}/
├─ Behavioral skill → x-workflows/skills/{name}/
├─ Knowledge skill → x-devsecops/skills/{category}/{name}/
├─ Agent (plugin) → ccsetup-plugin/agents/x-{name}.md
├─ Agent (project) → .claude/agents/x-{name}.md
├─ Command (plugin) → ccsetup-plugin/commands/{name}.md
├─ Command (project) → .claude/commands/{name}.md
└─ Local skill → .claude/skills/{name}/ or ~/.claude/skills/{name}/
```

## Smart Detection

Before creating, check if the target source repo exists locally:

1. **Check for source repo**: Look for `../x-workflows` or `../x-devsecops` relative to ccsetup root
2. **If found** → Create directly in the source repo at the correct path
3. **If not found** → Create locally in the detected scope + add migration TODO:
   ```markdown
   <!-- TODO: migrate to {repo}/skills/{path} when source repo is available -->
   ```

## Routing by Component Type

### Skills

| Skill Type | Indicators | Target Repo | Path |
|------------|-----------|-------------|------|
| Workflow (x-*) | Name starts with `x-`, user-invocable, has modes | x-workflows | `skills/x-{name}/` |
| Behavioral | Auto-activated, context-triggered, no `/x-` prefix | x-workflows | `skills/{name}/` |
| Knowledge | Domain expertise, reference material, category-based | x-devsecops | `skills/{category}/{name}/` |
| Local | Project-specific, not reusable across projects | N/A (local) | `.claude/skills/{name}/` |

### Knowledge Skill Categories

| Category | Examples |
|----------|---------|
| code | code-quality, design-patterns, refactoring-patterns, api-design |
| security | owasp, authentication, authorization, input-validation |
| quality | testing, debugging, performance, observability |
| data | database, caching, message-queues, nosql |
| delivery | ci-cd, deployment-strategies, release-management |
| meta | analysis, decision-making, architecture-patterns |
| operations | monitoring, sre-practices, incident-response, disaster-recovery |

### Commands

| Scope | When | Path |
|-------|------|------|
| Plugin | Extending ccsetup plugin | `ccsetup-plugin/commands/{name}.md` |
| Project | Project-specific command | `.claude/commands/{name}.md` |
| User | Personal global command | `~/.claude/commands/{name}.md` |

### Agents

| Scope | When | Path |
|-------|------|------|
| Plugin | Extending ccsetup plugin | `ccsetup-plugin/agents/x-{name}.md` |
| Project | Project-specific agent | `.claude/agents/x-{name}.md` |
| User | Personal global agent | `~/.claude/agents/x-{name}.md` |

## Critical Constraints

1. **ccsetup-plugin NEVER receives skills directly** — only via `make sync-skills`
2. **Workflow logic belongs in x-workflows** — never in ccsetup commands or agents
3. **Domain knowledge belongs in x-devsecops** — never in workflow skills
4. **Commands are thin wrappers** — they delegate to skills, not contain logic
