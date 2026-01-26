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
| improve | Code quality improvements |
| cleanup | Dead code removal, tech debt |

## Mode Detection

Scan user input for keywords:

| Keywords | Mode |
|----------|------|
| "fix", "bug", "error", "broken", "failing" | fix |
| "refactor", "restructure", "reorganize" | refactor |
| "improve", "enhance", "better", "optimize" | improve |
| "cleanup", "clean", "remove dead", "tech debt" | cleanup |
| (default) | implement |

## Execution

1. **Detect mode** from user input
2. **If no valid mode detected**, use default (implement)
3. **If no arguments provided**, ask for task description
4. **Load mode instructions** from `references/`
5. **Follow instructions** completely

## Behavioral Skills

This workflow activates these knowledge skills:

### Always Active
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

If your agent supports subagents, consider using:
- An exploration agent for pattern discovery
- A testing agent for test execution
- A review agent for SOLID validation

## TDD Workflow

```
1. Write failing test (Red)
2. Write minimal code to pass (Green)
3. Refactor while tests pass (Refactor)
4. Repeat
```

## Quality Gates

All modes enforce these gates:

| Gate | Must Pass |
|------|-----------|
| Lint | ✓ |
| Types | ✓ |
| Tests | ✓ |
| Build | ✓ |

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
- **For improve mode**: See `references/mode-improve.md`
- **For cleanup mode**: See `references/mode-cleanup.md`
