# Safety Protocol & Deletion Execution

Detailed safety rules, deletion procedures, and critical constraints for branch cleanup.

## Phase 4: Execute Cleanup (Detailed)

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
- Success: Local check, Remote check
- Partial: Local check, Remote x (remote delete failed)
- Failed: Local x (branch not deleted)

## Safety Rules

1. **Never delete protected branches** (main, master, develop, release-*, hotfix-*)
2. **Never delete current branch** (require checkout to different branch first)
3. **Never force-delete** without explicit human confirmation and showing unmerged commits
4. **Never delete remote branches** without verifying local deletion succeeded first
5. **Always preview** what `git remote prune` will do before executing
6. **Always retain** active branches (commits in last 30 days)

## Critical Rules

- **CRITICAL**: Protected branch patterns MUST be checked before every deletion
- **CRITICAL**: Force-delete gate MUST show unmerged commit list to user
- **CRITICAL**: Remote deletion failures MUST be reported (don't silently fail)
- **CRITICAL**: Current branch MUST never appear in deletion candidates
- **CRITICAL**: Stale branch deletion REQUIRES explicit "DELETE STALE" confirmation phrase

## Success Criteria

- All safe-to-delete branches removed successfully
- Stale branches handled per user preference
- Orphaned branches preserved unless explicitly approved
- Protected branches never touched
- Remote branches deleted where appropriate
- Stale remote refs pruned
- Naming convention report generated
- Cleanup summary report provided to user
