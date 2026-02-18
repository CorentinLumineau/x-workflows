---
name: x-auto
description: Use when you have a task but are unsure which workflow or command to use.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
  user-invocable: true
  argument-hint: "<task description>"
chains-to: []
chains-from:
  - skill: git-implement-issue
---

# /x-auto

> Intelligent task routing that assesses complexity and recommends the optimal workflow, agent, and chain.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | META (router) |
| **Phase** | routing |
| **Position** | 0 (entry point) |

**Flow**: **`x-auto`** -> `{routed workflow}`

## Intention

**Task**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Ask user: "What task would you like to work on?"
{{/if}}

## Behavioral Skills

This skill activates:
- `complexity-detection` - Workflow intent and complexity assessment
- `context-awareness` - Project context
- `agent-awareness` - Agent delegation and selection patterns

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Ambiguous routing decisions |

<instructions>

### Phase 1: Complexity Assessment

Activate `@skills/complexity-detection/` on the user's task description.

<deep-think purpose="complexity assessment" context="Classifying user task for optimal workflow routing">
Think step-by-step about: workflow intent (APEX/ONESHOT/DEBUG/BRAINSTORM), complexity tier (LOW/MEDIUM/HIGH/CRITICAL), recommended agent, variant selection, and suggested chain ordering.
</deep-think>

Produce a **routing context** with the following fields:
1. **intent** - Classified user intent (implement, fix, refactor, review, deploy, research)
2. **complexity-tier** - Assessed complexity level (1-5)
3. **recommended-agent** - Suggested agent from agent-awareness catalog
4. **chain** - Suggested skill chain sequence
5. **multi-session-flag** - Whether task likely exceeds single session
6. **confidence** - Assessment confidence percentage (0-100)
7. **agent-guidance** - Agent selection details from complexity-detection:
   - `model` - Recommended model tier (haiku/sonnet/opus)
   - `variant` - Cost-optimized variant agent (or "none")
   - `team-pattern` - Recommended team pattern (or "none")
   - `reasoning` - Brief rationale for selection

This routing context is passed to all downstream consumers (interview, agent-awareness) to avoid redundant re-assessment. The `agent-guidance` fields inform delegation decisions when spawning subagents or teams.

### Phase 2: Display Advisory

Present the assessment in a structured format:

```
## Auto-Route Assessment

| Dimension | Result |
|-----------|--------|
| **Workflow** | {APEX/ONESHOT/DEBUG/BRAINSTORM} |
| **Complexity** | {LOW/MEDIUM/HIGH/CRITICAL} |
| **Agent** | {recommended agent} |
| **Model** | {haiku/sonnet/opus} |
| **Variant** | {variant or "standard"} |
| **Chain** | {suggested command chain} |
| **Team** | {team pattern or "none"} |

### Rationale
{Brief explanation of why this routing was chosen}
```

### Phase 3: User Confirmation

**CRITICAL: NEVER auto-invoke a workflow without explicit user confirmation.**

<workflow-gate options="proceed,different-workflow,modify,cancel" default="proceed">
Present routing assessment and wait for explicit user choice before continuing.
</workflow-gate>

Present options:
1. **Proceed** - Execute the recommended workflow
2. **Different workflow** - Choose an alternative workflow
3. **Modify** - Adjust parameters (agent, variant, chain)
4. **Cancel** - Abort routing

Wait for explicit user choice before continuing.

### Phase 3b: Routing Correction Tracking

If user selects a DIFFERENT workflow than recommended (option 2: "Different workflow" or option 3: "Modify"):

Write routing correction to auto-memory topic file `routing-corrections.md`:
- Format: `"{timestamp}: {intent_type} — suggested {recommended}, user chose {user_choice}"`

Log: "Routing preference recorded for future sessions"

**Note**: Only record when user actively changes the recommendation, not when they accept it.

### Phase 4: Auto-Invoke Recommended Skill

After user confirms the recommended workflow:

1. **Validate confidence** — Reuse interview behavioral skill (Phase 0 gate)
   - Pass the routing context to interview so previously-assessed dimensions (intent, complexity-tier, recommended-agent) are not re-asked
   - All confidence dimensions must be at 100% to auto-invoke
   - If confidence < 100%: show manual commands instead (fallback)

2. **On 100% confidence + user approval**:
   - Auto-invoke the first skill in the confirmed chain
   - Pass context: `"{workflow_type} workflow for: {user request}. Complexity: {tier}."`

3. **On rejection or low confidence**:
   - Show manual invocation commands (current behavior):
   ```
   Suggested next step: /x-{skill} {original task description}
   ```

</instructions>

See @skills/complexity-detection/ for routing classification.

See @skills/agent-awareness/ for agent selection.

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | Workflow selection confirmation |
| **High** | ALWAYS ASK | Agent override |
| **Medium** | ASK IF UNCERTAIN | Ambiguous intent classification |
| **Low** | PROCEED | Display assessment |

<human-approval-framework>

When approval needed, structure question as:
1. **Context**: Assessment summary with rationale
2. **Options**: Proceed / Different workflow / Modify / Cancel
3. **Recommendation**: Highlight the suggested path
4. **Escape**: "Cancel" option always available

**CRITICAL**: Workflow selection approval is required before invoking any downstream skill.

</human-approval-framework>

## Workflow Chaining

**Next Verb**: Determined by routing assessment.

| Trigger | Chain To | Auto? |
|---------|----------|-------|
| User confirms APEX | First verb in APEX chain | **HUMAN APPROVAL REQUIRED** |
| User confirms ONESHOT | `/x-fix` | **HUMAN APPROVAL REQUIRED** |
| User confirms DEBUG | `/x-troubleshoot` | **HUMAN APPROVAL REQUIRED** |
| User confirms BRAINSTORM | `/x-brainstorm` | **HUMAN APPROVAL REQUIRED** |

<workflow-chain on="proceed" skill="x-{confirmed-verb}" args="{workflow_type} workflow for: {user request}. Complexity: {tier}." />
<workflow-chain on="cancel" action="end" />

<chaining-instruction>

After user confirms a workflow:

1. Display: "Routing to {workflow}. Auto-invoking first skill..."
2. Invoke the first verb in the chain:
   - skill: "x-{confirmed-verb}"
   - args: "{workflow_type} workflow for: {user request}. Complexity: {tier}."
3. If user rejects or confidence < 100%: Show manual commands instead:
   - "Suggested next step: /x-{skill} {original task description}"

Example:
```
skill: "x-plan"
args: "APEX workflow for: add OAuth2 authentication. Complexity: HIGH."
```

</chaining-instruction>

<critical_rules>

1. **NEVER** auto-invoke a workflow without explicit user confirmation
2. **ALWAYS** display the assessment before asking for confirmation
3. **ALWAYS** present at minimum: Proceed / Different workflow / Cancel
4. If user provides no task description, ask for one before assessing
5. If complexity is ambiguous, default to the MORE cautious workflow
6. For CRITICAL complexity, always recommend the full APEX chain

</critical_rules>

## Examples

**Simple fix** - `/x-auto fix the typo in the README header`:
Routes to ONESHOT (LOW) -> `/x-fix` -> `/git-commit`. Standard agent.

**Complex feature** - `/x-auto add OAuth2 with Google and GitHub providers`:
Routes to APEX (HIGH) -> `/x-analyze` -> `/x-plan` -> [APPROVAL] -> `/x-implement` -> `/x-review` -> `/git-commit`. Agent: x-designer (opus) for design phase.

**Debugging** - `/x-auto investigate why the API returns 500 on /users`:
Routes to DEBUG (MEDIUM) -> `/x-troubleshoot` -> `/x-fix`. Agent: x-debugger (sonnet).

## Navigation

| Direction | Verb | When |
|-----------|------|------|
| Next (build) | `/x-analyze` or `/x-plan` | APEX workflow confirmed |
| Next (fix) | `/x-fix` | ONESHOT workflow confirmed |
| Next (debug) | `/x-troubleshoot` | DEBUG workflow confirmed |
| Next (explore) | `/x-brainstorm` | BRAINSTORM workflow confirmed |

## Success Criteria

- [ ] Task description obtained
- [ ] Complexity assessment completed
- [ ] Advisory displayed to user
- [ ] User confirmation received
- [ ] Downstream skill invocation suggested

## References

- @skills/complexity-detection/ - Shared complexity and intent detection logic
- @skills/agent-awareness/ - Agent delegation and selection patterns
- @skills/orchestration/ - Workflow orchestration patterns
