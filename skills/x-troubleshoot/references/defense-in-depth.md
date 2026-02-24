# Defense-in-Depth Validation

> Layered validation model for robust error prevention and debugging.

## 4-Layer Validation Model

Each layer catches different failure classes. Defense-in-depth means no single layer is trusted alone.

```
Layer 1: Entry Validation       ← Catches bad input early
Layer 2: Business Logic Guards  ← Catches domain violations
Layer 3: Environment Guards     ← Catches infrastructure issues
Layer 4: Debug Instrumentation  ← Catches issues in development/staging
```

### Layer 1: Entry Validation

Validate at system boundaries where external data enters:

| Boundary | Validation |
|----------|------------|
| API endpoints | Schema validation (Zod, Joi, JSON Schema) |
| CLI arguments | Type checking, range validation |
| File I/O | Path sanitization, format validation |
| Environment variables | Required check at startup, type coercion |
| User input | Sanitization, length limits, encoding |

**Principle**: Reject invalid input as early as possible. Internal code should never see unvalidated data.

### Layer 2: Business Logic Guards

Enforce domain invariants within the application:

| Guard Type | Example |
|------------|---------|
| Preconditions | `assert(balance >= 0, "Balance cannot be negative")` |
| Postconditions | `assert(result.length <= input.length, "Filter cannot add items")` |
| Invariants | `assert(this.state !== 'closed', "Cannot operate on closed connection")` |
| Type narrowing | Discriminated unions, exhaustive switches |

**Principle**: Domain rules are enforced in domain code, not at the boundary. If a business rule can be violated, add a guard.

### Layer 3: Environment Guards

Validate infrastructure and runtime assumptions:

| Check | When |
|-------|------|
| Database connectivity | Application startup |
| Required services | Health check endpoints |
| File system permissions | Before first write operation |
| Memory/disk thresholds | Periodic monitoring |
| Configuration completeness | Startup validation |

**Principle**: Fail fast at startup rather than at runtime. Surface configuration problems before they affect users.

### Layer 4: Debug Instrumentation

Temporary validation for development and investigation:

| Technique | Purpose |
|-----------|---------|
| Verbose logging | Trace execution flow during investigation |
| State snapshots | Capture before/after state at suspected mutation points |
| Assertion mode | Extra runtime checks enabled via flag |
| Request tracing | Correlation IDs through async boundaries |

**Principle**: Debug instrumentation is temporary. Remove or gate behind flags before production.

## Applying to Troubleshooting

When investigating an issue, check each layer:

1. **Was input validated?** — If not, the root cause may be bad input passing through
2. **Were business rules enforced?** — If not, invalid state may have been created
3. **Were environment assumptions verified?** — If not, infrastructure may be the cause
4. **Is instrumentation available?** — If not, add targeted instrumentation to test hypotheses

## Layer Gap Analysis

A common root cause pattern is a **missing validation layer**:

| Symptom | Likely Missing Layer |
|---------|---------------------|
| Garbage data in database | Layer 1 (entry validation) |
| Business rule violated | Layer 2 (domain guards) |
| Works locally, fails in CI | Layer 3 (environment guards) |
| "It was working yesterday" | Layer 4 (no instrumentation to detect when it broke) |

When the root cause is found, add validation at the appropriate layer to prevent recurrence.
