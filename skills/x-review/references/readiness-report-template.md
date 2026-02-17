# Readiness Report Template

> Loaded on demand by x-review Phase 6. Template for generating the readiness report.

## Template

```markdown
## Readiness Report

### Mode: {mode}
### Scope: {file_count} files, {lines_added}+ / {lines_removed}-

### Quality Gates (Phase 2)
| Gate | Status | Evidence |
|------|--------|----------|
| Lint | PASS/FAIL | {summary} |
| Types | PASS/FAIL | {summary} |
| Tests | PASS/FAIL | {summary} |
| Build | PASS/FAIL | {summary} |
| Coverage | PASS/WARN/FAIL | {percentage}% |

### Code Review (Phase 3)
| Practice | Status | Violations | Action |
|----------|--------|------------|--------|
| Spec Compliance | PASS/FAIL | — | Pass / Fix needed |
| SOLID | PASS/FAIL | V-SOLID-XX | Pass / Fix needed |
| DRY | PASS/FAIL | V-DRY-XX | Pass / Fix needed |
| Security | PASS/FAIL | OWASP | Pass / Fix needed |
| Testing | PASS/WARN | V-TEST-XX | Pass / Flagged |
| Documentation | PASS/FAIL | V-DOC-XX | Pass / Fix needed |
| Patterns | PASS/WARN | V-PAT-XX | Pass / Flagged |
| Pareto | PASS/WARN | V-PARETO-XX | Pass / Flagged |

### Documentation (Phase 4)
- Code docs: PASS/WARN/FAIL
- Project docs: PASS/WARN/FAIL
- Initiative docs: PASS/WARN/N/A

### Regression (Phase 5)
- Coverage delta: {+/-}%
- Removed tests: {count}
- Disabled tests: {count}

### Verdict: {APPROVED / CHANGES REQUESTED / BLOCKED}

**ANY FAIL = cannot proceed to /git-commit.**
```

## Usage

Phase 6 MUST produce this report regardless of mode. Fill in actual values from prior phases. The verdict determines workflow chaining:
- APPROVED -> chain to `/git-commit`
- CHANGES REQUESTED -> chain to `/x-implement`
- BLOCKED -> require fix before proceeding
