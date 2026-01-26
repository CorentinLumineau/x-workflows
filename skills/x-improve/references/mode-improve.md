# Mode: improve

> **Invocation**: `/x-improve` or `/x:improve`
> **Legacy Command**: `/x:improve`

<purpose>
Holistic code health analyzer that evaluates coverage, best-practices, and refactoring opportunities across the codebase, then suggests 3 Pareto-optimized quick wins (20% effort → 80% value).
</purpose>

## Behavioral Skills

This mode activates:
- `analysis` - Pareto prioritization
- `code-quality` - SOLID/DRY/KISS assessment
- `testing` - Coverage evaluation

<instructions>

### Phase 1: Parallel Analysis

Launch 3 agents in parallel to analyze different aspects:

**Agent 1: Coverage Analysis**
```
Task prompt: "Analyze test coverage for this project:
- Identify current coverage percentage
- List top 5 untested or under-tested files
- Note critical paths without tests
- Score: 0-100 based on coverage %
Return: coverage_score, untested_files[], recommendations[]"

subagent_type: ccsetup:x-tester
model: haiku
```

**Agent 2: Best Practices Audit**
```
Task prompt: "Audit code quality and best practices:
- Check SOLID principle violations
- Identify code smells (long methods, god classes)
- Find missing error handling
- Check documentation gaps
- Score: 0-100 based on compliance
Return: practices_score, violations[], recommendations[]"

subagent_type: ccsetup:x-reviewer
model: haiku
```

**Agent 3: Refactoring Opportunities**
```
Task prompt: "Scan for refactoring opportunities:
- Find code duplication
- Identify high cyclomatic complexity
- Detect tight coupling
- Find dead code
- Score: 0-100 (lower = more opportunities)
Return: refactor_score, opportunities[], recommendations[]"

subagent_type: ccsetup:x-explorer
model: haiku
```

### Phase 2: Score & Present Health Report

Compile results into health dashboard:

```markdown
## Code Health Report

| Area | Score | Status | Top Issue |
|------|-------|--------|-----------|
| **Coverage** | {score}% | {emoji} | {top_issue} |
| **Best Practices** | {score}% | {emoji} | {top_issue} |
| **Refactoring** | {score}% | {emoji} | {top_issue} |

**Overall Health**: {average}% {emoji}
```

Status emojis:
- 90-100%: ✅ Excellent
- 70-89%: 🟡 Good
- 50-69%: 🟠 Needs Work
- 0-49%: 🔴 Critical

### Phase 3: Prioritize Quick Wins

Use sequential-thinking MCP to prioritize:

```json
{
  "thought": "Analyzing all recommendations from 3 agents to find 3 quick wins...",
  "criteria": {
    "impact": "How much will this improve the score?",
    "effort": "Time to implement (prefer <30 min)",
    "risk": "Chance of introducing bugs (prefer low)",
    "isolation": "Does it affect other code? (prefer isolated)"
  }
}
```

**Pareto Filter**: Select improvements where:
- Impact ≥ 5% score improvement
- Effort ≤ 30 minutes
- Risk = Low
- Isolated = Yes (minimal dependencies)

### Phase 4: Present Quick Wins

```markdown
## 3 Quick Wins (Pareto: 20% effort → 80% value)

### 1. [{Area}] {Title}
**Impact**: +{X}% {area} score
**Effort**: ~{minutes} min
**Files**: {file_list}
**Action**: {brief_description}

### 2. [{Area}] {Title}
...

### 3. [{Area}] {Title}
...
```

### Phase 5: User Action

Present options:

```json
{
  "questions": [{
    "question": "Which quick wins should I implement?",
    "header": "Execute",
    "options": [
      {"label": "All 3 (Recommended)", "description": "Implement all quick wins now"},
      {"label": "Pick specific", "description": "Let me choose which ones"},
      {"label": "Queue for later", "description": "Add to TodoWrite, continue current work"},
      {"label": "None", "description": "Just wanted the analysis"}
    ],
    "multiSelect": false
  }]
}
```

**If user selects "All 3"**:
Execute sequentially, marking each complete in TodoWrite.

**If user selects "Pick specific"**:
```json
{
  "questions": [{
    "question": "Select quick wins to implement:",
    "header": "Select",
    "options": [
      {"label": "1. {Title}", "description": "{Area}: +{X}%"},
      {"label": "2. {Title}", "description": "{Area}: +{X}%"},
      {"label": "3. {Title}", "description": "{Area}: +{X}%"}
    ],
    "multiSelect": true
  }]
}
```

**If user selects "Queue for later"**:
Add to TodoWrite:
```
- [ ] [Coverage] {Quick win 1 title}
- [ ] [Best Practices] {Quick win 2 title}
- [ ] [Refactor] {Quick win 3 title}
```

## Execution Handoff

When executing quick wins, route to appropriate skill:

| Quick Win Type | Route To |
|----------------|----------|
| Coverage improvement | `/x-verify coverage` + `/x-implement` |
| Best practices fix | `/x-implement fix` |
| Refactoring | `/x-implement refactor` |

## Focus Mode (Optional)

If user provides focus area, limit analysis:

```
/x:improve coverage
→ Only run coverage analysis, suggest coverage quick wins

/x:improve best-practices
→ Only run best practices audit, suggest BP quick wins

/x:improve refactor
→ Only run refactoring scan, suggest refactor quick wins
```

When focus provided, skip Phase 1 parallel analysis and run single agent.

</instructions>

<critical_rules>

1. **Pareto First** - Only suggest truly quick wins (not major refactors)
2. **Quantify Impact** - Every suggestion must have estimated score improvement
3. **Actionable** - Vague suggestions are useless, be specific
4. **User Control** - Always let user decide what to execute
5. **Track Progress** - Use TodoWrite for accountability

</critical_rules>

<success_criteria>

- [ ] Health scores calculated for all 3 areas
- [ ] 3 quick wins identified with impact estimates
- [ ] User presented with execution options
- [ ] Selected improvements executed or queued

</success_criteria>

## References

- @core-docs/principles/pareto-80-20.md - Pareto prioritization
- @core-docs/testing/testing-pyramid.md - Coverage targets (70/20/10)
- @core-docs/principles/solid.md - Best practices reference

---

**Version**: 5.1.3
