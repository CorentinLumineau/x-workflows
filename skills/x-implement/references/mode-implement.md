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
### Phase 0: Context Loading

Load project context following context-awareness skill:

1. **Read project configuration** - `documentation/config.yaml`
2. **Load domain context** - `documentation/domain/` for business rules
3. **Load implementation patterns** - `documentation/implementation/` for architecture
4. **Check initiative context** - `documentation/milestones/_active/` if applicable

### Phase 1: Discovery

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

### Phase 4: Validation

Run quality gates:
- [ ] Type checking - No errors
- [ ] SOLID principles - All validated
- [ ] Test coverage - 95%+
- [ ] Build & lint - Passing
- [ ] Docs synced

### Phase 5: Workflow Transition

Present next step via AskUserQuestion:

```json
{
  "questions": [{
    "question": "Implementation complete ({files_changed} files, {coverage}% coverage). Continue workflow?",
    "header": "Next",
    "options": [
      {"label": "/x-verify (Recommended)", "description": "Run all quality gates"},
      {"label": "/x-review", "description": "Pre-merge code review"},
      {"label": "Stop workflow", "description": "Manual review first"}
    ],
    "multiSelect": false
  }]
}
```
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

- @core-docs/principles/solid.md - SOLID principles
- @core-docs/testing/tdd-green-red-refactor.md - TDD methodology
- @core-docs/testing/testing-pyramid.md - Testing distribution
- @core-docs/patterns/ - Design patterns

<success_criteria>
- [ ] Context detected, patterns discovered
- [ ] All layers implemented bottom-up
- [ ] SOLID validated
- [ ] 95%+ coverage (70/20/10 pyramid)
- [ ] Quality gates passed
- [ ] Workflow transition presented
</success_criteria>
