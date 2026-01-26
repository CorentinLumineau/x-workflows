# Mode: agent

> **Invocation**: `/x-orchestrate agent` or `/x-orchestrate agent`
> **Legacy Command**: `/x:agent`

<purpose>
Subagent management - list, inspect, and get information about available custom subagents.
</purpose>

<instructions>

## Instructions

### Phase 1: List Agents

List available agents:

```markdown
## Available Subagents

### Explorer Agents
| Agent | Model | Purpose |
|-------|-------|---------|
| `ccsetup:x-explorer` | haiku | Fast codebase exploration |

### Implementation Agents
| Agent | Model | Purpose |
|-------|-------|---------|
| `ccsetup:x-tester` | haiku | Test execution, coverage |
| `ccsetup:x-refactorer` | haiku | Safe refactoring |

### Review Agents
| Agent | Model | Purpose |
|-------|-------|---------|
| `ccsetup:x-reviewer` | sonnet | Code review, quality |
| `ccsetup:x-refactorer` | sonnet | Complex debugging |

### Documentation Agents
| Agent | Model | Purpose |
|-------|-------|---------|
| `ccsetup:x-reviewer` | haiku | Documentation generation |
```

### Phase 2: Agent Details

Show details for specific agent:

```markdown
## Agent: {name}

**Model**: {model}
**Type**: {type}

### Capabilities
- {capability_1}
- {capability_2}

### When to Use
{description of use cases}

### Tools Available
- {tool_1}
- {tool_2}

### Example Invocation
```javascript
Task({
  subagent_type: "ccsetup:{name}",
  model: "{model}",
  prompt: "{example_prompt}"
})
```
```

### Phase 3: Agent Selection Help

```json
{
  "questions": [{
    "question": "What do you need to do?",
    "header": "Task",
    "options": [
      {"label": "Explore codebase", "description": "Use x-explorer (haiku)"},
      {"label": "Run tests", "description": "Use x-tester (haiku)"},
      {"label": "Review code", "description": "Use x-reviewer (sonnet)"},
      {"label": "Debug issue", "description": "Use x-refactorer (sonnet)"}
    ],
    "multiSelect": false
  }]
}
```

## Agent Categories

### Speed-Optimized (haiku)
- `x-explorer` - File discovery, pattern identification
- `x-tester` - Test execution, coverage
- `x-refactorer` - Safe refactoring
- `x-reviewer` - Documentation

### Quality-Optimized (sonnet)
- `x-reviewer` - Code review, SOLID validation
- `x-refactorer` - Complex debugging, root cause

## Agent Selection Guide

| Task | Agent | Reason |
|------|-------|--------|
| Find files | x-explorer | Fast, read-only |
| Run tests | x-tester | Test specialist |
| Review PR | x-reviewer | Quality focus |
| Debug bug | x-refactorer | Deep analysis |
| Refactor | x-refactorer | Safe changes |
| Write docs | x-reviewer | Doc patterns |

</instructions>

<critical_rules>

1. **Right Tool** - Match agent to task
2. **Model Choice** - haiku for speed, sonnet for quality
3. **Background Option** - Use for long tasks
4. **Monitor Progress** - Check background tasks

</critical_rules>

<success_criteria>

- [ ] Agents listed
- [ ] Details available
- [ ] Selection guidance provided

</success_criteria>

## References

- @core-docs/tools/task.md - Task tool usage
- @core-docs/AGENT_SELECTION_GUIDE.md - Selection guide
