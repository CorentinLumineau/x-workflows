# Delegation Patterns & Decision Matrix

Detailed delegation strategies, variant selection, and escalation protocols.

## Decision Matrix: When to Delegate

| Task Type | Complexity | Recommended Agent | Variant | Rationale |
|-----------|------------|-------------------|---------|-----------|
| Code review | Low | x-reviewer-quick | x-reviewer | Quick scan sufficient for low-risk |
| Code review | Medium-High | x-reviewer | x-security-reviewer | Full analysis, escalate if security |
| Security review | Any | x-security-reviewer | -- | Always full security analysis |
| Deployment | Any | x-deployer | -- | Rollback planning, health checks |
| Bug fix (simple) | Low | main agent | -- | Direct fix more efficient |
| Bug fix (complex) | High | x-debugger | x-debugger-deep | Hypothesis testing, isolation |
| Test failures | Low | x-tester-fast | x-tester | Quick validation first |
| Test failures | Medium-High | x-tester | -- | Owns test execution, knows patterns |
| Documentation | Any | x-doc-writer | -- | Consistent style, JSDoc expertise |
| Quick search | Low | x-explorer | -- | Fast, uses haiku, read-only |
| Refactoring | Medium | x-refactorer | -- | SOLID enforcement, safe changes |
| Architecture | High | x-designer | x-refactorer | System modeling, trade-offs |

## Complexity Indicators

**Low Complexity** (handle directly):
- Single file change, clear error message, known pattern fix, < 30 minutes

**Medium Complexity** (consider delegation):
- 2-5 files affected, requires investigation, pattern unclear, 30 min - 2 hours

**High Complexity** (delegate recommended):
- 5+ files affected, cross-cutting concerns, architecture impact, > 2 hours

## Variant Selection Criteria

| Condition | Choose | Over |
|-----------|--------|------|
| Low-risk, quick validation | x-reviewer-quick (haiku) | x-reviewer (sonnet) |
| High-risk, security-critical | x-security-reviewer (sonnet) | x-reviewer-quick (haiku) |
| Quick smoke test | x-tester-fast (haiku) | x-tester (sonnet) |
| Complex test failures | x-tester (sonnet) | x-tester-fast (haiku) |
| Simple bug, clear error | x-debugger (sonnet) | x-debugger-deep (opus) |
| Elusive, cross-service bug | x-debugger-deep (opus) | x-debugger (sonnet) |
| Standard implementation | x-refactorer (sonnet) | x-designer (opus) |
| Architectural decisions | x-designer (opus) | x-refactorer (sonnet) |

### Cost Optimization Rules

1. **Default to cheapest capable model** -- Use haiku variants when task is low-risk
2. **Escalate on failure** -- If haiku variant produces insufficient results, retry with sonnet
3. **Never under-resource critical paths** -- Security, architecture, and deep debugging always use sonnet or opus
4. **Parallel cost savings** -- Use haiku variants for parallel batch workers to reduce total cost

## Delegation Patterns

### Pattern 1: Sequential Delegation

```markdown
User: "Fix the auth bug and then review the changes"

1. Delegate to a **debugger** agent (sonnet):
   > "Investigate and fix the authentication bug"
2. After fix committed, delegate to a **code reviewer** agent (sonnet):
   > "Review the auth changes for quality and SOLID compliance"
3. If security concerns, escalate to a **security auditor** agent (sonnet):
   > "Audit the auth flow changes for vulnerabilities"
```

### Pattern 2: Parallel Delegation

```markdown
User: "Review this PR for quality and security"

Parallel delegation:
- **code reviewer** agent (sonnet):
  > "Review for code quality, SOLID, maintainability"
- **security auditor** agent (sonnet):
  > "Review for security vulnerabilities, auth issues"

Merge findings in response.
```

### Pattern 3: Conditional Delegation

```markdown
User: "Fix the tests"

Decision tree:
1. Are tests failing? -> Delegate to **test runner** agent
2. Is it a runtime bug? -> Delegate to **debugger** agent
3. Is coverage issue? -> Delegate to **test runner** agent
4. Is it architecture issue? -> Main agent + planning
```

### Pattern 4: Cost-Optimized Delegation

```markdown
User: "Quick check on the changes before I push"

Low-risk path:
1. Delegate to **quick reviewer** agent (haiku):
   > "Rapid scan of staged changes for obvious issues"
2. If issues found, escalate to **code reviewer** agent (sonnet):
   > "Full review of flagged areas"
```

## Variant Escalation Rules

### Escalation Table

| Trigger Condition | From (current) | To (escalated) | Detection |
|-------------------|----------------|----------------|-----------|
| Tests still failing after fix | x-tester-fast (haiku) | x-tester (sonnet) | Tests still red |
| Analysis shallow | x-reviewer-quick (haiku) | x-reviewer (sonnet) | Issues flagged but no root cause |
| Complex codebase | x-explorer (haiku) | general-purpose (sonnet) | Insufficient context returned |
| Root cause not found after 2 hypotheses | x-debugger (sonnet) | x-debugger-deep (opus) | Hypothesis list exhausted |
| Architectural scope during refactoring | x-refactorer (sonnet) | x-designer (opus) | Cross-service decisions needed |

### Escalation Protocol

1. **Detect trigger condition** from agent delegation outcome
2. **Log escalation** in delegation history
3. **Suggest or auto-escalate**: If orchestration skill is active, auto-escalate; otherwise suggest to user
4. **Max 1 escalation per delegation** -- no recursive escalation loops

### Escalation Decision Tree

```
Agent completes with insufficient result
    |
Check Escalation Table for matching trigger
    |
Match found? -- No -> Report result as-is
    |
    Yes
    |
Already escalated once? -- Yes -> Report, suggest manual intervention
    |
    No
    |
Orchestration active? -- Yes -> Auto-escalate (re-delegate)
    |
    No
    |
Suggest to user: "Escalate {from} to {to}?"
```

## Delegation History Tracking

When agent-awareness suggests a delegation:

### On Suggestion

Record the suggestion in MEMORY.md delegation patterns:
```
"suggestion: {agent} ({model}) for {task_type} [{complexity}] at {timestamp}"
```

### On User Decision

Track if user accepted or overrode the suggestion:
```
"user_override: suggested {agent}, user chose {other_agent}"
# OR
"user_accepted: {agent} for {task_type}"
```

### Acceptance Tracking

Store acceptance rate per agent-task combination to inform future suggestions:
- Track: `{agent} + {task_type} -> accepted/overridden`
- Pattern: If user consistently overrides a suggestion, adjust future recommendations
- Data location: MEMORY.md delegation patterns (L2)
