# Mode: improve

> **Invocation**: `/x-review improve` or `/x-review improve "scope"`

<purpose>
Pareto-focused best practices improvement. Delegates to x-improve for holistic analysis, then routes to x-implement for execution.
</purpose>

## Delegation Pattern

This mode **delegates** to the `x-improve` skill for comprehensive code health analysis rather than duplicating its logic.

### Why Delegation?

- **DRY Compliance**: Single source of truth for improvement logic
- **Consistency**: Same analysis methodology across all entry points
- **Maintainability**: Updates to x-improve automatically apply here

<instructions>

## Workflow

```
/x-review improve → [Delegate to x-improve] → Quick Wins → [Route to x-implement]
```

### Step 1: Invoke x-improve

Load and execute the canonical `x-improve` skill:

- **If scope provided**: `/x-improve {scope}`
- **If no scope**: `/x-improve`

The x-improve skill will:
1. Run parallel analysis (coverage, best practices, refactoring)
2. Calculate health scores
3. Present 3 Pareto-optimized quick wins

### Step 2: Post-Analysis Routing

After x-improve presents quick wins and user selects items to execute:

- Route each selected quick win to `/x-implement fix`
- Track progress via TodoWrite

### Execution Handoff

| Quick Win Type | Route To |
|----------------|----------|
| Coverage improvement | `/x-verify coverage` → `/x-implement` |
| Best practices fix | `/x-implement fix` |
| Refactoring | `/x-implement refactor` |

</instructions>

## References

- **Delegates to**: `x-improve` skill (canonical implementation)
- **Execution via**: `x-implement` skill

<success_criteria>

- [ ] x-improve skill invoked
- [ ] Health scores presented
- [ ] Quick wins identified
- [ ] Selected wins routed to x-implement

</success_criteria>

---

**Version**: 5.1.3 | **Pattern**: Delegation
