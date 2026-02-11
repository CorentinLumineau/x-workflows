---
name: x-commit
description: Intelligent commit with auto-generated conventional commit messages.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---

# /x-commit

> Create conventional commits with auto-generated messages.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | UTILITY |
| **Phase** | N/A |
| **Position** | End of any workflow |

**Flow**: `[any workflow]` → **`x-commit`** → `[optional: x-release]`

## Intention

**Changes**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Analyze staged changes automatically.
{{/if}}

## Behavioral Skills

This skill activates:
- `interview` - Zero-doubt confidence gate (only if ambiguous)

<instructions>

### Phase 0: Confidence Check (Conditional)

Activate `@skills/interview/` if:
- Mixed changes in staging (multiple concerns)
- Commit message scope unclear

**Bypass allowed**: When changes are homogeneous and type is obvious.

### Phase 0b: Workflow State Check

1. Read `.claude/workflow-state.json` (if exists)
2. If active workflow exists:
   - Expected next phase is `commit`? → Proceed
   - Skipping `review`? → Warn: "Skipping review phase. Continue? [Y/n]"
   - Active workflow at different phase? → Confirm: "Active workflow at {phase}. Start new? [Y/n]"
3. If no active workflow → OK (x-commit can be standalone)

### Phase 1: Change Analysis

Analyze staged and unstaged changes:

```bash
# Check status
git status

# See what's staged
git diff --staged

# See what's not staged
git diff

# Recent commits for style
git log --oneline -5
```

### Phase 2: Change Classification

Classify changes for commit type:

| Type | When |
|------|------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Code style (formatting) |
| `refactor` | Code restructuring |
| `test` | Adding/fixing tests |
| `chore` | Maintenance, deps |

### Phase 3: Commit Message Generation

Generate conventional commit message:

```
<type>(<scope>): <description>

[optional body - what and why]

[optional footer]
```

**Examples**:
- `feat(auth): add JWT token validation`
- `fix(api): handle null response from server`
- `docs(readme): update installation instructions`

### Phase 4: Stage and Commit

```bash
# Stage relevant files (specific, not -A)
git add <files>

# Commit with HEREDOC for message
git commit -m "$(cat <<'EOF'
<type>(<scope>): <description>

<body>
EOF
)"

# Verify success
git status
```

### Phase 5: Update Workflow State

After successful commit:

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
8. **Memory MCP cleanup** (best-effort):
   - Search for `orchestration-*` entities → delete all related to this workflow
   - Search for `delegation-log` → remove observations older than 7 days via `delete_observations`
   - Search for `interview-state` → remove expired observations via `delete_observations`

<state-cleanup phase="terminal">
  <delete path=".claude/workflow-state.json" condition="no-active-workflows" />
  <memory-prune entities="orchestration-*" older-than="7d" />
  <history-prune max-entries="5" />
</state-cleanup>

### Workflow Completion Summary (MANDATORY)

After successful commit, write a 1-line summary to MEMORY.md (L2):
```
## Recent Completions
- Completed {workflow_type} for {context_summary}: committed as {commit_hash_short}
```

This is a MANDATORY L2 write per the Workflow Completion Write Protocol
(see @skills/initiative/references/persistence-architecture.md).

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | Secrets detected in changes |
| **High** | ASK IF ABLE | Type classification ambiguous |
| **Medium** | ASK IF UNCERTAIN | Scope unclear |
| **Low** | PROCEED | Standard commit |

<human-approval-framework>

When approval needed, structure question as:
1. **Context**: Changes being committed
2. **Options**: Different commit types/scopes
3. **Recommendation**: Most appropriate classification
4. **Escape**: "Review changes first" option

</human-approval-framework>

## Agent Delegation

**Recommended Agent**: None (simple git operations)

| Delegate When | Keep Inline When |
|---------------|------------------|
| Never | Always inline |

## Workflow Chaining

**Next Verbs**: `/x-review`, `/x-release`

| Trigger | Chain To | Auto? |
|---------|----------|-------|
| "create PR", "review" | `/x-review` | No (suggest) |
| "release", "tag" | `/x-release` | No (suggest) |
| "done" | Stop | Yes |

<chaining-instruction>

**Terminal phase**: commit ends the workflow

After commit created:
1. Update `.claude/workflow-state.json` (mark workflow complete, move to history, prune to max 5, delete file if no active workflow)
2. Cleanup stale Memory MCP entities (orchestration-*, delegation-log, interview-state)
3. Present options (no auto-chain — workflow is done):
   "Commit created. What's next?"

<workflow-gate type="choice" id="commit-next">
  <question>Commit created. What's next?</question>
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

<workflow-chain on="release" skill="x-release" args="{commit summary}" />
<workflow-chain on="done" action="end" />

</chaining-instruction>

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
- **Scope**: Optional but helpful (component name)

## Safety Rules

**NEVER:**
- Force push to main/master
- Skip hooks without explicit request
- Amend pushed commits
- Commit secrets or credentials
- Commit without verification
- Use `git add -A` (always add specific files)
- Commit code with unresolved BLOCK-level violations

**ALWAYS:**
- Use conventional commit format
- Verify with git status after commit
- Run verification before committing
- Confirm x-verify enforcement summary shows no failures before staging

## Critical Rules

1. **Verify First** — Run `/x-verify` before staging
2. **Conventional Format** — ALWAYS follow type(scope): description
3. **Atomic Commits** — One logical change per commit
4. **No Secrets** — Never commit credentials, keys, or sensitive data
5. **No Force Push** — Never force push to main/master
6. **Enforcement gate** — x-verify enforcement summary MUST show all ✅ before staging

## Output Format

After successful commit:
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
| Next (release) | `/x-release` | Ready for release |
| Done | Stop | Commit complete |

## Success Criteria

- [ ] Changes analyzed (git status, diff reviewed)
- [ ] Commit type determined (feat/fix/docs/etc)
- [ ] Message generated with conventional format
- [ ] Files staged with git add (specific files)
- [ ] Commit created
- [ ] Status verified (git status shows clean)

## References

- @core-docs/RULES.md - Git workflow rules
- @skills/delivery-release-management/ - Safe release operations
