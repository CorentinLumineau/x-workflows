---
type: example
audience: [developers, llms]
scope: framework-agnostic
last-updated: 2026-01-28
status: current
---

# Example Initiative: Codebase Refactoring

Extracting a module from a monolithic codebase into a standalone package.

## Initiative Overview

| Field | Value |
|-------|-------|
| Name | extract-auth-module |
| Effort | 2-3 weeks |
| Risk | Medium |
| Milestones | 4 |

## Milestone Breakdown

### M1: Analyze (2 days) -- High ROI

**Goal**: Map all boundaries, dependencies, and consumers of the auth code.

- [ ] Identify all files belonging to the auth domain
- [ ] Map inbound dependencies (who calls auth code)
- [ ] Map outbound dependencies (what auth code imports)
- [ ] Document the public API surface
- [ ] Identify circular dependencies to break

**Acceptance criteria**:
- Dependency graph documented
- Public API surface defined
- No unknowns in the boundary

**Success metrics**:
- Files identified: target 100% coverage
- Circular dependencies: all catalogued

### M2: Plan (1 day) -- High ROI

**Goal**: Define the extraction strategy and new package structure.

- [ ] Design new package directory structure
- [ ] Define the public API (exports)
- [ ] Plan the adapter layer for current consumers
- [ ] Create migration checklist for each consumer
- [ ] Estimate effort per consumer migration

**Acceptance criteria**:
- Package structure documented
- Migration checklist for every consumer
- Adapter pattern defined

### M3: Extract (5 days) -- Medium ROI

**Goal**: Move code, create the package, and wire up adapters.

- [ ] Create new package with build configuration
- [ ] Move auth files to new package
- [ ] Create adapter/facade for backward compatibility
- [ ] Update all consumers to use adapter imports
- [ ] Remove circular dependencies
- [ ] Ensure build passes

**Acceptance criteria**:
- New package builds independently
- All consumers compile with adapter
- Zero circular dependencies

### M4: Validate (3 days) -- Medium ROI

**Goal**: Verify correctness, performance, and documentation.

- [ ] Run full test suite (unit + integration)
- [ ] Verify auth flows end-to-end
- [ ] Performance comparison (before/after)
- [ ] Update documentation and README
- [ ] Remove adapter layer once all consumers migrated (optional)

**Acceptance criteria**:
- All tests passing
- No performance regression
- Documentation complete

## Pareto Prioritization

The 80/20 analysis for this initiative:

| Item | Value | Effort | ROI |
|------|-------|--------|-----|
| M1 Analysis | High (prevents rework) | Low (2d) | Very High |
| M2 Plan | High (clear path) | Low (1d) | Very High |
| M3 Extract | High (the actual work) | Medium (5d) | Medium |
| M4 Validate | Medium (confidence) | Medium (3d) | Medium |

By completing M1-M2 first (3 days), we gain clarity that prevents wasted effort in M3-M4.

## Success Metrics

| Metric | Target |
|--------|--------|
| Test pass rate | 100% |
| Build time delta | <10% increase |
| Consumer migration | 100% of consumers |
| Public API size | Minimal surface area |

## Rollback Plan

If extraction fails mid-way:
1. Revert all changes (git revert the PR)
2. Auth code remains in monolith
3. Document lessons learned
4. Re-attempt with adjusted strategy

---

**Template source**: x-initiative playbooks
