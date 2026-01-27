---
name: x-git
description: |
  Safe git operations including conventional commits and releases. Feature branches, versioning.
  Activate when committing changes, creating releases, or managing git workflows.
  Triggers: commit, release, git, version, tag, changelog.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---

# x-git

Safe git operations including conventional commits, feature branches, and releases.

## Modes

| Mode | Description |
|------|-------------|
| commit (default) | Intelligent commit with auto-generated message |
| release | Release workflow with versioning |

## Mode Detection
| Keywords | Mode |
|----------|------|
| "release", "tag", "version", "publish" | release |
| (default) | commit |

## Execution
- **Default mode**: commit
- **No-args behavior**: Analyze staged changes

## Behavioral Skills

This workflow activates these behavioral skills:
- `interview` - Zero-doubt confidence gate (Phase 0, high-risk for release)
- `release-management` - SemVer, changelog, safe git operations

## Safety Rules

**NEVER:**
- Force push to main/master
- Skip hooks without explicit request
- Amend pushed commits
- Use destructive git commands (reset --hard, clean -f)

**ALWAYS:**
- Use conventional commit format
- Run verification before commit
- Create feature branches for work

## Conventional Commit Format

```
<type>(<scope>): <description>

[body]

[footer]
```

### Types

| Type | Description |
|------|-------------|
| feat | New feature |
| fix | Bug fix |
| docs | Documentation only |
| style | Formatting, no code change |
| refactor | Code restructuring |
| test | Adding tests |
| chore | Maintenance |

## Commit Workflow

```
1. Review staged changes
2. Determine commit type
3. Write descriptive message
4. Follow conventional commit format
5. Verify tests pass
6. Create commit
```

## Release Workflow

```
1. Determine version bump (major/minor/patch)
2. Update version in files
3. Update CHANGELOG.md
4. Create version commit
5. Tag release
6. Push with tags
```

## Checklist

- [ ] Conventional commit format used
- [ ] Commit message is descriptive
- [ ] Tests pass before commit
- [ ] No sensitive data in commit
- [ ] Feature branch used (not main)

## When to Load References

- **For commit mode**: See `references/mode-commit.md`
- **For release mode**: See `references/mode-release.md`
