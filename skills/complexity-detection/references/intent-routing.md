# Intent Detection Patterns & Routing

Reference tables for workflow intent detection and skill routing.

## Intent Detection Patterns

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

## Intent to Skill Mapping

| Intent | Complexity | Route |
|--------|------------|-------|
| APEX + LOW | Direct | x-implement |
| APEX + MEDIUM | Plan first | x-plan -> x-implement |
| APEX + HIGH | Initiative | **x-initiative** -> full APEX flow |
| APEX + CRITICAL | Initiative | **x-initiative** -> full APEX flow + security review |
| ONESHOT | Always LOW | x-implement (autonomous) |
| DEBUG + LOW | Direct | x-implement fix |
| DEBUG + MEDIUM | Investigate | x-troubleshoot debug |
| DEBUG + HIGH | Initiative | **x-initiative** -> x-troubleshoot |
| DEBUG + CRITICAL | Initiative | **x-initiative** -> x-troubleshoot + security review |
| BRAINSTORM + LOW | Quick answer | x-research ask |
| BRAINSTORM + MEDIUM | Deep dive | x-research deep |
| BRAINSTORM + HIGH | Initiative | **x-initiative** -> x-brainstorm |
| BRAINSTORM + CRITICAL | Initiative | **x-initiative** -> x-brainstorm + security review |
| GIT + "pr" (create) | Direct | git-create-pr |
| GIT + "pr" (review) | Direct | git-review-pr |
| GIT + "pr" (merge) | Direct | git-merge-pr |
| GIT + "ci"/"checks" | Direct | git-check-ci |
| GIT + "issue" (create) | Direct | git-create-issue |
| GIT + "issue" (implement) | Planning | git-implement-issue |
| GIT + "release" | Direct | git-create-release |
| GIT + "conflict" | Direct | git-resolve-conflict |
| GIT + "cleanup"/"branches" | Direct | git-cleanup-branches |
