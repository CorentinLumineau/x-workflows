---
name: complexity-detection
description: Intelligent routing for all workflows based on complexity and intent.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob
metadata:
  author: ccsetup contributors
  version: "2.0.0"
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
| APEX + SIMPLE | Direct | x-implement |
| APEX + MODERATE | Plan first | x-plan → x-implement |
| APEX + COMPLEX | Initiative | **x-initiative** → full APEX flow |
| ONESHOT | Always SIMPLE | x-implement (autonomous) |
| DEBUG + SIMPLE | Direct | x-implement fix |
| DEBUG + MODERATE | Investigate | x-troubleshoot debug |
| DEBUG + COMPLEX | Initiative | **x-initiative** → x-troubleshoot |
| BRAINSTORM + SIMPLE | Quick answer | x-research ask |
| BRAINSTORM + MODERATE | Deep dive | x-research deep |
| BRAINSTORM + COMPLEX | Initiative | **x-initiative** → x-plan brainstorm |

---

## x-initiative Auto-Trigger

### Automatic Activation Conditions

x-initiative is **automatically suggested** when ANY of these conditions are met:

```yaml
initiative_triggers:
  complexity_tier: 3  # COMPLEX tier always triggers

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
│ Detected: [WORKFLOW] | Complexity: [TIER]       │
│ → Recommended: /x-[skill] [mode]                │
│ → Multi-session: [Yes/No]                       │
│                                                 │
│ Override: use explicit /x-* command             │
└─────────────────────────────────────────────────┘
```

### Examples

**Example: Complex migration**
```
Input: "Migrate from Express to Fastify"
Detected: APEX | Complexity: COMPLEX
→ Recommended: /x-initiative → /x-implement migrate
→ Multi-session: Yes (major framework change)
```

**Example: Simple fix**
```
Input: "Fix typo in README"
Detected: ONESHOT | Complexity: SIMPLE
→ Recommended: /x-implement (autonomous)
→ Multi-session: No
```

**Example: Intermittent bug**
```
Input: "Login crashes randomly on production"
Detected: DEBUG | Complexity: COMPLEX
→ Recommended: /x-initiative → /x-troubleshoot
→ Multi-session: Yes (intermittent + environment-specific)
```

---

## Complexity Tiers

### Tier 1: Simple (→ fix mode)

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

### Tier 2: Moderate (→ debug mode)

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

### Tier 3: Complex (→ troubleshoot mode)

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

## Assessment Algorithm

```
1. Check Tier 1 (Simple):
   - Has obvious solution? → SIMPLE
   - Single file error? → SIMPLE
   - Syntax/type error? → SIMPLE

2. Check Tier 3 (Complex):
   - Intermittent keywords? → COMPLEX
   - No error message? → COMPLEX
   - Environment-specific? → COMPLEX
   - Performance-related? → COMPLEX
   - Multiple services? → COMPLEX

3. Default to Tier 2 (Moderate)
```

## Decision Table

| Signal | Weight | Tier |
|--------|--------|------|
| Clear error + line number | Strong | Simple |
| "typo", "import", "undefined" | Strong | Simple |
| "how does", "trace", "understand" | Strong | Moderate |
| Error with stack trace | Medium | Moderate |
| "intermittent", "random" | Strong | Complex |
| "no error", "silent" | Strong | Complex |
| "performance", "slow", "memory" | Strong | Complex |
| Environment-specific | Strong | Complex |

## Confidence Scoring

When assessment is ambiguous (confidence < 70%), ask user:
- "Can you reproduce this consistently?"
- "Is there an error message?"
- "Does this happen in all environments?"
- "How many components are involved?"

## Escalation Paths

```
fix (Tier 1)
├─ Complexity > expected → Recommend debug
└─ Still stuck → Recommend troubleshoot

debug (Tier 2)
├─ Simpler than expected → Can delegate to fix
└─ More complex → Recommend troubleshoot

troubleshoot (Tier 3)
└─ Once root cause found → Delegate to fix or debug
```

## Examples

### Example 1: Simple (→ fix)
```
Input: "TypeError: Cannot read property 'name' of undefined at UserService.ts:45"
Assessment: SIMPLE
- Clear error type (TypeError)
- Exact file and line
- Single point of failure
Route: fix mode
```

### Example 2: Moderate (→ debug)
```
Input: "User registration is failing but I don't understand why the validation rejects"
Assessment: MODERATE
- Has error (validation failure)
- Needs code flow understanding
- Single feature, clear entry point
Route: debug mode
```

### Example 3: Complex (→ troubleshoot)
```
Input: "Sometimes orders don't process. No error in logs. Works fine locally."
Assessment: COMPLEX
- Intermittent ("sometimes")
- No error message
- Environment-specific
Route: troubleshoot mode
```
