# Agent Capability Matrix

Detailed capability mapping and team composition patterns for all specialized agents.

## Capability Grid

```
+-----------------------+-----+------+-------+------+------+------+-----+------+------+-------+------+------+
| Capability            | Rev | Sec  | Deploy| Debug| Test | Doc  | Exp | Refac| Desgn| DbgDp | TstFt| RevQk|
+-----------------------+-----+------+-------+------+------+------+-----+------+------+-------+------+------+
| Read code             | Y   | Y    | Y     | Y    | Y    | Y    | Y   | Y    | Y    | Y     | Y    | Y    |
| Write code            | N   | N    | N     | Y    | Y    | Y    | N   | Y    | Y    | Y     | Y    | N    |
| Run tests             | Y   | N    | Y     | Y    | Y    | N    | N   | Y    | N    | Y     | Y    | Y    |
| Execute bash          | Y   | Y    | Y     | Y    | Y    | N    | N   | Y    | Y    | Y     | Y    | Y    |
| Security analysis     | B   | Y    | N     | N    | N    | N    | N   | N    | B    | N     | N    | N    |
| SOLID enforcement     | Y   | N    | N     | N    | N    | N    | N   | Y    | Y    | N     | N    | B    |
| Deploy verification   | N   | N    | Y     | N    | N    | N    | N   | N    | N    | N     | N    | N    |
| Architecture design   | N   | N    | N     | N    | N    | N    | N   | B    | Y    | N     | N    | N    |
+-----------------------+-----+------+-------+------+------+------+-----+------+------+-------+------+------+
Legend: Y = Primary, B = Basic, N = Not available
```

## Team Composition Patterns

### Team vs Subagent Decision Matrix

| Factor | Subagent | Agent Team |
|--------|----------|------------|
| Task independence | Independent, no coordination | Interdependent, need discussion |
| Communication | Result-only (return value) | Inter-agent messaging (SendMessage) |
| Parallelism | Sequential or fire-and-forget | True parallel with shared state |
| Cost model | 1 agent at a time | N agents simultaneously |
| Coordination | None needed | Shared task list, blocking dependencies |
| Best for | Focused single-domain work | Multi-domain, cross-cutting concerns |

**Rule of thumb**: If agents need to talk to each other, use a team. If they just return results, use subagents.

### Team Patterns

| Pattern | Size | Agents | Use When |
|---------|------|--------|----------|
| **Research Team** | 2-3 | x-explorer (haiku) + general-purpose (sonnet) | Multi-perspective exploration |
| **Feature Team** | 3-4 | x-refactorer + x-tester + x-reviewer (sonnet) | Multi-layer feature implementation |
| **Review Team** | 2-3 | x-reviewer + x-security-reviewer (sonnet) | Parallel quality + security analysis |
| **Debug Team** | 2-3 | x-debugger + x-explorer + x-tester | Parallel hypothesis testing |
| **Refactor Team** | 2-3 | x-refactorer + x-tester + x-reviewer | Large-scale restructuring |

### Model Selection for Teammates

| Model | Role in Team | Use For |
|-------|-------------|---------|
| **Haiku** | Read-only workers | Exploration, scanning, pattern search |
| **Sonnet** | Implementation workers | Code changes, testing, reviewing, debugging |
| **Opus** | Never for teammates | Too expensive for parallel agents; use as lead only |

### Cost Awareness

- **Subagent**: 1 agent runs at a time; cost = sum of sequential runs
- **Team**: N agents run simultaneously; cost = N x parallel token usage
- Teams are 2-5x more expensive than subagents for equivalent work
- Use teams only when parallelism or coordination provides clear value
- Default to subagents; escalate to teams via complexity-detection advisory

See @skills/x-team/references/team-patterns.md for spawn templates and lifecycle details.
