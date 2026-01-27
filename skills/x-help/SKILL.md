---
name: x-help
description: |
  Quick reference for all workflow commands and rules management.
  Activate when asking for help, listing commands, or managing behavioral rules.
  Triggers: help, commands, list, rules, how to, what can.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---

# x-help

Quick reference for all x/ commands and behavioral rules management.

## Modes

| Mode | Description |
|------|-------------|
| help (default) | Command reference |
| rules | Rules directory management |

## Mode Detection
| Keywords | Mode |
|----------|------|
| "rules", "create rule", "list rules", "behavioral" | rules |
| (default) | help |

## Execution
- **Default mode**: help
- **No-args behavior**: Show command overview

## Behavioral Skills

This workflow activates these behavioral skills:
- `interview` - Zero-doubt confidence gate (Phase 0)

## Command Categories

| Category | Skills | Purpose |
|----------|--------|---------|
| Planning | x-plan | Plan, brainstorm, design, analyze |
| Implementation | x-implement | Feature, fix, refactor, improve |
| Verification | x-verify | Test, build, coverage |
| Review | x-review | Code review, audit |
| Git | x-git | Commit, release |
| Debugging | x-troubleshoot | Debug, troubleshoot, explain |
| Documentation | x-docs | Doc management |
| Initiative | x-initiative | Project tracking |
| Research | x-research | Q&A, deep research |
| Improvement | x-improve | Code health analysis |
| Orchestration | x-orchestrate | Workflows, agents |
| Setup | x-setup | Project setup |
| Creation | x-create | Create skills/commands/agents |
| Deployment | x-deploy | Deployment workflows |
| Monitoring | x-monitor | Monitoring setup |

## Workflow Patterns

### Feature Development
```
x-plan brainstorm → x-plan design → x-plan
    ↓
x-implement → x-verify → x-review → x-git commit
```

### Bug Fix
```
x-troubleshoot → x-implement fix → x-verify → x-git commit
```

### Release
```
x-verify → x-git commit → x-git release
```

### Multi-Session Project
```
x-initiative create → [work] → x-initiative continue
    ↓
x-initiative archive (when complete)
```

## Rules Management

Rules are behavioral guidelines stored in project configuration:
- Create rules for project-specific patterns
- List active rules
- Rules affect all workflows

## Checklist

- [ ] Command reference accessible
- [ ] Rules can be listed
- [ ] New rules can be created
- [ ] Workflows are documented

## When to Load References

- **For help mode**: See `references/mode-help.md`
- **For rules mode**: See `references/mode-rules.md`
