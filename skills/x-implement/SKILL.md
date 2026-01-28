---
name: x-implement
description: |
  Context-aware implementation with TDD and quality gates. Fixes, refactoring, improvements.
  Activate when implementing features, fixing bugs, refactoring code, or cleaning up technical debt.
  Triggers: implement, feature, fix, bug, refactor, improve, cleanup, code change.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---

# x-implement

Context-aware implementation with automatic pattern discovery and smart workflow routing.

## Modes

| Mode | Description |
|------|-------------|
| implement (default) | New feature implementation with TDD |
| fix | Quick bug fixing with escalation |
| refactor | Safe refactoring with zero regression |
| enhance | Targeted code quality improvements |
| cleanup | Dead code removal, tech debt |

## Mode Detection
| Keywords | Mode |
|----------|------|
| "fix", "bug", "error", "broken", "failing" | fix |
| "refactor", "restructure", "reorganize" | refactor |
| "enhance", "improve", "better", "optimize" | enhance |
| "cleanup", "clean", "remove dead", "tech debt" | cleanup |
| (default) | implement |

## Execution
- **Default mode**: implement
- **No-args behavior**: Ask for task description

## Behavioral Skills

This workflow activates these behavioral skills:

### Always Active
- `interview` - Zero-doubt confidence gate (Phase 0)
- `code-quality` - SOLID, DRY, KISS enforcement
- `testing` - Testing pyramid (70/20/10)

### Context-Triggered
| Skill | Trigger Conditions |
|-------|-------------------|
| `authentication` | Auth flows, login, JWT, OAuth |
| `owasp` | Security-sensitive code |
| `database` | Schema changes, migrations |
| `api-design` | API endpoints, contracts |

## Agent Suggestions

Consider delegating to specialized agents:
- **Exploration**: Pattern discovery, codebase analysis
- **Testing**: Test execution, coverage analysis
- **Review**: SOLID validation, quality checks

## TDD Workflow

```
1. Write failing test (Red)
2. Write minimal code to pass (Green)
3. Refactor while tests pass (Refactor)
4. Repeat
```

## Quality Gates
All modes enforce: **Lint** | **Types** | **Tests** | **Build**

## Checklist

- [ ] Tests written first (TDD)
- [ ] All quality gates pass
- [ ] No regressions introduced
- [ ] Code follows SOLID principles
- [ ] Documentation updated if needed

## When to Load References

- **For implement mode**: See `references/mode-implement.md`
- **For fix mode**: See `references/mode-fix.md`
- **For refactor mode**: See `references/mode-refactor.md`
- **For enhance mode**: See `references/mode-enhance.md`
- **For cleanup mode**: See `references/mode-cleanup.md`
