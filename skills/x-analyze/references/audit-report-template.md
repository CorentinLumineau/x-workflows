# Audit Report Template

> Extracted from x-analyze SKILL.md — full audit document template for Phase 4a.

## Template

Write to `documentation/audits/analysis-{scope}-{YYYY-MM-DD}.md`:

```markdown
# Code Analysis Report

**Date**: {YYYY-MM-DD}
**Scope**: {scope description}
**Analyzer**: x-analyze v1.1.0

## Scope

### Included
- {files, modules, or features analyzed}

### Excluded
- {anything explicitly out of scope}

## Findings

### Quality Domain
| # | Issue | Severity | File | Line | Evidence |
|---|-------|----------|------|------|----------|
| 1 | {issue} | {critical/high/medium/low} | {path} | {line} | {evidence} |

### Security Domain
| # | Issue | Severity | File | Line | Evidence |
|---|-------|----------|------|------|----------|
| 1 | {issue} | {critical/high/medium/low} | {path} | {line} | {evidence} |

### Performance Domain
| # | Issue | Severity | File | Line | Evidence |
|---|-------|----------|------|------|----------|
| 1 | {issue} | {critical/high/medium/low} | {path} | {line} | {evidence} |

### Architecture Domain
| # | Issue | Severity | File | Line | Evidence |
|---|-------|----------|------|------|----------|
| 1 | {issue} | {critical/high/medium/low} | {path} | {line} | {evidence} |

## Risk Matrix

| Severity x Likelihood | Likely | Possible | Unlikely |
|------------------------|--------|----------|----------|
| **Critical** | {issues} | {issues} | {issues} |
| **High** | {issues} | {issues} | {issues} |
| **Medium** | {issues} | {issues} | {issues} |

## Recommendations

### Quick Wins (< 1 hour)
1. {Recommendation} — effort: {estimate}

### Planned Improvements (1-4 hours)
1. {Recommendation} — effort: {estimate}

### Architectural Changes (> 4 hours)
1. {Recommendation} — effort: {estimate}

## Suggested Next Steps

| Action | Command | When |
|--------|---------|------|
| Plan fixes | `/x-plan` | Create implementation plan from findings |
| Fix critical | `/x-fix` | Address critical issues immediately |
| Deep review | `/x-review audit` | Audit flagged files in depth |
| Document | `/x-docs` | Update docs based on findings |
```
