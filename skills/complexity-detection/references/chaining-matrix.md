# Chaining Matrix Awareness

Chain resolution logic for workflow skill sequencing.

## Purpose

Resolve valid next-step workflows by reading chain metadata from skill frontmatter. This implements the **chain resolver** -- the data itself will be populated in M5 when all workflow skills have `chains-to` and `chains-from` fields.

## Chain Resolution Algorithm

```
1. Read current skill's frontmatter (SKILL.md)
2. Extract chains-to and chains-from arrays
3. Combine with named path templates from WORKFLOW_CHAINS.md
4. Recommend valid next steps based on:
   - Current phase completion
   - Workflow intent (APEX/DEBUG/BRAINSTORM)
   - Complexity tier
   - Chain compatibility
```

## Chain Metadata Schema

```yaml
---
name: x-implement
chains-to:
  - x-review
  - x-test
  - git-create-pr
chains-from:
  - x-plan
  - x-analyze
  - git-implement-issue
---
```

## Named Path Templates

Reference `WORKFLOW_CHAINS.md` for pre-defined workflow sequences:

| Path Name | Chain | Use Case |
|-----------|-------|----------|
| apex-full | x-analyze -> x-plan -> x-implement -> x-review | Complete feature workflow |
| debug-flow | x-troubleshoot -> x-fix -> x-review | Error resolution workflow |
| quick-fix | x-implement -> x-review | Fast iteration for simple changes |
| research-to-build | x-research -> x-plan -> x-implement | Exploration -> implementation |
| git-pr-flow | x-implement -> git-create-pr -> git-merge-pr | PR creation workflow |
| git-issue-flow | git-implement-issue -> x-review -> git-create-pr | Issue implementation workflow |

## Next Step Resolution

```
Given: User completed x-implement
Current skill: x-implement
chains-to: [x-review, x-test, git-create-pr]

Recommendations:
1. Primary: x-review (validate implementation)
2. Alternative: x-test (run test suite)
3. Finalize: git-create-pr (create PR for review)

Output:
+---------------------------------------------+
| Next Steps                                  |
|                                             |
| 1. x-review (recommended)                  |
|    -> Validate implementation correctness   |
|                                             |
| 2. x-test (optional)                       |
|    -> Run comprehensive test suite          |
|                                             |
| 3. git-create-pr (finalize)                |
|    -> Create PR for code review             |
+---------------------------------------------+
```

## Chain Validation

```
Before suggesting next step:
1. Check if target skill exists in skills/ directory
2. Verify target skill has current skill in chains-from
3. Validate bidirectional compatibility
4. If chain is invalid -> log warning, skip suggestion

Example validation:
  x-implement chains-to: x-review (check)
  x-review chains-from: x-implement (check)
  Bidirectional: VALID
```

## Integration with Complexity Detection

```
Combine chain resolution with complexity tier:

Example: APEX + MEDIUM complexity
1. Detect mental model: APEX
2. Assess complexity: MEDIUM
3. Resolve initial chain: x-plan -> x-implement
4. After x-implement completes:
   - Read x-implement chains-to
   - Recommend: x-review (from chains-to)
   - User can override with explicit command

Example: GIT intent + "pr"
1. Detect mental model: GIT
2. Resolve direct route: git-create-pr
3. After git-create-pr completes:
   - Read git-create-pr chains-to
   - Recommend: git-review-pr or git-merge-pr
```

## Fallback Behavior

```
If chain metadata is missing or incomplete:
1. Fall back to complexity-based routing
2. Use mental model defaults (APEX -> plan -> implement -> review)
3. Log: "Chain metadata unavailable, using default routing"
4. Continue workflow with degraded guidance

This ensures the resolver works NOW (M4) while chain data is populated in M5.
```

## Status

**Implementation**: This section implements the chain resolver logic.

**Data population**: M5 will populate `chains-to` and `chains-from` in all workflow skill frontmatter.

**Current behavior**: Resolver falls back to complexity-based routing until M5 completes chain metadata population.
