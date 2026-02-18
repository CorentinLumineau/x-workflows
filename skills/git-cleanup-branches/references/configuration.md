# Configuration & Usage

## Example Usage

```bash
# Clean up branches after work session
/git-cleanup-branches

# Typically invoked after merging PRs
# Can be run periodically for maintenance
```

### Expected Workflow

1. User invokes skill after merging work or periodically
2. Skill analyzes all local and remote branches
3. Skill categorizes branches by safety and activity
4. Skill presents cleanup plan with recommendations
5. User approves deletions (default safe, or custom selection)
6. Skill executes deletions with force-delete confirmations as needed
7. Skill prunes stale remote refs
8. Skill generates naming convention report
9. Skill provides cleanup summary

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
