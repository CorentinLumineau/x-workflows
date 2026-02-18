# Complexity Tiers

Detailed tier definitions, detection patterns, assessment algorithm, and examples.

## Tier 1: LOW (-> fix mode)

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

## Tier 2: MEDIUM (-> debug mode)

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

## Tier 3: HIGH (-> troubleshoot mode)

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

## Tier 4: CRITICAL (-> initiative + security review)

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
   - Breaking change? -> CRITICAL
   - Security vulnerability? -> CRITICAL
   - Compliance-critical? -> CRITICAL
   - Multi-system coordination? -> CRITICAL

2. Check Tier 1 (LOW):
   - Has obvious solution? -> LOW
   - Single file error? -> LOW
   - Syntax/type error? -> LOW

3. Check Tier 3 (HIGH):
   - Intermittent keywords? -> HIGH
   - No error message? -> HIGH
   - Environment-specific? -> HIGH
   - Performance-related? -> HIGH
   - Multiple services? -> HIGH

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
+-- Complexity > expected -> Recommend debug
+-- Still stuck -> Recommend troubleshoot

debug (MEDIUM)
+-- Simpler than expected -> Can delegate to fix
+-- More complex -> Recommend troubleshoot

troubleshoot (HIGH)
+-- Once root cause found -> Delegate to fix or debug

critical (CRITICAL)
+-- Always requires initiative tracking + security review
```

## Examples

### Example 1: LOW (-> fix)
```
Input: "TypeError: Cannot read property 'name' of undefined at UserService.ts:45"
Assessment: LOW
- Clear error type (TypeError)
- Exact file and line
- Single point of failure
Route: fix mode
```

### Example 2: MEDIUM (-> debug)
```
Input: "User registration is failing but I don't understand why the validation rejects"
Assessment: MEDIUM
- Has error (validation failure)
- Needs code flow understanding
- Single feature, clear entry point
Route: debug mode
```

### Example 3: HIGH (-> troubleshoot)
```
Input: "Sometimes orders don't process. No error in logs. Works fine locally."
Assessment: HIGH
- Intermittent ("sometimes")
- No error message
- Environment-specific
Route: troubleshoot mode
```

### Example 4: CRITICAL (-> initiative + security review)
```
Input: "We need to migrate the auth system from sessions to JWT and update all 12 microservices"
Assessment: CRITICAL
- Breaking change across multiple services
- Security-critical (authentication)
- Multi-team coordination needed
Route: initiative mode + security review
```
