---
name: x-review
description: |
  Pre-merge validation with quality checks. Code review, auditing, best practices assessment.
  Activate when reviewing code, auditing practices, or checking quality before merge.
  Triggers: review, audit, code review, PR, pull request, best practices.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---

# x-review

Pre-merge validation with auto-detected target branch, conflict detection, and quality gates.

## Modes

| Mode | Description |
|------|-------------|
| review (default) | Pre-merge PR review |
| audit | SOLID audit, best practices check |
| improve | **Delegates to x-improve skill** for holistic analysis |

## Mode Detection
| Keywords | Mode |
|----------|------|
| "audit", "best practices", "solid", "quality check" | audit |
| "improve", "fix practices", "pareto" | improve |
| (default) | review |

## Execution
- **Default mode**: review
- **No-args behavior**: Review staged changes

## Behavioral Skills

This workflow activates these knowledge skills:

### Always Active
- `code-quality` - SOLID, DRY, KISS enforcement
- `owasp` - Security vulnerability check

### Context-Triggered
| Skill | Trigger Conditions |
|-------|-------------------|
| `authentication` | Auth-related changes |
| `performance` | Performance-critical paths |

## Agent Suggestions

Consider delegating to specialized agents:
- **Review**: Systematic code analysis, SOLID checks
- **Exploration**: Pattern analysis, architecture review

## Review Checklist

All reviews must check:

| Area | Check |
|------|-------|
| SOLID | Principles adherence |
| Security | No vulnerabilities |
| Tests | Adequate coverage |
| Docs | Documentation updated |
| Breaking | Breaking changes documented |

## Review Workflow

```
1. Identify changed files
2. For each file:
   a. Check SOLID compliance
   b. Check security issues
   c. Check test coverage
3. Summarize findings
4. Provide actionable feedback
```

## Severity Levels

| Level | Action |
|-------|--------|
| Critical | Must fix before merge |
| Warning | Should fix, or document reason |
| Info | Suggestion for improvement |

## Checklist

- [ ] All SOLID principles checked
- [ ] Security review complete
- [ ] Test coverage adequate
- [ ] Documentation updated
- [ ] Breaking changes documented

## When to Load References

- **For review mode**: See `references/mode-review.md`
- **For audit mode**: See `references/mode-audit.md`
- **For improve mode**: See `references/mode-improve.md`
