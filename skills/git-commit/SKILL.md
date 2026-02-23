---
name: git-commit
description: Use when code changes are complete and verified, ready to commit to git.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
user-invocable: true
argument-hint: "[message]"
metadata:
  author: ccsetup contributors
  version: "2.0.0"
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

<instructions>

### Phase 0: Confidence Check (Conditional)

Activate `@skills/interview/` if:
- Mixed changes in staging (multiple concerns)
- Commit message scope unclear
- Many unrelated changes across multiple areas

**Bypass allowed**: When changes are homogeneous and type is obvious.

### Phase 1: Change Detection

Detect ALL uncommitted changes (staged + unstaged + untracked):

```bash
# Full porcelain status for parsing
git status --porcelain

# Recent commits for style reference
git log --oneline -5
```

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

**For "all-separate" or "review-each"**: Iterate through each group in order:

1. Present group summary:
   ```
   ## Group {i}/{total}: {group_name}
   Files: {file_list}
   Type: {inferred_type}({scope})
   ```

2. If strategy is "review-each": show `git diff` for the group's files (staged and unstaged)

3. Auto-generate conventional commit message by analyzing the group's diff:
   - Refine type from diff content (not just path heuristics)
   - Generate imperative description (<50 chars)
   - Add body if changes warrant explanation

4. Present for text confirmation:
   ```
   Proposed: {type}({scope}): {description}
   Accept [Y], Skip [n], Edit [e]?
   ```
   - **Y** (default): Proceed to commit
   - **n**: Skip this group entirely (files remain uncommitted)
   - **e**: User provides alternative message

5. If confirmed:
   ```bash
   # Stage specific files for this group
   git add {file1} {file2} ...

   # Commit with HEREDOC for message
   git commit -m "$(cat <<'EOF'
   {type}({scope}): {description}

   {body}
   EOF
   )"

   # Verify success
   git status
   ```

6. Record commit hash, continue to next group

**For "single"**: Merge all groups into one commit:
1. Determine dominant type across all groups
2. Use broadest scope (or omit scope if too diverse)
3. Generate combined description
4. Present for confirmation (text prompt)
5. `git add` all files → single `git commit` → `git status`

**Safety enforced throughout**:
- Never use `git add -A` or `git add .` — always add specific files
- Never commit sensitive files (auto-excluded in Phase 1)
- Always use HEREDOC for commit messages
- Verify with `git status` after each commit

### Phase 5: Completion Summary + Chaining

Present commit summary table (see [references/conventional-format.md](references/conventional-format.md) for format).

Write a 1-line summary to MEMORY.md (L2) per the Workflow Completion Write Protocol.

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | Secrets detected; Strategy selection |
| **High** | ASK IF ABLE | Type classification ambiguous |
| **Medium** | ASK IF UNCERTAIN | Per-group commit confirmation |
| **Low** | PROCEED | Standard single-group commit |

## Workflow Chaining

<chaining-instruction>

**Terminal phase**: commit ends the workflow. Present next steps after completion:

<workflow-gate type="choice" id="commit-next">
  <question>{N} commit(s) created. What's next?</question>
  <header>After commit</header>
  <option key="release">
    <label>Create release</label>
    <description>Start release workflow for versioning and publishing</description>
  </option>
  <option key="done" recommended="true">
    <label>Done</label>
    <description>Workflow complete — no further action needed</description>
  </option>
</workflow-gate>

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

> See [references/conventional-format.md](references/conventional-format.md) for output format templates.

## Success Criteria

- [ ] Changes detected, grouped, and strategy selected
- [ ] Sensitive files auto-excluded
- [ ] Atomic commits created with conventional format
- [ ] Status verified after each commit

## References

- @core-docs/RULES.md - Git workflow rules
- @skills/delivery-release-git/ - Safe release operations
