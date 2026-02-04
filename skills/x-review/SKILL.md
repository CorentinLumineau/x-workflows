---
name: x-review
description: Pre-merge validation with quality checks and code review.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "2.0.0"
  category: workflow
---

# /x-review

> Perform code review with quality checks before merge.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | APEX |
| **Phase** | examine (X) |
| **Position** | 5 of 6 in workflow |

**Flow**: `x-verify` → **`x-review`** → `x-commit`

## Intention

**Target**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Review staged changes.
{{/if}}

## Behavioral Skills

This skill activates:

### Always Active
- `interview` - Zero-doubt confidence gate (Phase 0)
- `code-quality` - SOLID, DRY, KISS enforcement
- `owasp` - Security vulnerability check

### Context-Triggered
| Skill | Trigger Conditions |
|-------|-------------------|
| `authentication` | Auth-related changes |
| `performance` | Performance-critical paths |

## Agents

| Agent | When | Model |
|-------|------|-------|
| `ccsetup:x-reviewer` | Systematic code analysis | sonnet |
| `ccsetup:x-explorer` | Pattern analysis | haiku |

<instructions>

### Phase 0: Confidence Check

Activate `@skills/interview/` if:
- Review scope unclear
- Multiple review focuses possible
- Security implications unknown

### Phase 1: Documentation Pre-Check

Before review starts, verify documentation sync:

```
┌─────────────────────────────────────────────────┐
│ Pre-Review Documentation Check                  │
├─────────────────────────────────────────────────┤
│ Check API docs match code signatures            │
│ Check examples are current                      │
│ Check no broken internal links                  │
│ Flag docs that may need attention               │
└─────────────────────────────────────────────────┘
```

### Phase 2: Code Review

For each changed file:

1. **SOLID Compliance**
   - Single Responsibility
   - Open/Closed
   - Liskov Substitution
   - Interface Segregation
   - Dependency Inversion

2. **Security Issues**
   - Input validation
   - Authentication/Authorization
   - Data exposure
   - OWASP Top 10

3. **Test Coverage**
   - New code has tests
   - Edge cases covered
   - Integration tests if needed

### Phase 3: Severity Classification

| Level | Action |
|-------|--------|
| Critical | Must fix before merge |
| Warning | Should fix, or document reason |
| Info | Suggestion for improvement |

### Phase 4: Review Summary

Generate review summary:

```markdown
## Review Summary

### Critical Issues
- [ ] Issue 1: Description (file:line)

### Warnings
- [ ] Warning 1: Description (file:line)

### Suggestions
- Info 1: Description

### Overall
- SOLID: [Pass/Fail]
- Security: [Pass/Fail]
- Tests: [Pass/Fail]
- Docs: [Pass/Fail]
```

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | Critical issues found |
| **High** | ASK IF ABLE | Multiple warnings |
| **Medium** | ASK IF UNCERTAIN | Borderline issues |
| **Low** | PROCEED | Clean review |

<human-approval-framework>

When approval needed, structure question as:
1. **Context**: Review findings summary
2. **Options**: Fix issues, merge with warnings, or block
3. **Recommendation**: Fix criticals before merge
4. **Escape**: "Return to /x-implement" option

</human-approval-framework>

## Agent Delegation

**Recommended Agent**: `ccsetup:x-reviewer`

| Delegate When | Keep Inline When |
|---------------|------------------|
| Large changeset | Small changes |
| Security-sensitive | Simple refactors |

## Workflow Chaining

**Next Verb**: `/x-commit`

| Trigger | Chain To | Auto? |
|---------|----------|-------|
| Review approved | `/x-commit` | Yes |
| Changes requested | `/x-implement` | No (show feedback) |
| Critical issues | Block | No (require fix) |

<chaining-instruction>

When review approved:
- skill: "x-commit"
- args: "commit reviewed changes"

On changes requested:
"Review found issues to address. Return to /x-implement?"
- Option 1: `/x-implement` - Fix issues
- Option 2: Request exception (with justification)

</chaining-instruction>

## Review Checklist

| Area | Check |
|------|-------|
| SOLID | Principles adherence |
| Security | No vulnerabilities |
| Tests | Adequate coverage |
| Docs | Documentation updated |
| Breaking | Breaking changes documented |

## Severity Levels

| Level | Action |
|-------|--------|
| Critical | Must fix before merge |
| Warning | Should fix, or document reason |
| Info | Suggestion for improvement |

## Critical Rules

1. **No Critical Issues** - Block merge if critical issues exist
2. **Document Trade-offs** - If skipping warnings, document why
3. **Security First** - Security issues are always critical
4. **Test Coverage** - New code must have tests

## Navigation

| Direction | Verb | When |
|-----------|------|------|
| Previous | `/x-verify` | Need more verification |
| Previous | `/x-implement` | Need to fix issues |
| Next | `/x-commit` | Review approved |

## Success Criteria

- [ ] All files reviewed
- [ ] SOLID principles checked
- [ ] Security review complete
- [ ] Test coverage adequate
- [ ] Documentation updated
- [ ] No critical issues

## When to Load References

- **For review checklist**: See `references/mode-review.md`
- **For audit patterns**: See `references/mode-audit.md`
- **For security review**: See `references/mode-security.md`

## References

- @skills/code-code-quality/ - SOLID principles
- @skills/security-owasp/ - Security checklist
