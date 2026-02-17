# Phase Implementation Gates Reference

> Extracted from x-implement SKILL.md phases 4b, 5, and 6.
> These are detailed reference tables and checklists for post-implementation gates.

## Enforcement Summary

**Phase 4b — MANDATORY.** Output this compliance report after quality gates:

```
| Practice       | Status | Violations   | Action           |
|----------------|--------|--------------|------------------|
| TDD            | pass/fail  | V-TEST-01/02 | Pass / Fix needed |
| Testing        | pass/fail  | V-TEST-XX    | Pass / Fix needed |
| SOLID          | pass/warn  | V-SOLID-XX   | Pass / Flagged    |
| DRY/KISS/YAGNI | pass/warn  | V-DRY/KISS/YAGNI | Pass / Flagged |
| Patterns       | pass/warn  | V-PAT-XX     | Pass / Flagged    |
| Pareto         | pass/warn  | V-PARETO-XX  | Pass / Flagged    |
| Documentation  | pass/fail  | V-DOC-XX     | Pass / Fix needed |
```

**ANY fail = cannot proceed to Phase 5.**

## Documentation Sync

**Phase 5 — MANDATORY.** Verify documentation matches code changes:

1. Did public API signatures change? → Update API docs (V-DOC-01 BLOCK if skipped)
2. Were new public functions/classes created? → Add docs (V-DOC-02 BLOCK if skipped)
3. Did behavior change? → Update relevant docs (V-DOC-04 BLOCK if skipped)
4. Are internal doc references valid? → Verify (V-DOC-03)

**Phase 5 Exit Gate:**
- [ ] All public API docs match current signatures
- [ ] New public APIs documented
- [ ] Behavioral changes reflected in docs

**BLOCK if any exit gate fails.**

## Initiative Documentation

**Phase 6 — Conditional.** Skip if no active initiative exists.

### Initiative Detection

1. Check `.claude/initiative.json` for `currentMilestone`
2. If not found, check `documentation/milestones/_active/` for initiative directories
3. If no initiative detected, proceed to workflow chaining

### 5-Step Documentation Update Protocol

When an active initiative is detected, update documentation:

| Step | File | Update |
|------|------|--------|
| 1 | `_active/{initiative}/milestone-N.md` | Add progress update with completed tasks and metrics |
| 2 | `_active/{initiative}/README.md` | Update progress table (status, percentage, dates) |
| 3 | `documentation/milestones/README.md` | Update hub progress summary (if file exists) |
| 4 | `documentation/milestones/MASTER-PLAN.md` | Update orchestration status (if file exists) |
| 5 | `CLAUDE.md` | Update only for major milestone completions |

Update `.claude/initiative.json` checkpoint with latest progress.

**Reference**: See `@skills/x-initiative/playbooks/README.md` for the full documentation update workflow.
