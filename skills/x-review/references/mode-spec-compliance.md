# Mode: spec-compliance

> **Invocation**: `/x-review spec` or `/x-review spec-compliance` or `/x-review specification`

## Purpose

Verify that implementation matches the specification, plan, or requirements before proceeding to code quality review. This mode focuses exclusively on requirement tracing — not code quality, style, or architecture.

## Phases (from x-review)

Spec-compliance mode runs phases: **0 → 1 → SC → 6 → 7**

| Phase | Name | What Happens |
|-------|------|-------------|
| 0 | Confidence + State | Interview gate, workflow state check |
| 1 | Change Scoping | git diff, identify changed files and domains |
| SC | Spec Compliance | Requirement tracing (see below) |
| 6 | Readiness Report | Pass/warn/block synthesis |
| 7 | Workflow State | Update state, chain to next |

## Spec Compliance Phase (SC)

### Step 1: Load Specification

Locate the spec source in priority order:

| Source | Detection | Priority |
|--------|-----------|----------|
| Plan from `/x-plan` | `.claude/initiative.json` → plan output | 1 (highest) |
| Issue from `/git-implement-issue` | `.claude/initiative.json` → issue body | 2 |
| User-provided spec | `$ARGUMENTS` contains spec content | 3 |
| No spec available | Ask user to provide requirements | 4 (fallback) |

If no spec is found and user cannot provide one, skip spec-compliance and suggest full `review` mode instead.

### Step 2: Requirement Tracing

For each requirement in the spec, trace to implementation:

```
Requirement R1: "{description}"
├─ Implemented in: {file}:{line} ✓
├─ Test coverage: {test_file}:{test_name} ✓
└─ Status: PASS

Requirement R2: "{description}"
├─ Implemented in: NOT FOUND ✗
├─ Test coverage: N/A
└─ Status: MISSING
```

### Step 3: Gap Analysis

Identify three types of gaps:

| Gap Type | Description | Severity |
|----------|-------------|----------|
| **Missing requirement** | Spec item not implemented | CRITICAL |
| **Extra feature (YAGNI)** | Code not in spec (scope creep) | HIGH |
| **Misunderstanding** | Implemented differently than specified | CRITICAL |

### Step 4: Spec Compliance Report

```
## Spec Compliance Report

| Requirement | Status | Location | Notes |
|-------------|--------|----------|-------|
| R1: {desc} | PASS | file:line | — |
| R2: {desc} | MISSING | — | Not implemented |
| R3: {desc} | MISMATCH | file:line | Different interpretation |

### Extra Features (YAGNI Check)
- {file}: {description of unspecified feature}

### Verdict: {PASS | BLOCK}
```

## Gate Behavior

**If spec compliance PASSES**: Proceed to code quality review (suggest `/x-review` or `/x-review audit`).

**If spec compliance FAILS (BLOCK)**: Return to `/x-implement` with:
- List of missing requirements
- List of misunderstandings with spec vs implementation comparison
- List of YAGNI features to remove

Do NOT proceed to code quality review when spec compliance fails — fixing spec issues first prevents wasted review effort on code that may be rewritten.

## Success Criteria

- [ ] All spec requirements traced to implementation
- [ ] No missing requirements
- [ ] No misunderstandings (spec vs implementation match)
- [ ] YAGNI check passed (no unspecified features)
- [ ] Spec compliance report produced

## Chaining

| Result | Chain To | Auto? |
|--------|----------|-------|
| All requirements pass | `/x-review review` or `/x-review audit` | Yes (suggest) |
| Requirements missing | `/x-implement` | Yes (suggest) |
| Persistent gaps | `/x-plan` (revise plan) | No (ask) |
