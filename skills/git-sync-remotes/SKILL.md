---
name: git-sync-remotes
description: Use when pushing commits, tags, and release notes from origin to all other git remotes (mirrors).
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
user-invocable: true
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
chains-to: []
chains-from:
  - skill: git-merge-pr
    auto: false
  - skill: git-create-release
    auto: true
---

# /git-sync-remotes

> Distribute commits, tags, and GitHub release notes from origin (CorentinLumineau) to all non-origin remotes. Uses `gh` for GitHub remotes and `tea` for Gitea/Forgejo remotes.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | UTILITY |
| **Phase** | N/A |
| **Position** | After release or merge |

**Flow**: `[git-create-release or git-merge-pr]` → **`git-sync-remotes`** → `[done]`

## Current Remote Layout

| Repo | Remote | URL | CLI |
|------|--------|-----|-----|
| ccsetup | `origin` | github.com/CorentinLumineau/ccsetup | source |
| ccsetup | `github-expert` | github.com/e-XpertSolutions/ccsetup | `gh` |
| ccsetup | `gitea` | git.dev.e-xpertsolutions.lan:AI/ccsetup | `tea` |
| x-workflows | `origin` | github.com/CorentinLumineau/x-workflows | source only |
| x-devsecops | `origin` | github.com/CorentinLumineau/x-devsecops | source only |

Only repos with non-origin remotes are synced. Currently only ccsetup qualifies.

## Usage

Run the script to sync latest tags and releases to all mirrors:

```bash
# Sync all repos (auto-discovers ccsetup + siblings)
skills/git-sync-remotes/scripts/sync-remotes.sh

# Sync a specific tag
skills/git-sync-remotes/scripts/sync-remotes.sh --tag v6.3.1

# Dry run (preview without executing)
skills/git-sync-remotes/scripts/sync-remotes.sh --dry-run

# Tags only (no release notes)
skills/git-sync-remotes/scripts/sync-remotes.sh --tags-only

# Sync a specific repo
skills/git-sync-remotes/scripts/sync-remotes.sh /path/to/repo
```

## How It Works

For each repo with non-origin remotes:

1. **Detect forge type** from remote URL (`github.com` → gh, anything else → tea)
2. **Push branch commits** to the remote via `git push {remote} {branch}`
3. **Push all tags** to the remote via `git push {remote} --tags`
4. **Fetch release notes** from origin via `gh release view`
5. **Create release** on target:
   - GitHub: `gh release create {tag} --repo {owner/repo} --notes {body}`
   - Gitea: `tea release create --login {name} --repo {owner/repo} --tag {tag} --note {body}`

Existing releases are detected and skipped (idempotent).

## Prerequisites

| Tool | Purpose | Check |
|------|---------|-------|
| `gh` | GitHub CLI | `gh --version` |
| `tea` | Gitea CLI | `tea --version` |
| `tea login` | Gitea auth | `tea login list` must include target host |

## When to Use

- After `/git-create-release` completes — propagate to mirrors
- After manually creating a GitHub release on origin
- When adding a new remote to a repo and want to backfill
- Periodically to ensure mirrors are in sync

## Integration with /git-create-release

Run after `/git-create-release` to complete the distribution:

```
/git-create-release patch
  └── origin releases created (GitHub/CorentinLumineau)

/git-sync-remotes
  └── mirrors updated (Gitea, GitHub/e-XpertSolutions)
```

## Workflow Chaining

**Next Verb**: None (terminal)

| Trigger | Chain To | Auto? |
|---------|----------|-------|
| "done" | Stop | Yes |

<chaining-instruction>

After sync complete:
"All remotes synced. What's next?"
- Option 1: Done - Sync complete

</chaining-instruction>

## Safety Rules

**NEVER:**
- Force push to any remote
- Delete remote tags or releases
- Sync without verifying origin state

**ALWAYS:**
- Verify origin is the expected owner before syncing
- Skip existing releases (idempotent)
- Report failures per-remote without aborting entire sync

## References

- @skills/git-create-release/ - Release creation workflow
- @skills/git-merge-pr/ - PR merge workflow
