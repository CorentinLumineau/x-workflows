---
name: forge-awareness
description: Use when git operations need forge-specific CLI commands. Auto-detects forge platform (GitHub/Gitea) from remotes.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
user-invocable: false
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: behavioral
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

## CI/Headless Detection

> See [references/forge-detection.md](references/forge-detection.md) for CI environment detection scripts and headless mode adaptations.

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
4. Forge context detected (primary forge, CLI tool, remotes)
5. git-create-pr uses the detected forge context to select appropriate CLI/API

## References

- @skills/vcs-forge-operations/ - CLI equivalences and forge-specific operations
- @skills/vcs-git-workflows/ - Git workflow patterns
- @skills/delivery-ci-cd-delivery/ - CI/CD integration patterns
