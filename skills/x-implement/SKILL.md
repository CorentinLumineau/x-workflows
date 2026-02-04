---
name: x-implement
description: |
  Context-aware implementation with TDD and quality gates.
  APEX workflow, execute phase. Triggers: implement, build, create, code, feature.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
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

## Agents

| Agent | When | Model |
|-------|------|-------|
| `ccsetup:x-explorer` | Pattern discovery | haiku |
| `ccsetup:x-tester` | Test execution | haiku |

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

### Phase 1: Context Discovery

Discover existing patterns:

```
Task(
  subagent_type: "ccsetup:x-explorer",
  model: "haiku",
  prompt: "Find patterns for {feature type} in codebase"
)
```

Identify:
- Similar implementations
- Project conventions
- Test patterns
- Import structures

### Phase 2: TDD Implementation

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

### Phase 4: Quality Gates

Run all gates:
```bash
pnpm lint        # Code style
pnpm type-check  # Type safety
pnpm test        # All tests
pnpm build       # Build succeeds
```

**All gates must pass before proceeding.**

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

**Recommended Agent**: `ccsetup:x-tester` (for test execution)

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

When implementation complete:
- skill: "x-verify"
- args: "verify implementation changes"

If restructuring needed:
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
documentation skill activates (auto)
        ↓
x-docs sync (if drift detected)
```

## Critical Rules

1. **TDD Required** - Write tests first
2. **Quality Gates** - All must pass
3. **SOLID Principles** - Apply consistently
4. **Pattern Matching** - Follow existing conventions
5. **No Regressions** - All existing tests must pass

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

- [ ] Tests written first (TDD)
- [ ] All quality gates pass
- [ ] No regressions introduced
- [ ] Code follows SOLID principles
- [ ] Documentation updated if needed

## When to Load References

- **For implementation details**: See `references/mode-implement.md`
- **For enhancement patterns**: See `references/mode-enhance.md`
- **For migration guidance**: See `references/mode-migrate.md`

## References

- @skills/code-code-quality/ - SOLID, DRY, KISS principles
- @skills/quality-testing/ - Testing pyramid and TDD
