---
name: git-cleanup-branches
description: Use when branches have accumulated and need cleanup after merges or stale work.
version: "1.0.0"
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
user-invocable: true
argument-hint: "[--stale] [--orphaned]"
metadata:
  author: ccsetup contributors
  category: workflow
chains-to: []
chains-from:
  - skill: git-merge-pr
---

# /git-cleanup-branches

## Workflow Context

| Attribute | Value |
|-----------|-------|
| Type | UTILITY |
| Position | After merge or periodically |
| Flow | `git-merge-pr` → **`git-cleanup-branches`** → done |

---

## Intention

Safely clean up accumulated git branches through intelligent categorization:
- Identify merged, stale, orphaned, and active branches
- Present cleanup plan with safety categorization
- Execute user-approved deletions locally and remotely
- Validate branch naming conventions
- Generate cleanup report with recommendations

**Arguments**: None (analyzes entire repository)

---

## Behavioral Skills

| Skill | When | Purpose |
|-------|------|---------|
| `forge-awareness` | Phase 0 | Detect forge for remote branch deletion commands |

---

<instructions>

## Phase 0: Initialize Cleanup Context

<context-query tool="project_context">
  <fallback>
  1. `git remote -v` → detect forge type (GitHub/Gitea/GitLab)
  2. `gh --version 2>/dev/null || tea --version 2>/dev/null` → verify CLI availability
  </fallback>
</context-query>

**Capture current state**:
```bash
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
MAIN_BRANCH=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)
```

**Define protected branches** (never delete):
```
PROTECTED_BRANCHES=(
  "main"
  "master"
  "develop"
  "development"
  "staging"
  "production"
  "release-*"  # glob pattern
  "hotfix-*"   # glob pattern
)
```

**Sync remote state**:
```bash
git fetch --all --prune
```

This ensures accurate remote tracking information.

---

## Phase 1: Enumerate All Branches

<context-query tool="git_context" params='{"mode":"branch_list"}'>
  <fallback>
  **List local branches** with metadata:
  ```bash
  git for-each-ref --format='%(refname:short)|%(upstream)|%(committerdate:iso8601)|%(upstream:track)' refs/heads/
  ```

  **List remote branches**:
  ```bash
  git for-each-ref --format='%(refname:short)|%(committerdate:iso8601)' refs/remotes/origin/
  ```
  </fallback>
</context-query>

**Parse into structured data**:
For each local branch, capture:
- Name
- Upstream tracking branch (if any)
- Last commit date
- Tracking status (ahead/behind/gone)
- Merged status: `git branch --merged $MAIN_BRANCH | grep {branch}`

For each remote branch, capture:
- Name (strip `origin/` prefix)
- Last commit date

---

## Phase 2: Categorize Branches

**Process each branch** through categorization logic into: **protected**, **safe-to-delete** (merged + remote gone), **stale** (30+ days, unmerged), **orphaned** (no upstream), or **active**.

> **Detailed categorization scripts**: See `references/branch-categorization.md`

**Generate category summary**:
```
Branch Cleanup Analysis
=======================
Protected:        {count} branches (never deleted)
Safe to delete:   {count} branches (merged + remote deleted)
Stale:            {count} branches (30+ days, not merged)
Orphaned:         {count} branches (no remote tracking)
Active:           {count} branches (recent activity)
```

---

## Phase 3: Present Cleanup Plan

**Build interactive cleanup table**:

| Category | Branch Name | Last Commit | Status | Selected |
|----------|-------------|-------------|--------|----------|
| **Safe** | feature-123 | 5 days ago | Merged, remote deleted | ✓ |
| **Safe** | bugfix-456 | 2 weeks ago | Merged, remote deleted | ✓ |
| **Stale** | experiment-old | 45 days ago | Not merged | ✗ |
| **Stale** | feature-abandoned | 60 days ago | Not merged | ✗ |
| **Orphaned** | local-test | 10 days ago | No remote | ✗ |
| **Active** | feature-new | 2 days ago | In progress | ✗ |
| **Protected** | main | 1 hour ago | Protected | ✗ |

**Default selections**:
- Safe to delete: ✓ (selected by default)
- Stale: ✗ (not selected - requires user review)
- Orphaned: ✗ (not selected - may contain valuable local work)
- Active: ✗ (not selected)
- Protected: ✗ (never selectable)

<workflow-gate id="approve-cleanup-plan" severity="critical">
Present cleanup table and summary:

"Found {total} branches for potential cleanup:
- {safe_count} safe to delete (merged, remote deleted)
- {stale_count} stale branches (30+ days old, not merged)
- {orphaned_count} orphaned branches (no remote tracking)
- {active_count} active branches (kept)
- {protected_count} protected branches (never deleted)

Default: Delete {safe_count} safe branches.

Options:
1. Proceed with default (safe branches only)
2. Customize selection (choose which branches to delete)
3. Include stale branches (add 30+ day old branches)
4. Cancel cleanup

Choose option:"

Wait for user selection.
</workflow-gate>

If option 2 (customize):
- Present each branch individually
- Ask: "Delete {branch}? (merged: {yes/no}, age: {days}, remote: {exists/gone})"
- Build custom deletion list

If option 3 (include stale):
- Add all stale branches to deletion list
- Require additional confirmation:
  <workflow-gate id="confirm-stale-deletion" severity="high">
  "WARNING: Deleting {count} stale branches that are NOT merged:
  {list of stale branches}

  This may lose work if branches contain unmerged changes.
  Type 'DELETE STALE' to confirm."

  Require exact phrase match.
  </workflow-gate>

---

## Phase 4: Execute Cleanup

**For each branch in deletion list**:
1. Verify deletability (not current, not protected, not main)
2. Delete local branch via `git branch -d` (safe) or `git branch -D` (force)
3. If not fully merged, require force-delete confirmation:

<workflow-gate id="force-delete-branch-{branch}" severity="high">
"Branch {branch} is not fully merged. Force delete will LOSE UNMERGED COMMITS. Force delete? (yes/no)"
</workflow-gate>

4. Delete remote branch via `git push origin --delete {branch}`
5. Track deletion status per branch (success/partial/failed)

> **Detailed deletion commands and verification**: See `references/cleanup-execution.md`

---

## Phase 5: Prune Stale Remote References

Run `git remote prune origin` (preview with `--dry-run` first) to remove refs to deleted remote branches. Verify with `git branch -r`.

---

## Phase 6: Naming Convention Report

**Analyze remaining branches** for naming convention compliance (feature/, fix/, hotfix/, release/, chore/, docs/, test/). Generate compliance report with rename suggestions for non-conforming branches.

> **Convention patterns and check scripts**: See `references/naming-conventions.md`

---

## Phase 7: Cleanup Summary

Generate final report with deleted/retained counts, failed deletions, pruned refs, naming compliance, and disk space estimate. Optionally run `git gc --auto`.

> **Report template**: See `references/cleanup-execution.md`

</instructions>

---

## Human-in-Loop Gates

| Gate ID | Severity | Trigger | Required Action |
|---------|----------|---------|-----------------|
| `approve-cleanup-plan` | Critical | Before any deletions | Select cleanup strategy (default/custom/include-stale/cancel) |
| `confirm-stale-deletion` | High | User wants to delete stale unmerged branches | Explicit confirmation with phrase match |
| `force-delete-branch-{branch}` | High | Branch not fully merged but user wants to delete | Confirm force-delete knowing commits will be lost |

---

## Workflow Chaining

| Relationship | Target Skill | Condition |
|--------------|--------------|-----------|
| chains-to | None | Terminal skill (no chaining) |
| chains-from | `git-merge-pr` | PR merged, cleanup merged branches |

---

## Safety Rules

1. **Never delete protected branches** (main, master, develop, release-*, hotfix-*)
2. **Never delete current branch** (require checkout to different branch first)
3. **Never force-delete** without explicit human confirmation and showing unmerged commits
4. **Never delete remote branches** without verifying local deletion succeeded first
5. **Always preview** what `git remote prune` will do before executing
6. **Always retain** active branches (commits in last 30 days)

---

## Critical Rules

- **CRITICAL**: Protected branch patterns MUST be checked before every deletion
- **CRITICAL**: Force-delete gate MUST show unmerged commit list to user
- **CRITICAL**: Remote deletion failures MUST be reported (don't silently fail)
- **CRITICAL**: Current branch MUST never appear in deletion candidates
- **CRITICAL**: Stale branch deletion REQUIRES explicit "DELETE STALE" confirmation phrase

---

## Success Criteria

- All safe-to-delete branches removed successfully
- Stale branches handled per user preference
- Orphaned branches preserved unless explicitly approved
- Protected branches never touched
- Remote branches deleted where appropriate
- Stale remote refs pruned
- Naming convention report generated
- Cleanup summary report provided to user

---

## References

- Behavioral skill: `@skills/forge-awareness/` (remote deletion commands)
- Knowledge skill: `@skills/vcs-git-workflows/` (branch lifecycle patterns)
- Knowledge skill: `@skills/vcs-conventional-commits/` (naming convention standards)

---

## When to Load References

- **For branch categorization scripts (merged, stale, orphaned, active)**: See `references/branch-categorization.md`
- **For branch naming convention patterns and compliance checks**: See `references/naming-conventions.md`
- **For configuration options and usage examples**: See `references/configuration.md`
- **For deletion commands, verification steps, and cleanup summary report template**: See `references/cleanup-execution.md`
- **For safety rules, deletion procedures, and critical constraints**: See `references/safety-protocol.md`
