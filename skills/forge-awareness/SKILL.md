---
name: forge-awareness
description: Use when git operations need forge-specific CLI commands. Auto-detects forge platform (GitHub/Gitea) from remotes.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: behavioral
  user-invocable: false
---

# forge-awareness

## Purpose

Extract forge detection logic into a shared behavioral skill to ensure DRY compliance across all git-* workflow skills. Auto-triggers when git-* workflow skills activate to provide forge context without each skill implementing its own detection logic.

This skill eliminates duplicate forge detection code, provides consistent forge classification, enables forge-agnostic operations, and maintains a cached forge context for session-wide access.

## Activation Triggers

| Trigger | Condition | Timing |
|---------|-----------|--------|
| git-* skill activation | Any skill with `forge-awareness` in behavioral skills list | Before Phase 0 |
| Explicit invocation | User runs a forge-related operation | On-demand |
| CI environment | Detect headless mode for adapter behavior | On first git operation |
| Remote URL change | After `git remote add/remove/set-url` | After git operation |

## Core Detection Algorithm

### Phase 1: Parse Git Remotes

```bash
# Extract all configured remotes
git remote -v | grep fetch

# For each remote, parse URL patterns:
# SSH format: git@hostname:owner/repo.git
# HTTPS format: https://hostname/owner/repo.git
# Extract: hostname, owner, repo
```

**URL Pattern Matching:**

| Pattern | Example | Extraction |
|---------|---------|------------|
| SSH | `git@github.com:user/repo.git` | hostname=github.com, owner=user, repo=repo |
| HTTPS | `https://gitea.example.com/org/project.git` | hostname=gitea.example.com, owner=org, repo=project |
| HTTPS (no .git) | `https://github.com/owner/repo` | hostname=github.com, owner=owner, repo=repo |

### Phase 2: Classify Forge Platform

```
For each unique hostname:

1. GitHub Detection:
   - hostname == "github.com" → GitHub
   - hostname matches "*.github.com" → GitHub Enterprise
   - hostname matches "ghe.*.com" → GitHub Enterprise

2. GitLab Detection:
   - hostname == "gitlab.com" → GitLab
   - hostname matches "gitlab.*" → GitLab Self-Hosted

3. Gitea/Forgejo Detection:
   - Check known Gitea domains (from config)
   - Try Gitea API probe: GET /api/v1/version
     - HTTP 200 + valid JSON → Gitea/Forgejo
     - HTTP 404/other → Not Gitea

4. Unknown Classification:
   - No match → Unknown
   - Prompt user: "Detected unknown forge at {hostname}. Is this (g)itea, (l)ab, or (o)ther?"
```

> See [references/forge-detection.md](references/forge-detection.md) for forge API signatures and response patterns.

### Phase 3: Check CLI Tool Availability

```bash
# GitHub
if command -v gh &> /dev/null; then
  cli_available=true
  cli_tool="gh"
  gh_version=$(gh --version | head -n1)
fi

# Gitea
if command -v tea &> /dev/null; then
  cli_available=true
  cli_tool="tea"
  tea_version=$(tea --version)
fi

# GitLab
if command -v glab &> /dev/null; then
  cli_available=true
  cli_tool="glab"
  glab_version=$(glab --version)
fi
```

> See [references/forge-detection.md](references/forge-detection.md) for CLI install commands and fallback strategies.

### Phase 4: Store in Workflow State

Write to `.claude/workflow-state.json`:

```json
{
  "forge_context": {
    "primary_forge": "github",
    "primary_remote": "origin",
    "cli_available": true,
    "cli_tool": "gh",
    "cli_version": "gh version 2.40.0 (2024-01-15)",
    "remotes": [
      {
        "name": "origin",
        "forge": "github",
        "url": "git@github.com:owner/repo.git",
        "owner": "owner",
        "repo": "repo",
        "hostname": "github.com"
      },
      {
        "name": "gitea-mirror",
        "forge": "gitea",
        "url": "https://gitea.example.com/org/project.git",
        "owner": "org",
        "repo": "project",
        "hostname": "gitea.example.com"
      }
    ],
    "detected_at": "2026-02-16T10:30:00Z",
    "ttl": "2026-02-17T10:30:00Z"
  }
}
```

## Multi-Remote Support

When multiple remotes exist (common in mirror setups):

1. **Primary Remote Selection:**
   - Default to `origin` if present
   - If no `origin`, use first remote alphabetically
   - Allow user override via config: `.claude/config.json` → `forge.primary_remote`

2. **Remote Listing:**
   - List ALL remotes with their forge types
   - Track which remotes are read-only vs. push-enabled
   - Identify mirror relationships (same owner/repo on different forges)

3. **Operation Targeting:**
   - git-* skills operate on primary remote by default
   - Support `--remote` flag to target specific remote
   - Example: `git-create-pr --remote gitea-mirror`

**Multi-Remote State Example:**

```json
{
  "forge_context": {
    "primary_forge": "github",
    "primary_remote": "origin",
    "mirror_detected": true,
    "mirror_remotes": ["gitea-mirror", "gitlab-backup"],
    "remotes": [...]
  }
}
```

## CI/Headless Detection

> See [references/forge-detection.md](references/forge-detection.md) for CI environment detection scripts and headless mode adaptations.

## Caching Strategy

**Cache Duration:**
- Default TTL: 24 hours
- Invalidation triggers: Remote URL change, manual cache clear

**Cache Storage:**
- Location: `.claude/workflow-state.json` (forge_context key)

**Cache Refresh Logic:**

```
On skill activation:
  1. Check if forge_context exists in workflow-state.json
  2. Check if ttl expired (current_time > ttl)
  3. If expired OR remotes changed → re-detect
  4. Else → use cached context
```

**Manual Cache Clear:**

```bash
# Clear forge context from workflow state
# (Consumed by git-clear-state or similar)
rm -f .claude/workflow-state.json
```

## Error Handling

> See [references/forge-detection.md](references/forge-detection.md) for error conditions, handling strategies, and error state persistence format.

## Integration Pattern

Other skills reference forge-awareness in their behavioral skills list:

```yaml
# Example: git-create-pr/SKILL.md
behavioral-skills:
  - forge-awareness
  - interview
```

**Activation Sequence:**

1. User invokes `git-create-pr`
2. Compiler detects `forge-awareness` in behavioral skills
3. forge-awareness auto-fires **before** Phase 0 of git-create-pr
4. forge_context written to workflow-state.json
5. git-create-pr reads forge_context and uses appropriate CLI/API

**Accessing Forge Context in Skills:**

```markdown
## Phase 0: Load Forge Context

<doc-query>
Read forge context from workflow-state.json
Extract: primary_forge, cli_tool, primary_remote
</doc-query>

<workflow-gate>
If forge is GitHub AND cli_tool is "gh":
  → Use gh CLI commands
Else if forge is Gitea AND cli_tool is "tea":
  → Use tea CLI commands
Else:
  → Fall back to API calls (see @skills/vcs-forge-operations/)
</workflow-gate>
```

## State Persistence

**File Persistence:**
- Path: `.claude/workflow-state.json`
- Key: `forge_context`
- Format: JSON object with remotes array, primary selections, CLI availability

**State Schema:**

```typescript
interface ForgeContext {
  primary_forge: "github" | "gitea" | "gitlab" | "unknown";
  primary_remote: string;
  cli_available: boolean;
  cli_tool: "gh" | "tea" | "glab" | "none";
  cli_version?: string;
  remotes: Array<{
    name: string;
    forge: string;
    url: string;
    owner: string;
    repo: string;
    hostname: string;
  }>;
  detected_at: string; // ISO 8601
  ttl: string; // ISO 8601
  is_headless?: boolean;
  ci_platform?: string;
  error?: boolean;
  error_message?: string;
}
```

## References

- @skills/vcs-forge-operations/ - CLI equivalences and forge-specific operations
- @skills/vcs-git-workflows/ - Git workflow patterns
- @skills/delivery-ci-cd-delivery/ - CI/CD integration patterns
