# Forge-Specific CI Commands

## Querying CI Status

### GitHub Actions

```bash
# Get PR checks
gh pr checks {pr_number} --json name,state,conclusion,detailsUrl

# Get recent workflow runs for branch
gh run list --branch {branch} --limit 5 --json name,status,conclusion,databaseId,createdAt

# Get specific run details
gh run view {run_id} --json jobs,status,conclusion
```

### Gitea Actions

```bash
# Using tea CLI (if available)
tea ci ls

# Using Gitea API
curl -s https://{hostname}/api/v1/repos/{owner}/{repo}/statuses/{sha}
```

### GitLab CI

```bash
# Using glab CLI
glab ci status --pipeline-id {pipeline_id}

# Using GitLab API
curl -s https://gitlab.com/api/v4/projects/{project_id}/pipelines/{pipeline_id}
```

## Log Retrieval

### GitHub Actions

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

### Gitea Actions

```bash
# Gitea API: Get workflow run jobs
curl -s https://{hostname}/api/v1/repos/{owner}/{repo}/actions/runs/{run_id}/jobs

# Extract job IDs and fetch logs
curl -s https://{hostname}/api/v1/repos/{owner}/{repo}/actions/jobs/{job_id}/logs
```

### GitLab CI

```bash
# Using glab CLI
glab ci view {pipeline_id}

# Get job logs
glab ci trace {job_id}
```

## Log Parsing Strategy

1. Retrieve last 100 lines of failed job log
2. Search for error patterns (see Failure Classification table in SKILL.md)
3. Extract relevant context (5 lines before/after error)
4. Identify file paths, line numbers, error messages
5. Format for presentation to user or x-fix skill

## Branch Protection Rules

```bash
# GitHub
gh api repos/{owner}/{repo}/branches/{branch}/protection

# Extract:
# - required_status_checks.contexts (array of required check names)
# - required_pull_request_reviews.required_approving_review_count
# - enforce_admins
```
