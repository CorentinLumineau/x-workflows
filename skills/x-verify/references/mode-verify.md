# Mode: verify

> **Invocation**: `/x-verify` or `/x-verify verify`
> **Legacy Command**: `/x:verify`

## Purpose

<purpose>
Zero-tolerance quality validation. Run all quality gates (lint, type-check, tests, build) with auto-fix loop until 100% passing. No issues tolerated.
</purpose>

## Behavioral Skills

This mode activates:
- `testing` - Testing pyramid enforcement
- `code-quality` - Quality gates validation

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **test runner** | Parallel gate execution | Can edit and run commands |
| **code reviewer** | Analysis mode | Read-only analysis |

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Auto-fix decision logic |
| `memory` | Cross-session persistence |

## Instructions

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 25%, context 20%, technical 30%, scope 15%, risk 10%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Test scope unclear, test failure interpretation ambiguous, fix strategy unclear (fix code or fix test?).

---

### Phase 1: Context Detection

Detect verification mode:

| Context | Mode |
|---------|------|
| No staged files | Test mode - targeted tests |
| Staged files detected | Full verification |
| "quality" keyword | Analysis mode |
| "docs" keyword | Documentation validation |

### Phase 2: Quality Gate Execution

Delegate to **test runner** agents (can edit and run commands) in parallel:
> "Run lint check"
> (Same for type-check, tests, build)

#### Gate Specifications

| Gate | Command | Pass Criteria |
|------|---------|---------------|
| Lint | `pnpm lint` | No errors |
| Types | `pnpm type-check` | No errors |
| Tests | `pnpm test` | 100% pass |
| Build | `pnpm build` | Success |

### Phase 3: Auto-Fix Loop

If any gate fails:

```
While (failures exist):
  1. Attempt auto-fix (ESLint --fix, Prettier)
  2. Re-run failed gate
  3. If still failing:
     - Use Sequential Thinking for analysis
     - Apply manual fix
  4. Verify fix worked
```

**Auto-fix commands**:
```bash
pnpm lint --fix
pnpm prettier --write .
```

### Phase 4: Documentation Validation

Verify documentation:
- [ ] Documentation structure exists
- [ ] Code changes have doc updates
- [ ] No broken references

### Phase 5: Workflow Transition

Present next step based on result:

**Success**:
```json
{
  "questions": [{
    "question": "All quality gates passed. Continue?",
    "header": "Next",
    "options": [
      {"label": "/x-git commit (Recommended)", "description": "Commit verified changes"},
      {"label": "/x-review", "description": "Code review before commit"},
      {"label": "Stop", "description": "Done for now"}
    ],
    "multiSelect": false
  }]
}
```

**Failure** (after auto-fix attempts):
```json
{
  "questions": [{
    "question": "Quality gates failed. How to proceed?",
    "header": "Next",
    "options": [
      {"label": "/x-implement fix (Recommended)", "description": "Fix failing tests"},
      {"label": "Continue fixing", "description": "I'll fix manually"},
      {"label": "Stop", "description": "Investigate offline"}
    ],
    "multiSelect": false
  }]
}
```


</instructions>

## Critical Rules

<critical_rules>
1. **Zero Tolerance** - ALL issues MUST be fixed
2. **100% Passing** - Continue loop until everything passes
3. **Auto-Fix First** - Try automated fixes before manual
4. **No Deferrals** - Don't skip or postpone issues
</critical_rules>

## Decision Making

<decision_making>
**Execute autonomously when**:
- Issues have obvious auto-fixes
- Test failure matches code change
- Clear lint/type errors

**Use AskUserQuestion when**:
- Test failure unclear (intentional change?)
- Multiple fix strategies
- Significant code changes needed
</decision_making>

## References

- @skills/quality-testing/ - Testing pyramid and coverage targets
- @skills/code-code-quality/ - Quality enforcement

## Success Criteria

<success_criteria>
- [ ] All quality gates passed
- [ ] 100% test pass rate
- [ ] Auto-fixes applied where possible
- [ ] Workflow transition presented
</success_criteria>
