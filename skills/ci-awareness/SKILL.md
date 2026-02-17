---
name: ci-awareness
description: Detect CI/CD system and query pipeline status for merge readiness and failure diagnosis.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: behavioral
  user-invocable: false
---

# ci-awareness

## Purpose

Provide CI/CD status intelligence to workflow skills. Auto-triggers before merge operations, after PR creation, and during CI status checks. Eliminates duplicate CI detection logic across git-check-ci, git-merge-pr, and git-create-pr.

This skill detects the CI/CD system in use, queries pipeline status, classifies check results, determines merge readiness, and provides failure diagnosis when checks fail.

## Activation Triggers

| Trigger | Condition | Timing |
|---------|-----------|--------|
| Pre-merge validation | Before git-merge-pr proceeds | After PR readiness check |
| Post-PR creation | After git-create-pr completes | After PR URL returned |
| CI status check | During git-check-ci execution | On-demand |
| Build failure analysis | When CI fails and diagnosis needed | After failure detected |
| Periodic polling | In workclaude comment-driven workflows | Every 5 minutes |

## Core Detection Algorithm

### Phase 1: Detect CI System from Forge Type

```
Read forge_context from workflow-state.json:
  - primary_forge == "github" → GitHub Actions
  - primary_forge == "gitea" → Gitea Actions
  - primary_forge == "gitlab" → GitLab CI

Verify CI config files exist:
  - GitHub: .github/workflows/*.yml
  - Gitea: .gitea/workflows/*.yml OR .github/workflows/*.yml
  - GitLab: .gitlab-ci.yml
  - Jenkins: Jenkinsfile
  - CircleCI: .circleci/config.yml
  - Travis: .travis.yml
```

**CI Detection Priority:**

1. Check forge-specific CI first (e.g., GitHub Actions for GitHub repos)
2. Check for secondary CI configs (e.g., CircleCI on GitHub)
3. List all detected CI systems
4. Mark primary CI (matches forge) vs. supplementary CI

**Multi-CI Scenario:**

```json
{
  "ci_systems": [
    {
      "name": "GitHub Actions",
      "primary": true,
      "config_files": [".github/workflows/test.yml", ".github/workflows/build.yml"]
    },
    {
      "name": "CircleCI",
      "primary": false,
      "config_files": [".circleci/config.yml"]
    }
  ]
}
```

### Phase 2: Query CI Status

**GitHub Actions:**

```bash
# Get PR checks
gh pr checks {pr_number} --json name,state,conclusion,detailsUrl

# Get recent workflow runs for branch
gh run list --branch {branch} --limit 5 --json name,status,conclusion,databaseId,createdAt

# Get specific run details
gh run view {run_id} --json jobs,status,conclusion
```

**Gitea Actions:**

```bash
# Using tea CLI (if available)
tea ci ls

# Using Gitea API
curl -s https://{hostname}/api/v1/repos/{owner}/{repo}/statuses/{sha}
```

**GitLab CI:**

```bash
# Using glab CLI
glab ci status --pipeline-id {pipeline_id}

# Using GitLab API
curl -s https://gitlab.com/api/v4/projects/{project_id}/pipelines/{pipeline_id}
```

### Phase 3: Parse and Classify Results

**Per-Check Data Structure:**

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

**Status Classification:**

| Status | Conclusion | Meaning | Action Required |
|--------|-----------|---------|-----------------|
| completed | success | Check passed | None |
| completed | failure | Check failed | Diagnose and fix |
| completed | neutral | Check completed but not pass/fail | Review manually |
| completed | cancelled | Check was cancelled | Re-run or investigate |
| completed | skipped | Check was skipped | Verify if intentional |
| in_progress | - | Check is running | Wait for completion |
| queued | - | Check is queued | Wait for start |

**Aggregate CI Status:**

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

### Phase 4: Failure Diagnosis

When checks fail, retrieve logs and classify the failure:

```bash
# GitHub: Get logs for failed jobs
gh run view {run_id} --log-failed

# Parse logs and classify errors
```

**Failure Classification:**

| Failure Type | Detection Pattern | Suggested Action |
|--------------|-------------------|------------------|
| Test failure | `FAIL:`, `AssertionError`, exit code 1 | x-fix with test context |
| Lint error | `eslint`, `flake8`, `rubocop` error output | x-fix with linter rules |
| Build error | `compilation failed`, `cargo build` error | x-fix with compiler output |
| Timeout | `timeout`, `killed`, `SIGTERM` | Investigate performance, increase timeout |
| Infrastructure | `curl failed`, `docker pull` error | Retry, check CI config |
| Flaky test | Intermittent failure, passes on retry | Mark as flaky, investigate root cause |

**Failure Diagnosis Output:**

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

## Merge Readiness Check

**Merge Readiness Algorithm:**

```
merge_ready = TRUE if ALL of:
  1. All required checks passed (conclusion == "success")
  2. No required checks pending (status != "in_progress" AND status != "queued")
  3. No merge conflicts detected
  4. Review approved (if required by branch protection)
  5. No blocking labels (e.g., "do-not-merge", "wip")

Else merge_ready = FALSE
```

**Merge Readiness Matrix:**

| Required Checks | Optional Checks | Pending | Merge Conflicts | Reviews | Merge Ready? |
|----------------|-----------------|---------|----------------|---------|--------------|
| ✅ All pass | ✅ All pass | 0 | No | Approved | ✅ YES |
| ✅ All pass | ❌ Some fail | 0 | No | Approved | ✅ YES (optional checks don't block) |
| ❌ Any fail | - | - | - | - | ❌ NO |
| ✅ All pass | - | 1+ | - | - | ❌ NO (wait for pending) |
| ✅ All pass | ✅ All pass | 0 | Yes | - | ❌ NO (resolve conflicts) |
| ✅ All pass | ✅ All pass | 0 | No | Pending | ❌ NO (wait for review) |

**Branch Protection Rules:**

Read branch protection settings from forge API:

```bash
# GitHub
gh api repos/{owner}/{repo}/branches/{branch}/protection

# Extract:
# - required_status_checks.contexts (array of required check names)
# - required_pull_request_reviews.required_approving_review_count
# - enforce_admins
```

## Log Retrieval

**GitHub Actions:**

```bash
# View run summary
gh run view {run_id}

# Get logs for specific job
gh run view {run_id} --job {job_id} --log

# Get logs for failed jobs only
gh run view {run_id} --log-failed

# Download logs to file
gh run download {run_id} --name logs
```

**Gitea Actions:**

```bash
# Gitea API: Get workflow run jobs
curl -s https://{hostname}/api/v1/repos/{owner}/{repo}/actions/runs/{run_id}/jobs

# Extract job IDs and fetch logs
curl -s https://{hostname}/api/v1/repos/{owner}/{repo}/actions/jobs/{job_id}/logs
```

**GitLab CI:**

```bash
# Using glab CLI
glab ci view {pipeline_id}

# Get job logs
glab ci trace {job_id}
```

**Log Parsing Strategy:**

1. Retrieve last 100 lines of failed job log
2. Search for error patterns (see Failure Classification table)
3. Extract relevant context (5 lines before/after error)
4. Identify file paths, line numbers, error messages
5. Format for presentation to user or x-fix skill

## Status Polling

For workclaude comment-driven workflows or long-running CI:

```
Polling Strategy:
  1. Initial check: Immediately after PR creation
  2. Subsequent checks: Every 5 minutes
  3. Max polling duration: 30 minutes
  4. Early exit: If all checks complete (pass or fail)
```

**Polling State Management:**

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

## Required vs. Optional Checks

**Determining Required Checks:**

1. **From Branch Protection:**
   - Query branch protection API
   - Extract `required_status_checks.contexts`

2. **From CI Config (Heuristic):**
   - Checks named `test`, `lint`, `build` → Usually required
   - Checks named `docs`, `coverage-report` → Usually optional

3. **From Historical Merges:**
   - Analyze last 10 merged PRs
   - Checks present in all → Likely required

**Marking Checks:**

```json
{
  "checks": [
    { "name": "test-suite", "required": true },
    { "name": "lint", "required": true },
    { "name": "coverage-report", "required": false }
  ]
}
```

## CI Status Summary

Generate human-readable status summary:

```
✅ All checks passing (8/8)
❌ 2 checks failing: lint, integration-tests
⏳ 1 check pending: e2e-tests
🔒 Merge blocked: Required check "lint" failing

Failing Checks:
  - lint: 3 style violations (eslint)
  - integration-tests: AssertionError in POST /api/users

Suggested Actions:
  - Run x-fix to address lint violations
  - Investigate integration test failure
```

## State Persistence

**File Persistence:**
- Path: `.claude/workflow-state.json`
- Key: `ci_context`
- TTL: 5 minutes (CI status changes frequently)

**Memory MCP Persistence:**
- Entity: `ci-status`
- Entity Type: `ci-pipeline-status`
- Observations:
  - All checks passing: {true|false}
  - Merge ready: {true|false}
  - Failing checks: {comma-separated list}
  - Last checked: {ISO timestamp}

**State Schema:**

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

## Integration Pattern

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

**Accessing CI Context in Skills:**

```markdown
## Phase 1: Check Merge Readiness

<doc-query>
Read ci_context from workflow-state.json
Extract: merge_ready, failing_checks, status_summary
</doc-query>

<workflow-gate>
If merge_ready is true:
  → Proceed to merge
Else:
  → Show failing checks
  → Suggest: Run x-fix for {failure_type} issues
  → Ask user: Retry checks, force merge, or cancel?
</workflow-gate>
```

## Error Handling

| Error Condition | Detection | Handling Strategy |
|----------------|-----------|-------------------|
| No CI configured | No config files found | Warn "No CI detected", proceed with merge (no blocking) |
| API rate limit | HTTP 429 response | Wait and retry, use cached status if available |
| CLI not installed | `command -v {cli}` fails | Fall back to API calls |
| Network error | API timeout | Use cached status, warn user, retry later |
| Unknown CI system | Config file present but unrecognized | Log warning, skip CI checks |
| Partial check data | Some checks missing from API | Use available data, mark status as "incomplete" |

## References

- @skills/delivery-ci-cd-delivery/ - CI/CD pipeline patterns
- @skills/vcs-forge-operations/ - Forge-specific CI commands
- @skills/quality-testing/ - Test failure diagnosis patterns
