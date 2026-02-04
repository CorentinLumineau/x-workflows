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
Co-Authored-By: Claude <noreply@anthropic.com>
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

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"

# Verify success
git status
```

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

After commit created:
"Commit created. What's next?"
- Option 1: `/x-review` - PR review
- Option 2: `/x-release` - Create release
- Option 3: Done

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

**ALWAYS:**
- Use conventional commit format
- Include Co-Authored-By footer
- Verify with git status after commit
- Run verification before committing

## Critical Rules

1. **Verify First** - Run `/x-verify` before staging
2. **Conventional Format** - ALWAYS follow type(scope): description
3. **Include Co-Author** - Every commit must include Co-Authored-By
4. **Atomic Commits** - One logical change per commit
5. **No Secrets** - Never commit credentials, keys, or sensitive data
6. **No Force Push** - Never force push to main/master

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
