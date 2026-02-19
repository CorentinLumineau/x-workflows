---
name: ci-review-issue
description: Self-review implementation and fix issues in CI context.
license: Apache-2.0
compatibility: CI-only — called programmatically by workclaude Python scripts.
allowed-tools: Read Write Edit Grep Glob Bash
user-invocable: false
metadata:
  author: workclaude
  version: "1.0.0"
  category: ci
chains-to: []
chains-from:
  - skill: ci-implement-issue
---

# ci-review-issue

> Self-review the implementation against quality gates, fix issues found, and produce a structured verdict.

## Purpose

Called programmatically by workclaude `issue_handler.py` during the **REVIEW phase**. Receives the git diff of all changes and plan context. Reviews code quality, fixes issues it finds, and produces a structured JSON verdict.

This skill has **full filesystem access** -- it can fix issues it discovers during review.

## Input Context

The following context is injected into the prompt by the Python caller:

| Input | Source | Description |
|-------|--------|-------------|
| Changed files | `git diff` | Full diff of all changes on the branch |
| Plan context | Branch session files | The approved plan and implementation log |
| Issue title/body | Gitea API | Original requirements for validation |
| Review feedback | Comment | Human feedback if re-reviewing |

## Behavioral References

This skill activates the following behavioral patterns:

- `@skills/quality-testing/` -- Quality gates and testing standards
- `@skills/security-secure-coding/` -- OWASP Top 10 security checks
- `@skills/code-code-quality/` -- SOLID principle validation

<instructions>

## Phase 1: Change Inventory

1. Parse the provided git diff to build a list of all changed files
2. Categorize changes: new files, modified files, deleted files
3. Identify the type of each change: source code, tests, configuration, documentation
4. Read each changed file in full to understand context beyond the diff

## Phase 2: Quality Gate Review

Review all changes against these quality gates:

### 2a: Test Coverage

- Are new functions/methods covered by tests?
- Do tests cover happy path, edge cases, and error cases?
- Is the test-to-code ratio reasonable (not testing implementation details)?
- Are tests isolated and deterministic?
- Severity: **critical** if no tests for new logic, **warning** if edge cases missing

### 2b: SOLID Principles

Using `@skills/code-code-quality/`:

| Principle | Check |
|-----------|-------|
| Single Responsibility | Does each function/class have one reason to change? |
| Open/Closed | Can behavior be extended without modifying existing code? |
| Liskov Substitution | Are subtypes properly substitutable? |
| Interface Segregation | Are interfaces minimal and focused? |
| Dependency Inversion | Do modules depend on abstractions, not concretions? |

- Severity: **warning** for violations, **critical** if violation causes fragility

### 2c: Security (OWASP Top 10)

Using `@skills/security-secure-coding/`:

| Check | What to look for |
|-------|-----------------|
| Injection | Unsanitized input in SQL, commands, templates |
| Broken Auth | Hardcoded credentials, weak token handling |
| Sensitive Data | Secrets in code, unencrypted sensitive data |
| XXE | Unsafe XML parsing |
| Broken Access Control | Missing authorization checks |
| Misconfiguration | Debug mode, default credentials, verbose errors |
| XSS | Unsanitized output in HTML/JS contexts |
| Deserialization | Unsafe deserialization of untrusted data |
| Vulnerable Components | Known-vulnerable dependency versions |
| Logging Gaps | Missing audit trail for sensitive operations |

- Severity: **critical** for any security finding

### 2d: Error Handling

- Are errors handled, not silently swallowed?
- Are error messages informative without leaking internals?
- Are resources properly cleaned up (files closed, connections released)?
- Severity: **warning** for missing error handling, **critical** if it causes data loss

### 2e: Code Quality

- Naming: Are variables, functions, and classes clearly named?
- Complexity: Are functions reasonably sized (< 50 lines)?
- Duplication: Is there unnecessary code repetition?
- Conventions: Do changes follow the project's existing style?
- Severity: **info** for style issues, **warning** for complexity

## Phase 3: Fix Issues

For each finding that can be fixed:

1. Apply the fix directly to the file
2. Mark the finding as `fixed: true` in the output
3. Stage and commit the fix with a conventional commit message:
   - `fix(scope): description` for bug fixes
   - `refactor(scope): description` for quality improvements
   - `test(scope): description` for test additions
4. Reference the issue number in the commit message

**Iteration limit**: Maximum 3 review-fix iterations to prevent infinite loops. After 3 iterations, report remaining unfixed findings and stop.

## Phase 4: Verdict

Determine the overall status:

| Status | Condition |
|--------|-----------|
| **pass** | No findings, or all findings are info-level |
| **pass_with_warnings** | Warnings exist but no critical findings remain unfixed |
| **needs_fixes** | Critical findings remain that could not be auto-fixed |

## Output Format

Output MUST be valid JSON matching this exact schema. The Python caller enforces this via `output_format`.

```json
{
  "status": "pass | pass_with_warnings | needs_fixes",
  "findings": [
    {
      "severity": "critical | warning | info",
      "category": "testing | security | solid | error-handling | code-quality",
      "description": "What was found and why it matters",
      "file": "path/to/file.py",
      "line": 42,
      "fixed": true
    }
  ],
  "summary": "Human-readable summary of the review outcome"
}
```

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `status` | string | `pass` (clean), `pass_with_warnings` (non-critical issues), or `needs_fixes` (critical unfixed) |
| `findings` | array | All issues found during review |
| `findings[].severity` | string | `critical` (must fix), `warning` (should fix), `info` (nice to fix) |
| `findings[].category` | string | Which quality gate triggered the finding |
| `findings[].description` | string | Clear description of the issue |
| `findings[].file` | string | File path relative to repo root |
| `findings[].line` | number | Line number where the issue was found (0 if not applicable) |
| `findings[].fixed` | boolean | Whether the issue was auto-fixed in this review |
| `summary` | string | One-paragraph summary for the status comment |

## Constraints

- **DO NOT push**: The Python orchestrator handles `git push` after review completes.
- **Max 3 iterations**: Stop after 3 review-fix cycles to prevent infinite loops.
- **Conventional commits**: ALL fix commits MUST follow the conventional commit format.
- **Issue reference**: ALL fix commits MUST reference the issue number.
- **No scope creep**: Only fix issues in changed files. Do NOT refactor unrelated code.
- **No force operations**: Do NOT use `git push --force`, `git reset --hard`, or similar destructive commands.

</instructions>

## References

- @skills/quality-testing/ -- Quality gates and testing standards
- @skills/security-secure-coding/ -- OWASP Top 10 security checklist
- @skills/code-code-quality/ -- SOLID principle definitions and validation
