---
name: complexity-detection
description: Intelligent routing for all workflows based on complexity and intent.
license: Apache-2.0
allowed-tools: Read Grep Glob
metadata:
  author: ccsetup contributors
  version: "2.1.0"
  category: behavioral
  user-invocable: false
---

# Complexity Detection

Intelligent routing for all workflows based on complexity and intent.

## Purpose

Extract complexity detection logic into a shared skill to ensure consistent assessment and DRY compliance across all workflows. This skill:

1. **Detects workflow intent** → Routes to correct mental model (APEX/ONESHOT/DEBUG/BRAINSTORM)
2. **Assesses complexity tier** → Determines appropriate skill and mode
3. **Auto-triggers x-initiative** → For complex multi-session tasks

---

## Workflow Intent Detection

### The 4 Mental Models

| Mental Model | Intent | Description |
|--------------|--------|-------------|
| **APEX** | Build/Create | Systematic: Analyze → Plan → Execute → Verify |
| **ONESHOT** | Quick Fix | Ultra-fast for trivial changes |
| **DEBUG** | Fix Error | Error resolution and troubleshooting |
| **BRAINSTORM** | Explore/Research | Research and architectural decisions |

> See [references/intent-routing.md](references/intent-routing.md) for intent detection patterns and intent-to-skill mapping table.

---

## x-initiative Auto-Trigger

### Automatic Activation Conditions

x-initiative is **automatically suggested** when ANY of these conditions are met:

```yaml
initiative_triggers:
  complexity_tier: 3  # HIGH/CRITICAL tier always triggers

  keywords:
    - "migrate", "migration"
    - "refactor entire", "major refactor"
    - "redesign", "rewrite"
    - "large-scale", "major change"
    - "multi-phase", "multi-day"

  scope_signals:
    - Estimated >5 files affected
    - Multiple directories/modules involved
    - Cross-cutting concerns

  duration_signals:
    - "will take time", "over several sessions"
    - Estimated >4 hours
    - Multiple milestones mentioned
```

### Auto-Suggestion Output Format

When routing is determined, output:

```
┌─────────────────────────────────────────────────┐
│ Complexity: [TIER] | Mental Model: [MODEL]      │
│                                                 │
│ Agent: [recommended-agent] (model: [tier])      │
│ Variant: [alternative-agent] (model: [tier])    │
│ Chain: [skill1] → [skill2] → [skill3]           │
│                                                 │
│ Multi-session: [Yes/No]                         │
│ Team: [pattern] ([size] agents) | none          │
│ Override: use explicit /x-* command             │
└─────────────────────────────────────────────────┘
```

### Advisory Output Fields

| Field | Values | Purpose |
|-------|--------|---------|
| `Complexity` | LOW / MEDIUM / HIGH / CRITICAL | Tier assessment driving model and agent selection |
| `Mental Model` | APEX / ONESHOT / DEBUG / BRAINSTORM | Workflow intent determining skill chain |
| `Agent` | Primary agent recommendation | Best-fit agent from agent-awareness catalog |
| `Variant` | Alternative agent (cheaper or deeper) | Cost optimization or capability escalation |
| `Chain` | Skill sequence (→ separated) | Recommended workflow skill execution order |
| `Multi-session` | Yes / No | Whether x-initiative tracking is needed |
| `Team` | Pattern (N agents) / none | Agent Team advisory from team triggers below |
| `Override` | /x-* command | User can bypass auto-routing with explicit command |

### Team Triggers

The Team field is advisory — it suggests when Agent Teams would benefit the task.

| Condition | Team Pattern | Size |
|-----------|-------------|------|
| HIGH complexity + multi-domain scope | Review Team or Feature Team | 2-4 |
| HIGH complexity + 10+ files affected | Refactor Team | 2-3 |
| HIGH complexity + 3+ hypotheses needed | Debug Team | 2-3 |
| Any complexity + research-heavy task | Research Team | 2-3 |
| LOW/MEDIUM + single domain | none | — |

Team is `none` by default. Only populated when parallelism or inter-agent coordination provides clear value over subagent delegation.

### Examples

**Example: Critical migration**
```
Input: "Migrate from Express to Fastify"
Complexity: CRITICAL | Mental Model: APEX
Agent: x-refactorer (sonnet)
Variant: x-designer (opus)
Chain: x-plan → x-implement → x-review
Multi-session: Yes (major framework change)
Team: Refactor Team (3 agents)
```

**Example: Low fix**
```
Input: "Fix typo in README"
Complexity: LOW | Mental Model: ONESHOT
Agent: main agent
Variant: none
Chain: x-implement
Multi-session: No
Team: none
```

**Example: High intermittent bug**
```
Input: "Login crashes randomly on production"
Complexity: HIGH | Mental Model: DEBUG
Agent: x-debugger (sonnet)
Variant: x-debugger-deep (opus)
Chain: x-troubleshoot → x-fix
Multi-session: Yes (intermittent + environment-specific)
Team: Debug Team (3 agents)
```

---

## Complexity Tiers

> See [references/complexity-tiers.md](references/complexity-tiers.md) for detailed tier definitions (LOW/MEDIUM/HIGH/CRITICAL), detection patterns, assessment algorithm, decision table, confidence scoring, escalation paths, and examples.

**Quick reference:**

| Tier | Mode | Time Estimate |
|------|------|---------------|
| LOW | fix | <30 minutes |
| MEDIUM | debug | 30 min - 2 hours |
| HIGH | troubleshoot | 2+ hours |
| CRITICAL | initiative + security review | Multi-day |

---

## Chaining Matrix Awareness

> See [references/chaining-matrix.md](references/chaining-matrix.md) for chain resolution algorithm, metadata schema, named path templates, validation logic, and fallback behavior.

**Key concept**: After each workflow step completes, read the skill's `chains-to` frontmatter to recommend valid next steps. Falls back to complexity-based routing when chain metadata is unavailable.

---

## Agent Guidance Output

After complexity assessment, emit additional guidance for agent selection and team composition:

| Field | Source | Description |
|-------|--------|-------------|
| `agent_guidance.recommended` | Agent capability matrix | Primary agent suited for this task |
| `agent_guidance.variant` | Variant selection criteria | Cost-optimized alternative agent |
| `agent_guidance.model` | Complexity tier mapping | Model tier recommendation (haiku/sonnet/opus) |
| `agent_guidance.team_pattern` | Team triggers + parallelizability | Team pattern if beneficial, else "none" |
| `agent_guidance.reasoning` | Assessment output | Why this recommendation was made |

### Complexity-to-Model Mapping

| Complexity | Primary Model | Explorer Model | Rationale |
|------------|---------------|----------------|-----------|
| LOW | haiku | haiku | Fast and cheap for simple tasks |
| MEDIUM | sonnet | haiku | Balanced reasoning for standard tasks |
| HIGH | sonnet | sonnet | Deep analysis, opus for architecture decisions |
| CRITICAL | opus | sonnet | Maximum reasoning + security review |

### Complexity-to-Team Mapping

| Complexity | Parallelizable? | Recommended Team | Pattern |
|------------|----------------|------------------|---------|
| LOW | No | none | Direct delegation |
| MEDIUM | Maybe | none (default) | Subagent delegation |
| HIGH + multi-domain | Yes | Review/Feature/Debug Team | 2-4 agents |
| CRITICAL | Yes | Feature Team + Security | 3-5 agents |

Agent guidance fields are written to the routing context (see below) and consumed by x-auto and agent-awareness for delegation decisions.

---

## Routing Context Contract

The routing context is a session-ephemeral advisory structure produced by complexity-detection and consumed by x-auto, interview, and agent-awareness:

| Field | Type | Description |
|-------|------|-------------|
| intent | string | Classified user intent (implement, fix, refactor, review, deploy, research) |
| complexity-tier | 1-5 | Assessed complexity level |
| recommended-agent | string | Suggested agent from agent-awareness catalog |
| chain | string[] | Suggested skill chain sequence |
| multi-session-flag | boolean | Whether task likely exceeds single session |
| confidence | 0-100 | Assessment confidence percentage |
| agent-guidance.model | string | Recommended model tier (haiku/sonnet/opus) |
| agent-guidance.variant | string | Cost-optimized variant agent (or "none") |
| agent-guidance.team-pattern | string | Recommended team pattern (or "none") |
| agent-guidance.reasoning | string | Brief rationale for agent/model selection |

This contract is advisory — downstream consumers may override any field based on additional context.

---

## Routing Corrections Reader

At assessment start, read historical routing corrections to improve future routing accuracy:

1. **Read correction data**: Query Memory MCP entity `"delegation-log"` for `routing_correction` observations
2. **Parse corrections**: Extract `{suggested_workflow → user_chosen_workflow}` pairs grouped by intent type
3. **Build frequency table**: Count corrections per `{intent_type → preferred_workflow}` pair
4. **Apply adjustment**: If count ≥ 3 for same pattern, add advisory signal:
   ```
   Routing adjustment: {intent_type} historically routed to {preferred} (corrected {count} times)
   ```
5. **Advisory is ADDITIVE** — never overrides explicit complexity signals, only adds context
6. **If Memory MCP unavailable**: Skip correction read silently (graceful degradation)
7. **If auto-memory `routing-corrections.md` exists**: Read as fallback when Memory MCP unavailable

### Correction Data Sources

| Source | Priority | Availability |
|--------|----------|-------------|
| Memory MCP `delegation-log` entity | Primary | Requires MCP |
| Auto-memory `routing-corrections.md` | Fallback | Always available |

At workflow completion, x-auto writes correction summary to auto-memory topic file `routing-corrections.md` for cross-session persistence without MCP dependency.

---

## References

- @skills/agent-awareness/ - Agent delegation awareness and selection patterns
- WORKFLOW_CHAINS.md - Named path templates and chain definitions (populated in M5)
