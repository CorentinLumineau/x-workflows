# Mode: improve

> **Invocation**: `/x-review improve` or `/x-review improve "scope"`
> **Legacy Command**: `/x:improve-best-practices`

<purpose>
Pareto-focused best practices improvement. Identify and fix the 20% of issues that cause 80% of quality problems.
</purpose>

## Behavioral Skills

This mode activates:
- `code-quality` - Quality enforcement
- `analysis` - Pareto prioritization

## Agents

| Agent | When | Model |
|-------|------|-------|
| `ccsetup:x-reviewer` | Issue identification | sonnet |
| `ccsetup:x-refactorer` | Fix application | haiku |

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Prioritization decisions |

<instructions>

## Instructions

### Phase 1: Issue Identification

Run audit to find issues (or use previous audit):

```
Task(
  subagent_type: "ccsetup:x-reviewer",
  model: "sonnet",
  prompt: "Identify best practices violations"
)
```

### Phase 2: Pareto Prioritization

Rank issues by impact/effort:

| Priority | Criteria | Action |
|----------|----------|--------|
| **P1** | High impact, Low effort | Fix first |
| **P2** | High impact, High effort | Plan carefully |
| **P3** | Low impact, Low effort | Quick wins |
| **P4** | Low impact, High effort | Skip |

### Phase 3: Iterative Improvement

For each P1 issue:

1. **Verify baseline** - Tests pass before changes
2. **Apply fix** - One fix at a time
3. **Verify** - Tests still pass
4. **Commit** - Atomic commit per fix

```
While (P1 issues remain AND tests pass):
  1. Pick next P1 issue
  2. Apply fix
  3. Run tests
  4. If tests pass:
     - Commit fix
     - Mark issue resolved
  5. Else:
     - Rollback
     - Re-evaluate issue
```

### Phase 4: Verification

After all P1 fixes:

```bash
pnpm test
pnpm lint
pnpm type-check
```

### Phase 5: Progress Report

```markdown
## Best Practices Improvement Report

### Before
- SOLID Score: {before}%
- Issues: {before_count}

### After
- SOLID Score: {after}%
- Issues: {after_count}

### Fixes Applied
1. {Fix 1}: {description}
2. {Fix 2}: {description}

### Remaining Issues
- P2: {count} issues
- P3: {count} issues
```

### Phase 6: Workflow Transition

```json
{
  "questions": [{
    "question": "Improvement complete. SOLID score: {before}% → {after}%. Continue?",
    "header": "Next",
    "options": [
      {"label": "/x-verify (Recommended)", "description": "Full quality gates"},
      {"label": "/x-git commit", "description": "Commit improvements"},
      {"label": "Continue improving", "description": "Fix more issues"}
    ],
    "multiSelect": false
  }]
}
```

## Improvement Strategies

### SOLID Fixes

| Violation | Fix Strategy |
|-----------|--------------|
| SRP violation | Extract class/function |
| OCP violation | Add abstraction layer |
| LSP violation | Fix inheritance hierarchy |
| ISP violation | Split interface |
| DIP violation | Inject dependencies |

### Quality Fixes

| Issue | Fix Strategy |
|-------|--------------|
| Duplication | Extract shared code |
| Complexity | Simplify, split |
| Dead code | Remove |

</instructions>

<critical_rules>

## Critical Rules

1. **Test First** - Verify tests pass before and after
2. **One at a Time** - Single fix per commit
3. **Pareto Focus** - P1 issues first
4. **Preserve Behavior** - No functional changes

</critical_rules>

<decision_making>

## Decision Making

**Fix autonomously when**:
- Clear violation
- Safe fix pattern
- Tests provide coverage

**Ask first when**:
- Multiple fix approaches
- Breaking change risk
- Large scope change

</decision_making>

## References

- @core-docs/principles/solid.md - SOLID principles
- @core-docs/principles/pareto-80-20.md - Pareto focus

<success_criteria>

## Success Criteria

- [ ] Issues prioritized
- [ ] P1 issues fixed
- [ ] Tests passing
- [ ] Progress reported

</success_criteria>
