---
name: x-verify
description: Quality verification with auto-fix enforcement.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "2.0.0"
  category: workflow
---

# /x-verify

> Run quality gates and ensure all tests pass.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | APEX |
| **Phase** | test (X) |
| **Position** | 4 of 6 in workflow |

**Flow**: `x-implement` → **`x-verify`** → `x-review`

## Intention

**Scope**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Run full verification on all changes.
{{/if}}

## Behavioral Skills

This skill activates:
- `interview` - Zero-doubt confidence gate (Phase 0)
- `testing` - Testing pyramid enforcement
- `quality-gates` - CI quality checks

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **test runner** | Test execution, coverage | Can edit and run commands |

<instructions>

### Phase 0: Confidence Check

Activate `@skills/interview/` if:
- Test scope unclear
- Multiple test strategies possible
- Coverage targets undefined

### Phase 1: Run Quality Gates

Execute all gates:

```bash
# Lint check
pnpm lint

# Type check
pnpm type-check

# Run tests
pnpm test

# Build verification
pnpm build
```

### Phase 2: Handle Failures

If any gate fails:

```
Gate Failure Detected
        ↓
Attempt Auto-Fix
        ↓
Re-run Gate
        ↓
Still Failing? → Report and suggest fix
        ↓
Passing → Continue
```

**Auto-fix capabilities:**
- Lint errors: `pnpm lint --fix`
- Type errors: Suggest type additions
- Test failures: Analyze and suggest fixes
- Build errors: Report with context

### Phase 3: Coverage Analysis

Check test coverage targets:

| Type | Target |
|------|--------|
| Unit | 70% |
| Integration | 20% |
| E2E | 10% |

If coverage is below target, suggest tests to add.

### Phase 4: Verification Complete

When all gates pass:
- All linting passes
- Type checking passes
- All tests pass
- Build succeeds
- Coverage targets met

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | Skip verification to commit |
| **High** | ASK IF ABLE | Persistent test failures |
| **Medium** | ASK IF UNCERTAIN | Coverage below target |
| **Low** | PROCEED | Standard verification |

<human-approval-framework>

When approval needed, structure question as:
1. **Context**: Current verification status
2. **Options**: Fix issues, skip (with warning), or investigate
3. **Recommendation**: Fix before proceeding
4. **Escape**: "Return to /x-implement" option

</human-approval-framework>

## Agent Delegation

**Recommended Agent**: **test runner** (test execution)

| Delegate When | Keep Inline When |
|---------------|------------------|
| Large test suite | Quick verification |
| Coverage analysis | Simple lint/type check |

## Workflow Chaining

**Next Verb**: `/x-review`

| Trigger | Chain To | Auto? |
|---------|----------|-------|
| All gates pass | `/x-review` | Yes |
| Tests fail | `/x-implement` | No (show failures) |
| Persistent failures | `/x-troubleshoot` | No (ask) |

<chaining-instruction>

When verification passes:
- skill: "x-review"
- args: "review verified changes"

On test failures:
"Verification found {count} failures. Fix with /x-implement or investigate?"
- Option 1: `/x-implement` - Fix the issues
- Option 2: `/x-troubleshoot` - Investigate deeper
- Option 3: Review failures

</chaining-instruction>

## Quality Gates

All must pass:
- **Lint** | **Types** | **Tests** | **Build**

## Coverage Targets

| Type | Target |
|------|--------|
| Unit | 70% |
| Integration | 20% |
| E2E | 10% |

## Critical Rules

1. **Zero Tolerance** - All gates must pass
2. **Auto-Fix First** - Attempt fixes before reporting
3. **Coverage Matters** - Track and improve coverage
4. **No Regressions** - Existing tests must still pass

## Navigation

| Direction | Verb | When |
|-----------|------|------|
| Previous | `/x-implement` | Need to fix code |
| Next | `/x-review` | Verification passes |
| Branch | `/x-troubleshoot` | Persistent failures |

## Success Criteria

- [ ] All linting passes
- [ ] Type checking passes
- [ ] All tests pass
- [ ] Build succeeds
- [ ] Coverage targets met

## When to Load References

- **For verification details**: See `references/mode-verify.md`
- **For build guidance**: See `references/mode-build.md`
- **For coverage improvement**: See `references/mode-coverage.md`

## References

- @skills/quality-testing/ - Testing pyramid and strategies
- @skills/quality-quality-gates/ - CI quality checks
