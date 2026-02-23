# Team Patterns Reference

> Detailed templates for Agent Team compositions by task type.

## Pattern 1: Research Team

**When**: Investigation, exploration, competitive analysis, design research

**Structure**: 2-4 investigators + lead as synthesizer

**Template**:
```
Create an agent team to research: {topic}

Spawn {N} teammates:
- Investigator A: "Research {angle 1} for {topic}. Focus on {specific area}.
  Look at {files/docs/sources}. Report findings with evidence and confidence levels.
  Challenge other teammates' conclusions if you disagree."
- Investigator B: "Research {angle 2} for {topic}. Focus on {specific area}.
  Look at {files/docs/sources}. Report findings with evidence and confidence levels.
  Challenge other teammates' conclusions if you disagree."
- Devil's Advocate: "Challenge all findings from other teammates. Look for
  counter-evidence, edge cases, and overlooked risks. Your job is to stress-test
  every conclusion."

Team rules:
- Teammates should share findings and challenge each other
- Use /x-research for deep investigation
- Final synthesis should present consensus and dissenting views
```

**Model recommendation**: Sonnet for investigators (complex reasoning needed), Haiku for a pure search/grep investigator

---

## Pattern 2: Feature Team

**When**: Building new functionality that spans multiple layers or modules

**Structure**: 2-3 specialists, each owning a layer

**Template**:
```
Create an agent team to implement: {feature description}

Spawn {N} teammates:
- Backend: "Implement the backend for {feature}. Own files in {src/api/, src/services/}.
  Follow existing patterns in the codebase. Use /x-implement with TDD.
  Do NOT modify files outside your scope."
- Frontend: "Implement the frontend for {feature}. Own files in {src/components/, src/pages/}.
  Follow existing UI patterns. Use /x-implement with TDD.
  Do NOT modify files outside your scope."
- Tests: "Write integration and E2E tests for {feature}. Own files in {tests/}.
  Wait for backend and frontend teammates to finish their unit tests first.
  Use /x-review to validate all quality gates pass."

Team rules:
- Each teammate owns specific directories (no overlap)
- Backend and Frontend can work in parallel
- Tests teammate waits for others to complete
- All teammates follow CLAUDE.md conventions
- Require plan approval before making changes
```

**Model recommendation**: Sonnet for backend/frontend, Haiku for tests

**Alternative**: If teammates need to modify overlapping files (e.g., shared types, config), use Worktree Mode instead of file ownership.

---

## Pattern 3: Review Team

**When**: Code review, PR review, security audit, compliance check

**Structure**: 2-3 reviewers with different lenses

**Template**:
```
Create an agent team to review: {target (PR, module, codebase)}

Spawn {N} teammates:
- Security Reviewer: "Review {target} for security vulnerabilities. Focus on
  OWASP Top 10, input validation, authentication, and authorization.
  Use /x-analyze with security focus. Rate findings by severity."
- Performance Reviewer: "Review {target} for performance issues. Focus on
  N+1 queries, unnecessary re-renders, memory leaks, and algorithmic complexity.
  Use /x-analyze with performance focus. Rate findings by impact."
- Quality Reviewer: "Review {target} for code quality. Focus on SOLID principles,
  test coverage gaps, error handling, and maintainability.
  Use /x-analyze with quality focus. Rate findings by severity."

Team rules:
- Reviewers work independently (no file conflicts, read-only analysis)
- Each reviewer produces a structured report
- Synthesize all findings into a prioritized action list
```

**Model recommendation**: Sonnet for security/performance reviewers, Haiku for quality reviewer (checklist-based)

---

## Pattern 4: Debug Team

**When**: Complex bugs with unclear root cause, competing hypotheses

**Structure**: 3-5 investigators, each testing a different theory

**Template**:
```
Create an agent team to debug: {bug description}

Spawn {N} teammates:
- Hypothesis A: "Investigate whether {bug} is caused by {theory A}.
  Look at {relevant files/logs}. Gather evidence for and against this theory.
  Use /x-troubleshoot methodology. Share findings with other teammates."
- Hypothesis B: "Investigate whether {bug} is caused by {theory B}.
  Look at {relevant files/logs}. Gather evidence for and against this theory.
  Use /x-troubleshoot methodology. Share findings with other teammates."
- Hypothesis C: "Investigate whether {bug} is caused by {theory C}.
  Look at {relevant files/logs}. Gather evidence for and against this theory.
  Use /x-troubleshoot methodology. Share findings with other teammates."

Team rules:
- Teammates should actively challenge each other's theories
- Share evidence that disproves other hypotheses
- Converge on the root cause through adversarial debate
- Once root cause is found, the winning investigator proposes a fix
```

**Model recommendation**: Sonnet for hypothesis testers (complex reasoning), Haiku if a teammate only does log/trace search

---

## Pattern 5: Refactor Team

**When**: Large refactoring across multiple modules

**Structure**: 2-3 workers, each owning a module boundary

**Template**:
```
Create an agent team to refactor: {refactoring goal}

Spawn {N} teammates:
- Module A Owner: "Refactor {module A} to {goal}. Own files in {path/to/module-a/}.
  Use /x-refactor. Ensure all existing tests pass. Do NOT modify files outside your scope.
  Coordinate interface changes with other teammates."
- Module B Owner: "Refactor {module B} to {goal}. Own files in {path/to/module-b/}.
  Use /x-refactor. Ensure all existing tests pass. Do NOT modify files outside your scope.
  Coordinate interface changes with other teammates."

Team rules:
- Require plan approval before any changes
- Each teammate owns non-overlapping file sets
- Interface changes must be communicated via messages
- All teammates must keep existing tests passing
- Run /x-review after completion
```

**Model recommendation**: Sonnet for all (safe refactoring needs care)

**Alternative**: For cross-cutting refactors where module boundaries overlap, use Worktree Mode for safer parallel execution.

---

## Worktree Mode

Worktree isolation is an alternative to file ownership for team patterns. Instead of requiring each teammate to own specific directories, worktrees give each teammate an isolated copy of the entire repository.

### When to Use Worktree Mode

| Scenario | Worktree | File Ownership |
|----------|----------|----------------|
| Overlapping file modifications | **Worktree** | Cannot do safely |
| Cross-cutting refactoring | **Worktree** | Risky with shared files |
| Database migration + API changes | **Worktree** | Risky coordination |
| Independent module work | Either | **Preferred** (simpler) |
| Read-only analysis (Review, Debug) | Not needed | N/A |

### Worktree Team Template

```
Create an agent team to implement: {feature with overlapping concerns}

Spawn {N} teammates with worktree isolation:
- Backend: "Implement backend for {feature}. You have an isolated worktree —
  feel free to modify any file. Use /x-implement with TDD.
  Focus on {backend scope} but update shared types if needed."
  [spawn with isolation: "worktree"]
- Frontend: "Implement frontend for {feature}. You have an isolated worktree —
  feel free to modify any file. Use /x-implement with TDD.
  Focus on {frontend scope} but update shared types if needed."
  [spawn with isolation: "worktree"]

Team rules:
- Each teammate works in an isolated worktree (no file conflicts possible)
- Teammates can modify any file including shared types, configs, etc.
- After completion, branches are merged back sequentially
- Conflicts resolved via git merge tooling
- All teammates follow CLAUDE.md conventions
```

### Merge-Back After Worktree Mode

After all worktree teammates complete:
1. Merge each worktree branch back to source (one at a time)
2. Resolve conflicts at each merge step
3. Run full test suite after all merges
4. Prune all worktrees

---

## Sizing Guide

| Task Scope | Recommended Size | Reasoning |
|------------|-----------------|-----------|
| 2 independent angles | 2 teammates | Minimal overhead |
| 3 layers (FE/BE/Test) | 3 teammates | Natural layer split |
| Broad investigation | 3-4 teammates | Diminishing returns past 4 |
| Very complex debug | 4-5 teammates | More hypotheses = faster convergence |
| > 5 teammates | Avoid | Coordination overhead dominates |

## Model Selection

**Never use Opus for teammates** — reserve Opus for the lead session only.

| Role Type | Model | Why |
|-----------|-------|-----|
| Complex reasoning, architecture | Sonnet | Nuanced analysis, trade-off evaluation |
| Multi-file implementation | Sonnet | Code quality, cross-file coherence |
| Security/performance audit | Sonnet | Domain expertise, subtle patterns |
| Refactoring, debugging | Sonnet | Safe restructuring, hypothesis testing |
| Test writing, test running | **Haiku** | Focused, clear inputs/outputs, fast |
| Doc generation, changelog | **Haiku** | Template-driven, lower reasoning |
| Exploration, search, grep | **Haiku** | Read-only, fast, cheapest option |
| Simple single-file changes | **Haiku** | Clear requirements, boilerplate work |

**Cost multiplier guide**: A 3-teammate Sonnet team costs ~3-4x a single session. Swapping 1 teammate to Haiku saves ~25-30% of that team's cost.

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| Same-file editing | Teammates overwrite each other | Assign file ownership |
| Too many teammates | Coordination exceeds benefit | Cap at 5 |
| No spawn context | Teammates lack project knowledge | Include full context in spawn prompt |
| Sequential dependencies | Teammates block on each other | Use subagents instead |
| Unmonitored teams | Wasted effort, divergent work | Check in regularly |
| Missing cleanup | Orphaned tmux sessions | Always clean up the team |
