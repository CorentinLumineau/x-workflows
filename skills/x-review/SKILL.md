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
| security | OWASP Top 10 security assessment |

## Mode Detection
| Keywords | Mode |
|----------|------|
| "security", "owasp", "vulnerability", "security review" | security |
| "audit", "best practices", "solid", "quality check" | audit |
| (default) | review |

> **Note**: For code improvements, use `/x-improve` (holistic analysis with health scores) or `/x-implement enhance` (targeted improvements).

## Execution
- **Default mode**: review
- **No-args behavior**: Review staged changes

## Behavioral Skills

This workflow activates these behavioral skills:

### Always Active
- `interview` - Zero-doubt confidence gate (Phase 0)
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
| Docs | Documentation updated (via x-docs verify) |
| Doc Sync | No stale documentation (auto-verified) |
| Breaking | Breaking changes documented |

### Documentation Validation (Auto)

Before review starts, the `documentation` behavioral skill runs `x-docs verify` to ensure:

```
┌─────────────────────────────────────────────────┐
│ Pre-Review Documentation Check                  │
├─────────────────────────────────────────────────┤
│ ✓ API docs match code signatures               │
│ ✓ Examples are current                          │
│ ✓ No broken internal links                      │
│ ⚠ 1 doc may need attention:                    │
│   • docs/auth.md - new method not documented   │
└─────────────────────────────────────────────────┘
```

If documentation drift is detected, the reviewer is notified before proceeding.

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
- **For security mode**: See `references/mode-security.md`
