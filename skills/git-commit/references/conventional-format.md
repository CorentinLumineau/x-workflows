# Conventional Commit Format Reference

> Extracted from git-commit SKILL.md — commit format rules and type definitions.

## Format

```
<type>(<scope>): <description>

[body]

[footer]
```

## Types

| Type | Description |
|------|-------------|
| feat | New feature |
| fix | Bug fix |
| docs | Documentation only |
| style | Formatting, no code change |
| refactor | Code restructuring |
| test | Adding tests |
| chore | Maintenance |

## Footer: Issue Closure

When committing directly to the default branch (main/master), append issue-closing footer:

| Keyword | Example |
|---------|---------|
| Closes | `Closes #42` |
| Fixes | `Fixes #42` |
| Resolves | `Resolves #42` |

Only for direct-to-main commits. Feature branches use PR description footers instead.

## Guidelines

- **Subject**: Imperative mood, <50 chars
- **Body**: Explain what and why, not how
- **Scope**: Derived from group name (last path segment)
- **Footer**: Closes #N for direct-to-main commits linked to an issue

## Safety Rules

**NEVER:**
- Force push to main/master
- Skip hooks without explicit request
- Amend pushed commits
- Commit secrets or credentials (auto-excluded by sensitive scan)
- Commit without verification
- Use `git add -A` or `git add .` (always add specific files)
- Commit code with unresolved BLOCK-level violations

**ALWAYS:**
- Use conventional commit format
- Verify with git status after each commit
- Run verification before committing
- Confirm x-review enforcement summary shows no failures before staging
- Scan for sensitive files before grouping
- Create atomic commits (one logical change per commit)

## Output Formats

### Multi-commit summary:
```
## Commit Summary

| # | Type | Scope | Message | Files | Hash |
|---|------|-------|---------|-------|------|
| 1 | {type} | {scope} | {description} | {count} | {hash} |
| ... |

Total: {N} commits, {total_files} files
Verification: All checks passed
```

### Single commit (backwards-compatible):
```
Commit created:
- Type: {type}
- Scope: {scope}
- Message: {subject}
- Files: {count} files staged
- Hash: {commit_hash}

Verification: All checks passed
```
