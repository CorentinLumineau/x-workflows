# Mode: implement

> **Invocation**: `/x-implement` or `/x-implement implement`
> **Legacy Command**: `/x:implement`

<purpose>
Context-aware feature implementation with automatic pattern discovery, TDD methodology, and SOLID validation. Implements features bottom-up following existing codebase patterns.
</purpose>

## Behavioral Skills

This mode activates:
- `context-awareness` - Phase 0 context loading
- `code-quality` - SOLID/DRY/KISS enforcement
- `testing` - Testing pyramid (70/20/10)

## Agents

| Agent | When | Model |
|-------|------|-------|
| `ccsetup:x-explorer` | Pattern discovery, codebase exploration | haiku |
| `ccsetup:x-tester` | Test execution, coverage verification | haiku |
| `ccsetup:x-reviewer` | SOLID validation, quality review | sonnet |

## MCP Servers

| Server | When |
|--------|------|
| `context7` | Library documentation lookup |
| `sequential-thinking` | Complex implementation decisions |
| `memory` | Cross-session persistence |

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
4. **If confidence = 100%** - Proceed to Phase 0b

**Triggers for this mode**: Multiple implementation approaches, missing acceptance criteria, breaking change to public API, TDD scope unclear.

---

### Phase 0b: Context Loading

Load project context following context-awareness skill:

1. **Read project configuration** - `documentation/config.yaml`
2. **Load domain context** - `documentation/domain/` for business rules
3. **Load implementation patterns** - `documentation/implementation/` for architecture
4. **Check initiative context** - `documentation/milestones/_active/` if applicable

### Phase 1: Discovery

<parallel_exploration max_agents="3">

Explore in parallel:

1. **Existing Patterns** - Search codebase for similar implementations in services/, repos/, components/
2. **Test Utilities** - Find existing test utilities in tests/utils/ to reuse
3. **Framework Patterns** - Look up framework best practices via Context7

</parallel_exploration>

Use Task tool with x-explorer agent (haiku):

```
Task(
  subagent_type: "ccsetup:x-explorer",
  model: "haiku",
  prompt: "Discover patterns for {feature_type}"
)
```

Discover:
- Existing patterns in services/, repos/, components/
- Similar implementations to replicate
- Test utilities in tests/utils/
- Framework patterns via Context7

<checkpoint id="discovery_complete" phase="1">

**Discovery Complete**

- Patterns found: {list discovered patterns}
- Similar implementations: {list files to reference}
- Test utilities: {list test utilities to use}

**Proceed to implementation?**

</checkpoint>

---

### Phase 2: Implementation

**Bottom-Up Order**: Database → Repository → Service → API → UI

For each layer:
1. **Find pattern** - Locate similar implementation
2. **Replicate structure** - Copy patterns, adapt to feature
3. **Write tests first** - TDD: red → green → refactor
4. **Implement feature** - Following discovered patterns
5. **Validate SOLID** - All five principles

**Auto-Launch Agents by Scope**:

| Scope | Agent Pattern |
|-------|---------------|
| Initiative (milestones/) | 2 agents per milestone in background |
| Complex (4+ layers) | 1 agent per layer |
| Feature (simple) | Inline, no subagents |

### Phase 3: Testing

Use testing skill and x-tester agent:

```
Task(
  subagent_type: "ccsetup:x-tester",
  model: "haiku",
  prompt: "Verify coverage for {files}"
)
```

Requirements:
- **95%+ coverage** for new/changed code
- **Testing pyramid**: 70% unit, 20% integration, 10% E2E
- **Use shared utilities** from tests/utils/

<checkpoint id="tests_passing" phase="3">

**Tests Complete**

- Coverage: {percentage}%
- Unit tests: {count} ({percentage}%)
- Integration tests: {count} ({percentage}%)
- E2E tests: {count} ({percentage}%)

**Proceed to validation?**

</checkpoint>

---

### Phase 4: Validation

<deep_reasoning topic="quality_validation">

Validate implementation against quality gates:

1. **Type Safety** - Are all types correct? Any `any` types that should be specific?
2. **SOLID Compliance** - Does new code follow all five principles?
3. **Test Coverage** - Is 95%+ coverage achieved?
4. **Build Health** - Does build pass without warnings?
5. **Documentation** - Are docs in sync with implementation?

</deep_reasoning>

Run quality gates:
- [ ] Type checking - No errors
- [ ] SOLID principles - All validated
- [ ] Test coverage - 95%+
- [ ] Build & lint - Passing
- [ ] Docs synced

<checkpoint id="validation_complete" phase="4">

**Validation Complete**

Quality gates:
- Type checking: {pass/fail}
- SOLID: {pass/fail}
- Coverage: {percentage}%
- Build: {pass/fail}
- Docs: {synced/stale}

**Proceed to workflow transition?**

</checkpoint>

---

### Phase 5: Workflow Transition

<user_interaction type="structured_question" required="true" id="next_step">

**Question**: Implementation complete ({files_changed} files, {coverage}% coverage). What's next?

| Option | Description |
|--------|-------------|
| /x-verify (Recommended) | Run all quality gates |
| /x-review | Pre-merge code review |
| Stop workflow | Manual review first |

**Multi-select**: No

</user_interaction>
</instructions>

<critical_rules>
1. **Pattern First** - Never invent; replicate existing codebase patterns
2. **TDD Required** - Write tests before implementation
3. **Bottom-Up** - Database → Repository → Service → API → UI
4. **SOLID Required** - All five principles validated
5. **95%+ Coverage** - For all new/changed code
</critical_rules>

<decision_making>
**Execute autonomously when**:
- Clear requirements
- Existing patterns to follow
- Low breaking change risk

**Use AskUserQuestion when**:
- Multiple implementation approaches
- Code behavior ambiguity (null/empty handling)
- Breaking change risk
- Test scope uncertainty
</decision_making>

## References

- @skills/code-code-quality/ - SOLID principles
- @skills/quality-testing/ - TDD methodology and testing pyramid
- @skills/code-design-patterns/ - Design patterns

<success_criteria>
- [ ] Context detected, patterns discovered
- [ ] All layers implemented bottom-up
- [ ] SOLID validated
- [ ] 95%+ coverage (70/20/10 pyramid)
- [ ] Quality gates passed
- [ ] Workflow transition presented
</success_criteria>
