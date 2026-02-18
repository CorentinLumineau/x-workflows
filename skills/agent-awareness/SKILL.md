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

### Agent Capabilities Matrix

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                      AGENT CAPABILITY MATRIX                                            │
├─────────────────────┬─────┬──────┬───────┬──────┬──────┬──────┬─────┬──────┬──────┬───────┬──────┬──────┤
│ Capability          │ Rev │ Sec  │ Deploy│ Debug│ Test │ Doc  │ Exp │ Refac│ Desgn│ DbgDp │ TstFt│ RevQk│
├─────────────────────┼─────┼──────┼───────┼──────┼──────┼──────┼─────┼──────┼──────┼───────┼──────┼──────┤
│ Read code           │ ✅  │ ✅   │ ✅    │ ✅   │ ✅   │ ✅   │ ✅  │ ✅   │ ✅   │ ✅    │ ✅   │ ✅   │
│ Write code          │ ❌  │ ❌   │ ❌    │ ✅   │ ✅   │ ✅   │ ❌  │ ✅   │ ✅   │ ✅    │ ✅   │ ❌   │
│ Run tests           │ ✅  │ ❌   │ ✅    │ ✅   │ ✅   │ ❌   │ ❌  │ ✅   │ ❌   │ ✅    │ ✅   │ ✅   │
│ Execute bash        │ ✅  │ ✅   │ ✅    │ ✅   │ ✅   │ ❌   │ ❌  │ ✅   │ ✅   │ ✅    │ ✅   │ ✅   │
│ Security analysis   │ ⚡  │ ✅   │ ❌    │ ❌   │ ❌   │ ❌   │ ❌  │ ❌   │ ⚡   │ ❌    │ ❌   │ ❌   │
│ SOLID enforcement   │ ✅  │ ❌   │ ❌    │ ❌   │ ❌   │ ❌   │ ❌  │ ✅   │ ✅   │ ❌    │ ❌   │ ⚡   │
│ Deploy verification │ ❌  │ ❌   │ ✅    │ ❌   │ ❌   │ ❌   │ ❌  │ ❌   │ ❌   │ ❌    │ ❌   │ ❌   │
│ Architecture design │ ❌  │ ❌   │ ❌    │ ❌   │ ❌   │ ❌   │ ❌  │ ⚡   │ ✅   │ ❌    │ ❌   │ ❌   │
└─────────────────────┴─────┴──────┴───────┴──────┴──────┴──────┴─────┴──────┴──────┴───────┴──────┴──────┘
Legend: ✅ = Primary, ⚡ = Basic, ❌ = Not available
```

## Team Composition

### Team vs Subagent Decision Matrix

| Factor | Subagent | Agent Team |
|--------|----------|------------|
| Task independence | Independent, no coordination | Interdependent, need discussion |
| Communication | Result-only (return value) | Inter-agent messaging (SendMessage) |
| Parallelism | Sequential or fire-and-forget | True parallel with shared state |
| Cost model | 1 agent at a time | N agents simultaneously |
| Coordination | None needed | Shared task list, blocking dependencies |
| Best for | Focused single-domain work | Multi-domain, cross-cutting concerns |

**Rule of thumb**: If agents need to talk to each other, use a team. If they just return results, use subagents.

### Team Composition Patterns

| Pattern | Size | Agents | Use When |
|---------|------|--------|----------|
| **Research Team** | 2-3 | x-explorer (haiku) + general-purpose (sonnet) | Multi-perspective exploration, evidence gathering |
| **Feature Team** | 3-4 | x-refactorer (sonnet) + x-tester (sonnet) + x-reviewer (sonnet) | Multi-layer feature implementation with parallel testing |
| **Review Team** | 2-3 | x-reviewer (sonnet) + x-security-reviewer (sonnet) | Parallel quality + security analysis on large PRs |
| **Debug Team** | 2-3 | x-debugger (sonnet) + x-explorer (haiku) + x-tester (sonnet) | Parallel hypothesis testing with context gathering |
| **Refactor Team** | 2-3 | x-refactorer (sonnet) + x-tester (sonnet) + x-reviewer (sonnet) | Large-scale restructuring with continuous verification |

### Model Selection for Teammates

| Model | Role in Team | Use For |
|-------|-------------|---------|
| **Haiku** | Read-only workers | Exploration, scanning, pattern search |
| **Sonnet** | Implementation workers | Code changes, testing, reviewing, debugging |
| **Opus** | Never for teammates | Too expensive for parallel agents; use as lead only |

### Cost Awareness

- **Subagent**: 1 agent runs at a time; cost = sum of sequential runs
- **Team**: N agents run simultaneously; cost = N x parallel token usage
- Teams are 2-5x more expensive than subagents for equivalent work
- Use teams only when parallelism or coordination provides clear value
- Default to subagents; escalate to teams via complexity-detection advisory

See @skills/x-team/references/team-patterns.md for spawn templates and lifecycle details.

## Role Resolution Table

When skills reference generic roles, resolve to concrete agents using this table:

| Generic Role | Agent | Model | Capabilities |
|-------------|-------|-------|--------------|
| codebase explorer | x-explorer | haiku | Fast read-only file discovery and pattern search |
| test runner | x-tester | sonnet | Test execution, failure diagnosis, coverage improvement |
| fast test runner | x-tester-fast | haiku | Quick smoke tests, fast validation |
| code reviewer | x-reviewer | sonnet | Read-only quality analysis, best practices audit |
| quick reviewer | x-reviewer-quick | haiku | Rapid code scan, sanity check |
| security auditor | x-security-reviewer | sonnet | OWASP vulnerability detection, security compliance |
| documentation writer | x-doc-writer | haiku | Documentation generation, update, and sync |
| debugger | x-debugger | sonnet | Runtime error investigation, integration debugging |
| deep debugger | x-debugger-deep | opus | Elusive bugs, cross-service issues, performance analysis |
| deployment verifier | x-deployer | sonnet | Deployment verification, rollback assessment |
| refactoring agent | x-refactorer | sonnet | Safe code restructuring with zero-regression guarantee |
| architect | x-designer | opus | Architecture design, system modeling, trade-off analysis |

### Resolution Rules

1. Skills use **generic role names** (left column) in their body text
2. This table resolves roles to **concrete agents** at runtime
3. The LLM reads this table at session start and applies it to delegation requests
4. If a skill says "delegate to a **codebase explorer**", use `x-explorer`
5. If no matching role exists, use the main agent or a general-purpose agent

## Reading Complexity Assessment

When complexity-detection produces its advisory output, read the structured fields:

1. **Complexity + Mental Model** → Determines workflow chain
2. **Agent recommendation** → Primary delegation target
3. **Variant** → Cost optimization alternative
4. **Chain** → Workflow sequence to follow

### Model Tier Mapping

| Complexity | Default Model | Rationale |
|------------|---------------|-----------|
| LOW | haiku | Fast, cheap, sufficient |
| MEDIUM | sonnet | Balanced capability/cost |
| HIGH | opus | Maximum reasoning depth |
| CRITICAL | opus | Maximum reasoning depth + security review |

### Example: Reading Advisory Output

```
┌─────────────────────────────────────────────────┐
│ Complexity: HIGH | Mental Model: APEX            │
│                                                 │
│ Agent: x-refactorer (sonnet)                    │
│ Variant: x-designer (opus)                      │
│ Chain: x-plan → x-implement → x-review           │
│                                                 │
│ Multi-session: Yes                              │
│ Override: use explicit /x-* command             │
└─────────────────────────────────────────────────┘
```

**Interpretation:**
- Primary agent: delegate refactoring work to a **refactoring agent** (sonnet)
- If architecture decisions are needed: escalate to an **architect** (opus)
- Follow chain: plan first, then implement, then review
- Track via x-initiative (multi-session)

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

1. **Default to cheapest capable model** — Use haiku variants when task is low-risk
2. **Escalate on failure** — If haiku variant produces insufficient results, retry with sonnet
3. **Never under-resource critical paths** — Security, architecture, and deep debugging always use sonnet or opus
4. **Parallel cost savings** — Use haiku variants for parallel batch workers to reduce total cost

## Decision Matrix

### When to Delegate

| Task Type | Complexity | Recommended Agent | Variant | Rationale |
|-----------|------------|-------------------|---------|-----------|
| Code review | Low | x-reviewer-quick | x-reviewer | Quick scan sufficient for low-risk |
| Code review | Medium-High | x-reviewer | x-security-reviewer | Full analysis, escalate if security |
| Security review | Any | x-security-reviewer | — | Always full security analysis |
| Deployment | Any | x-deployer | — | Rollback planning, health checks |
| Bug fix (simple) | Low | main agent | — | Direct fix more efficient |
| Bug fix (complex) | High | x-debugger | x-debugger-deep | Hypothesis testing, isolation |
| Test failures | Low | x-tester-fast | x-tester | Quick validation first |
| Test failures | Medium-High | x-tester | — | Owns test execution, knows patterns |
| Documentation | Any | x-doc-writer | — | Consistent style, JSDoc expertise |
| Quick search | Low | x-explorer | — | Fast, uses haiku, read-only |
| Refactoring | Medium | x-refactorer | — | SOLID enforcement, safe changes |
| Architecture | High | x-designer | x-refactorer | System modeling, trade-offs |

### Complexity Indicators

**Low Complexity** (handle directly):
- Single file change
- Clear error message
- Known pattern fix
- < 30 minutes estimated

**Medium Complexity** (consider delegation):
- 2-5 files affected
- Requires investigation
- Pattern unclear
- 30 min - 2 hours estimated

**High Complexity** (delegate recommended):
- 5+ files affected
- Cross-cutting concerns
- Architecture impact
- > 2 hours estimated

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
1. Are tests failing? → Delegate to **test runner** agent
2. Is it a runtime bug? → Delegate to **debugger** agent
3. Is coverage issue? → Delegate to **test runner** agent
4. Is it architecture issue? → Main agent + planning
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

## Invocation Format

Skills request delegation using **generic roles**. The LLM resolves them via the Role Resolution Table above.

**In skill body** (agent-agnostic):
```markdown
Delegate to a **code reviewer** agent (sonnet):
> "Review the changes in src/auth/ for quality and SOLID compliance"
```

**The LLM resolves generic roles** to platform-specific agent invocations at runtime using whatever delegation mechanism the host platform provides (e.g., Task tool in Claude Code, agent spawning in other platforms).

## Integration Points

### With context-awareness

This skill is loaded by context-awareness at session start:

```markdown
Integration:
  - Load agent-awareness for agent catalog
  - Provide agent suggestions based on task type
```

### With complexity-detection

Agent-awareness reads the enriched advisory output from complexity-detection:

```markdown
complexity-detection outputs:
  Complexity: HIGH | Mental Model: APEX
  Agent: x-refactorer (sonnet)
  Variant: x-designer (opus)
  Chain: x-plan → x-implement → x-review

agent-awareness interprets:
  → Resolve "x-refactorer" via Role Resolution Table
  → Apply Variant Selection Criteria if conditions change
  → Follow Chain for workflow execution order
```

### With commands

Commands can include `agent_hint` for soft suggestions:

```yaml
# In commands-registry
- name: review
  skill: x-review
  mode: review
  agent_hint: x-reviewer  # Suggests delegation
```

## Variant Escalation Rules

When an agent delegation produces insufficient results, escalate to a more capable variant.

### Escalation Table

| Trigger Condition | From (current) | To (escalated) | Detection |
|-------------------|----------------|----------------|-----------|
| Tests still failing after fix attempt | x-tester-fast (haiku) | x-tester (sonnet) | Agent outcome: tests still red |
| Analysis shallow, issues found but not diagnosed | x-reviewer-quick (haiku) | x-reviewer (sonnet) | Agent flagged issues but no root cause |
| Complex codebase, need deeper exploration | x-explorer (haiku) | general-purpose (sonnet) | Agent returned insufficient context |
| Root cause not found after 2 hypotheses | x-debugger (sonnet) | x-debugger-deep (opus) | Agent exhausted hypothesis list |
| Architectural scope during refactoring | x-refactorer (sonnet) | x-designer (opus) | Task requires cross-service/system-level decisions |

### Escalation Protocol

1. **Detect trigger condition** from agent delegation outcome
2. **Log escalation** in delegation history (Memory MCP entity `"delegation-log"`):
   ```
   add_observations:
     entityName: "delegation-log"
     contents:
       - "escalation: {from_agent} ({from_model}) -> {to_agent} ({to_model}), reason: {trigger}, task: {task_type} at {timestamp}"
   ```
3. **Suggest or auto-escalate**:
   - If orchestration skill is active → auto-escalate (re-delegate to upgraded variant)
   - If not orchestrated → suggest escalation to user
4. **Max 1 escalation per delegation** — no recursive escalation loops
   - If escalated agent also fails → report to user, do NOT escalate further

### Escalation Decision Tree

```
Agent completes with insufficient result
        ↓
Check Escalation Table for matching trigger
        ↓
Match found? ────── No → Report result as-is
        │
        Yes
        ↓
Already escalated once? ── Yes → Report, suggest manual intervention
        │
        No
        ↓
Orchestration active? ── Yes → Auto-escalate (re-delegate)
        │
        No
        ↓
Suggest to user: "Escalate {from} to {to}?"
```

## Delegation History Tracking

When agent-awareness suggests a delegation:

### On Suggestion

Record the suggestion in delegation log:
```
add_observations:
  entityName: "delegation-log"
  contents:
    - "suggestion: {agent} ({model}) for {task_type} [{complexity}] at {timestamp}"
```

### On User Decision

Track if user accepted or overrode the suggestion:
```
add_observations:
  entityName: "delegation-log"
  contents:
    - "user_override: suggested {agent}, user chose {other_agent}"
    # OR
    - "user_accepted: {agent} for {task_type}"
```

### Acceptance Tracking

Store acceptance rate per agent-task combination to inform future suggestions:
- Track: `{agent} + {task_type} → accepted/overridden`
- Pattern: If user consistently overrides a suggestion, adjust future recommendations
- Data location: Memory MCP entity `"delegation-log"` (L3)

## Feedback-Informed Selection

At session start, after loading agent catalog:

1. **Read feedback data**: `open_nodes(["delegation-log"])`
2. **Parse correction observations**: Extract `routing_correction` and `user_override` entries
3. **Build frequency table**: Count `{intent_type → preferred_workflow/agent}` pairs
4. **If count ≥ 3 for same pattern**: Add advisory signal to routing recommendations:
   ```
   User preference detected: {intent_type} → {preferred} (overridden {count} times)
   ```
5. **Advisory is ADDITIVE** — never overrides explicit complexity-detection routing
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
10. **Max-1 Escalation**: Never escalate more than once per delegation — if upgraded agent also fails, report to user
11. **Feedback-Informed**: Consider user correction history when suggesting agents (advisory only, ≥3 corrections required)
</behavioral_rules>

## References

- @skills/complexity-detection/ - Shared complexity and intent detection logic

## When to Load References

- **For agent details**: See `references/agent-catalog.md`
