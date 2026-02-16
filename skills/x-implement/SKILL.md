---
name: x-implement
description: Use when you have a plan and need to write code following TDD methodology.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
user-invocable: true
metadata:
  author: ccsetup contributors
  version: "3.0.0"
  category: workflow
---

# /x-implement

> Write code with TDD methodology and quality gates.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | APEX |
| **Phase** | execute (E) |
| **Position** | 3 of 6 in workflow |

**Flow**: `x-plan` → **`x-implement`** → `x-verify`

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
| `authentication` | Auth flows, login, JWT, OAuth |
| `owasp` | Security-sensitive code |
| `database` | Schema changes, migrations |
| `api-design` | API endpoints, contracts |

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

### Phase 0b: Workflow State Check

1. Read `.claude/workflow-state.json` (if exists)
2. If active workflow exists:
   - Expected next phase is `implement`? → Proceed
   - Skipping `plan`? → Warn: "Skipping plan phase. Continue? [Y/n]"
   - Active workflow at different phase? → Confirm: "Active workflow at {phase}. Start new? [Y/n]"
3. If no active workflow → Create new APEX workflow state at `implement` phase

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

**This phase CANNOT be skipped.** Output compliance report:

```
| Practice       | Status | Violations   | Action           |
|----------------|--------|--------------|------------------|
| TDD            | ✅/❌  | V-TEST-01/02 | Pass / Fix needed |
| Testing        | ✅/❌  | V-TEST-XX    | Pass / Fix needed |
| SOLID          | ✅/⚠️  | V-SOLID-XX   | Pass / Flagged    |
| DRY/KISS/YAGNI | ✅/⚠️  | V-DRY/KISS/YAGNI | Pass / Flagged |
| Patterns       | ✅/⚠️  | V-PAT-XX     | Pass / Flagged    |
| Pareto         | ✅/⚠️  | V-PARETO-XX  | Pass / Flagged    |
| Documentation  | ✅/❌  | V-DOC-XX     | Pass / Fix needed |
```

**ANY ❌ = cannot proceed to Phase 5.**

### Phase 5: Documentation Sync — MANDATORY

**This phase CANNOT be skipped.**

1. Did public API signatures change? → Update API docs (V-DOC-01 BLOCK if skipped)
2. Were new public functions/classes created? → Add docs (V-DOC-02 BLOCK if skipped)
3. Did behavior change? → Update relevant docs (V-DOC-04 BLOCK if skipped)
4. Are internal doc references valid? → Verify (V-DOC-03)

**Phase 5 Exit Gate:**
- [ ] All public API docs match current signatures
- [ ] New public APIs documented
- [ ] Behavioral changes reflected in docs

**BLOCK if any exit gate fails.**

### Phase 6: Initiative Documentation Update (Conditional)

**Skip this phase if no active initiative exists.**

Detect active initiative:
1. Check `.claude/initiative.json` for `currentMilestone`
2. If not found, check `documentation/milestones/_active/` for initiative directories
3. If no initiative detected, proceed to workflow chaining

When an active initiative is detected, update documentation following the mandatory 5-step protocol:

| Step | File | Update |
|------|------|--------|
| 1 | `_active/{initiative}/milestone-N.md` | Add progress update with completed tasks and metrics |
| 2 | `_active/{initiative}/README.md` | Update progress table (status, percentage, dates) |
| 3 | `documentation/milestones/README.md` | Update hub progress summary (if file exists) |
| 4 | `documentation/milestones/MASTER-PLAN.md` | Update orchestration status (if file exists) |
| 5 | `CLAUDE.md` | Update only for major milestone completions |

Update `.claude/initiative.json` checkpoint with latest progress.

**Reference**: See `@skills/x-initiative/playbooks/README.md` for the full documentation update workflow.

### Phase 7: Update Workflow State

After completing implementation:

1. Read `.claude/workflow-state.json`
2. Mark `implement` phase as `"completed"` with timestamp
3. Set `verify` phase as `"in_progress"`
4. Write updated state to `.claude/workflow-state.json`
5. Write to Memory MCP entity `"workflow-state"`:
   - `"phase: implement -> completed"`
   - `"next: verify"`

<state-checkpoint phase="implement" status="completed">
  <file path=".claude/workflow-state.json">Mark implement complete, set verify in_progress</file>
  <memory entity="workflow-state">phase: implement -> completed; next: verify</memory>
</state-checkpoint>

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | Architecture changes, breaking API |
| **High** | ASK IF ABLE | Multiple implementation approaches |
| **Medium** | ASK IF UNCERTAIN | Test strategy |
| **Low** | PROCEED | Standard implementation |

<human-approval-framework>

When approval needed, structure question as:
1. **Context**: What's being implemented
2. **Options**: Different implementation approaches
3. **Recommendation**: Best approach with rationale
4. **Escape**: "Pause implementation" option

</human-approval-framework>

## Agent Delegation

**Recommended Agent**: **test runner** (for test execution)

| Delegate When | Keep Inline When |
|---------------|------------------|
| Large test suite | Simple unit tests |
| Coverage analysis | Quick verification |

## Workflow Chaining

**Next Verb**: `/x-verify`

| Trigger | Chain To | Auto? |
|---------|----------|-------|
| Code written | `/x-verify` | Yes |
| Needs restructure | `/x-refactor` | No (ask) |
| Tests failing | (stay in x-implement) | Yes (fix inline) |

<chaining-instruction>

**Auto-chain**: implement → verify (no approval needed)

After implementation complete:
1. Update `.claude/workflow-state.json` (mark implement complete, set verify in_progress)
2. Auto-invoke next skill via Skill tool:
   - skill: "x-verify"
   - args: "verify implementation changes"

<workflow-chain on="auto" skill="x-verify" args="verify implementation changes" />

If restructuring needed (manual):
"Code is working but needs restructuring. Use /x-refactor?"
- Option 1: `/x-refactor` - Restructure first
- Option 2: `/x-verify` - Verify as-is
- Option 3: Continue implementing

</chaining-instruction>

## TDD Workflow

> **Canonical source**: `@quality-testing` skill
> Follow Red-Green-Refactor cycle.

```
Write Test (RED)
     ↓
Test Fails (expected)
     ↓
Write Code (GREEN)
     ↓
Test Passes
     ↓
Refactor (if needed)
     ↓
All Tests Still Pass
     ↓
Next Feature
```

## Quality Gates

All implementations must pass:
- **Lint** - Code style compliance
- **Types** - Type safety
- **Tests** - All tests passing
- **Build** - Successful build

## Documentation Sync

After x-implement completes, documentation is automatically checked:

```
x-implement completes
        ↓
code documentation sync (auto)
        ↓
x-docs sync (if drift detected)
        ↓
initiative documentation updated (if active initiative)
```

Initiative documentation updates are handled in Phase 6 (inside instructions) when an active initiative is detected via `.claude/initiative.json` or `documentation/milestones/_active/`.

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
| Next | `/x-verify` | Implementation complete |
| Branch | `/x-refactor` | Need to restructure |

## Related Verbs

For specific needs:
- `/x-fix` - Quick bug fixes (ONESHOT workflow)
- `/x-refactor` - Code restructuring (sub-flow)

## Success Criteria

- [ ] Tests written first (TDD) — V-TEST-02
- [ ] All quality gates pass
- [ ] No regressions introduced
- [ ] Code follows SOLID principles — V-SOLID-*
- [ ] Documentation synced (MANDATORY) — V-DOC-*
- [ ] Enforcement summary produced
- [ ] Initiative documentation updated (if active initiative)

## When to Load References

- **For implementation details**: See `references/mode-implement.md`
- **For enhancement patterns**: See `references/mode-enhance.md`
- **For migration guidance**: See `references/mode-migrate.md`

## References

- @skills/code-code-quality/ - SOLID, DRY, KISS principles
- @skills/quality-testing/ - Testing pyramid and TDD
