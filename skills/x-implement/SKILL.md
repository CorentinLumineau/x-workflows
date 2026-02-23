---
name: x-implement
description: Use when you have a plan and need to write code following TDD methodology.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
user-invocable: true
argument-hint: "<task description>"
metadata:
  author: ccsetup contributors
  version: "3.0.0"
  category: workflow
chains-to:
  - skill: x-review
    condition: "after implementation"
  - skill: x-refactor
    condition: "restructure needed"
  - skill: git-resolve-conflict
    condition: "conflict during dev"
chains-from:
  - skill: x-plan
  - skill: x-troubleshoot
  - skill: x-review
    condition: "changes requested"
  - skill: git-implement-issue
  - skill: x-create
---

# /x-implement

> Write code with TDD methodology and quality gates.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | APEX |
| **Phase** | execute (E) |
| **Position** | 3 of 5 in workflow |

**Flow**: `x-plan` → **`x-implement`** → `x-review`

## Intention

**Task**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Ask user: "What would you like to implement?"
{{/if}}

## Behavioral Skills

This skill activates:

### Always Active
- `interview` - Zero-doubt confidence gate (Phase 0)
- `code-quality` - SOLID, DRY, KISS enforcement
- `testing` - Testing pyramid (70/20/10)

### Context-Triggered
| Skill | Trigger Conditions |
|-------|-------------------|
| `identity-access` | Auth flows, login, JWT, OAuth |
| `secure-coding` | Security-sensitive code |
| `database` | Schema changes, migrations |
| `api-design` | API endpoints, contracts |
| `worktree-awareness` | Complex task, user requests isolation |

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **codebase explorer** | Pattern discovery | Fast, read-only |
| **test runner** | Test execution | Can edit and run commands |

## MCP Servers

| Server | When |
|--------|------|
| `context7` | Library documentation |
| `sequential-thinking` | Complex implementation decisions |

<instructions>

### Phase 0: Confidence Check

Activate `@skills/interview/` if:
- Requirements unclear
- Multiple implementation approaches
- Technical constraints unknown

### Phase 0b: Workflow State Check (ENFORCED)

1. Read `.claude/workflow-state.json` (if exists)
2. If active workflow exists:
   - Plan phase completed and approved? → Proceed to implementation
   - **Plan phase NOT completed? → BLOCK**: "Cannot proceed to implementation. Required predecessor 'plan' is not completed. Run /x-plan first."
   - No active workflow → Create new workflow state, proceed
3. If no workflow state file exists → Proceed (backward compatibility)

### Phase 0c: Isolation Suggestion (Conditional)

Skip if task complexity is SIMPLE or MODERATE.

When complexity-detection indicates COMPLEX:

<workflow-gate type="choice" id="worktree-suggestion">
  <question>This is a complex task. Work in an isolated worktree? This lets other work continue on the main branch.</question>
  <header>Isolation</header>
  <option key="inline" recommended="true">
    <label>Work inline</label>
    <description>Continue on current branch (default behavior)</description>
  </option>
  <option key="worktree">
    <label>Use worktree</label>
    <description>Create isolated worktree — merge back when done</description>
  </option>
</workflow-gate>

If worktree selected:
- Call `EnterWorktree` tool with a descriptive name based on the task
- Branch becomes PR-ready on completion
- Merge-back step added after Phase 7

Uses: @skills/worktree-awareness/

### Phase 1: Context Discovery

Delegate to a **codebase explorer** agent (fast, read-only):
> "Find patterns for {feature type} in codebase"

<agent-delegate role="codebase explorer" subagent="x-explorer" model="haiku">
  <prompt>Find patterns for {feature type} in codebase — similar implementations, conventions, test patterns, import structures</prompt>
  <context>Context discovery for implementation phase of APEX workflow</context>
</agent-delegate>

Identify:
- Similar implementations
- Project conventions
- Test patterns
- Import structures

### Phase 2: TDD Implementation — MANDATORY

**This phase CANNOT be skipped. TDD is non-negotiable.**

<doc-query trigger="implementation-start">
  <purpose>Look up library APIs and patterns relevant to the implementation task</purpose>
  <context>Starting TDD implementation — need current API docs for libraries being used</context>
</doc-query>

<deep-think purpose="implementation approach" context="Determining TDD strategy, file changes, and integration points">
  <purpose>Determine optimal implementation approach considering SOLID principles, existing patterns, and TDD strategy</purpose>
  <context>Multiple requirements to implement with TDD; need structured reasoning for implementation order and design decisions</context>
</deep-think>

<team name="impl-team" pattern="feature">
  <lead role="implementer" model="sonnet" />
  <teammate role="test runner" subagent="x-tester" model="sonnet" />
  <task-template>
    <task owner="test runner" subject="Run tests after each implementation cycle and report coverage" />
  </task-template>
  <activation>When implementation spans 3+ files across multiple modules and continuous test feedback would accelerate TDD cycles</activation>
</team>

Follow Red-Green-Refactor cycle:

```
1. RED: Write failing test
2. GREEN: Write minimal code to pass
3. REFACTOR: Improve without changing behavior
4. REPEAT: For each requirement
```

**Testing Pyramid:**
- 70% Unit tests
- 20% Integration tests
- 10% E2E tests

**Phase 2 Exit Gate:**
- [ ] Tests exist for all new production code (V-TEST-01)
- [ ] Tests written before production code (V-TEST-02)
- [ ] All tests pass
- [ ] No CRITICAL SOLID violations introduced (V-SOLID-01, V-SOLID-03)

**BLOCK if any exit gate fails.**

#### STOP — TDD Hard Gate

> **You MUST stop here and verify before writing any production code.**

**Checklist** (ALL must be true to proceed):
- [ ] A failing test exists for the new behavior
- [ ] The test was written BEFORE the production code
- [ ] All tests currently pass (run them, read the output — not "should pass")

**Common Rationalizations** (if you're thinking any of these, STOP):

| Excuse | Reality |
|--------|---------|
| "The code is trivial" | Trivial code gets trivial tests. Still mandatory. (V-TEST-02) |
| "I will add tests after" | TDD means tests FIRST. "After" is not TDD. (V-TEST-02) |
| "Running low on context" | Stop coding. Write the test. Resume after. (V-TEST-01) |
| "This is just a refactor" | Refactors need tests to prove behavior unchanged. (V-TEST-01) |

> **Foundational principle**: Violating the letter of this gate IS violating its spirit. There is no "technically compliant" shortcut.

See `@skills/code-code-quality/references/anti-rationalization.md` for the full excuse/reality reference.

### Phase 3: Code Quality

Apply quality principles:

| Principle | Check |
|-----------|-------|
| **S**ingle Responsibility | One reason to change |
| **O**pen/Closed | Extend without modifying |
| **L**iskov Substitution | Subtypes work |
| **I**nterface Segregation | Specific interfaces |
| **D**ependency Inversion | Depend on abstractions |

Also enforce:
- **DRY** - Don't Repeat Yourself
- **KISS** - Keep It Simple
- **YAGNI** - You Ain't Gonna Need It
- **Patterns** - No God Objects (V-PAT-01), No circular dependencies (V-PAT-02)

### Phase 4: Quality Gates

Run all gates:
```bash
pnpm lint        # Code style
pnpm type-check  # Type safety
pnpm test        # All tests
pnpm build       # Build succeeds
```

<agent-delegate role="test runner" subagent="x-tester-fast" model="haiku">
  <prompt>Run full quality gates: lint, type-check, test, build — report pass/fail for each</prompt>
  <context>Post-implementation quality gate verification in APEX workflow</context>
  <escalate to="x-tester" model="sonnet" trigger="persistent test failures (>3), flaky test patterns, or coverage analysis needed" />
</agent-delegate>

**All gates must pass before proceeding.**

### Phase 4b: Enforcement Summary — MANDATORY

**This phase CANNOT be skipped.** Output compliance report. **ANY fail = cannot proceed to Phase 5.**

For enforcement summary table template, see `references/phase-implementation-gates.md#enforcement-summary`.

After generating the enforcement summary, persist results to workflow state:

1. Collect all V-* violations from the quality gate output
2. Write `enforcement` field to `.claude/workflow-state.json` with violations, blocking status, and summary
3. If `blocking: true` (any CRITICAL or HIGH violation), halt and report — do not proceed to Phase 5

### Phase 5: Documentation Sync — MANDATORY

**This phase CANNOT be skipped.** Verify documentation matches code changes. **BLOCK if any exit gate fails.**

For documentation sync checklist and exit gate, see `references/phase-implementation-gates.md#documentation-sync`.

### Phase 6: Initiative Documentation Update (Conditional)

**Skip this phase if no active initiative exists.** Detect initiative via `.claude/initiative.json` or `documentation/milestones/_active/`.

For initiative detection steps and 5-step update protocol, see `references/phase-implementation-gates.md#initiative-documentation`.

### Phase 7: Update Workflow State

After completing implementation:

1. Read `.claude/workflow-state.json`
2. Mark `implement` phase as `"completed"` with timestamp
3. Set `verify` phase as `"in_progress"`
4. Write updated state to `.claude/workflow-state.json`

<state-checkpoint phase="implement" status="completed">
  <file path=".claude/workflow-state.json">Mark implement complete, set verify in_progress</file>
</state-checkpoint>

### Phase 8: Worktree Merge-Back (Conditional)

Skip if not working in a worktree.

When implementation is complete in a worktree:

<workflow-gate type="choice" id="worktree-merge">
  <question>Implementation complete in worktree. Merge back to the source branch?</question>
  <header>Merge</header>
  <option key="merge" recommended="true">
    <label>Merge back</label>
    <description>Merge worktree branch to source and prune</description>
  </option>
  <option key="pr">
    <label>Create PR instead</label>
    <description>Keep worktree branch and create a pull request</description>
  </option>
  <option key="keep">
    <label>Keep worktree</label>
    <description>Leave worktree active for more work</description>
  </option>
</workflow-gate>

If merge selected:
1. Switch to source branch
2. Merge worktree branch
3. Resolve conflicts if needed (delegate to @skills/git-resolve-conflict/)
4. Run tests to verify merge
5. Prune worktree

If PR selected:
- Chain to `/git-create-pr` with worktree branch

Uses: @skills/worktree-awareness/ merge-back protocol.

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | Architecture changes, breaking API |
| **High** | ASK IF ABLE | Multiple implementation approaches |
| **Medium** | ASK IF UNCERTAIN | Test strategy |
| **Low** | PROCEED | Standard implementation |

## Workflow Chaining

**Next Verb**: `/x-review`

| Trigger | Chain To |
|---------|----------|
| Code written | `/x-review` (suggest) |
| Needs restructure | `/x-refactor` (suggest) |
| Tests failing | Stay in x-implement |

<chaining-instruction>

After implementation complete:

<workflow-gate type="choice" id="implement-next">
  <question>Implementation complete. How would you like to proceed?</question>
  <header>Next step</header>
  <option key="review" recommended="true">
    <label>Review changes</label>
    <description>Run quality gates and code review on implementation</description>
  </option>
  <option key="refactor">
    <label>Refactor first</label>
    <description>Restructure code before review</description>
  </option>
  <option key="done">
    <label>Done</label>
    <description>Stop here without review</description>
  </option>
</workflow-gate>

<workflow-chain on="review" skill="x-review" args="review implementation changes" />
<workflow-chain on="refactor" skill="x-refactor" args="{areas needing restructure}" />
<workflow-chain on="done" action="end" />

</chaining-instruction>

## Quick Reference

- **TDD**: Red-Green-Refactor cycle in Phase 2. Canonical source: `@skills/quality-testing/`
- **Quality Gates**: lint, type-check, test, build in Phase 4.
- **Documentation Sync**: Phase 5 checklist + Phase 6 initiative docs. See `references/phase-implementation-gates.md`.

## Critical Rules

1. **TDD is MANDATORY** — NEVER write production code before its test (V-TEST-02)
2. **All gates MUST pass** — NEVER proceed with failing tests
3. **SOLID at all times** — Apply during coding, not after (V-SOLID-*)
4. **Documentation sync is MANDATORY** — NEVER skip Phase 5 (V-DOC-*)
5. **Follow existing conventions** — Match codebase patterns
6. **No regressions** — All existing tests MUST pass
7. **Enforcement summary** — Output compliance table after Phase 4
8. **Initiative Docs** — Update milestone documentation when active initiative exists
9. **Anti-rationalization** — See `@skills/code-code-quality/references/anti-rationalization.md`

## Navigation

| Direction | Verb | When |
|-----------|------|------|
| Previous | `/x-plan` | Need to revise plan |
| Next | `/x-review` | Implementation complete |
| Branch | `/x-refactor` | Need to restructure |

## Success Criteria

- [ ] TDD followed (tests first) — V-TEST-02
- [ ] All quality gates pass, no regressions
- [ ] SOLID principles applied — V-SOLID-*
- [ ] Documentation synced, enforcement summary produced

## When to Load References

- **For implementation details**: See `references/mode-implement.md`
- **For enhancement patterns**: See `references/mode-enhance.md`
- **For fix patterns**: See `references/mode-fix.md`

## References

- @skills/code-code-quality/ - SOLID, DRY, KISS principles
- @skills/quality-testing/ - Testing pyramid and TDD
