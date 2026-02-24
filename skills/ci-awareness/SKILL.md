---
name: ci-awareness
description: Use when checking CI/CD pipeline status, diagnosing build failures, or verifying merge readiness.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
user-invocable: false
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: behavioral
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
Detect forge type from forge-awareness:
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

Query CI status using forge-appropriate CLI (gh/tea/glab) or API. Extract check names, status, conclusion, URLs, and timing.

> **Per-forge CLI commands**: See `references/forge-ci-commands.md`

### Phase 3: Parse and Classify Results

Classify each check by status (completed/in_progress/queued) and conclusion (success/failure/neutral/cancelled/skipped). Aggregate into merge readiness assessment tracking required vs optional checks.

### Phase 4: Failure Diagnosis

When checks fail, retrieve logs via forge CLI and classify the failure:

| Failure Type | Detection Pattern | Suggested Action |
|--------------|-------------------|------------------|
| Test failure | `FAIL:`, `AssertionError`, exit code 1 | x-fix with test context |
| Lint error | `eslint`, `flake8`, `rubocop` error output | x-fix with linter rules |
| Build error | `compilation failed`, `cargo build` error | x-fix with compiler output |
| Timeout | `timeout`, `killed`, `SIGTERM` | Investigate performance |
| Infrastructure | `curl failed`, `docker pull` error | Retry, check CI config |
| Flaky test | Intermittent failure, passes on retry | Mark as flaky, investigate |

> **Log retrieval commands and diagnosis output**: See `references/forge-ci-commands.md`

## Merge Readiness Check

**Merge Readiness Algorithm:**

`merge_ready = TRUE` if ALL of:
1. All required checks passed (conclusion == "success")
2. No required checks pending
3. No merge conflicts detected
4. Review approved (if required by branch protection)
5. No blocking labels (e.g., "do-not-merge", "wip")

Optional check failures do NOT block merge readiness. Read branch protection rules from forge API to determine which checks are required.

> **Branch protection commands**: See `references/forge-ci-commands.md`

## Status Polling

For long-running CI: poll every 5 minutes (max 30 minutes), exit early when all checks complete.

## Required vs. Optional Checks

Determine required checks from: branch protection API, CI config heuristics (test/lint/build = required), or historical merge analysis.

## Error Handling

| Error Condition | Detection | Handling Strategy |
|----------------|-----------|-------------------|
| No CI configured | No config files found | Warn "No CI detected", proceed with merge (no blocking) |
| API rate limit | HTTP 429 response | Wait and retry, use cached status if available |
| CLI not installed | `command -v {cli}` fails | Fall back to API calls |
| Network error | API timeout | Use cached status, warn user, retry later |
| Unknown CI system | Config file present but unrecognized | Log warning, skip CI checks |
| Partial check data | Some checks missing from API | Use available data, mark status as "incomplete" |

## When to Load References

- **For per-forge CLI commands, log retrieval, branch protection queries, and diagnosis output**: See `references/forge-ci-commands.md`

## References

- @skills/delivery-ci-cd-delivery/ - CI/CD pipeline patterns
- @skills/vcs-forge-operations/ - Forge-specific CI commands
- @skills/quality-testing/ - Test failure diagnosis patterns
