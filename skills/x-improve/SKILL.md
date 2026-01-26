---
name: x-improve
description: |
  Holistic code health analyzer with Pareto-optimized quick wins suggestions.
  Activate when analyzing code quality, suggesting improvements, or scoring health.
  Triggers: improve, quick wins, code health, analyze quality, what should I improve.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---

# x-improve

Holistic code health analyzer that scores coverage, best-practices, and refactoring opportunities, then suggests 3 Pareto-optimized quick wins.

## Modes

| Mode | Description |
|------|-------------|
| improve (default) | Holistic analysis |

## Execution
- **Default mode**: improve (single-mode skill)
- **No-args behavior**: Run full code health analysis

## Behavioral Skills

This workflow activates these knowledge skills:
- `analysis` - Pareto 80/20 prioritization
- `code-quality` - SOLID, DRY, KISS assessment
- `testing` - Coverage evaluation

## Agent Suggestions

Consider delegating to specialized agents:
- **Testing**: Coverage analysis, test gap identification
- **Review**: Best practices audit, SOLID validation
- **Exploration**: Refactoring opportunities discovery

## Analysis Workflow

```
Phase 1: Parallel Analysis
├── Coverage scan
├── Best practices audit
└── Refactoring scan
    ↓
Phase 2: Score & Prioritize
    ↓
Phase 3: Suggest 3 Quick Wins
    ↓
Phase 4: User selects → Execute
```

## Health Scoring

| Area | Measures |
|------|----------|
| Coverage | Test coverage %, untested files |
| Best Practices | SOLID violations, code smells |
| Refactoring | Duplication, complexity, coupling |

## Quick Wins Criteria

| Criterion | Description |
|-----------|-------------|
| Impact | How much does this improve the score? |
| Effort | How long to implement? (prefer <30 min) |
| Risk | Low risk changes preferred |
| Dependencies | Isolated changes preferred |

## Pareto Principle

Focus on 20% of changes that deliver 80% improvement:

```
Quick Wins = High Impact + Low Effort + Low Risk
```

## Output Format

```
# Code Health Analysis

## Scores
- Coverage: 72% (target: 80%)
- Best Practices: 85%
- Refactoring: 68%

## Quick Wins (Pareto-Optimized)

1. **[Win Name]** - Impact: High, Effort: 15min
   [Description]

2. **[Win Name]** - Impact: Medium, Effort: 30min
   [Description]

3. **[Win Name]** - Impact: Medium, Effort: 20min
   [Description]

Select 1-3 to execute, or 'all' for all.
```

## Checklist

- [ ] All areas analyzed
- [ ] Scores calculated
- [ ] Quick wins identified
- [ ] Pareto prioritization applied
- [ ] User can select actions

## When to Load References

- **For improve mode**: See `references/mode-improve.md`
