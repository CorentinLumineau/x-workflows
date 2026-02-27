---
name: git-commit
description: Use when code changes are complete and verified, ready to commit to git.
version: "2.0.0"
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
user-invocable: true
argument-hint: "[message] [closes #N]"
metadata:
  author: ccsetup contributors
  category: workflow
chains-to:
  - skill: git-create-pr
    condition: "branch != main"
  - skill: git-create-release
    condition: "release workflow"
chains-from:
  - skill: x-review
  - skill: x-fix
  - skill: git-resolve-conflict
---

# /git-commit

> Interactively commit all changes grouped by area with auto-generated conventional commit messages.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | UTILITY |
| **Phase** | N/A |
| **Position** | End of any workflow |

**Flow**: `[any workflow]` → **`git-commit`** → `[optional: git-create-release]`

## Intention

**Changes**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Detect all uncommitted changes (staged, unstaged, untracked), group by area, and commit interactively.
{{/if}}

## Behavioral Skills

This skill activates:
- `forge-awareness` - Detect forge type for post-commit chaining context
- `interview` - Zero-doubt confidence gate (only if ambiguous)
- `verification-before-completion` - Pre-commit verification evidence gate

<instructions>

<hook-trigger event="PreToolUse" tool="Bash" condition="Before git commit operations">
  <action>Validate pre-commit hooks pass (secret scanning, lint-staged) before staging files</action>
</hook-trigger>

<permission-scope mode="default">
  <allowed>Read, Grep, Glob (change detection); Bash (git add, git commit, git status, git log, git diff)</allowed>
  <denied>Force push, amend published commits, commit sensitive files (.env, credentials, keys)</denied>
</permission-scope>

### Phase 0-1: Context Gathering, Branch Safety & Change Detection

<context-query tool="git_context" params='{"mode":"commit"}'>
  <fallback>
  1. `git branch --show-current` → detect current branch
  2. `git status --porcelain` → full change detection (staged + unstaged + untracked)
  3. `git log --oneline -5` → recent commits for style reference
  4. `git diff --stat` → unstaged diff summary
  5. `git diff --cached --stat` → staged diff summary
  </fallback>
</context-query>

**Branch safety** (always runs first):

If current branch is `main`, `master`, or `develop`:
- **WARN** user: "You are committing directly to protected branch"
- Force `@skills/interview/` activation (no bypass) to confirm intent
- If user declines: suggest `git checkout -b feature/my-change` first

**Issue-closing awareness** (main/master only):

If current branch is `main` or `master` (NOT `develop`):

1. **Check $ARGUMENTS** for issue reference pattern:
   - Match: `closes? #(\d+)`, `fix(?:es)? #(\d+)`, `resolve[sd]? #(\d+)` (case-insensitive)
   - If found: extract issue number → `CLOSE_ISSUE_NUMBER`, strip pattern from arguments

2. **If no issue in $ARGUMENTS**, offer interactive linking:

<workflow-gate type="choice" id="issue-link">
  <question>You are committing directly to {branch}. Link this commit to close an issue?</question>
  <header>Issue closure</header>
  <option key="enter-number">
    <label>Enter issue number</label>
    <description>Append "Closes #N" footer to commit message(s) — auto-closes the issue on push</description>
  </option>
  <option key="skip" recommended="true">
    <label>Skip</label>
    <description>Commit without issue reference</description>
  </option>
</workflow-gate>

   - "Enter issue number" → prompt for number, validate positive integer, store as `CLOSE_ISSUE_NUMBER`
   - "Skip" → `CLOSE_ISSUE_NUMBER = null`, proceed normally

3. If `CLOSE_ISSUE_NUMBER` set, confirm: `Issue linking: Commits will include "Closes #N" footer`

**Confidence check** (conditional):

Activate `@skills/interview/` if:
- Mixed changes in staging (multiple concerns)
- Commit message scope unclear
- Many unrelated changes across multiple areas

**Bypass allowed**: When changes are homogeneous and type is obvious.

**Edge case**: No changes detected → inform user "No uncommitted changes found.", exit gracefully.

Present a summary table:

```
## Change Summary

| Category | Count |
|----------|-------|
| Staged | {n} |
| Modified (unstaged) | {n} |
| Untracked | {n} |
| Deleted | {n} |
| **Total** | **{n}** |
```

**Sensitive file scan**: Match all detected files against these patterns:
- `.env*`, `credentials*`, `secret*`, `*.key`, `*.pem`, `*.p12`, `*.pfx`
- `*password*`, `*token*`, `*.keystore`, `id_rsa*`, `id_ed25519*`

If sensitive files are found:
1. Display WARNING with the list of matched files
2. **Auto-exclude** these files from ALL groups (do NOT include them in any commit)
3. Inform user: "Excluded {n} sensitive file(s) from commit groups. Review and commit manually if intended."

### Phase 2: Smart Grouping

Group all non-excluded changes by area using path analysis.

**Grouping algorithm** (applied to each file path):

1. **Config files** → `config` group
   - Matches: `package.json`, `package-lock.json`, `tsconfig*.json`, `Makefile`, `.github/*`, `.claude/*`, `.gitignore`, `*.config.js`, `*.config.ts`, `*.config.mjs`, `.eslintrc*`, `.prettierrc*`, `docker-compose*.yml`, `Dockerfile*`
2. **Root files** (no `/` in path) → `root` group
3. **Collection directories** (skills, agents, hooks, commands, src, lib, test, tests, components, pages, routes) with 2+ path segments → `{dir1}/{dir2}` group
   - Example: `skills/git-commit/SKILL.md` → group `skills/git-commit`
   - Example: `src/utils/helpers.ts` → group `src/utils`
4. **Other** → first directory segment as group name
   - Example: `docs/README.md` → group `docs`
   - Example: `scripts/build.sh` → group `scripts`

**Per-group inference** (agent refines via diff analysis):

| Condition | Inferred Type |
|-----------|---------------|
| All files are new (untracked/added) | `feat` |
| All files are `*.md` or docs paths | `docs` |
| All files are deleted | `chore` |
| All files in test/tests directories | `test` |
| Mixed or other | `chore` (conservative default) |

- **Scope**: Last path segment of the group name (e.g., `skills/git-commit` → `git-commit`, `config` → `config`, `root` → project name)

Present groups table to user:

```
## Change Groups

| # | Group | Files | Suggested Type | Scope |
|---|-------|-------|----------------|-------|
| 1 | skills/git-commit | 2 | docs | git-commit |
| 2 | config | 3 | chore | config |
| 3 | src/utils | 1 | feat | utils |
```

**Edge case**: Single group detected → Skip Phase 3, proceed directly to Phase 4 with "all-separate" strategy (single commit).

### Phase 3: Interactive Strategy Selection

<workflow-gate type="choice" id="commit-strategy">
  <question>How would you like to commit these {N} groups?</question>
  <header>Strategy</header>
  <option key="all-separate" recommended="true">
    <label>Commit all groups separately</label>
    <description>One atomic conventional commit per group (recommended)</description>
  </option>
  <option key="review-each">
    <label>Review each group</label>
    <description>Inspect diff, confirm/skip/edit message for each group</description>
  </option>
  <option key="single">
    <label>Commit everything together</label>
    <description>Single combined commit for all changes</description>
  </option>
  <option key="cancel">
    <label>Cancel</label>
    <description>Abort without committing anything</description>
  </option>
</workflow-gate>

<workflow-chain on="cancel" action="end" />

### Phase 4: Per-Group Commit Loop

**For "cancel"**: Inform user "Commit cancelled.", exit gracefully.

For the full per-group commit loop steps (present summary, show diff, generate message, confirm, stage+commit with HEREDOC, verify) and the single-commit strategy, see `references/commit-loop.md`.

**Key safety rules**: Never `git add -A`, never commit sensitive files, always use HEREDOC, always verify with `git status` after each commit.

### Phase 5: Completion Summary + Chaining

Present commit summary table (see [references/conventional-format.md](references/conventional-format.md) for format).

If `CLOSE_ISSUE_NUMBER` was set:
> Issue closure: Commits include "Closes #N" — issue will auto-close on push to {branch}

Write a 1-line summary to MEMORY.md (L2) per the Workflow Completion Write Protocol.

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | Secrets detected; Strategy selection |
| **High** | ASK IF ABLE | Type classification ambiguous |
| **Medium** | ASK IF UNCERTAIN | Per-group commit confirmation; Issue linking on main/master |
| **Low** | PROCEED | Standard single-group commit |

## Workflow Chaining

<chaining-instruction>

**Terminal phase**: commit ends the workflow. Present next steps after completion:

<workflow-gate type="choice" id="commit-next">
  <question>{N} commit(s) created. What's next?</question>
  <header>After commit</header>
  <option key="pr">
    <label>Create PR</label>
    <description>Open a pull request for this feature branch (branch != main only)</description>
  </option>
  <option key="release">
    <label>Create release</label>
    <description>Start release workflow for versioning and publishing</description>
  </option>
  <option key="done" recommended="true">
    <label>Done</label>
    <description>Workflow complete — no further action needed</description>
  </option>
</workflow-gate>

<workflow-chain on="pr" skill="git-create-pr" args="{branch name and commit summary}" />
<workflow-chain on="release" skill="git-create-release" args="{commit summary}" />
<workflow-chain on="done" action="end" />

</chaining-instruction>

## Grouping Rules

> See [references/grouping-rules.md](references/grouping-rules.md) for config file patterns, sensitive file patterns, and collection directory patterns.

## Conventional Commit Format & Safety

> See [references/conventional-format.md](references/conventional-format.md) for commit format, type definitions, safety rules, and output formats.

## Critical Rules

1. **Verify First** — Run `/x-review quick` before staging
2. **Conventional Format** — ALWAYS follow type(scope): description
3. **Atomic Commits** — One logical change per commit (per group)
4. **No Secrets** — Never commit credentials, keys, or sensitive data (auto-excluded)
5. **No Force Push** — Never force push to main/master
6. **Enforcement gate** — x-review enforcement summary MUST show all pass before staging
7. **Sensitive Scan** — Always scan for sensitive files and auto-exclude before grouping

## When to Load References

- **For commit format, type definitions, safety rules, and output templates**: See `references/conventional-format.md`
- **For config file patterns, sensitive file patterns, and collection directory patterns**: See `references/grouping-rules.md`
- **For per-group commit loop steps, single-commit strategy, and HEREDOC template**: See `references/commit-loop.md`

## Success Criteria

- [ ] Changes detected, grouped, and strategy selected
- [ ] Sensitive files auto-excluded
- [ ] Atomic commits created with conventional format
- [ ] Status verified after each commit
- [ ] Issue footer appended when on main/master and issue number provided

## References

- @core-docs/RULES.md - Git workflow rules
- @skills/delivery-release-git/ - Safe release operations
