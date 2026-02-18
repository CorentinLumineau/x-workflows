# Cleanup Execution Details

## Delete Local Branch

```bash
# Safe delete (only if merged)
git branch -d {branch}

# If safe delete fails and user approved force-delete
git branch -D {branch}
```

Capture exit code:
- Exit 0: Success
- Exit 1: Not fully merged (requires -D)

## Delete Remote Branch

**GitHub/Gitea/GitLab**:
```bash
git push origin --delete {branch}
```

Verify deletion:
```bash
git ls-remote --heads origin {branch}
```

Should return empty (branch deleted remotely).

## Track Deletion Status

- Success: Local done, Remote done
- Partial: Local done, Remote failed
- Failed: Local not deleted

## Prune Stale Remote References

Preview what will be pruned:
```bash
git remote prune origin --dry-run
```

Execute pruning:
```bash
git remote prune origin
```

Verify:
```bash
git branch -r
```

Ensure no `origin/{deleted-branch}` refs remain for deleted branches.

## Cleanup Summary Report Template

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

## Optional: Garbage Collection

```bash
git gc --auto
```

This cleans up unreachable objects from deleted branches.
