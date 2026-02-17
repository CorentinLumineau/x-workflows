---
name: git-cleanup-branches
description: Use when branches have accumulated and need cleanup after merges or stale work.
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

<state-checkpoint id="cleanup-init" phase="git-cleanup-branches" status="cleanup-init">
Checkpoint captures: Current branch, repository state, protected branches list
</state-checkpoint>

**Activate forge-awareness** to detect GitHub/Gitea/GitLab context.

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

**List local branches** with metadata:
```bash
git for-each-ref --format='%(refname:short)|%(upstream)|%(committerdate:iso8601)|%(upstream:track)' refs/heads/
```

**List remote branches**:
```bash
git for-each-ref --format='%(refname:short)|%(committerdate:iso8601)' refs/remotes/origin/
```

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

<state-checkpoint id="branch-inventory" phase="git-cleanup-branches" status="branch-inventory">
Checkpoint captures: Local branches list, remote branches list, metadata per branch
</state-checkpoint>

---

## Phase 2: Categorize Branches

**Process each branch** through categorization logic:

### Protected Branches
Match against `PROTECTED_BRANCHES` patterns:
```bash
for pattern in "${PROTECTED_BRANCHES[@]}"; do
  if [[ "$branch" == $pattern ]]; then
    CATEGORY="protected"
  fi
done
```

### Safe to Delete
Criteria:
1. Merged into main branch: `git branch --merged $MAIN_BRANCH | grep -q "^  $branch$"`
2. AND remote branch deleted (upstream status shows "gone")
3. AND NOT protected
4. AND NOT current branch

Example detection:
```bash
MERGED=$(git branch --merged $MAIN_BRANCH | grep -q "^  $branch$" && echo "yes" || echo "no")
UPSTREAM_STATUS=$(git for-each-ref --format='%(upstream:track)' refs/heads/$branch)
if [[ "$MERGED" == "yes" && "$UPSTREAM_STATUS" == "[gone]" ]]; then
  CATEGORY="safe-to-delete"
fi
```

### Stale Branches
Criteria:
1. No commits in 30+ days
2. NOT merged into main
3. NOT protected
4. NOT current branch

Calculate days since last commit:
```bash
LAST_COMMIT_DATE=$(git log -1 --format=%ci $branch)
DAYS_AGO=$(( ($(date +%s) - $(date -d "$LAST_COMMIT_DATE" +%s)) / 86400 ))
if [[ $DAYS_AGO -gt 30 && "$MERGED" == "no" ]]; then
  CATEGORY="stale"
fi
```

### Orphaned Branches
Criteria:
1. Local branch exists
2. No upstream tracking branch configured
3. NOT merged
4. NOT protected

Detection:
```bash
UPSTREAM=$(git for-each-ref --format='%(upstream)' refs/heads/$branch)
if [[ -z "$UPSTREAM" && "$MERGED" == "no" ]]; then
  CATEGORY="orphaned"
fi
```

### Active Branches
Criteria:
1. Commits in last 30 days
2. OR currently checked out
3. OR has active upstream tracking

Anything not matching other categories is "active".

<state-checkpoint id="branches-categorized" phase="git-cleanup-branches" status="branches-categorized">
Checkpoint captures: Category assignments per branch, statistics per category
</state-checkpoint>

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

<state-checkpoint id="deletion-plan-approved" phase="git-cleanup-branches" status="deletion-plan-approved">
Checkpoint captures: Selected branches for deletion, deletion strategy, user confirmation
</state-checkpoint>

---

## Phase 4: Execute Cleanup

**For each branch in deletion list**:

### 4.1 Verify Deletability
Double-check branch is not:
- Current branch
- Protected pattern match
- Main branch

If any safety check fails, skip with warning.

### 4.2 Delete Local Branch
```bash
# Safe delete (only if merged)
git branch -d {branch}

# If safe delete fails and user approved force-delete
git branch -D {branch}
```

Capture exit code:
- Exit 0: Success
- Exit 1: Not fully merged (requires -D)

If not fully merged:
<workflow-gate id="force-delete-branch-{branch}" severity="high">
"Branch {branch} is not fully merged to {main_branch}.

Force delete will LOSE UNMERGED COMMITS.

Unmerged commits:
{git log {main_branch}..{branch} --oneline}

Force delete {branch}? (yes/no)"
</workflow-gate>

If user confirms, use `git branch -D {branch}`.

### 4.3 Delete Remote Branch
If branch has remote counterpart:

**GitHub/Gitea/GitLab**:
```bash
git push origin --delete {branch}
```

Verify deletion:
```bash
git ls-remote --heads origin {branch}
```

Should return empty (branch deleted remotely).

**Track deletion status**:
- Success: Local ✓, Remote ✓
- Partial: Local ✓, Remote ✗ (remote delete failed)
- Failed: Local ✗ (branch not deleted)

<state-checkpoint id="cleanup-executed" phase="git-cleanup-branches" status="cleanup-executed">
Checkpoint captures: Deletion results per branch, success/failure counts, error messages
</state-checkpoint>

---

## Phase 5: Prune Stale Remote References

**Clean up stale remote-tracking branches**:
```bash
git remote prune origin --dry-run
```

Preview what will be pruned, then:
```bash
git remote prune origin
```

This removes refs to remote branches that no longer exist.

**Verify pruning**:
```bash
git branch -r
```

Ensure no `origin/{deleted-branch}` refs remain for deleted branches.

---

## Phase 6: Naming Convention Report

**Analyze remaining branches** for naming convention compliance.

**Standard conventions** (configurable):
```
feature/{description}    - New features
fix/{description}        - Bug fixes
hotfix/{description}     - Production hotfixes
release/{version}        - Release branches
chore/{description}      - Maintenance tasks
docs/{description}       - Documentation
test/{description}       - Testing branches
```

**Check each active branch** against patterns:
```bash
for branch in $(git branch --format='%(refname:short)'); do
  if [[ ! "$branch" =~ ^(feature|fix|hotfix|release|chore|docs|test)/ ]]; then
    NON_CONFORMING+=("$branch")
  fi
done
```

**Generate naming report**:
```
Branch Naming Convention Report
================================
Compliant:        {count} branches
Non-compliant:    {count} branches

Non-compliant branches:
- {branch1} → Suggested: feature/{branch1}
- {branch2} → Suggested: fix/{branch2}
- my-test   → Suggested: test/my-test

Recommendation: Rename non-compliant branches for consistency.
Use: git branch -m {old-name} {new-name}
```

Present report to user with suggestions.

---

## Phase 7: Cleanup Summary

<state-checkpoint id="cleanup-complete" phase="git-cleanup-branches" status="cleanup-complete">
Checkpoint captures: Final statistics, deletion summary, naming report, timestamp
</state-checkpoint>

**Generate final report**:
```
Branch Cleanup Complete
=======================

Deleted:
- Local branches:   {count}
- Remote branches:  {count}

Retained:
- Active branches:  {count}
- Protected:        {count}

Failed deletions:   {count}
{list failures if any}

Remote references pruned: {count}

Naming convention:
- Compliant:        {count}
- Non-compliant:    {count} (see report above)

Disk space reclaimed: ~{estimate} MB
```

**Optional: Run garbage collection**:
```bash
git gc --auto
```

This cleans up unreachable objects from deleted branches.

<state-cleanup id="cleanup-finished">
Clear checkpoints: cleanup-init, branch-inventory, branches-categorized, deletion-plan-approved, cleanup-executed, cleanup-complete
Retain summary report for audit
</state-cleanup>

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

## Example Usage

```bash
# Clean up branches after work session
/git-cleanup-branches

# Typically invoked after merging PRs
# Can be run periodically for maintenance
```

Expected workflow:
1. User invokes skill after merging work or periodically
2. Skill analyzes all local and remote branches
3. Skill categorizes branches by safety and activity
4. Skill presents cleanup plan with recommendations
5. User approves deletions (default safe, or custom selection)
6. Skill executes deletions with force-delete confirmations as needed
7. Skill prunes stale remote refs
8. Skill generates naming convention report
9. Skill provides cleanup summary

---

## Configuration (Optional)

Users can customize cleanup behavior via git config:

```bash
# Set stale branch threshold (days)
git config cleanup.staleDays 30

# Set protected branch patterns
git config cleanup.protectedPatterns "main,master,develop,release-*,hotfix-*"

# Enable auto-prune after cleanup
git config cleanup.autoPrune true

# Set naming convention patterns
git config cleanup.namingConvention "feature/,fix/,hotfix/,release/,chore/,docs/,test/"
```

Skill reads these configs if present, otherwise uses defaults.
