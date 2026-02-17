# Mode: docs

> **Invocation**: `/x-review docs` or `/x-review documentation`

## Purpose

<purpose>
Documentation completeness and freshness audit. Verify that code changes have corresponding documentation updates, API docs match signatures, and initiative documentation is current.
</purpose>

## Phases (from x-review)

Docs mode runs phases: **0 → 1 → 4 → 6 → 7**

| Phase | Name | What Happens |
|-------|------|-------------|
| 0 | Confidence + State | Interview gate, workflow state check |
| 1 | Change Scoping | git diff analysis, identify doc-relevant changes |
| 4 | Documentation Audit | Full documentation check |
| 6 | Readiness Report | Pass/warn/block synthesis |
| 7 | Workflow State | Update state, chain to next |

## Documentation Audit Checklist

### Code Documentation
- [ ] Public API signatures have JSDoc/docstrings
- [ ] Complex logic has explanatory comments
- [ ] Examples are current and runnable
- [ ] No broken internal links or references

### Project Documentation
- [ ] README reflects current state
- [ ] CHANGELOG updated for user-facing changes
- [ ] Architecture docs match implementation
- [ ] Configuration docs list all options

### Initiative Documentation (if active)
- [ ] Milestone file updated with progress
- [ ] Initiative README progress table current
- [ ] Milestones hub reflects latest status
- [ ] MASTER-PLAN.md reflects latest status

Detection:
1. Check `.claude/initiative.json` for `currentMilestone`
2. If not found, check `documentation/milestones/_active/` for initiative dirs
3. If no initiative, skip initiative checks

### Violation Definitions

| ID | Severity | Description |
|----|----------|-------------|
| V-DOC-01 | HIGH | Public API undocumented |
| V-DOC-02 | CRITICAL | Breaking change undocumented |
| V-DOC-03 | MEDIUM | Stale example or reference |
| V-DOC-04 | HIGH | README out of date |

## Agent Delegation

| Role | Agent | Model |
|------|-------|-------|
| Codebase explorer | x-explorer | haiku |

## References

- @skills/code-code-quality/ - Documentation violation definitions
