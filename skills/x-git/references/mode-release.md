# Mode: release

> **Invocation**: `/x-git release` or `/x-git release "version"`
> **Legacy Command**: `/x:release`

<purpose>
Automated GitHub release workflow with semantic versioning, tag creation, and release notes generation.
</purpose>

## Behavioral Skills

This mode activates:
- `git-workflow` - Safe git operations

<instructions>

### Phase 0: Interview Check (REQUIRED - HIGH RISK)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 15%, context 10%, technical 20%, scope 15%, risk **40%**)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode** (CRITICAL):
- Version bump type unclear (major/minor/patch?)
- Unreleased changes unreviewed
- Tag already exists (would overwrite)
- Breaking changes present (needs migration guide)

**Note**: Release mode has **40% risk weight** - always interview unless version is explicitly specified.

---

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

### Phase 2: Version Determination

Determine new version:

| Change Type | Version Bump |
|-------------|--------------|
| Breaking change | Major (1.0.0 → 2.0.0) |
| New feature | Minor (1.0.0 → 1.1.0) |
| Bug fix | Patch (1.0.0 → 1.0.1) |

If version not specified, analyze commits since last release:

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

### Phase 6: Workflow Transition

```json
{
  "questions": [{
    "question": "Release v{version} created. What's next?",
    "header": "Next",
    "options": [
      {"label": "Done", "description": "Release complete"},
      {"label": "Start next feature", "description": "Continue development"}
    ],
    "multiSelect": false
  }]
}
```

</instructions>

<decision_making>
**Act Autonomously**:
- Analyze commits and determine semantic version bump (major/minor/patch)
- Generate release notes from conventional commits
- Create tag and GitHub release without interruption

**Ask User When**:
- Version not specified AND commit history is ambiguous (ask: "Should this be v{major}.{minor}.{patch}?")
- Release notes need clarification (ask: "Is the summary accurate?")
- Non-main branch release (ask: "Release from {branch}? This is not main!")
- Test failures detected (ask: "Tests failed. Continue anyway?")
</decision_making>

<critical_rules>
1. **Verify First** - All quality gates must pass (tests, lint, build)
2. **Semantic Versioning** - ALWAYS follow semver (major.minor.patch)
3. **Document Changes** - Release notes must be comprehensive and accurate
4. **Tag Immutable** - Never delete or modify release tags after creation
5. **Main Branch Only** - Releases only from main/master (blocking rule)
6. **No Uncommitted Changes** - Working directory must be clean
7. **No Test Failures** - Release only with passing tests

**NEVER**:
- Release from non-main branch without explicit approval
- Release with failing tests
- Release with uncommitted changes
- Delete or modify existing release tags
- Skip release notes generation
</critical_rules>

<output_format>
After successful release, output:
```
Release Published:
- Version: v{version}
- Tag: {git_tag_hash}
- Branch: {branch}
- Commits: {count} since last release
- Release Notes: {url}

Verification: ✓ All checks passed, release live
```
</output_format>

## Safety Rules

**NEVER**:
- Release from non-main branch (without explicit approval)
- Release with failing tests
- Release with uncommitted changes
- Delete release tags

**ALWAYS**:
- Run full verification first
- Generate release notes
- Use semantic versioning

<success_criteria>
Release is complete when:
- [ ] Pre-checks passed (on main, no uncommitted changes, up to date)
- [ ] All tests passing (pnpm test)
- [ ] Build successful (pnpm build)
- [ ] Version determined (semantic versioning)
- [ ] Release notes generated (formatted with features/fixes/changes)
- [ ] Tag created (git tag -a v{version})
- [ ] Tag pushed (git push origin v{version})
- [ ] GitHub release published (gh release create)
- [ ] CHANGELOG updated (if applicable)
- [ ] Output confirmed and verified
</success_criteria>

## References

- @core-docs/RULES.md - Git workflow rules
- @skills/git-workflow/SKILL.md - Safe operations
