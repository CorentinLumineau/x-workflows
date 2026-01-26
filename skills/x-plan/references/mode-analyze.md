# Mode: analyze

> **Invocation**: `/x-plan analyze` or `/x-plan analyze "target"`
> **Legacy Command**: `/x:analyze`

<purpose>
Comprehensive code analysis across quality, security, performance, and architecture domains. Identify issues and improvement opportunities.
</purpose>

## Behavioral Skills

This mode activates:
- `analysis` - Pareto prioritization
- `code-quality` - Quality assessment
- `context-awareness` - Pattern awareness

## Agents

| Agent | When | Model |
|-------|------|-------|
| `ccsetup:x-reviewer` | Quality analysis | sonnet |
| `ccsetup:x-explorer` | Pattern discovery | haiku |

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Complex analysis |

<instructions>

### Phase 1: Scope Definition

Determine analysis scope:

| Scope | Target |
|-------|--------|
| File | Single file analysis |
| Module | Directory/module |
| Feature | Related components |
| Codebase | Full project |

### Phase 2: Multi-Domain Analysis

Use x-reviewer for comprehensive analysis:

```
Task(
  subagent_type: "ccsetup:x-reviewer",
  model: "sonnet",
  prompt: "Analyze {scope} across all domains"
)
```

#### Quality Domain
- [ ] SOLID adherence
- [ ] DRY violations
- [ ] KISS violations
- [ ] Code complexity

#### Security Domain
- [ ] Input validation
- [ ] Authentication/Authorization
- [ ] Data exposure
- [ ] OWASP Top 10

#### Performance Domain
- [ ] N+1 queries
- [ ] Memory leaks
- [ ] Inefficient algorithms
- [ ] Missing caching

#### Architecture Domain
- [ ] Layer violations
- [ ] Circular dependencies
- [ ] Component coupling
- [ ] Abstraction levels

### Phase 3: Issue Prioritization

Prioritize findings using Pareto:

| Severity | Impact | Action |
|----------|--------|--------|
| **Critical** | Security, data loss | Fix immediately |
| **High** | Performance, correctness | Fix soon |
| **Medium** | Quality, maintainability | Plan to fix |
| **Low** | Style, preferences | Fix opportunistically |

### Phase 4: Report Generation

Generate analysis report:

```markdown
# Code Analysis Report

## Summary
- Files analyzed: {count}
- Critical issues: {count}
- High issues: {count}
- Medium issues: {count}

## Critical Issues
1. **{Issue}**: {Description}
   - File: {path}
   - Line: {line}
   - Fix: {recommendation}

## High Issues
...

## Recommendations

### Quick Wins (< 1 hour)
1. {Recommendation}

### Planned Improvements (1-4 hours)
1. {Recommendation}

### Architectural Changes (> 4 hours)
1. {Recommendation}
```

### Phase 5: Workflow Transition

Present next step based on findings:

**Critical issues found**:
```json
{
  "questions": [{
    "question": "Analysis found {critical_count} critical issues. Address now?",
    "header": "Next",
    "options": [
      {"label": "/x-implement fix (Recommended)", "description": "Fix critical issues"},
      {"label": "/x-review", "description": "Detailed review"},
      {"label": "Stop", "description": "Review report first"}
    ],
    "multiSelect": false
  }]
}
```

**No critical issues**:
```json
{
  "questions": [{
    "question": "Analysis complete. {high_count} high, {med_count} medium issues. Continue?",
    "header": "Next",
    "options": [
      {"label": "/x-implement improve (Recommended)", "description": "Improve quality"},
      {"label": "/x-implement refactor", "description": "Refactor code"},
      {"label": "Stop", "description": "Review report first"}
    ],
    "multiSelect": false
  }]
}
```

</instructions>

## Analysis Tools

| Tool | Purpose |
|------|---------|
| ESLint | Code quality |
| TypeScript | Type safety |
| SonarQube | Security, quality |
| Complexity | Cyclomatic complexity |

<critical_rules>

## Critical Rules

1. **Be Objective** - Facts, not opinions
2. **Prioritize Ruthlessly** - Focus on impact
3. **Provide Solutions** - Don't just identify problems
4. **Consider Context** - Not all issues need fixing

</critical_rules>

<decision_making>

## Decision Making

**Report findings when**:
- Analysis complete
- Issues prioritized
- Recommendations ready

**Dig deeper when**:
- Critical issues found
- Pattern of problems
- Architecture concerns

</decision_making>

## References

- @core-docs/principles/solid.md - SOLID principles
- @core-docs/security/owasp-top-10.md - Security checklist
- @templates/optional/performance/application-performance.md - Performance (optional)

<success_criteria>

## Success Criteria

- [ ] Scope analyzed
- [ ] Issues identified
- [ ] Findings prioritized
- [ ] Report generated
- [ ] Next step presented

</success_criteria>
