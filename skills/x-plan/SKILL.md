---
name: x-plan
description: |
  Scale-adaptive implementation planning. Brainstorming, design, analysis workflows.
  Activate when planning features, brainstorming ideas, designing architecture, or analyzing code.
  Triggers: plan, brainstorm, design, architecture, analyze, implement planning.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---

# x-plan

Scale-adaptive implementation planning with automatic complexity detection and appropriate track routing.

## Modes

| Mode | Description |
|------|-------------|
| plan (default) | Implementation planning |
| brainstorm | Requirements discovery |
| design | Architecture design |
| analyze | Code analysis |

## Mode Detection

Scan user input for keywords:

| Keywords | Mode |
|----------|------|
| "brainstorm", "ideas", "requirements", "discover" | brainstorm |
| "design", "architecture", "architect", "system design" | design |
| "analyze", "analysis", "assess", "evaluate" | analyze |
| (default) | plan |

## Execution

1. **Detect mode** from user input
2. **If no valid mode detected**, use default (plan)
3. **If no arguments provided**, ask for planning scope
4. **Load mode instructions** from `references/`
5. **Follow instructions** completely

## Behavioral Skills

This workflow activates these knowledge skills:
- `analysis` - Pareto 80/20 prioritization

## Agent Suggestions

If your agent supports subagents, consider using:
- An exploration agent for codebase discovery
- A thinking agent for complex planning decisions

## Complexity Tracks

| Track | Complexity | Approach |
|-------|------------|----------|
| Quick | 1-2 hours | Inline planning |
| Standard | 3-8 hours | Story file + milestones |
| Enterprise | 8+ hours | Full initiative structure |

## Planning Workflow

```
1. Understand scope
2. Identify complexity track
3. Break into milestones
4. Prioritize with Pareto (20% effort → 80% value)
5. Create actionable plan
```

## Checklist

- [ ] Scope clearly defined
- [ ] Complexity track identified
- [ ] Milestones broken down
- [ ] Pareto prioritization applied
- [ ] Plan is actionable

## When to Load References

- **For plan mode**: See `references/mode-plan.md`
- **For brainstorm mode**: See `references/mode-brainstorm.md`
- **For design mode**: See `references/mode-design.md`
- **For analyze mode**: See `references/mode-analyze.md`
