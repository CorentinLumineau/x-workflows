# Mode: brainstorm

> **Invocation**: `/x-plan brainstorm` or `/x-plan brainstorm "topic"`
> **Legacy Command**: `/x:brainstorm`

<purpose>
Transform vague ideas into structured requirements through guided discovery. Extract requirements, identify constraints, and prioritize with Pareto focus.
</purpose>

## Behavioral Skills

This mode activates:
- `analysis` - Pareto prioritization
- `context-awareness` - Project context

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Idea structuring |
| `context7` | Reference implementations |

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 40%, context 30%, technical 10%, scope 15%, risk 5%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Undefined problem space, no success criteria, multiple stakeholders unspecified.

---

### Phase 1: Idea Capture

Start with open exploration by asking the user what they want to build:

<user_interaction type="structured_question" required="true" id="problem_type">

**Question**: What problem are you trying to solve?

| Option | Description |
|--------|-------------|
| New feature | Add new functionality to the system |
| Improvement | Enhance an existing feature |
| Integration | Connect with external systems |
| Performance | Optimize for speed or efficiency |

**Allow custom input**: Yes
**Multi-select**: No

</user_interaction>

Based on the response, gather more context:

<user_interaction type="freeform" required="true" id="problem_details">

**Question**: Describe the problem or idea in more detail. What would success look like?

</user_interaction>

---

### Phase 2: Requirements Discovery

<parallel_exploration max_agents="2">

Explore in parallel:

1. **Existing Patterns** - Search codebase for similar implementations or related code
2. **Best Practices** - Look up recommended approaches for this type of problem

</parallel_exploration>

For each idea, ask structured questions:

<user_interaction type="structured_question" required="true" id="functional_scope">

**Functional Requirements** - What should it do?

| Option | Description |
|--------|-------------|
| User-facing feature | Visible to end users |
| Internal tooling | Developer/admin functionality |
| API/Integration | Backend service or integration |
| Data processing | Data transformation or analytics |

**Multi-select**: Yes

</user_interaction>

<user_interaction type="structured_question" required="false" id="nonfunctional_needs">

**Non-Functional Requirements** - What qualities matter most?

| Option | Description |
|--------|-------------|
| Performance | Speed and responsiveness |
| Security | Authentication, authorization, data protection |
| Scalability | Handle growth in users/data |
| Reliability | Uptime and error handling |

**Multi-select**: Yes

</user_interaction>

<user_interaction type="structured_question" required="false" id="constraints">

**Constraints** - What limitations exist?

| Option | Description |
|--------|-------------|
| Time constraint | Deadline pressure |
| Technology constraint | Must use specific stack |
| Budget constraint | Limited resources |
| Compatibility | Must work with existing systems |

**Multi-select**: Yes

</user_interaction>

<checkpoint id="requirements_gathered" phase="2">

**Requirements Gathered**

Summary of discovered requirements:
- Problem type: {problem_type response}
- Details: {problem_details response}
- Functional scope: {functional_scope response}
- Non-functional needs: {nonfunctional_needs response}
- Constraints: {constraints response}

**Confirm understanding before prioritization?**

</checkpoint>

---

### Phase 3: Prioritization

<deep_reasoning topic="requirement_prioritization">

Apply Pareto principle (80/20) to prioritize requirements:

1. Identify the 20% of requirements that deliver 80% of the value
2. Classify each requirement:

| Priority | Criteria |
|----------|----------|
| **Must Have** | Core functionality, no workarounds exist |
| **Should Have** | Important but not critical for MVP |
| **Could Have** | Nice to have, enhances experience |
| **Won't Have** | Out of scope for this iteration |

Consider:
- User impact vs implementation effort
- Dependencies between requirements
- Risk if not implemented

</deep_reasoning>

<user_interaction type="confirmation" required="true" id="priority_confirmation">

**Proposed Prioritization**:

**Must Have (MVP)**:
- {list must-have requirements}

**Should Have**:
- {list should-have requirements}

**Could Have**:
- {list could-have requirements}

**Won't Have (Out of Scope)**:
- {list deferred requirements}

Does this prioritization look correct?

</user_interaction>

---

### Phase 4: Structure Output

Create structured requirements document:

```markdown
## Problem Statement
{Clear description of the problem from user input}

## Requirements

### Must Have
- [ ] Requirement 1
- [ ] Requirement 2

### Should Have
- [ ] Requirement 3

### Could Have
- [ ] Requirement 4

## Constraints
- Constraint 1
- Constraint 2

## Success Metrics
- Metric 1: Target
- Metric 2: Target
```

<checkpoint id="document_complete" phase="4">

**Requirements Document Complete**

The structured requirements have been created above.

**Review and confirm before proceeding to next workflow?**

</checkpoint>

---

### Phase 5: Workflow Transition

<user_interaction type="structured_question" required="true" id="next_step">

**Question**: Requirements captured. What's next?

| Option | Description |
|--------|-------------|
| /x-plan design (Recommended) | Design the technical solution |
| /x-plan | Create detailed implementation plan |
| /x-implement | Start implementing immediately |
| Stop | Review requirements first, continue later |

**Multi-select**: No

</user_interaction>

</instructions>

## Brainstorming Techniques

### 5 Whys
Ask "why?" five times to find root cause.

### User Stories
"As a [user], I want to [action] so that [benefit]"

### Impact Mapping
Goal → Actors → Impacts → Deliverables

<critical_rules>

## Critical Rules

1. **No Judgement** - Capture all ideas first
2. **Ask Why** - Understand the real problem
3. **Be Specific** - Vague requirements fail
4. **Prioritize Ruthlessly** - 20% delivers 80% value

</critical_rules>

<decision_making>

## Decision Making

**Explore more when**:
- Requirements unclear
- Multiple stakeholders
- Complex domain

**Move to planning when**:
- Core requirements clear
- Priorities established
- Constraints understood

</decision_making>

## References

- @skills/meta-analysis/ - Pareto prioritization and analysis patterns

<success_criteria>

## Success Criteria

- [ ] Problem clearly defined
- [ ] Requirements captured
- [ ] Priorities established
- [ ] Next step presented

</success_criteria>
