# Mode: cleanup

> **Invocation**: `/x-implement cleanup` or `/x-implement cleanup "description"`
> **Legacy Command**: `/x:cleanup`

<purpose>
Technical debt cleanup including dead code removal, unused dependencies, and codebase organization. Remove what's not needed, organize what remains.
</purpose>

## Behavioral Skills

This mode activates:
- `code-quality` - Quality enforcement
- `context-awareness` - Pattern awareness

## Agents

| Agent | When | Model |
|-------|------|-------|
| `ccsetup:x-explorer` | Dead code detection | haiku |
| `ccsetup:x-tester` | Verification | haiku |

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Complex decisions |

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 20%, context 30%, technical 25%, scope 15%, risk 10%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Definition of "clean" unclear, deletion criteria undefined, scope boundaries unclear.

---

### Phase 1: Detection

Identify cleanup targets:

#### Dead Code
```bash
# Find unused exports
npx ts-prune

# Find unused dependencies
npx depcheck
```

#### Code Smells
- Commented-out code blocks
- TODO comments older than 30 days
- Deprecated function usage
- Unused imports
- Empty files

### Phase 2: Safe Removal

**Critical**: Remove incrementally with verification.

For each removal:
1. **Identify target** - What to remove
2. **Check dependencies** - Ensure nothing uses it
3. **Remove** - Delete the code
4. **Verify** - Tests pass
5. **Commit** - Atomic removal

### Phase 3: Organization

After removals, organize:
- Move misplaced files to correct directories
- Rename files following conventions
- Update import paths
- Clean up directory structure

### Phase 4: Verification

Full quality gate check:
```bash
pnpm test
pnpm lint
pnpm type-check
pnpm build
```

### Phase 5: Workflow Transition

Present next step:
```json
{
  "questions": [{
    "question": "Cleanup complete. {removed_count} items removed. Continue?",
    "header": "Next",
    "options": [
      {"label": "/x-verify (Recommended)", "description": "Full quality gates"},
      {"label": "/x-git commit", "description": "Commit cleanup"},
      {"label": "Stop", "description": "Review manually"}
    ],
    "multiSelect": false
  }]
}
```
</instructions>

## Cleanup Categories

### Dead Code Removal
- Unused functions
- Unused components
- Unused utilities
- Unused types/interfaces
- Unused CSS classes

### Dependency Cleanup
- Unused npm packages
- Outdated dependencies (with /x-verify)
- Duplicate dependencies

### Code Organization
- Misplaced files
- Inconsistent naming
- Flat directory structure
- Missing index files

### Comment Cleanup
- Remove commented-out code
- Resolve or remove stale TODOs
- Update outdated comments

<critical_rules>
1. **Verify Before Remove** - Check nothing depends on it
2. **Remove Incrementally** - One at a time
3. **Test After Each Removal** - Catch breakage early
4. **Document Significant Removals** - Update CHANGELOG
</critical_rules>

## What NOT to Remove

- Code with `@deprecated` until replacement ready
- Feature flags for unreleased features
- Test utilities (may seem unused)
- Type definitions referenced in other packages

<decision_making>
**Remove autonomously when**:
- No references found
- Clearly dead code
- Tests pass after removal

**Use AskUserQuestion when**:
- Uncertain if used elsewhere
- Large removal scope
- Public API changes
</decision_making>

## References

- @core-docs/principles/dry-kiss-yagni.md - YAGNI principle
- @skills/code-quality/SKILL.md - Quality enforcement

<success_criteria>
- [ ] Dead code identified
- [ ] Safe removals completed
- [ ] Tests passing
- [ ] Build successful
- [ ] Codebase organized
</success_criteria>
