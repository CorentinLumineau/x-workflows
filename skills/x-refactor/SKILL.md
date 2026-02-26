---
name: x-refactor
description: Use when code needs structural improvement without changing behavior.
version: "1.0.0"
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
user-invocable: true
argument-hint: "[path or component]"
metadata:
  author: ccsetup contributors
  category: workflow
chains-to:
  - skill: x-review
    condition: "refactor complete"
chains-from:
  - skill: x-implement
---

# /x-refactor

> Restructure code safely with zero regression guarantee.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | APEX |
| **Phase** | restructure |
| **Position** | Sub-flow of execute phase |

**Flow**: `x-implement` → (needs restructure) → **`x-refactor`** → `x-review`

## Intention

**Target**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Ask user: "What would you like to refactor?"
{{/if}}

## Behavioral Skills

This skill activates:
- `interview` - Zero-doubt confidence gate (Phase 0)
- `code-quality` - SOLID/DRY/KISS enforcement
- `testing` - Test-driven refactoring
- `complexity-detection` - Scope assessment

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **refactoring agent** | Complex refactoring | Safe restructuring |
| **test runner** | Verification | Can edit and run commands |
| **codebase explorer** | Pattern discovery, scope analysis | Fast, read-only |

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Complex refactoring decisions |

<instructions>

### Phase 0: Confidence Check

Activate `@skills/interview/` if:
- Scope of refactoring undefined
- No performance baseline exists
- Definition of "clean" unclear

### Phase 0b: Scope Detection (CRITICAL)

**Before any refactoring, assess scope.**

Use x-explorer agent to analyze:

<agent-delegate role="codebase explorer" subagent="x-explorer" model="haiku">
  <prompt>Analyze refactoring scope for: {user description} — count files that need changes, identify architectural impact, estimate complexity (small/medium/large)</prompt>
  <context>Scope detection before refactoring — need file count, layers affected, complexity assessment</context>
</agent-delegate>

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
| **Medium** | 4-10 files, 2-3 components, <1 day | Continue with tracking |
| **Large** | 10+ files, architectural changes, >1 day | **Redirect to x-initiative** |

**If LARGE scope detected:**
Ask: "This refactoring affects 10+ files. Create an initiative to track it properly?"
- Option 1: `/x-initiative create` (Recommended)
- Option 2: Continue anyway (not recommended)
- Option 3: Narrow scope

### Phase 1: Pre-Refactor Baseline

**CRITICAL**: Establish baseline BEFORE any changes.

```bash
# Run full test suite
pnpm test

# Capture baseline metrics
pnpm lint
pnpm type-check
```

**All tests MUST pass before proceeding.** If tests fail, fix them first.

### Phase 2: Analysis

<deep-think purpose="refactoring analysis" context="Identifying SOLID violations, code smells, and safe restructuring approach">
  <purpose>Analyze code smells and determine optimal refactoring strategy with minimal risk</purpose>
  <context>Need structured reasoning to identify refactoring opportunities, assess risk, and plan incremental steps</context>
</deep-think>

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

**CRITICAL**: Small steps, verify after each.

<team name="refactor-team" pattern="refactor">
  <lead role="refactoring agent" model="sonnet" />
  <teammate role="test runner" subagent="x-tester" model="sonnet" />
  <teammate role="code reviewer" subagent="x-reviewer-quick" model="haiku" />
  <task-template>
    <task owner="test runner" subject="Run tests after each incremental refactoring step and report pass/fail evidence" />
    <task owner="code reviewer" subject="Verify SOLID compliance after each refactoring change is applied" />
  </task-template>
  <activation>When refactoring scope is Medium (4-10 files, 2-3 components) and continuous test verification during incremental changes would accelerate zero-regression guarantee</activation>
</team>

<agent-delegate role="refactoring agent" subagent="x-refactorer" model="sonnet">
  <prompt>Apply incremental refactoring for {target} — one change at a time, run tests after each step, rollback on failure</prompt>
  <context>Safe restructuring with zero regression guarantee — atomic commits per refactoring step</context>
</agent-delegate>

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

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | Large scope → initiative redirect |
| **High** | ASK IF ABLE | Multiple refactoring approaches |
| **Medium** | ASK IF UNCERTAIN | Breaking API changes |
| **Low** | PROCEED | Standard refactoring |

<human-approval-framework>

When approval needed, structure question as:
1. **Context**: Current code smell / issue
2. **Options**: Different refactoring approaches
3. **Recommendation**: Lowest-risk option
4. **Escape**: "Skip this refactoring" option

</human-approval-framework>

## Agent Delegation

**Recommended Agent**: **refactoring agent** (safe restructuring)

| Delegate When | Keep Inline When |
|---------------|------------------|
| Complex multi-file refactoring | Single file changes |
| Pattern extraction | Simple renames |

## Workflow Chaining

**Next Verb**: `/x-review`

| Trigger | Chain To |
|---------|----------|
| Refactoring complete | `/x-review` (suggest) |
| Tests failing | `/x-implement` (suggest) |
| Large scope | `/x-initiative` (suggest) |

<chaining-instruction>

After refactoring complete:

<workflow-gate type="choice" id="refactor-next">
  <question>Refactoring complete. How would you like to proceed?</question>
  <header>Next step</header>
  <option key="review" recommended="true">
    <label>Review changes</label>
    <description>Run quality gates and code review on refactored code</description>
  </option>
  <option key="done">
    <label>Done</label>
    <description>Refactoring complete, no further action</description>
  </option>
</workflow-gate>

<workflow-chain on="review" skill="x-review" args="review refactoring changes" />
<workflow-chain on="done" action="end" />

</chaining-instruction>

## SOLID Checklist

Apply these principles:
- [ ] **S**ingle Responsibility - One reason to change
- [ ] **O**pen/Closed - Open for extension, closed for modification
- [ ] **L**iskov Substitution - Subtypes substitutable
- [ ] **I**nterface Segregation - Specific interfaces
- [ ] **D**ependency Inversion - Depend on abstractions

## Critical Rules

1. **Zero Regression** - All tests must pass throughout
2. **Small Steps** - One refactoring at a time
3. **Verify Always** - Run tests after each change
4. **Atomic Commits** - Each refactoring is one commit
5. **No Behavior Change** - Preserve existing functionality

## Navigation

| Direction | Verb | When |
|-----------|------|------|
| Previous | `/x-implement` | Return to implementation |
| Next | `/x-review` | Refactoring complete |
| Escalate | `/x-initiative` | Large scope detected |

## Success Criteria

- [ ] Scope assessed (Phase 0b complete)
- [ ] Large scope redirected to initiative OR user confirmed
- [ ] Baseline captured
- [ ] All refactorings applied incrementally
- [ ] Zero test failures
- [ ] SOLID principles improved
- [ ] No behavior changes

## References

- @skills/code-code-quality/ - SOLID, DRY, KISS, YAGNI principles
- @skills/code-code-quality/ - Refactoring patterns
