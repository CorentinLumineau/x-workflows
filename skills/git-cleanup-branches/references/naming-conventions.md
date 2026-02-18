# Branch Naming Convention Report

## Standard Conventions (configurable)

```
feature/{description}    - New features
fix/{description}        - Bug fixes
hotfix/{description}     - Production hotfixes
release/{version}        - Release branches
chore/{description}      - Maintenance tasks
docs/{description}       - Documentation
test/{description}       - Testing branches
```

## Compliance Check

Check each active branch against patterns:
```bash
for branch in $(git branch --format='%(refname:short)'); do
  if [[ ! "$branch" =~ ^(feature|fix|hotfix|release|chore|docs|test)/ ]]; then
    NON_CONFORMING+=("$branch")
  fi
done
```

## Report Format

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
