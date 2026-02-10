# Mode: assess

> **Invocation**: `/x-research assess` or `/x-research assess "pattern/URL"`
> **Legacy Command**: `/x:assess-integration`

<purpose>
Research external patterns, libraries, or concepts; assess their pertinence to the project; and design integration strategy. Prevents over-engineering by validating alignment before implementation.
</purpose>

## Configuration Variables

Projects configure these via thin wrappers:

| Variable | Purpose | Example |
|----------|---------|---------|
| `$PROJECT_PLANNING_DOC` | Planning document path | `documentation/milestones/MASTER-PLAN.md` |
| `$PROJECT_ARCHIVE_DOC` | Archive document path | `documentation/milestones/ARCHIVE.md` |
| `$PROJECT_STRUCTURE_GLOB` | Architecture discovery glob | `src/{components,services}/**/*.ts` |

## Behavioral Skills

This mode activates:
- `context-awareness` - Project context loading
- `interview` - Zero-doubt confidence gate (Phase 0)

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **codebase explorer** | Architecture compatibility analysis | Fast, read-only |

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Multi-step pertinence analysis |

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 35%, context 30%, technical 20%, scope 10%, risk 5%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Input unclear (URL vs concept), project architecture unclear, assessment criteria unclear.

---

## Instructions

### Phase 0: Context Loading

**Load project state before research:**

```
1. Read $PROJECT_PLANNING_DOC → Check active/completed initiatives
2. Read $PROJECT_ARCHIVE_DOC → Check reverted/cancelled initiatives (learn from failures)
3. Glob $PROJECT_STRUCTURE_GLOB → Understand current architecture
4. Grep pain points in documentation → Identify documented gaps

Tool Usage:
- Read: Planning doc, Archive doc
- Glob: Project structure pattern
- Grep: "problem", "gap", "missing" in documentation
```

**Anti-Patterns to Check:**

- Overlap: Is this already an active initiative?
- Revert History: Was similar pattern tried and reverted? Why?
- Gap Mismatch: Does this solve a documented problem?

### Phase 1: Research

**Adapt research strategy based on input type:**

#### Context-Aware Execution

| Input Pattern | Detected Context | Execution Path |
|---------------|------------------|----------------|
| GitHub URL (e.g., github.com/user/repo) | Repository link | Fetch README → analyze architecture → assess fit |
| npm/package URL (e.g., npmjs.com/package/X) | Package page | Fetch stats → analyze dependencies → assess value |
| Blog/article URL (e.g., blog.com/pattern) | Technical writing | Extract concepts → validate claims → research best practices |
| Concept name (e.g., "Defense-in-Depth") | Abstract pattern | WebSearch research → gather examples → assess applicability |
| Default (any input) | General assessment | Attempt URL parse → fallback to concept research |

**For GitHub URLs:**

```
1. WebFetch repository README → Extract: purpose, key features, architecture
2. WebSearch "{repo_name} production usage" → Validate: stars, adoption, stability
3. WebFetch technical documentation → Understand: patterns, dependencies, complexity
4. Sequential Thinking: Analyze transferability to project architecture
```

**For npm/package URLs:**

```
1. WebFetch package page → Extract: downloads/week, dependencies, maintenance
2. WebSearch "{package} comparison alternatives" → Context: ecosystem position
3. WebFetch package GitHub → Understand: issue tracker, community health
4. Sequential Thinking: Assess integration complexity and value
```

**For Blog/Article URLs:**

```
1. WebFetch article → Extract: core concepts, claims, examples
2. WebSearch concept validation → Verify: authoritative sources, production use
3. WebSearch "{concept} best practices" → Research: established patterns
4. Sequential Thinking: Evaluate concept applicability to project
```

**For Concept Names:**

```
1. WebSearch "{concept} definition" → Understand: meaning, origin, context
2. WebSearch "{concept} production examples" → Find: real-world implementations
3. WebSearch "{concept} best practices" → Research: established patterns
4. Sequential Thinking: Design project-specific application
```

### Phase 2: Pertinence Assessment

**Use Sequential Thinking MCP for structured evaluation:**

```
Evaluation Framework:
┌─────────────────────────────────────────┐
│ 1. Problem Alignment                    │
│    - Does this solve documented gap?    │
│    - Score: High/Medium/Low              │
├─────────────────────────────────────────┤
│ 2. Architecture Compatibility           │
│    - Fits existing project structure?   │
│    - Score: High/Medium/Low              │
├─────────────────────────────────────────┤
│ 3. Validation (Production Proven)       │
│    - Stars/downloads/adoption?           │
│    - Score: High (5k+)/Medium/Low        │
├─────────────────────────────────────────┤
│ 4. Transferability                      │
│    - Patterns translate to project?      │
│    - Score: High/Medium/Low              │
└─────────────────────────────────────────┘

Overall Pertinence: Average of 4 scores
```

**Quality Gates (Automatic Failure):**

```
FAIL if:
- Overlap: Active initiative exists for same pattern
- Revert History: Similar pattern was tried and reverted
- No Gap: Doesn't solve documented problem
- Architecture Mismatch: Doesn't fit project structure
```

**Output Pertinence Report:**

```markdown
## Pertinence Assessment

**Source**: [{pattern-name}]({url})
**Status**: ✅ Pertinent | ⚠️ Conditional | ❌ Not Pertinent

| Factor | Score | Rationale |
|--------|-------|-----------|
| Problem Alignment | {High/Medium/Low} | {reason} |
| Architecture Compatibility | {High/Medium/Low} | {reason} |
| Validation | {High/Medium/Low} | {reason} |
| Transferability | {High/Medium/Low} | {reason} |

**Overall**: {Pertinence Level} ({X}/4 High scores)

**Recommendation**: {Proceed to design / Refine assessment / Stop}
**Risks**: {Implementation complexity, maintenance burden, etc.}
```

### Validation Gate 1: User Approval

**Use AskUserQuestion to get explicit approval:**

```json
{
  "questions": [
    {
      "question": "Pertinence assessment complete. Proceed to integration design?",
      "header": "Approval",
      "multiSelect": false,
      "options": [
        {
          "label": "Yes - Design integration",
          "description": "High pertinence confirmed, proceed"
        },
        {
          "label": "No - Stop here",
          "description": "Assessment sufficient, no design needed"
        },
        {
          "label": "Refine assessment",
          "description": "Need more research before decision"
        }
      ]
    }
  ]
}
```

**STOP if user says No** - Do not proceed to Phase 3

### Phase 3: Integration Design (If Approved)

**Design technical architecture:**

```
1. Identify transferable patterns → List specific features/behaviors
2. Map to project architecture → Components, modules, services
3. Design Pareto 80/20 breakdown → Tier 1 (high value) vs Tier 2
4. Estimate effort and impact → Days, % improvement metrics
5. Create milestone specifications → M1-M4 with success criteria
```

**Output Design Document:**

```markdown
## Integration Design

### Transferable Patterns ({N} identified)

1. {Pattern 1} → {Component mapping}
2. {Pattern 2} → {Component mapping}
...

### Architecture Mapping

| Pattern | Project Component | Implementation |
|---------|-------------------|----------------|
| {Pattern} | {Component} | {File/location} |

### Pareto 80/20 Breakdown

**Tier 1 (80% value, {X} days)**:
- M1: {Milestone 1}
- M2: {Milestone 2}

**Tier 2 (20% value, {Y} days)**:
- M3: {Milestone 3}
- M4: {Milestone 4}
```

### Validation Gate 2: Initiative Creation

**Use AskUserQuestion for final confirmation:**

```json
{
  "questions": [
    {
      "question": "Create initiative to track implementation?",
      "header": "Initiative",
      "multiSelect": false,
      "options": [
        {
          "label": "Yes - Create now",
          "description": "Design approved, formalize initiative"
        },
        {
          "label": "Save design only",
          "description": "Save design document, create initiative later"
        },
        {
          "label": "Discard",
          "description": "Assessment complete, no further action"
        }
      ]
    }
  ]
}
```

### Phase 4: Initiative Creation (If Approved)

**Invoke initiative workflow:**

```
1. Create initiative documentation directory
2. Generate milestone files (M1-M4)
3. Update planning document
4. Initialize workflow status tracking
```

</instructions>

<decision_making>

## Decision Making

**Execute autonomously when:**
- Input is clear (URL or concept name)
- Research sources are accessible
- No active initiative overlaps detected
- Quality gates pass automatically

**Ask clarifying questions when:**
- Input is ambiguous (unclear URL or concept)
- Pertinence is conditional (Medium scores)
- Architecture fit is uncertain
- Multiple integration approaches possible

**Stop and ask for approval when:**
- Pertinence assessment complete (Validation Gate 1)
- Integration design complete (Validation Gate 2)
- Quality gate fails (overlap, revert history, no gap)

**Principle**: Validate alignment at each gate to avoid over-engineering and wasted effort.

</decision_making>

<critical_rules>

1. **Pertinence Gate Required** - Must validate alignment and user approval before proceeding to design phase
2. **Architecture Compatibility Check** - Verify pattern fits existing project architecture
3. **YAGNI Enforcement** - Only evaluate features solving documented problems
4. **User Approval at Gate** - Stop and ask before proceeding from assessment to design

</critical_rules>

## Agent Usage

For analyzing project architecture compatibility, use exploration agents:

Delegate to a **codebase explorer** agent (fast, read-only):
> "Analyze project structure. Identify: component patterns, conventions, common sections. Report: how new patterns could integrate."

**When to use agents:**
- Understanding current project architecture
- Identifying integration points
- Discovering existing patterns
- Validating compatibility

**Stay inline for:**
- Web research (WebFetch/WebSearch)
- Pertinence assessment (Sequential Thinking)
- User interaction (AskUserQuestion)

## References

- Sequential Thinking MCP server - Analysis structuring (built-in)
- AskUserQuestion tool - User approval gates (built-in)

<success_criteria>

- [ ] Phase 0 context loaded (planning doc, archive, project architecture)
- [ ] Phase 1 research finished (WebFetch/WebSearch complete)
- [ ] Phase 2 pertinence scored (4-factor evaluation with High/Medium/Low)
- [ ] Quality gates passed (no overlap, no revert, solves gap, compatible)
- [ ] User approval obtained at Gate 1 (if proceeding to design)
- [ ] Design document created (if Gate 1 approved)
- [ ] Initiative created (if Gate 2 approved)

</success_criteria>
