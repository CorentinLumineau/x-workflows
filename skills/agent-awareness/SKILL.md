---
name: agent-awareness
description: Agent delegation awareness with catalog, decision matrix, and patterns. Auto-triggered.
license: Apache-2.0
allowed-tools:
  - Read
mcp:
  preferred:
    - memory
  triggers:
    memory: "recalling previous agent delegation decisions"
metadata:
  author: ccsetup contributors
  version: "2.0.0"
  category: behavioral
  user-invocable: false
---

# Agent Awareness v2.0.0

<purpose>
Behavioral skill providing awareness of available specialized agents and delegation patterns.
This skill is auto-loaded at session start and influences agent delegation decisions throughout the session.

**This is a behavioral skill** - it should NOT be added to commands-registry.yml.
</purpose>

<activation_triggers>
This skill auto-activates via context-awareness at session start.
Agent suggestions appear when task complexity matches agent specialization.
</activation_triggers>

## Agent Catalog

### Available Specialized Agents

| Agent | Specialization | Model | Use When |
|-------|----------------|-------|----------|
| `x-reviewer` | Code review, SOLID analysis | sonnet | Code modifications complete, pre-merge |
| `x-security-reviewer` | Security audit, OWASP | sonnet | Security-sensitive code, auth flows |
| `x-deployer` | Deployment verification | sonnet | Release, deployment, infrastructure |
| `x-debugger` | Root cause analysis | sonnet | Complex bugs, race conditions |
| `x-tester` | Test execution | sonnet | Test failures, coverage gaps |
| `x-doc-writer` | Documentation generation | haiku | Generating/updating docs |
| `x-explorer` | Fast codebase exploration | haiku | Quick searches, understanding structure |
| `x-refactorer` | Safe refactoring | sonnet | SOLID improvements, cleanup |
| `x-designer` | Architecture design, system modeling | opus | Complex architecture decisions, system design |
| `x-debugger-deep` | Deep root cause analysis | opus | Elusive bugs, cross-service, performance |
| `x-tester-fast` | Quick test validation | haiku | Fast smoke tests, quick verification |
| `x-reviewer-quick` | Rapid code scan | haiku | Quick sanity check, low-risk changes |

> See [references/capability-matrix.md](references/capability-matrix.md) for the full capability grid and team composition patterns.

## Role Resolution Table

When skills reference generic roles, resolve to concrete agents using this table:

| Generic Role | Agent | Model |
|-------------|-------|-------|
| codebase explorer | x-explorer | haiku |
| test runner | x-tester | sonnet |
| fast test runner | x-tester-fast | haiku |
| code reviewer | x-reviewer | sonnet |
| quick reviewer | x-reviewer-quick | haiku |
| security auditor | x-security-reviewer | sonnet |
| documentation writer | x-doc-writer | haiku |
| debugger | x-debugger | sonnet |
| deep debugger | x-debugger-deep | opus |
| deployment verifier | x-deployer | sonnet |
| refactoring agent | x-refactorer | sonnet |
| architect | x-designer | opus |

### Resolution Rules

1. Skills use **generic role names** (left column) in their body text
2. This table resolves roles to **concrete agents** at runtime
3. If a skill says "delegate to a **codebase explorer**", use `x-explorer`
4. If no matching role exists, use the main agent or a general-purpose agent

## Complexity Integration

Agent-awareness consumes the full routing context from complexity-detection, including the `agent-guidance` fields.

### Signal-to-Agent Mapping

| Complexity Signal | Agent Selection | Model | Team? |
|------------------|-----------------|-------|-------|
| LOW + any intent | Cheapest capable variant | haiku | No |
| MEDIUM + implement | x-refactorer or main | sonnet | No |
| MEDIUM + review | x-reviewer-quick first | haiku -> sonnet | No |
| HIGH + implement | x-refactorer | sonnet | Maybe (Feature Team) |
| HIGH + debug | x-debugger | sonnet | Maybe (Debug Team) |
| HIGH + review | x-reviewer + x-security-reviewer | sonnet | Yes (Review Team) |
| CRITICAL + any | x-designer or x-debugger-deep | opus | Yes |

### Model Tier Mapping

| Complexity | Default Model | Rationale |
|------------|---------------|-----------|
| LOW | haiku | Fast, cheap, sufficient |
| MEDIUM | sonnet | Balanced capability/cost |
| HIGH | opus | Maximum reasoning depth |
| CRITICAL | opus | Maximum reasoning depth + security review |

> See [references/delegation-patterns.md](references/delegation-patterns.md) for decision matrix, variant selection criteria, delegation patterns, escalation rules, and history tracking.

## Invocation Format

Skills request delegation using **generic roles**. The LLM resolves them via the Role Resolution Table above.

**In skill body** (agent-agnostic):
```markdown
Delegate to a **code reviewer** agent (sonnet):
> "Review the changes in src/auth/ for quality and SOLID compliance"
```

The LLM resolves generic roles to platform-specific agent invocations at runtime.

## Integration Points

### With context-awareness

This skill is loaded by context-awareness at session start to provide agent suggestions based on task type.

### With complexity-detection

Agent-awareness reads the enriched advisory output (Complexity, Agent, Variant, Chain, agent-guidance fields) and resolves agents via the Role Resolution Table.

### With commands

Commands can include `agent_hint` for soft suggestions:

```yaml
- name: review
  skill: x-review
  mode: review
  agent_hint: x-reviewer
```

## Feedback-Informed Selection

At session start, after loading agent catalog:

1. **Read feedback data**: `open_nodes(["delegation-log"])`
2. **Parse correction observations**: Extract `routing_correction` and `user_override` entries
3. **Build frequency table**: Count `{intent_type -> preferred_workflow/agent}` pairs
4. **If count >= 3 for same pattern**: Add advisory signal to routing recommendations
5. **Advisory is ADDITIVE** -- never overrides explicit complexity-detection routing
6. **If Memory MCP unavailable**: Skip feedback read silently (graceful degradation)

## Behavioral Rules

<behavioral_rules>
1. **Suggest, Don't Force**: Agent hints are suggestions, not requirements
2. **Match Complexity**: Only delegate when task matches agent specialization
3. **Prefer Parallel**: When reviewing both quality and security, use parallel agents
4. **Escalate Appropriately**: Security findings always go to x-security-reviewer
5. **Read-Only Awareness**: Know which agents cannot write (x-reviewer, x-explorer, x-reviewer-quick)
6. **Model Awareness**: Use haiku for fast exploration, sonnet for analysis, opus for deep reasoning
7. **Cost Consciousness**: Default to cheapest capable variant, escalate on failure
8. **Variant Awareness**: Consider variant agents before defaulting to standard agents
9. **Log Suggestions**: Record all delegation suggestions and user decisions
10. **Max-1 Escalation**: Never escalate more than once per delegation
11. **Feedback-Informed**: Consider user correction history when suggesting agents (advisory only)
</behavioral_rules>

## References

- @skills/complexity-detection/ - Shared complexity and intent detection logic

## When to Load References

- **For agent details**: See `references/agent-catalog.md`
- **For capability grid and teams**: See `references/capability-matrix.md`
- **For delegation patterns and escalation**: See `references/delegation-patterns.md`
