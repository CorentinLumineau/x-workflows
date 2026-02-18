# CI Awareness State Schema

## State Persistence

**File Persistence:**
- Path: `.claude/workflow-state.json`
- Key: `ci_context`
- TTL: 5 minutes (CI status changes frequently)

## TypeScript Interface

```typescript
interface CIContext {
  ci_systems: Array<{
    name: string;
    primary: boolean;
    config_files: string[];
  }>;
  pr_number?: number;
  branch: string;
  sha: string;
  checks: Array<{
    name: string;
    status: "completed" | "in_progress" | "queued";
    conclusion?: "success" | "failure" | "neutral" | "cancelled" | "skipped";
    required: boolean;
    url: string;
    duration?: string;
    started_at?: string;
    completed_at?: string;
  }>;
  aggregate: {
    all_passing: boolean;
    required_passing: boolean;
    pending_count: number;
    failing_checks: string[];
    total_checks: number;
    required_checks: number;
    optional_checks: number;
    merge_ready: boolean;
    status_summary: string;
  };
  failures?: Array<{
    check_name: string;
    failure_type: string;
    failure_message: string;
    log_excerpt: string;
    suggested_action: string;
  }>;
  detected_at: string; // ISO 8601
  ttl: string; // ISO 8601
}
```

## Per-Check Data Structure

```json
{
  "name": "test-suite",
  "status": "completed",
  "conclusion": "success",
  "url": "https://github.com/owner/repo/actions/runs/12345",
  "duration": "2m30s",
  "required": true,
  "started_at": "2026-02-16T10:00:00Z",
  "completed_at": "2026-02-16T10:02:30Z"
}
```

## Aggregate CI Status

```json
{
  "all_passing": false,
  "required_passing": true,
  "pending_count": 1,
  "failing_checks": ["lint", "integration-tests"],
  "total_checks": 8,
  "required_checks": 5,
  "optional_checks": 3,
  "merge_ready": false,
  "status_summary": "5/5 required checks passing, 1/3 optional checks failing, 1 pending"
}
```

## Failure Diagnosis Output

```json
{
  "check_name": "integration-tests",
  "failure_type": "test-failure",
  "failure_message": "AssertionError: Expected 200, got 404",
  "log_excerpt": "...",
  "suggested_action": "x-fix",
  "retry_count": 0,
  "flaky_probability": "low"
}
```

## Polling State

```json
{
  "ci_polling": {
    "pr_number": 123,
    "started_at": "2026-02-16T10:00:00Z",
    "last_check_at": "2026-02-16T10:10:00Z",
    "check_count": 3,
    "status": "polling",
    "checks_completed": 5,
    "checks_pending": 2,
    "checks_total": 7
  }
}
```

## Integration Example

Skills reference ci-awareness when they need CI intelligence:

```yaml
# Example: git-merge-pr/SKILL.md
behavioral-skills:
  - forge-awareness
  - ci-awareness
```

**Activation Sequence:**

1. User invokes `git-merge-pr`
2. Compiler detects `ci-awareness` in behavioral skills
3. ci-awareness auto-fires and queries CI status
4. ci_context written to workflow-state.json
5. git-merge-pr reads ci_context and checks merge_ready flag
6. If merge_ready == false → block merge, show failing checks
7. If merge_ready == true → proceed with merge
