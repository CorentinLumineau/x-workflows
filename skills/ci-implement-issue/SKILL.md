---
name: ci-implement-issue
description: Implement approved plan using TDD methodology in CI context.
license: Apache-2.0
compatibility: CI-only — called programmatically by workclaude Python scripts.
allowed-tools: Read Write Edit Grep Glob Bash
user-invocable: false
metadata:
  author: workclaude
  version: "1.0.0"
  category: ci
chains-to:
  - skill: ci-review-issue
    condition: "implementation complete"
chains-from:
  - skill: ci-analyze-issue
---

# ci-implement-issue

> Implement an approved plan using TDD methodology, committing changes with conventional commit messages.

## Purpose

Called programmatically by workclaude `issue_handler.py` during the **IMPLEMENT phase**. Receives the approved plan and issue context. Writes code directly to the filesystem and commits changes. Produces a free-text implementation log.

This skill has **full filesystem access** -- it creates, modifies, and deletes files as needed to implement the plan.

## Input Context

The following context is injected into the prompt by the Python caller:

| Input | Source | Description |
|-------|--------|-------------|
| Issue title | Gitea API | Issue title text |
| Issue body | Gitea API | Full issue description (markdown) |
| Issue number | Gitea API | Reference number for commit messages |
| Approved plan | Branch session files | The plan from ci-analyze-issue (approved by human) |
| Conversation history | Gitea API | All comments including approval and feedback |
| Session files | Git branch | `analysis.md`, `decisions.md` from analysis phase |
| Implementation feedback | Comment | Human feedback if re-implementing |

## Behavioral References

This skill activates the following behavioral patterns:

- `@skills/quality-testing/` -- TDD methodology, testing pyramid (70% unit, 20% integration, 10% E2E)
- `@skills/code-code-quality/` -- SOLID, DRY, KISS principles
- `@skills/vcs-conventional-commits/` -- Commit message format

<instructions>

## Phase 1: Preparation

1. Read the approved plan from session files
2. Read `analysis.md` and `decisions.md` for codebase context
3. If this is a re-implementation (feedback provided), review feedback and adjust approach
4. Identify the project's existing patterns: coding style, test framework, directory structure
5. Verify the working branch is correct and clean

## Phase 2: Step-by-Step Implementation (TDD)

For each step in the approved plan, follow the RED-GREEN-REFACTOR cycle:

### RED: Write Tests First

1. Write failing tests that define the expected behavior for this step
2. Tests should cover:
   - Happy path (expected behavior)
   - Edge cases (boundary conditions)
   - Error cases (invalid inputs, failure modes)
3. Follow the project's existing test conventions and framework
4. Verify tests fail before proceeding (if test runner is available)

### GREEN: Implement

1. Write the minimum code to make tests pass
2. Follow existing project conventions and patterns
3. Respect SOLID principles (`@skills/code-code-quality/`):
   - Single Responsibility: each function/class does one thing
   - Open/Closed: extend behavior without modifying existing code
   - Liskov Substitution: subtypes are substitutable
   - Interface Segregation: no forced dependencies on unused interfaces
   - Dependency Inversion: depend on abstractions
4. If the plan is ambiguous for this step, make a reasonable decision and document it

### REFACTOR: Clean Up

1. Remove duplication (DRY)
2. Simplify where possible (KISS)
3. Ensure naming is clear and consistent
4. Do NOT over-engineer -- only refactor what was just written

### Commit

After each step (or logical group of changes):
1. Stage changed files with `git add` (specific files, not `-A`)
2. Commit with a conventional commit message:
   - `feat(scope): description` for new features
   - `fix(scope): description` for bug fixes
   - `test(scope): description` for test-only changes
   - `refactor(scope): description` for refactoring
   - `docs(scope): description` for documentation
3. Reference the issue number: `feat(auth): add JWT validation (#42)`

## Phase 3: Verification

1. Run the project's test suite if a test runner is available and identifiable
2. Run linting if a linter is configured
3. Verify all new files are committed
4. Review the git log to confirm clean commit history

## Phase 4: Session Files

Update session files on the branch:

| File | Content |
|------|---------|
| `session.md` | Implementation log: what was done, files changed, tests added |
| `decisions.md` | Updated with any decisions made during implementation |

Commit session files: `docs(session): update implementation log (#N)`

## Output Format

Output is **free text** -- an implementation log describing what was done. NOT structured JSON.

The log should include:
- Summary of changes made
- List of files created or modified
- Tests added and their coverage areas
- Any decisions made where the plan was ambiguous
- Any issues encountered and how they were resolved

## Constraints

- **DO NOT push**: The Python orchestrator handles `git push` after implementation completes.
- **DO NOT create PRs**: The Python orchestrator handles PR creation.
- **DO NOT modify CI/CD configuration**: Changes to workflows or CI config are out of scope.
- **Commit granularity**: Prefer small, focused commits over one large commit.
- **Conventional commits**: ALL commit messages MUST follow the conventional commit format.
- **Issue reference**: ALL commit messages MUST reference the issue number.
- **No force operations**: Do NOT use `git push --force`, `git reset --hard`, or similar destructive commands.

</instructions>

## References

- @skills/quality-testing/ -- TDD methodology and testing pyramid
- @skills/code-code-quality/ -- SOLID, DRY, KISS principles
- @skills/vcs-conventional-commits/ -- Commit message format specification
