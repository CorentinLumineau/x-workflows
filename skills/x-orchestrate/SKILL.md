---
name: x-orchestrate
description: |
  Guided workflow execution with human-first checkpoints and background task management.
  Activate when running multi-step workflows, managing background tasks, or coordinating agents.
  Triggers: orchestrate, workflow, background, agent, coordinate, parallel.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---

# x-orchestrate

Guided workflow execution with human-first checkpoints and background task management.

## Modes

| Mode | Description |
|------|-------------|
| orchestrate (default) | Guided workflow |
| background | Background task management |
| agent | Subagent information |

## Mode Detection
| Keywords | Mode |
|----------|------|
| "background", "async", "running tasks", "check tasks" | background |
| "agent", "subagent", "list agents", "agent info" | agent |
| (default) | orchestrate |

## Execution
- **Default mode**: orchestrate
- **No-args behavior**: List available workflows

## Behavioral Skills

This workflow activates these behavioral skills:
- `interview` - Zero-doubt confidence gate (Phase 0)

## Available Workflows

| Workflow | Sequence |
|----------|----------|
| Feature | brainstorm → plan → implement → verify → commit |
| Bug Fix | debug → fix → verify → commit |
| Refactor | analyze → refactor → verify → commit |
| Release | verify → commit → release |

## Workflow Execution

Each workflow step:
1. Execute step
2. Checkpoint (human verification if needed)
3. Proceed or adjust
4. Repeat until complete

## Agent Suggestions

If your agent supports subagents, consider:

| Agent Type | Purpose | Use When |
|------------|---------|----------|
| Explorer | Fast codebase exploration | Pattern discovery |
| Tester | Test execution | Verification |
| Reviewer | Code review | Quality checks |
| Refactorer | Safe refactoring | Code restructuring |
| Debugger | Complex debugging | Multi-layer issues |
| Doc Writer | Documentation generation | Doc updates |

## Background Tasks

For long-running tasks, consider background execution:

```
1. Start task in background
2. Continue other work
3. Check status when needed
4. Retrieve results
```

## Parallelization

When tasks are independent:
- Run exploration and analysis in parallel
- Run independent tests in parallel
- Parallelize where no dependencies exist

## Human-First Checkpoints

| Checkpoint | Ask User |
|------------|----------|
| Plan approval | Before major implementation |
| Breaking changes | Before applying |
| Deployment | Before production |
| Destructive actions | Always |

## Checklist

- [ ] Workflow identified
- [ ] Steps sequenced correctly
- [ ] Checkpoints placed
- [ ] Parallelization considered
- [ ] Human approval where needed

## When to Load References

- **For orchestrate mode**: See `references/mode-orchestrate.md`
- **For background mode**: See `references/mode-background.md`
- **For agent mode**: See `references/mode-agent.md`
