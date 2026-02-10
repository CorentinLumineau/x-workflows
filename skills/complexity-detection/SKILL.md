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

### Intent Detection Patterns

```yaml
workflow_patterns:
  APEX:
    - "add", "implement", "feature", "build", "create"
    - "refactor", "enhance", "improve", "update"
    - "integrate", "connect", "setup"

  ONESHOT:
    - "fix typo", "quick", "simple", "minor"
    - "rename", "small change", "trivial"

  DEBUG:
    - "bug", "broken", "error", "crash", "failing"
    - "intermittent", "doesn't work", "issue"
    - "troubleshoot", "investigate", "debug"

  BRAINSTORM:
    - "discuss", "explore", "options", "should we"
    - "architecture", "design", "approach"
    - "research", "compare", "evaluate"
```

### Intent → Skill Mapping

| Intent | Complexity | Route |
|--------|------------|-------|
| APEX + LOW | Direct | x-implement |
| APEX + MEDIUM | Plan first | x-plan → x-implement |
| APEX + HIGH | Initiative | **x-initiative** → full APEX flow |
| APEX + CRITICAL | Initiative | **x-initiative** → full APEX flow + security review |
| ONESHOT | Always LOW | x-implement (autonomous) |
| DEBUG + LOW | Direct | x-implement fix |
| DEBUG + MEDIUM | Investigate | x-troubleshoot debug |
| DEBUG + HIGH | Initiative | **x-initiative** → x-troubleshoot |
| DEBUG + CRITICAL | Initiative | **x-initiative** → x-troubleshoot + security review |
| BRAINSTORM + LOW | Quick answer | x-research ask |
| BRAINSTORM + MEDIUM | Deep dive | x-research deep |
| BRAINSTORM + HIGH | Initiative | **x-initiative** → x-plan brainstorm |
| BRAINSTORM + CRITICAL | Initiative | **x-initiative** → x-plan brainstorm + security review |

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
| `Override` | /x-* command | User can bypass auto-routing with explicit command |

### Examples

**Example: Critical migration**
```
Input: "Migrate from Express to Fastify"
Complexity: CRITICAL | Mental Model: APEX
Agent: x-refactorer (sonnet)
Variant: x-designer (opus)
Chain: x-plan → x-implement → x-verify
Multi-session: Yes (major framework change)
```

**Example: Low fix**
```
Input: "Fix typo in README"
Complexity: LOW | Mental Model: ONESHOT
Agent: main agent
Variant: none
Chain: x-implement
Multi-session: No
```

**Example: High intermittent bug**
```
Input: "Login crashes randomly on production"
Complexity: HIGH | Mental Model: DEBUG
Agent: x-debugger (sonnet)
Variant: x-debugger-deep (opus)
Chain: x-troubleshoot → x-fix
Multi-session: Yes (intermittent + environment-specific)
```

---

## Complexity Tiers

### Tier 1: LOW (→ fix mode)

**Characteristics:**
- Clear error message with obvious solution
- Single file/component involved
- No cross-layer debugging needed
- Quick patch possible

**Detection Patterns:**
- "typo", "spelling", "rename"
- "missing import", "undefined variable"
- "syntax error"
- Compilation/lint errors with line numbers
- Simple test assertion failures
- "TypeError", "ReferenceError" with clear stack

**Time Estimate:** <30 minutes

### Tier 2: MEDIUM (→ debug mode)

**Characteristics:**
- Traceable error through known paths
- Standard debugging workflow
- Single layer or 2-3 components
- Requires understanding code flow

**Detection Patterns:**
- "how does X work?"
- "trace", "flow", "understand"
- Error in business logic (not infrastructure)
- Test failures with unclear assertions
- "sometimes fails", but reproducible
- Standard exceptions with meaningful context

**Time Estimate:** 30 min - 2 hours

### Tier 3: HIGH (→ troubleshoot mode)

**Characteristics:**
- Root cause unclear
- Multiple possible causes
- Requires user context gathering
- May need instrumentation/logging
- Cross-layer or multi-service

**Detection Patterns:**
- "intermittent", "random", "sometimes"
- "no error message", "silent failure"
- "works locally but not in production"
- Performance issues, memory leaks
- Race conditions, timing issues
- "tried everything", "can't figure out"
- Multi-service or infrastructure issues

**Time Estimate:** 2+ hours

### Tier 4: CRITICAL (→ initiative + security review)

**Characteristics:**
- Multi-system, breaking-change, or security-critical tasks
- Requires coordinated changes across multiple services
- Breaking API contracts or data migrations
- Security vulnerabilities with active exploitation risk
- Compliance-critical changes (GDPR, SOC2, HIPAA)

**Detection Patterns:**
- "breaking change", "migration", "deprecation"
- "security vulnerability", "CVE", "exploit"
- "compliance", "audit", "regulatory"
- "production outage", "data loss risk"
- Multiple teams or services affected
- Rollback requires coordinated effort

**Time Estimate:** Multi-day, multi-session

## Assessment Algorithm

```
1. Check Tier 4 (CRITICAL):
   - Breaking change? → CRITICAL
   - Security vulnerability? → CRITICAL
   - Compliance-critical? → CRITICAL
   - Multi-system coordination? → CRITICAL

2. Check Tier 1 (LOW):
   - Has obvious solution? → LOW
   - Single file error? → LOW
   - Syntax/type error? → LOW

3. Check Tier 3 (HIGH):
   - Intermittent keywords? → HIGH
   - No error message? → HIGH
   - Environment-specific? → HIGH
   - Performance-related? → HIGH
   - Multiple services? → HIGH

4. Default to Tier 2 (MEDIUM)
```

## Decision Table

| Signal | Weight | Tier |
|--------|--------|------|
| "breaking change", "migration" | Strong | CRITICAL |
| "security vulnerability", "CVE" | Strong | CRITICAL |
| "compliance", "regulatory" | Strong | CRITICAL |
| Clear error + line number | Strong | LOW |
| "typo", "import", "undefined" | Strong | LOW |
| "how does", "trace", "understand" | Strong | MEDIUM |
| Error with stack trace | Medium | MEDIUM |
| "intermittent", "random" | Strong | HIGH |
| "no error", "silent" | Strong | HIGH |
| "performance", "slow", "memory" | Strong | HIGH |
| Environment-specific | Strong | HIGH |

## Confidence Scoring

When assessment is ambiguous (confidence < 70%), ask user:
- "Can you reproduce this consistently?"
- "Is there an error message?"
- "Does this happen in all environments?"
- "How many components are involved?"

## Escalation Paths

```
fix (LOW)
├─ Complexity > expected → Recommend debug
└─ Still stuck → Recommend troubleshoot

debug (MEDIUM)
├─ Simpler than expected → Can delegate to fix
└─ More complex → Recommend troubleshoot

troubleshoot (HIGH)
└─ Once root cause found → Delegate to fix or debug

critical (CRITICAL)
└─ Always requires initiative tracking + security review
```

## Examples

### Example 1: LOW (→ fix)
```
Input: "TypeError: Cannot read property 'name' of undefined at UserService.ts:45"
Assessment: LOW
- Clear error type (TypeError)
- Exact file and line
- Single point of failure
Route: fix mode
```

### Example 2: MEDIUM (→ debug)
```
Input: "User registration is failing but I don't understand why the validation rejects"
Assessment: MEDIUM
- Has error (validation failure)
- Needs code flow understanding
- Single feature, clear entry point
Route: debug mode
```

### Example 3: HIGH (→ troubleshoot)
```
Input: "Sometimes orders don't process. No error in logs. Works fine locally."
Assessment: HIGH
- Intermittent ("sometimes")
- No error message
- Environment-specific
Route: troubleshoot mode
```

### Example 4: CRITICAL (→ initiative + security review)
```
Input: "We need to migrate the auth system from sessions to JWT and update all 12 microservices"
Assessment: CRITICAL
- Breaking change across multiple services
- Security-critical (authentication)
- Multi-team coordination needed
Route: initiative mode + security review
```

## References

- @skills/agent-awareness/ - Agent delegation awareness and selection patterns
