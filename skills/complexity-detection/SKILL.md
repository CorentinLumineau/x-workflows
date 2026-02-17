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

  GIT:
    - "pr", "pull request", "create pr", "merge pr"
    - "merge", "review pr", "check ci"
    - "issue", "create issue", "implement issue"
    - "release", "tag", "create release"
    - "ci", "pipeline", "checks", "build status"
    - "conflict", "resolve conflict"
    - "cleanup", "stale branches", "branch cleanup"
    - "sync", "mirror", "push to remotes"
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
| GIT + "pr" (create) | Direct | git-create-pr |
| GIT + "pr" (review) | Direct | git-review-pr |
| GIT + "pr" (merge) | Direct | git-merge-pr |
| GIT + "ci"/"checks" | Direct | git-check-ci |
| GIT + "issue" (create) | Direct | git-create-issue |
| GIT + "issue" (implement) | Planning | git-implement-issue |
| GIT + "release" | Direct | git-create-release |
| GIT + "conflict" | Direct | git-resolve-conflict |
| GIT + "cleanup"/"branches" | Direct | git-cleanup-branches |

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

## Chaining Matrix Awareness

### Purpose

Resolve valid next-step workflows by reading chain metadata from skill frontmatter. This implements the **chain resolver** — the data itself will be populated in M5 when all workflow skills have `chains-to` and `chains-from` fields.

### Chain Resolution Algorithm

```
1. Read current skill's frontmatter (SKILL.md)
2. Extract chains-to and chains-from arrays
3. Combine with named path templates from WORKFLOW_CHAINS.md
4. Recommend valid next steps based on:
   - Current phase completion
   - Workflow intent (APEX/DEBUG/BRAINSTORM)
   - Complexity tier
   - Chain compatibility
```

### Chain Metadata Schema

```yaml
---
name: x-implement
chains-to:
  - x-review
  - x-test
  - git-create-pr
chains-from:
  - x-plan
  - x-analyze
  - git-implement-issue
---
```

### Named Path Templates

Reference `WORKFLOW_CHAINS.md` for pre-defined workflow sequences:

| Path Name | Chain | Use Case |
|-----------|-------|----------|
| apex-full | x-analyze → x-plan → x-implement → x-review | Complete feature workflow |
| debug-flow | x-troubleshoot → x-fix → x-review | Error resolution workflow |
| quick-fix | x-implement → x-review | Fast iteration for simple changes |
| research-to-build | x-research → x-plan → x-implement | Exploration → implementation |
| git-pr-flow | x-implement → git-create-pr → git-merge-pr | PR creation workflow |
| git-issue-flow | git-implement-issue → x-review → git-create-pr | Issue implementation workflow |

### Next Step Resolution

```
Given: User completed x-implement
Current skill: x-implement
chains-to: [x-review, x-test, git-create-pr]

Recommendations:
1. Primary: x-review (validate implementation)
2. Alternative: x-test (run test suite)
3. Finalize: git-create-pr (create PR for review)

Output:
┌─────────────────────────────────────────────┐
│ Next Steps                                  │
│                                             │
│ 1. x-review (recommended)                   │
│    → Validate implementation correctness    │
│                                             │
│ 2. x-test (optional)                        │
│    → Run comprehensive test suite           │
│                                             │
│ 3. git-create-pr (finalize)                 │
│    → Create PR for code review              │
└─────────────────────────────────────────────┘
```

### Chain Validation

```
Before suggesting next step:
1. Check if target skill exists in skills/ directory
2. Verify target skill has current skill in chains-from
3. Validate bidirectional compatibility
4. If chain is invalid → log warning, skip suggestion

Example validation:
  x-implement chains-to: x-review ✓
  x-review chains-from: x-implement ✓
  Bidirectional: VALID
```

### Integration with Complexity Detection

```
Combine chain resolution with complexity tier:

Example: APEX + MEDIUM complexity
1. Detect mental model: APEX
2. Assess complexity: MEDIUM
3. Resolve initial chain: x-plan → x-implement
4. After x-implement completes:
   - Read x-implement chains-to
   - Recommend: x-review (from chains-to)
   - User can override with explicit command

Example: GIT intent + "pr"
1. Detect mental model: GIT
2. Resolve direct route: git-create-pr
3. After git-create-pr completes:
   - Read git-create-pr chains-to
   - Recommend: git-review-pr or git-merge-pr
```

### Fallback Behavior

```
If chain metadata is missing or incomplete:
1. Fall back to complexity-based routing
2. Use mental model defaults (APEX → plan → implement → review)
3. Log: "Chain metadata unavailable, using default routing"
4. Continue workflow with degraded guidance

This ensures the resolver works NOW (M4) while chain data is populated in M5.
```

### Status

**Implementation**: This section implements the chain resolver logic.

**Data population**: M5 will populate `chains-to` and `chains-from` in all workflow skill frontmatter.

**Current behavior**: Resolver falls back to complexity-based routing until M5 completes chain metadata population.

---

## References

- @skills/agent-awareness/ - Agent delegation awareness and selection patterns
- WORKFLOW_CHAINS.md - Named path templates and chain definitions (populated in M5)
