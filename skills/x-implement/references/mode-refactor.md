# Mode: refactor

> **Invocation**: `/x:refactor` or `/x-implement refactor "description"`
> **Legacy Command**: `/x:improve-refactor`

<purpose>
Safe code refactoring with zero regression guarantee and scope detection. Apply SOLID, DRY, KISS principles while maintaining existing behavior. If refactoring scope is too large, redirects to initiative creation for proper tracking.
</purpose>

## Behavioral Skills

This mode activates:
- `code-quality` - SOLID/DRY/KISS enforcement
- `testing` - Test-driven refactoring
- `context-awareness` - Pattern awareness
- `complexity-detection` - Scope assessment

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **refactoring agent** | Complex refactoring operations | Safe restructuring |
| **test runner** | Verification | Can edit and run commands |
| **codebase explorer** | Pattern discovery, scope analysis | Fast, read-only |

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Complex refactoring decisions, scope assessment |

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 20%, context 25%, technical 30%, scope 15%, risk 10%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 0b

**Triggers for this mode**: Scope of refactoring undefined, no performance baseline, definition of "clean" unclear.

---

### Phase 0b: Scope Detection (CRITICAL)

**Before any refactoring, assess scope to determine approach.**

Use x-explorer agent to analyze:
```
Task prompt: "Analyze refactoring scope for: {user description}
- Count files that need changes
- Identify architectural impact
- Estimate complexity
Return: file count, layers affected, complexity (small/medium/large)"
```

**Scope Classification:**

| Scope | Criteria | Action |
|-------|----------|--------|
| **Small** | 1-3 files, single component, <2 hours | Continue with refactor |
| **Medium** | 4-10 files, 2-3 components, <1 day | Continue with TodoWrite tracking |
| **Large** | 10+ files, architectural changes, >1 day | **Redirect to initiative** |

**If LARGE scope detected:**

```json
{
  "questions": [{
    "question": "This refactoring is too large for a single session. It affects 10+ files and requires architectural changes. Create an initiative to track it properly?",
    "header": "Large Refactor",
    "options": [
      {"label": "/x:initiative create (Recommended)", "description": "Create initiative with milestones for this refactor"},
      {"label": "Continue anyway", "description": "Proceed with refactor (not recommended for large scope)"},
      {"label": "Narrow scope", "description": "Help me focus on a smaller part"}
    ],
    "multiSelect": false
  }]
}
```

**If user chooses initiative creation:**
- Stop refactoring
- Create initiative with milestones using `/x:initiative create`
- Each milestone = one coherent refactoring phase
- Example: M1: Extract interfaces, M2: Implement new structure, M3: Migrate consumers

### Phase 1: Pre-Refactor Baseline

**Critical**: Establish baseline BEFORE any changes.

```bash
# Run full test suite
pnpm test

# Capture baseline metrics
pnpm lint
pnpm type-check
```

All tests MUST pass before proceeding. If tests fail, fix them first.

### Phase 2: Analysis

Analyze code for refactoring opportunities:

| Smell | Refactoring |
|-------|-------------|
| Long method (>50 lines) | Extract method |
| Large class | Extract class |
| Duplicate code | Extract shared function |
| God class | Split responsibilities |
| Feature envy | Move method |
| Primitive obsession | Introduce value object |

### Phase 3: Incremental Refactoring

**Critical**: Small steps, verify after each.

For each refactoring:
1. **Make ONE change** - Single responsibility
2. **Run tests** - Must pass
3. **Commit if passing** - Atomic commits
4. **Continue or rollback** - Never proceed with failing tests

```
Change → Test → Pass? → Commit → Next
              ↓ Fail
           Rollback
```

### Phase 4: Verify Zero Regression

After all changes:
```bash
pnpm test        # All tests pass
pnpm lint        # No lint errors
pnpm type-check  # No type errors
pnpm build       # Builds successfully
```

### Phase 5: Workflow Transition

Present next step:
```json
{
  "questions": [{
    "question": "Refactoring complete. All tests passing. Continue?",
    "header": "Next",
    "options": [
      {"label": "/x-review (Recommended)", "description": "Full quality gates"},
      {"label": "/x-review", "description": "Code review"},
      {"label": "/git-commit", "description": "Commit changes"}
    ],
    "multiSelect": false
  }]
}
```
</instructions>

<critical_rules>
1. **Zero Regression** - All tests must pass throughout
2. **Small Steps** - One refactoring at a time
3. **Verify Always** - Run tests after each change
4. **Atomic Commits** - Each refactoring is one commit
5. **No Behavior Change** - Preserve existing functionality
</critical_rules>

## SOLID Checklist

Apply these principles:
- [ ] **S**ingle Responsibility - One reason to change
- [ ] **O**pen/Closed - Open for extension, closed for modification
- [ ] **L**iskov Substitution - Subtypes substitutable
- [ ] **I**nterface Segregation - Specific interfaces
- [ ] **D**ependency Inversion - Depend on abstractions

<decision_making>
**Refactor autonomously when**:
- Clear code smell
- Established refactoring pattern
- All tests pass

**Use AskUserQuestion when**:
- Multiple refactoring approaches
- Large scope change
- Breaking API change risk
</decision_making>

## References

- @skills/code-code-quality/ - SOLID, DRY, KISS, YAGNI principles

<success_criteria>
- [ ] **Scope assessed** (Phase 0 complete)
- [ ] Large scope redirected to initiative OR user confirmed proceed
- [ ] Baseline captured
- [ ] All refactorings applied incrementally
- [ ] Zero test failures
- [ ] SOLID principles improved
- [ ] No behavior changes
</success_criteria>
