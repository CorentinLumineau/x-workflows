---
name: x-analyze
description: Use when you need to assess a codebase before planning changes.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Grep Glob Bash
user-invocable: true
metadata:
  author: ccsetup contributors
  version: "1.1.0"
  category: workflow
chains-to:
  - skill: x-plan
    condition: "analysis complete"
  - skill: x-fix
    condition: "critical issues found"
  - skill: x-review
    condition: "deep audit needed"
  - skill: x-docs
    condition: "documentation gaps found"
chains-from: []
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
- `analysis-architecture` - Pareto prioritization
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

<plan-mode phase="exploration" trigger="after-interview">
  <enter>After confidence gate passes, enter read-only exploration mode for codebase analysis</enter>
  <scope>Phases 1-3: scope definition, multi-domain analysis, issue prioritization (read-only: Glob, Grep, Read only)</scope>
  <exit trigger="analysis-complete">Present analysis report and prioritized findings for user approval before proceeding to plan</exit>
</plan-mode>

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

<agent-delegate role="code reviewer" subagent="x-reviewer" model="sonnet">
  <prompt>Analyze {scope} across quality, security, performance, and architecture domains</prompt>
  <context>Full multi-domain code analysis for APEX workflow analyze phase</context>
</agent-delegate>

<agent-delegate role="codebase explorer" subagent="x-explorer" model="haiku">
  <prompt>Search codebase for patterns and conventions related to {scope}</prompt>
  <context>Pattern discovery to support multi-domain analysis</context>
</agent-delegate>

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

<deep-think purpose="prioritization" context="Analyzing codebase to prioritize findings by impact and risk">
  <purpose>Apply Pareto 80/20 analysis to prioritize findings by severity and impact</purpose>
  <context>Multiple issues identified across quality, security, performance, and architecture domains; need structured reasoning to classify and prioritize</context>
</deep-think>

Prioritize findings:

| Severity | Impact | Action |
|----------|--------|--------|
| **Critical** | Security, data loss | Fix immediately |
| **High** | Performance, correctness | Fix soon |
| **Medium** | Quality, maintainability | Plan to fix |
| **Low** | Style, preferences | Fix opportunistically |

### Phase 4a: Write Full Audit Document

Write the complete audit report to `documentation/audits/analysis-{scope}-{YYYY-MM-DD}.md`.

Create the `documentation/audits/` directory if it does not exist.

> See [references/audit-report-template.md](references/audit-report-template.md) for the full report template.

### Phase 4b: Display Executive Summary

After writing the audit document, display a condensed executive summary to the user:

```
## Analysis Executive Summary

**Scope**: {scope} | **Date**: {date} | **Files analyzed**: {count}

### Findings
| Severity | Count | Top Issue |
|----------|-------|-----------|
| Critical | {n}   | {headline} |
| High     | {n}   | {headline} |
| Medium   | {n}   | {headline} |
| Low      | {n}   | — |

### Top 3 Recommendations
1. {recommendation} — effort: {estimate}
2. {recommendation} — effort: {estimate}
3. {recommendation} — effort: {estimate}

Full report: `documentation/audits/analysis-{scope}-{date}.md`
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

<state-checkpoint phase="analyze" status="completed">
  <file path=".claude/workflow-state.json">Mark analyze complete, set plan in_progress</file>
  <memory entity="workflow-state">phase: analyze -> completed; next: plan</memory>
</state-checkpoint>

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

| Trigger | Chain To |
|---------|----------|
| Analysis complete | `/x-plan` (suggest) |
| Critical issues, fix now | `/x-fix` (suggest) |
| Needs deep audit | `/x-review audit` (suggest) |
| Documentation gaps found | `/x-docs` (suggest) |
| Needs implementation | `/x-implement` (suggest) |

<chaining-instruction>

After analysis complete:

<workflow-gate type="choice" id="analyze-next">
  <question>Analysis complete. How would you like to proceed?</question>
  <header>Next step</header>
  <option key="plan" recommended="true">
    <label>Plan implementation</label>
    <description>Create implementation plan based on analysis findings</description>
  </option>
  <option key="fix">
    <label>Fix critical issues</label>
    <description>Address critical issues immediately with a targeted fix</description>
  </option>
  <option key="review">
    <label>Deep review</label>
    <description>Run deep code and security audit on flagged files</description>
  </option>
  <option key="docs">
    <label>Document findings</label>
    <description>Update or create documentation based on analysis findings</description>
  </option>
  <option key="done">
    <label>Done</label>
    <description>Review analysis report without further action</description>
  </option>
</workflow-gate>

<workflow-chain on="plan" skill="x-plan" args="{analysis summary with prioritized issues}" />
<workflow-chain on="fix" skill="x-fix" args="{critical issues to fix}" />
<workflow-chain on="review" skill="x-review" args="audit {flagged files from analysis}" />
<workflow-chain on="docs" skill="x-docs" args="{documentation gaps identified in analysis}" />
<workflow-chain on="done" action="end" />

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
- [ ] Audit document written to `documentation/audits/`
- [ ] Executive summary displayed to user
- [ ] Next step presented

## References

- @skills/code-code-quality/ - SOLID principles
- @skills/security-secure-coding/ - Security checklist
