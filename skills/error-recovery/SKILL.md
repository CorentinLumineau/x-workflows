---
name: error-recovery
description: Use when a tool call fails, a network error occurs, or a session interruption is detected. Applies recovery strategies.
version: "1.0.0"
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
user-invocable: false
metadata:
  author: ccsetup contributors
  category: behavioral
---

# Error Recovery

Classify and recover from tool failures, network errors, and session interruptions.

## Purpose

Classify errors as transient/permanent/corruption and provide recovery strategies. Prevents workflow abandonment by providing structured recovery paths.

This behavioral skill wraps ALL workflow skills with resilient error handling, ensuring temporary failures don't derail multi-phase workflows and permanent failures are reported with actionable context.

---

## Activation Triggers

| Trigger | Condition |
|---------|-----------|
| Tool failure | Any tool call returns an error |
| Network error | HTTP timeout, DNS failure, connection refused |
| Session interruption | Context window approaching limit, agent crash |
Error recovery activates automatically when ANY tool call fails. It does not require user invocation.

---

## Error Classification

| Error Type | Examples | Strategy | Max Retries |
|------------|----------|----------|-------------|
| **Transient** | Network timeout, rate limit, temporary file lock | Retry with exponential backoff | 3 |
| **Permanent** | File not found, permission denied, invalid argument | Report with context, suggest fix | 0 |
| **Partial** | Some files written, commit incomplete | Resume from checkpoint | 1 |

### Classification Algorithm

```
1. Parse error message and exit code
2. Match against known patterns:

   Transient patterns:
   - "ECONNREFUSED", "ETIMEDOUT", "ENOTFOUND"
   - "429 Too Many Requests"
   - "EBUSY", "EAGAIN", "LOCKED"
   - "rate limit", "quota exceeded"

   Permanent patterns:
   - "ENOENT", "EACCES", "EPERM"
   - "404 Not Found", "403 Forbidden"
   - "Invalid argument", "Syntax error"
   - "Command not found"

   Partial patterns:
   - "Operation incomplete"
   - Checkpoint exists but final state missing
   - Some expected artifacts present, others missing

3. If no pattern matches → default to Permanent
4. Log classification decision
```

---

## Recovery Algorithms

### Transient Recovery

```
1. Log initial failure: "Transient error detected: {error_message}"
2. Wait: 2^attempt seconds (2s → 4s → 8s)
3. Retry the failed operation with identical parameters
4. Track retry count
5. If attempt 1-3 succeeds:
   - Log: "Transient error recovered after {N} retries"
   - Continue workflow
6. If all 3 attempts fail:
   - Reclassify as Permanent
   - Log: "Escalating to permanent after 3 failed retries"
   - Proceed to Permanent Recovery
```

**Example:**
```
Attempt 1: Network timeout → Wait 2s → Retry
Attempt 2: Network timeout → Wait 4s → Retry
Attempt 3: Success → Log "Recovered after 2 retries" → Continue
```

### Permanent Recovery

```
1. Log the error with full context:
   - Tool name
   - Arguments passed
   - Error message
   - Stack trace (if available)
   - Current workflow phase

2. Determine operation criticality:
   - Required: Operation blocks workflow progress
   - Optional: Operation enhances workflow but isn't blocking

3. If operation is Optional:
   - Log: "Skipping optional operation: {reason}"
   - Continue workflow with degraded functionality
   - Add warning to final summary

4. If operation is Required:
   - Generate actionable error report:
     * What failed
     * Why it failed (root cause hypothesis)
     * Suggested fixes (ranked by likelihood)
     * Alternative approaches
   - Halt workflow
   - Present report to user

5. User options:
   - Fix and resume from checkpoint
   - Skip operation (if possible)
   - Abort workflow
```

**Suggested Fix Generation:**

```
Error: "ENOENT: no such file or directory, open 'config.json'"

Suggestions (ranked):
1. Create missing file: touch config.json
2. Check file path typo: Did you mean config/app.json?
3. Check working directory: Expected in /project/root
4. Restore from backup: .claude/backups/config.json
```

### Partial Recovery

```
1. Identify completed vs incomplete operations:
   - Check if expected artifacts exist on disk
   - Verify git commits match checkpoint
   - Compare file checksums if available

3. Determine resume point:
   - Last completed phase with verified artifacts
   - Skip completed operations
   - Queue remaining operations

4. Resume from last completed phase:
   - Set workflow state to resume point
   - Re-execute incomplete operations
   - Do NOT re-run completed phases

5. Verify after resume:
   - Check all expected artifacts exist
   - Validate workflow state consistency
   - Update checkpoint

6. Continue workflow normally
```

**Example:**
```
Checkpoint shows:
  phases_completed: ["analyze", "plan", "implement"]
  current_phase: "verify"
  artifacts:
    files: ["src/feature.ts", "tests/feature.test.ts"]
    commits: ["abc123"]

Resume verification:
  ✓ src/feature.ts exists
  ✓ tests/feature.test.ts exists
  ✓ Commit abc123 exists
  ✗ No test results found

Action: Resume from "verify" phase (re-run tests only)
```

---

## Integration Pattern

error-recovery is **automatically active** in ALL workflow skills. It wraps tool calls with retry logic and provides recovery paths when operations fail.

### Skill Integration

Workflow skills reference error-recovery for resilience:

```markdown
## Error Handling

Uses: @skills/error-recovery/

If any phase fails:
1. error-recovery classifies the error
2. Attempts automatic recovery
3. Falls back to user intervention if needed
```

### Tool Call Wrapper Pattern

```
Before tool call:
1. Check if operation is optional or required
2. Save checkpoint if required

Execute tool call:
1. Attempt operation
2. If error → classify via error-recovery
3. If transient → retry with backoff
4. If permanent + optional → skip with warning
5. If permanent + required → save state, report to user
6. If corruption → attempt restore from backup

After successful tool call:
1. Update checkpoint
2. Write backup
```

---

## References

- @skills/context-awareness/ - Session state management and cleanup
- @skills/permission-awareness/ - Runtime permission detection
