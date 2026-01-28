---
type: example
audience: [developers, llms]
scope: framework-agnostic
last-updated: 2026-01-28
status: current
---

# Example Initiative: Major Dependency Update

Updating a framework from v4 to v5 across a production codebase.

## Initiative Overview

| Field | Value |
|-------|-------|
| Name | framework-v5-migration |
| Effort | 3-4 weeks |
| Risk | Medium-High |
| Milestones | 4 |

## Milestone Breakdown

### M1: Audit (2 days) -- High ROI

**Goal**: Understand the scope of breaking changes.

- [ ] Read migration guide and changelog
- [ ] Inventory all direct usages of deprecated APIs
- [ ] Identify affected test files
- [ ] Document breaking changes with file locations
- [ ] Produce risk assessment

**Acceptance criteria**:
- Complete list of breaking changes with affected files
- Risk assessment document reviewed

### M2: Update and Fix (5 days) -- High ROI

**Goal**: Apply the version bump and fix all compilation/runtime errors.

- [ ] Update dependency version in package manifest
- [ ] Fix compilation errors (type changes, removed APIs)
- [ ] Update configuration files for new conventions
- [ ] Fix runtime errors discovered during smoke testing
- [ ] Update related peer dependencies

**Acceptance criteria**:
- Project builds without errors
- All imports resolve correctly

### M3: Test and Validate (3 days) -- Medium ROI

**Goal**: Ensure all tests pass and no regressions exist.

- [ ] Run full test suite, fix failures
- [ ] Run integration tests against updated APIs
- [ ] Performance benchmark comparison (before/after)
- [ ] Manual smoke test of critical user flows
- [ ] Update test snapshots and fixtures

**Acceptance criteria**:
- All tests passing
- No performance regression >5%
- Critical flows verified manually

### M4: Deploy and Monitor (2 days) -- Medium ROI

**Goal**: Ship to production with confidence.

- [ ] Deploy to staging environment
- [ ] Run E2E tests on staging
- [ ] Deploy to production (canary or blue-green)
- [ ] Monitor error rates for 24 hours
- [ ] Update documentation with new version notes

**Acceptance criteria**:
- Production error rate unchanged
- No rollback needed within 24 hours

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Hidden breaking change | Medium | High | Comprehensive audit in M1 |
| Test gaps | Low | Medium | Add tests for untested paths in M3 |
| Performance regression | Low | High | Benchmark in M3 before deploy |

## Rollback Plan

1. Revert the dependency version in package manifest
2. Revert all code changes (single PR makes this clean)
3. Redeploy previous version
4. Document what failed for retry

---

**Template source**: x-initiative playbooks
