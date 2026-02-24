---
name: context-awareness
description: Use when session starts or context needs detection. Identifies environment, session state, and tool availability.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
user-invocable: false
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: behavioral
---

# Context Awareness

Detect runtime environment, manage session state, and provide tool availability context.

## Purpose

Provide unified context detection for all workflow skills:
1. **Environment Detection** → CI vs interactive, agent type, platform
2. **Session State Management** → session context lifecycle
3. **Tool Availability** → CLI presence, version checking, fallback strategies

This behavioral skill ensures workflows adapt to their execution environment and have access to accurate tool availability data.

---

## Activation Triggers

| Trigger | Condition |
|---------|-----------|
| Workflow start | First phase of any workflow skill |
| Tool usage | Before invoking external CLI tools |

context-awareness activates automatically at workflow boundaries to ensure environment and state are properly initialized.

---

## Environment Detection

### Detection Algorithm

```
1. Check CI environment:
   - CI=true → CI mode
   - GITHUB_ACTIONS=true → GitHub Actions
   - GITLAB_CI=true → GitLab CI
   - CIRCLECI=true → CircleCI
   - Any CI env var → CI mode

2. Detect agent type:
   - Check for Claude Code markers
   - Check for Cursor markers
   - Check for Cline markers
   - Fallback: Generic skills.sh agent

3. Detect platform:
   - uname -s → Linux, Darwin, Windows
   - Architecture: x86_64, arm64
```

### Environment Context Schema

```json
{
  "environment": {
    "is_ci": true,
    "ci_platform": "github-actions",
    "agent_type": "claude-code",
    "platform": "linux",
    "architecture": "x86_64",
    "shell": "bash",
    "is_worktree": false,
    "worktree_name": null,
    "detected_at": "2026-02-16T10:30:00Z"
  }
}
```

---

## Worktree Detection

### Detection Algorithm

After environment detection, check for git worktree context:

```
5. Detect git worktree state:
   - git rev-parse --is-inside-work-tree → confirms git repo
   - git rev-parse --show-toplevel → current working tree root
   - git rev-parse --git-dir → .git path for current tree
   - git rev-parse --git-common-dir → shared .git for worktrees
   - If git-common-dir path differs from git-dir → session is in a worktree
   - Extract worktree name from path (e.g., .claude/worktrees/<name>/)
   - Get current branch: git branch --show-current
   - Report: is_worktree, worktree_name, worktree_branch, main_repo_path
```

### Worktree Context Schema

```json
{
  "worktree": {
    "is_worktree": true,
    "worktree_name": "feature-auth",
    "worktree_branch": "worktree-feature-auth",
    "worktree_path": "/repo/.claude/worktrees/feature-auth",
    "main_repo_path": "/repo",
    "detected_at": "2026-02-23T10:30:00Z"
  }
}
```

When not in a worktree:
```json
{
  "worktree": {
    "is_worktree": false,
    "detected_at": "2026-02-23T10:30:00Z"
  }
}
```

### Worktree State in Environment Context

Add worktree fields to the environment context:

```json
{
  "environment": {
    "is_ci": false,
    "ci_platform": null,
    "agent_type": "claude-code",
    "platform": "linux",
    "architecture": "x86_64",
    "shell": "bash",
    "is_worktree": true,
    "worktree_name": "feature-auth",
    "detected_at": "2026-02-23T10:30:00Z"
  }
}
```

---

## Tool Detection

### Detection Protocol

Run `which` checks for common CLIs to determine tool availability:

```
Tools to check:
- Version control: gh, tea, glab, git
- Package managers: npm, yarn, pnpm, bun
- Runtimes: node, python, python3, ruby
- Build tools: make, cmake, gradle, maven
- Containers: docker, podman, kubectl
- CI tools: act, circleci

Detection process:
1. Run: which <tool> (or where <tool> on Windows)
2. If found → check version: <tool> --version
3. Cache results in session context for the duration of the workflow
```

### Tool Availability Schema

```json
{
  "tool_availability": {
    "gh": {
      "available": true,
      "path": "/usr/local/bin/gh",
      "version": "2.40.1",
      "checked_at": "2026-02-16T10:30:00Z"
    },
    "tea": {
      "available": false,
      "checked_at": "2026-02-16T10:30:00Z"
    },
    "glab": {
      "available": true,
      "path": "/usr/bin/glab",
      "version": "1.36.0",
      "checked_at": "2026-02-16T10:30:00Z"
    },
    "docker": {
      "available": true,
      "path": "/usr/bin/docker",
      "version": "25.0.3",
      "checked_at": "2026-02-16T10:30:00Z"
    }
  }
}
```

### Tool Check Caching

```
Cache strategy:
1. Check if tool was already detected in current session
2. If already detected → use cached result
3. If not yet detected → run detection
4. Always re-check if version is required for compatibility

When to re-check:
- New session (no prior cache)
- After package manager operations (npm install, etc.)
- On explicit request (user runs tool detection command)
- If cached version doesn't meet minimum requirements
```

### Version Checking Patterns

```bash
# Git forge CLIs
gh --version         # GitHub CLI
tea --version        # Gitea CLI
glab --version       # GitLab CLI

# Package managers
npm --version
yarn --version
pnpm --version
bun --version

# Runtimes
node --version
python --version
python3 --version
ruby --version

# Build tools
make --version
docker --version
kubectl version --client
```

---

## Tool Availability Matrix

| Tool | Category | Priority | Fallback |
|------|----------|----------|----------|
| gh | Git forge | High | glab, tea, git |
| tea | Git forge | Medium | gh, glab, git |
| glab | Git forge | Medium | gh, tea, git |
| git | VCS | Critical | None (required) |
| npm | Package manager | High | yarn, pnpm, bun |
| node | Runtime | High | None (if npm used) |
| docker | Container | Medium | podman |
| make | Build tool | Medium | npm scripts |
| bun | Runtime | Low | node |

### Fallback Strategies

When a required tool is missing:

```
1. Check fallback options in priority order
2. If fallback available:
   - Log: "Tool {primary} not found, using {fallback}"
   - Adapt workflow to use fallback
   - Continue execution

3. If no fallback available:
   - Determine if tool is critical or optional
   - If optional: skip operations requiring tool, warn user
   - If critical: halt workflow, report missing dependency

4. Provide installation guidance:
   - Suggest package manager command
   - Link to official installation docs
   - Platform-specific instructions
```

**Example: GitHub CLI missing**

```
Primary: gh (not found)
Fallbacks: glab (found), tea (not found), git (found)

Decision: Use glab for GitLab operations, git for basic VCS
Warning: Some GitHub-specific features unavailable
Guidance: Install gh via: brew install gh (macOS) or apt install gh (Ubuntu)
```

---

## Integration Pattern

context-awareness is **automatically active** in ALL workflow skills. It provides environment context and tool availability data to all phases.

### Skill Integration

Workflow skills reference context-awareness for environment detection:

```markdown
## Environment Detection

Uses: @skills/context-awareness/

Before execution:
1. Detect CI vs interactive mode
2. Check tool availability (gh, npm, docker)
3. Adapt workflow based on available tools
```

---

## When to Load References

- **For complete tool detection protocol, version checks, and fallback strategies**: See `references/tool-detection.md`

## References

See: @skills/context-awareness/references/tool-detection.md for complete tool detection protocol and fallback strategies.
