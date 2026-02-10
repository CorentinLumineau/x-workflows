# Mode: context

> **Invocation**: `/x-help context` or "show me the current context"

<purpose>
Display current session context state across all loaded layers.
</purpose>

<instructions>

### Phase 1: Gather Context State

Read each context layer and check availability:

1. **Project docs** — Check if `CLAUDE.md` is loaded (read accessible)
2. **Initiative** — Read `.claude/initiative.json` for active initiative
3. **Workflow state** — Read `.claude/workflow-state.json` for active workflow
4. **Agent awareness** — Check if agent-awareness behavioral skill is active (12-agent catalog)
5. **Auto-memory** — Check if `MEMORY.md` is accessible and read last update
6. **MCP Memory** — Attempt `search_nodes("initiative-checkpoint")` to verify connection
7. **Interview state** — Read `.claude/interview-state.json` for confidence history
8. **Delegation history** — Search Memory MCP for `"delegation-log"` entity

### Phase 2: Display Context Table

Present results in a structured format:

```markdown
## Session Context

| Layer | Status | Details |
|-------|--------|---------|
| Project docs | {check/cross} | CLAUDE.md {loaded/not found} |
| Initiative | {check/cross} | {name} at {milestone} / No active initiative |
| Workflow state | {check/cross} | {type} at phase {n}/{total} ({phase}) / No active workflow |
| Agent awareness | {check/cross} | {count} agents loaded / Not loaded |
| Auto-memory | {check/cross} | MEMORY.md accessible / Not found |
| MCP Memory | {check/cross} | Connected ({entity_count} entities) / Unavailable (degraded mode) |
| Interview state | {check/cross} | {count} sessions recorded / No history |
| Delegation history | {check/cross} | {count} delegations recorded / No history |
```

### Phase 3: Recommendations

Based on context state, suggest actions:

| Missing Layer | Recommendation |
|---------------|----------------|
| Project docs | Run `/x-setup` to initialize project documentation |
| Initiative | Use `/x-initiative create` for multi-session tracking |
| Workflow state | Normal — created on first verb skill invocation |
| Agent awareness | Should auto-load; check context-awareness skill |
| MCP Memory | Verify Memory MCP server is configured in `.mcp.json` |
| Interview state | Normal — created on first interview |

</instructions>

<critical_rules>
1. **Read-only** — Never modify state, only display it
2. **Graceful** — Show cross for unavailable layers, never error
3. **Helpful** — Include actionable recommendations for missing layers
4. **On-demand** — Only run when explicitly requested
</critical_rules>

<success_criteria>
- [ ] All 8 layers checked
- [ ] Status clearly shown (check/cross)
- [ ] Details provided for each layer
- [ ] Recommendations given for missing layers
</success_criteria>
