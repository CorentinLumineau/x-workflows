---
name: x-analyze
description: Comprehensive code analysis across quality, security, performance, and architecture.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---

# /x-analyze

> Assess codebase across quality, security, performance, and architecture domains.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | APEX |
| **Phase** | analyze (A) |
| **Position** | 1 of 6 in workflow |

**Flow**: `[start]` → **`x-analyze`** → `x-plan`

## Intention

**Target**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Ask user: "What would you like to analyze? (file, module, feature, or codebase)"
{{/if}}

## Behavioral Skills

This skill activates:
- `interview` - Zero-doubt confidence gate (Phase 0)
- `analysis` - Pareto prioritization
- `code-quality` - Quality assessment

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **code reviewer** | Quality analysis | Read-only analysis |
| **codebase explorer** | Pattern discovery | Fast, read-only |

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Complex analysis |

<instructions>

### Phase 0: Confidence Check

Activate `@skills/interview/` if:
- Scope boundaries unclear
- No comparison baseline
- Analysis focus undefined

### Phase 0b: Workflow State Check

1. Read `.claude/workflow-state.json` (if exists)
2. If active workflow exists:
   - Expected next phase is `analyze`? → Proceed
   - Skipping a phase? → Warn: "Skipping {phase}. Continue? [Y/n]"
   - Active workflow at different phase? → Confirm: "Active workflow at {phase}. Start new? [Y/n]"
3. If no active workflow → Create new APEX workflow state

### Phase 1: Scope Definition

Determine analysis scope:

| Scope | Target |
|-------|--------|
| File | Single file analysis |
| Module | Directory/module |
| Feature | Related components |
| Codebase | Full project |

### Phase 2: Multi-Domain Analysis

Delegate to a **code reviewer** agent (read-only analysis):
> "Analyze {scope} across all domains"

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

### Phase 3: Issue Prioritization (Pareto)

Prioritize findings:

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

### Phase 5: Update Workflow State

After completing analysis:

1. Read `.claude/workflow-state.json`
2. Mark `analyze` phase as `"completed"` with timestamp
3. Set `plan` phase as `"in_progress"`
4. Write updated state to `.claude/workflow-state.json`
5. Write to Memory MCP entity `"workflow-state"`:
   - `"phase: analyze -> completed"`
   - `"next: plan"`

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | Critical security issues found |
| **High** | ASK IF ABLE | Multiple remediation approaches |
| **Medium** | ASK IF UNCERTAIN | Scope expansion during analysis |
| **Low** | PROCEED | Continue analysis |

<human-approval-framework>

When approval needed, structure question as:
1. **Context**: What was found in analysis
2. **Options**: Different remediation approaches
3. **Recommendation**: Prioritized fix order
4. **Escape**: "Review report first" option

</human-approval-framework>

## Agent Delegation

**Recommended Agent**: **code reviewer** (quality analysis)

| Delegate When | Keep Inline When |
|---------------|------------------|
| Full codebase analysis | Single file analysis |
| Security deep dive | Quick quality check |

## Workflow Chaining

**Next Verb**: `/x-plan`

| Trigger | Chain To | Auto? |
|---------|----------|-------|
| Analysis complete | `/x-plan` | Yes |
| Critical issues, fix now | `/x-fix` | No (ask) |
| Needs implementation | `/x-implement` | No (ask) |

<chaining-instruction>

**Auto-chain**: analyze → plan (no approval needed)

After analysis complete:
1. Update `.claude/workflow-state.json` (mark analyze complete, set plan in_progress)
2. Auto-invoke next skill via Skill tool:
   - skill: "x-plan"
   - args: "{analysis summary with prioritized issues}"

If critical issues found requiring immediate fix (manual):
"Found {count} critical issues. Fix now with /x-fix or plan with /x-plan?"
- Option 1: `/x-fix` - Fix critical issues immediately
- Option 2: `/x-plan` - Plan comprehensive fix

</chaining-instruction>

## Analysis Tools

| Tool | Purpose |
|------|---------|
| ESLint | Code quality |
| TypeScript | Type safety |
| SonarQube | Security, quality |
| Complexity | Cyclomatic complexity |

## Critical Rules

1. **Be Objective** - Facts, not opinions
2. **Prioritize Ruthlessly** - Focus on impact
3. **Provide Solutions** - Don't just identify problems
4. **Consider Context** - Not all issues need fixing

## Navigation

| Direction | Verb | When |
|-----------|------|------|
| Next | `/x-plan` | Analysis complete, plan fixes |
| Quick fix | `/x-fix` | Critical issues, fix immediately |
| Skip to implement | `/x-implement` | Small scope, obvious fixes |

## Success Criteria

- [ ] Scope analyzed
- [ ] Issues identified across all domains
- [ ] Findings prioritized
- [ ] Report generated
- [ ] Next step presented

## References

- @skills/code-code-quality/ - SOLID principles
- @skills/security-owasp/ - Security checklist
