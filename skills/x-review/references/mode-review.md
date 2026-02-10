# Mode: review

> **Invocation**: `/x-review` or `/x-review review`
> **Legacy Command**: `/x:review`

<purpose>
Pre-merge code review with auto-detected target branch, conflict detection, and quality gates. Systematic review following best practices checklist.
</purpose>

## Behavioral Skills

This mode activates:
- `code-quality` - Quality enforcement
- `git-workflow` - Branch management

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **code reviewer** | Code review | Read-only analysis |

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Complex review decisions |

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 20%, context 25%, technical 30%, scope 15%, risk 10%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Review focus unclear, severity classification ambiguous, standards reference missing.

---

## Instructions

### Phase 1: Context Detection

Detect review context:

```bash
# Get current branch
git branch --show-current

# Detect target branch
git rev-parse --abbrev-ref @{upstream} 2>/dev/null || echo "main"

# Get changed files
git diff --name-only {target}...HEAD
```

### Phase 2: Conflict Check

Check for merge conflicts:

```bash
git fetch origin
git merge-base HEAD origin/{target}
```

If conflicts exist, report and suggest resolution.

### Phase 3: Systematic Review

Delegate to a **code reviewer** agent (read-only analysis):
> "Review changes for PR"

#### Review Checklist

**Code Quality**:
- [ ] SOLID principles followed
- [ ] DRY - No unnecessary duplication
- [ ] KISS - Not over-engineered
- [ ] Naming clear and consistent

**Testing**:
- [ ] Tests cover new/changed code
- [ ] Edge cases tested
- [ ] No skipped/disabled tests

**Security**:
- [ ] No hardcoded secrets
- [ ] Input validation present
- [ ] No SQL injection risks
- [ ] No XSS vulnerabilities

**Documentation**:
- [ ] Public APIs documented
- [ ] Complex logic explained
- [ ] README updated if needed

**Breaking Changes**:
- [ ] Breaking changes documented
- [ ] Migration path provided

### Phase 4: Generate Review Report

```markdown
## Code Review Report

**Branch**: {branch} → {target}
**Files Changed**: {count}
**Lines**: +{added} -{removed}

### Summary
{Overall assessment}

### Issues Found

#### Must Fix (Blocking)
- [ ] Issue 1: {description}
  - File: {path}:{line}
  - Fix: {suggestion}

#### Should Fix (Non-blocking)
- [ ] Issue 1: {description}

#### Suggestions
- Consider: {suggestion}

### Approval Status
{APPROVED / CHANGES REQUESTED / NEEDS DISCUSSION}
```

### Phase 5: Workflow Transition

Present next step based on review:

**Approved**:
```json
{
  "questions": [{
    "question": "Review passed. Ready to merge?",
    "header": "Next",
    "options": [
      {"label": "/x-git commit (Recommended)", "description": "Create merge commit"},
      {"label": "Stop", "description": "Manual merge"}
    ],
    "multiSelect": false
  }]
}
```

**Changes Requested**:
```json
{
  "questions": [{
    "question": "Review found issues. How to proceed?",
    "header": "Next",
    "options": [
      {"label": "/x-implement fix (Recommended)", "description": "Address issues"},
      {"label": "Stop", "description": "Review feedback first"}
    ],
    "multiSelect": false
  }]
}
```

</instructions>

<critical_rules>

## Critical Rules

1. **Be Constructive** - Suggest improvements, don't just criticize
2. **Prioritize Issues** - Blocking vs suggestions
3. **Explain Why** - Reasoning helps learning
4. **Check Tests** - Code without tests is incomplete

</critical_rules>

<decision_making>

## Decision Making

**Approve when**:
- No blocking issues
- Tests adequate
- Follows patterns

**Request changes when**:
- Security issues
- Missing tests for critical paths
- Breaking changes undocumented

</decision_making>

## References

- @core-docs/PRINCIPLES_ENFORCEMENT.md - SOLID principles
- @skills/security-owasp/ - Security checklist
- @skills/code-code-quality/ - Quality standards

<success_criteria>

## Success Criteria

- [ ] Branch context detected
- [ ] All files reviewed
- [ ] Checklist completed
- [ ] Report generated
- [ ] Next step presented

</success_criteria>
