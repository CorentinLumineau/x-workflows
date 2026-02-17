---
name: git-create-release
description: Use when ready to create a versioned release after all quality checks pass.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
user-invocable: true
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
chains-to:
  - skill: git-sync-remotes
    condition: "multi-remote"
    auto: true
chains-from:
  - skill: git-commit
    auto: false
  - skill: git-merge-pr
    auto: false
---

# /git-create-release

> Create releases with semantic versioning and auto-generated release notes.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | UTILITY |
| **Phase** | N/A |
| **Position** | End of development cycle |

**Flow**: `[x-review approved]` → **`git-create-release`** → `[done]`

## Intention

**Version**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Determine version from commit history.
{{/if}}

## Behavioral Skills

This skill activates:
- `interview` - Zero-doubt confidence gate (HIGH RISK - 40% weight)

<instructions>

### Phase 0: Confidence Check (REQUIRED - HIGH RISK)

<workflow-gate type="choice" id="release-approval">
  <question>Ready to start release process. How would you like to proceed?</question>
  <header>Release approval</header>
  <option key="proceed" recommended="true">
    <label>Proceed with release</label>
    <description>Run pre-checks, determine version, and create release</description>
  </option>
  <option key="review-changes">
    <label>Review changes first</label>
    <description>Inspect unreleased changes before deciding on release</description>
  </option>
  <option key="cancel">
    <label>Cancel</label>
    <description>Abort release process</description>
  </option>
</workflow-gate>

<workflow-chain on="cancel" action="end" />

**Release mode has 40% risk weight** - always interview unless version is explicitly specified.

Activate `@skills/interview/` if:
- Version bump type unclear (major/minor/patch?)
- Unreleased changes unreviewed
- Tag already exists (would overwrite)
- Breaking changes present (needs migration guide)

### Phase 1: Pre-Release Checks

Verify ready for release:

```bash
# Ensure on main branch
git branch --show-current

# Ensure no uncommitted changes
git status

# Ensure up to date
git fetch origin
git status

# Run all quality gates
pnpm test
pnpm lint
pnpm build
```

**All checks must pass.** Stop if any fail.

### Phase 2: Version Determination

Determine new version based on semantic versioning:

| Change Type | Version Bump |
|-------------|--------------|
| Breaking change | Major (1.0.0 → 2.0.0) |
| New feature | Minor (1.0.0 → 1.1.0) |
| Bug fix | Patch (1.0.0 → 1.0.1) |

Analyze commits since last release:

```bash
# Get last tag
git describe --tags --abbrev=0

# Commits since last tag
git log $(git describe --tags --abbrev=0)..HEAD --oneline
```

### Phase 3: Release Notes Generation

Generate release notes from commits:

```markdown
## What's Changed

### Features
- feat: {description} ({commit})

### Bug Fixes
- fix: {description} ({commit})

### Other Changes
- chore: {description} ({commit})

**Full Changelog**: {compare_url}
```

### Phase 4: Create Release

<state-checkpoint phase="release" status="tag-created">
Track release progress: pre-checks passed, version determined, notes generated, tag created, release published.
</state-checkpoint>

```bash
# Create and push tag
git tag -a v{version} -m "Release v{version}"
git push origin v{version}

# Create GitHub release
gh release create v{version} \
  --title "v{version}" \
  --notes-file release-notes.md
```

### Phase 5: Post-Release

- Update version in package.json if needed
- Update CHANGELOG.md
- Announce release

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | Any release action |
| **High** | ALWAYS ASK | Version determination |
| **Medium** | ALWAYS ASK | Release notes review |
| **Low** | PROCEED | Only post-release cleanup |

<human-approval-framework>

**Releases ALWAYS require human approval.**

When approval needed, structure question as:
1. **Context**: Changes since last release
2. **Options**: Version bump choices (major/minor/patch)
3. **Recommendation**: Appropriate version based on commits
4. **Escape**: "Review changes first" option

</human-approval-framework>

## Agent Delegation

**Recommended Agent**: None (requires human oversight)

| Delegate When | Keep Inline When |
|---------------|------------------|
| Never (high risk) | Always inline with human oversight |

## Workflow Chaining

**Next Verb**: None (terminal)

| Trigger | Chain To | Auto? |
|---------|----------|-------|
| "done" | Stop | Yes |
| "start next feature" | `/x-plan` or `/x-brainstorm` | No (suggest) |

<chaining-instruction>

**Terminal phase**: release ends the workflow

After release published:
1. Update `.claude/workflow-state.json` (mark workflow complete, move to history, prune to max 5, delete file if no active workflow)
2. Cleanup stale Memory MCP entities (orchestration-*, delegation-log, interview-state)
3. Present options (no auto-chain — workflow is done):

<workflow-gate type="choice" id="release-next">
  <question>Release v{version} published. What's next?</question>
  <header>After release</header>
  <option key="sync">
    <label>Sync remotes</label>
    <description>Push release tag and changes to mirror remotes</description>
  </option>
  <option key="next-feature">
    <label>Start next feature</label>
    <description>Continue development with a new planning cycle</description>
  </option>
  <option key="done" recommended="true">
    <label>Done</label>
    <description>Release complete — no further action needed</description>
  </option>
</workflow-gate>

<workflow-chain on="sync" skill="git-sync-remotes" args="v{version}" />
<workflow-chain on="next-feature" skill="x-plan" args="{next feature context}" />
<workflow-chain on="done" action="end" />

<state-cleanup phase="terminal">
  <delete path=".claude/workflow-state.json" condition="no-active-workflows" />
  <memory-prune entities="orchestration-*" older-than="7d" />
  <history-prune max-entries="5" />
</state-cleanup>

</chaining-instruction>

## Semantic Versioning

```
MAJOR.MINOR.PATCH

MAJOR - Breaking changes (incompatible API changes)
MINOR - New features (backwards compatible)
PATCH - Bug fixes (backwards compatible)
```

### Pre-release Versions

```
1.0.0-alpha.1
1.0.0-beta.1
1.0.0-rc.1
```

## Safety Rules

**NEVER:**
- Release from non-main branch (without explicit approval)
- Release with failing tests
- Release with uncommitted changes
- Delete or modify release tags
- Skip release notes generation

**ALWAYS:**
- Run full verification first
- Generate release notes
- Use semantic versioning
- Get human approval before creating tag/release

## Critical Rules

1. **Verify First** - All quality gates must pass
2. **Semantic Versioning** - ALWAYS follow semver
3. **Document Changes** - Release notes must be comprehensive
4. **Tag Immutable** - Never modify release tags after creation
5. **Main Branch Only** - Releases only from main/master
6. **No Uncommitted Changes** - Working directory must be clean
7. **No Test Failures** - Release only with passing tests
8. **Human Approval** - Always get approval before release

## Output Format

After successful release:
```
Release Published:
- Version: v{version}
- Tag: {git_tag_hash}
- Branch: {branch}
- Commits: {count} since last release
- Release Notes: {url}

Verification: All checks passed, release live
```

## Navigation

| Direction | Verb | When |
|-----------|------|------|
| Previous | `/x-review` | Need more review |
| Done | Stop | Release complete |
| Next cycle | `/x-plan` | Start next feature |

## Success Criteria

- [ ] Pre-checks passed (on main, no uncommitted changes)
- [ ] All tests passing
- [ ] Build successful
- [ ] Version determined (semantic versioning)
- [ ] Release notes generated
- [ ] Human approval received
- [ ] Tag created
- [ ] Tag pushed
- [ ] GitHub release published
- [ ] CHANGELOG updated

## References

- @core-docs/RULES.md - Git workflow rules
- @skills/delivery-release-management/ - Safe release operations
