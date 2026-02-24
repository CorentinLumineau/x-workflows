# Root-Cause Tracing

> Backward tracing technique for systematic root cause identification.

## Backward Tracing Method

Trace from symptom back to original trigger through the full causal chain:

```
Symptom → Immediate Cause → Call Chain → Original Trigger
```

### Step 1: Identify the Symptom

Document the observable failure precisely:
- Exact error message or unexpected behavior
- When it occurs (always, intermittent, specific conditions)
- What changed recently (deploy, config, dependency update)

### Step 2: Find the Immediate Cause

The line of code or condition that directly produces the symptom:

| Symptom Type | Investigation |
|--------------|---------------|
| Exception/crash | Stack trace → top frame in project code |
| Wrong output | Last assignment to the incorrect value |
| Performance | Profile hotspot → slowest function |
| Flaky test | Non-deterministic input (time, random, order) |

### Step 3: Trace the Call Chain

Walk backward from the immediate cause:

```
1. Read the immediate cause function
2. Find all callers (Grep for function name)
3. For each caller, check what data it passes
4. Identify where the bad data originates
5. Repeat until you reach the entry point or external input
```

**Key questions at each hop**:
- What precondition was assumed but not validated?
- What input was trusted but shouldn't have been?
- What side effect was unexpected?

### Step 4: Identify the Original Trigger

The root cause is the earliest point where a fix would prevent the symptom:

| Root Cause Category | Example | Fix Pattern |
|--------------------|---------|-------------|
| Missing validation | No null check on API response | Add guard clause at boundary |
| Wrong assumption | Assumed array is sorted | Document and enforce precondition |
| State mutation | Shared mutable state modified concurrently | Immutable data or proper locking |
| Configuration | Wrong env variable in staging | Validate config at startup |
| Dependency change | Library updated with breaking change | Pin versions, add integration test |

## Stack Trace Instrumentation

When stack traces are insufficient, add targeted instrumentation:

```
1. Add logging at suspected branch points
2. Log function entry/exit with key parameters
3. Log state transitions (before/after values)
4. Remove instrumentation after root cause is found
```

**Rules**:
- Instrument the hypothesis, not the entire codebase
- Use structured logging (JSON) for parseability
- Include timestamps for ordering and latency analysis
- Clean up all instrumentation before committing

## Test Pollution Detection

When tests pass individually but fail together, suspect test pollution:

| Signal | Investigation |
|--------|---------------|
| Test passes alone, fails in suite | Shared state leak between tests |
| Test order matters | Global variable or singleton mutation |
| Flaky in CI, stable locally | Timing, parallelism, or resource contention |
| Fails after specific test | That test leaves dirty state |

**Detection steps**:
1. Run the failing test in isolation — does it pass?
2. Binary search: run with first half of suite, then second half
3. Narrow to the specific polluting test
4. Check for: global variables, database state, file system artifacts, environment variables

## Integration with x-troubleshoot

This reference supports Phase 2 (Hypothesize) and Phase 3 (Test):
- Use backward tracing to form hypotheses in Phase 2
- Use instrumentation to validate hypotheses in Phase 3
- Use test pollution detection when debugging flaky tests
