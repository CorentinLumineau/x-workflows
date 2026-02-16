---
name: git-create-commit
description: Use when code changes are complete and verified, ready to commit to git.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
user-invocable: true
metadata:
  author: ccsetup contributors
  version: "2.0.0"
  category: workflow
chains-to:
  - skill: git-create-pr
    condition: "branch != main"
    auto: true
  - skill: git-create-release
    condition: "release workflow"
    auto: false
chains-from:
  - skill: x-review
    auto: true
  - skill: x-verify
    auto: false
  - skill: git-resolve-conflict
    auto: true
---

# /git-create-commit

> Interactively commit all changes grouped by area with auto-generated conventional commit messages.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | UTILITY |
| **Phase** | N/A |
| **Position** | End of any workflow |

**Flow**: `[any workflow]` → **`git-create-commit`** → `[optional: git-create-release]`

## Intention

**Changes**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Detect all uncommitted changes (staged, unstaged, untracked), group by area, and commit interactively.
{{/if}}

## Behavioral Skills

This skill activates:
- `interview` - Zero-doubt confidence gate (only if ambiguous)

<instructions>

### Phase 0: Confidence Check (Conditional)

Activate `@skills/interview/` if:
- Mixed changes in staging (multiple concerns)
- Commit message scope unclear
- Many unrelated changes across multiple areas

**Bypass allowed**: When changes are homogeneous and type is obvious.

### Phase 0b: Workflow State Check

1. Read `.claude/workflow-state.json` (if exists)
2. If active workflow exists:
   - Expected next phase is `commit`? → Proceed
   - Skipping `review`? → Warn: "Skipping review phase. Continue? [Y/n]"
   - Active workflow at different phase? → Confirm: "Active workflow at {phase}. Start new? [Y/n]"
3. If no active workflow → OK (git-create-commit can be standalone)

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
   - Example: `skills/git-create-commit/SKILL.md` → group `skills/git-create-commit`
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

- **Scope**: Last path segment of the group name (e.g., `skills/git-create-commit` → `git-create-commit`, `config` → `config`, `root` → project name)

Present groups table to user:

```
## Change Groups

| # | Group | Files | Suggested Type | Scope |
|---|-------|-------|----------------|-------|
| 1 | skills/git-create-commit | 2 | docs | git-create-commit |
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

### Phase 5: Update Workflow State

After all commits completed:

1. Read `.claude/workflow-state.json`
2. Mark `commit` phase as `"completed"` with timestamp
3. Mark entire workflow as `"completed"` (move to `history` array)
4. **Prune history**: Keep only the last 5 entries in the `history` array, remove older entries
5. **Cleanup check**: If no active workflow remains (only completed history):
   - Delete `.claude/workflow-state.json` entirely (prevents orphan accumulation)
6. If active workflow remains, write updated state to `.claude/workflow-state.json`
7. Write to Memory MCP entity `"workflow-state"`:
   - `"phase: commit -> completed"`
   - `"workflow: completed"`
   - `"commits: {count} atomic commits created"`
8. **Memory MCP cleanup** (best-effort):
   - Search for `orchestration-*` entities → delete all related to this workflow
   - Search for `delegation-log` → remove observations older than 7 days via `delete_observations`
   - Search for `interview-state` → remove expired observations via `delete_observations`

<state-cleanup phase="terminal">
  <delete path=".claude/workflow-state.json" condition="no-active-workflows" />
  <memory-prune entities="orchestration-*" older-than="7d" />
  <history-prune max-entries="5" />
</state-cleanup>

### Phase 6: Completion Summary + Chaining

Present multi-commit summary table:

```
## Commit Summary

| # | Type | Scope | Message | Files | Hash |
|---|------|-------|---------|-------|------|
| 1 | {type} | {scope} | {description} | {count} | {short_hash} |
| 2 | {type} | {scope} | {description} | {count} | {short_hash} |
| ... |

**Total**: {N} commits created, {total_files} files committed
```

If any groups were skipped, note: "Skipped groups: {list} ({file_count} files remain uncommitted)"

### Workflow Completion Summary (MANDATORY)

After successful commit(s), write a 1-line summary to MEMORY.md (L2):
```
## Recent Completions
- Completed {workflow_type} for {context_summary}: {N} commits created ({commit_hashes_short})
```

This is a MANDATORY L2 write per the Workflow Completion Write Protocol
(see @skills/initiative/references/persistence-architecture.md).

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | Secrets detected in changes; Strategy selection (Phase 3) |
| **High** | ASK IF ABLE | Type classification ambiguous |
| **Medium** | ASK IF UNCERTAIN | Per-group commit confirmation |
| **Low** | PROCEED | Standard single-group commit |

<human-approval-framework>

When approval needed, structure question as:
1. **Context**: Changes being committed (groups summary)
2. **Options**: Strategy choices or per-group accept/skip/edit
3. **Recommendation**: Most appropriate classification
4. **Escape**: "Cancel" or "Skip" option always available

</human-approval-framework>

## Agent Delegation

**Recommended Agent**: None (git operations inline)

| Delegate When | Keep Inline When |
|---------------|------------------|
| Never | Always inline |

## Workflow Chaining

**Next Verbs**: `/x-review`, `/git-create-release`

| Trigger | Chain To | Auto? |
|---------|----------|-------|
| "create PR", "review" | `/x-review` | No (suggest) |
| "release", "tag" | `/git-create-release` | No (suggest) |
| "done" | Stop | Yes |

<chaining-instruction>

**Terminal phase**: commit ends the workflow

After all commits created:
1. Update `.claude/workflow-state.json` (mark workflow complete, move to history, prune to max 5, delete file if no active workflow)
2. Cleanup stale Memory MCP entities (orchestration-*, delegation-log, interview-state)
3. Present options (no auto-chain — workflow is done):

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

### Config File Patterns

Files matching these patterns are grouped into the `config` group:
- `package.json`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
- `tsconfig*.json`, `jsconfig*.json`
- `Makefile`, `Rakefile`, `CMakeLists.txt`
- `.github/**`, `.claude/**`, `.vscode/**`
- `.gitignore`, `.gitattributes`, `.editorconfig`
- `*.config.js`, `*.config.ts`, `*.config.mjs`, `*.config.cjs`
- `.eslintrc*`, `.prettierrc*`, `.stylelintrc*`
- `docker-compose*.yml`, `Dockerfile*`
- `*.toml` (at root), `*.yaml`/`*.yml` (at root, excluding data files)

### Sensitive File Patterns (Auto-Excluded)

Files matching these patterns are **excluded from all groups** with a warning:
- `.env`, `.env.*` (e.g., `.env.local`, `.env.production`)
- `credentials*`, `secret*`, `*password*`, `*token*`
- `*.key`, `*.pem`, `*.p12`, `*.pfx`, `*.keystore`
- `id_rsa*`, `id_ed25519*`, `id_ecdsa*`
- `*.secret`, `*.credentials`

### Collection Directory Patterns

Directories that group at the second level (e.g., `skills/git-create-commit`):
- `skills`, `agents`, `hooks`, `commands`
- `src`, `lib`, `pkg`, `internal`
- `test`, `tests`, `__tests__`, `spec`
- `components`, `pages`, `routes`, `views`
- `modules`, `packages`, `apps`

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

### Guidelines

- **Subject**: Imperative mood, <50 chars
- **Body**: Explain what and why, not how
- **Scope**: Derived from group name (last path segment)

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
- Confirm x-verify enforcement summary shows no failures before staging
- Scan for sensitive files before grouping
- Create atomic commits (one logical change per commit)

## Critical Rules

1. **Verify First** — Run `/x-verify` before staging
2. **Conventional Format** — ALWAYS follow type(scope): description
3. **Atomic Commits** — One logical change per commit (per group)
4. **No Secrets** — Never commit credentials, keys, or sensitive data (auto-excluded)
5. **No Force Push** — Never force push to main/master
6. **Enforcement gate** — x-verify enforcement summary MUST show all pass before staging
7. **Sensitive Scan** — Always scan for sensitive files and auto-exclude before grouping
8. **Atomic Per Group** — Each group gets its own commit; never mix groups in one commit (unless user selects "single" strategy)

## Output Format

After successful commit(s):
```
## Commit Summary

| # | Type | Scope | Message | Files | Hash |
|---|------|-------|---------|-------|------|
| 1 | {type} | {scope} | {description} | {count} | {hash} |
| ... |

Total: {N} commits, {total_files} files
Verification: All checks passed
```

For single commit (backwards-compatible):
```
Commit created:
- Type: {type}
- Scope: {scope}
- Message: {subject}
- Files: {count} files staged
- Hash: {commit_hash}

Verification: All checks passed
```

## Navigation

| Direction | Verb | When |
|-----------|------|------|
| Next (review) | `/x-review` | Want PR review |
| Next (release) | `/git-create-release` | Ready for release |
| Done | Stop | Commit(s) complete |

## Success Criteria

- [ ] All uncommitted changes detected (staged + unstaged + untracked)
- [ ] Sensitive files scanned and auto-excluded
- [ ] Changes grouped by area using path analysis
- [ ] Strategy selected by user (separate/review/single/cancel)
- [ ] Commit type determined per group (feat/fix/docs/etc)
- [ ] Messages generated with conventional format
- [ ] Files staged with git add (specific files per group)
- [ ] Atomic commits created (one per group)
- [ ] Status verified after each commit (git status shows expected state)

## References

- @core-docs/RULES.md - Git workflow rules
- @skills/delivery-release-management/ - Safe release operations
