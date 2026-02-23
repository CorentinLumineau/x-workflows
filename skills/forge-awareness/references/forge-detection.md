# Forge Detection Reference

> Extracted from forge-awareness SKILL.md — API signatures, CLI matrix, and error handling.

## Known Forge Signatures

| Forge | API Endpoint | Response Signature |
|-------|--------------|-------------------|
| GitHub | `/api/v3` | JSON with `current_user_url` field |
| GitLab | `/api/v4/version` | JSON with `version` and `revision` fields |
| Gitea | `/api/v1/version` | JSON with `version` field |
| Forgejo | `/api/v1/version` | JSON with `version` field (Gitea-compatible) |

## CLI Availability Matrix

| Forge | CLI Tool | Install Command | Fallback Strategy |
|-------|----------|-----------------|-------------------|
| GitHub | `gh` | `brew install gh` / `apt install gh` | Use GitHub API directly |
| Gitea | `tea` | `brew install tea` / Download binary | Use Gitea API directly |
| GitLab | `glab` | `brew install glab` / `apt install glab` | Use GitLab API directly |

## CI/Headless Detection

```bash
# Detect headless/CI environment
is_headless=false

# Check CI environment variables
if [[ "$CI" == "true" ]] || [[ "$CI" == "1" ]]; then
  is_headless=true
fi

# Check for specific CI platforms
if [[ "$GITHUB_ACTIONS" == "true" ]]; then
  ci_platform="github-actions"
  is_headless=true
fi

if [[ "$GITEA_ACTIONS" == "true" ]]; then
  ci_platform="gitea-actions"
  is_headless=true
fi

# Check for TTY
if ! test -t 0; then
  is_headless=true
fi
```

## Headless Mode Adaptations

| Feature | Interactive Mode | Headless Mode |
|---------|------------------|---------------|
| workflow-gate | Prompt user for choice | Auto-proceed with recommended option |
| Unknown forge | Ask user to classify | Classify as "unknown", log warning |
| CLI not found | Suggest install command | Use API fallback, log warning |

## Error Handling

| Error Condition | Detection | Handling Strategy |
|----------------|-----------|-------------------|
| No git repository | `git rev-parse --git-dir` fails | Skip detection, warn "Not a git repository" |
| No remotes | `git remote` returns empty | Skip detection, warn "No remotes configured" |
| CLI not installed | `command -v {cli}` fails | Continue without CLI, use API fallback |
| Network error | API probe times out | Classify as unknown, retry on next invocation |
| Ambiguous forge | Multiple unknowns | Prompt user once, cache response |
| Invalid remote URL | URL parsing fails | Log warning, skip remote |

## Error State Persistence

```json
{
  "forge_context": {
    "error": true,
    "error_message": "No git repository detected",
    "error_code": "NO_GIT_REPO",
    "detected_at": "2026-02-16T10:30:00Z"
  }
}
```
