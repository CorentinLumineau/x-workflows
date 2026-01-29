# Mode: commit

> **Invocation**: `/x-git` or `/x-git commit`
> **Legacy Command**: `/x:commit`

<purpose>
Intelligent commit with auto-generated conventional commit messages following git-workflow skill safety rules.
</purpose>

## Behavioral Skills

This mode activates:
- `git-workflow` - Safe git operations

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 20%, context 25%, technical 20%, scope 25%, risk 10%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Mixed changes in staging, commit message scope unclear.

---

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
Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

**Examples**:
- `feat(auth): add JWT token validation`
- `fix(api): handle null response from server`
- `docs(readme): update installation instructions`

### Phase 4: Stage and Commit

```bash
# Stage relevant files
git add <files>

# Commit with HEREDOC for message
git commit -m "$(cat <<'EOF'
<type>(<scope>): <description>

<body>

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"

# Verify success
git status
```

### Phase 5: Workflow Transition

```json
{
  "questions": [{
    "question": "Commit created. Continue?",
    "header": "Next",
    "options": [
      {"label": "/x-review (Recommended)", "description": "PR review"},
      {"label": "/x-git release", "description": "Create release"},
      {"label": "Stop", "description": "Done"}
    ],
    "multiSelect": false
  }]
}
```

</instructions>

<decision_making>
**Act Autonomously**: Always perform all phases (1-5) to completion without asking between phases. The workflow is standardized.

**Ask User When**:
- Type classification is ambiguous (ask: "Is this a feat or refactor?")
- Scope is unclear (ask: "What's the scope - auth, api, or database?")
- Breaking changes detected (ask: "Is this a breaking change?")
- Secrets detected in changes (ask: "Should I exclude this file?")
</decision_making>

<critical_rules>
1. **Verify First** - Run `/x-verify` before staging files
2. **Conventional Format** - ALWAYS follow type(scope): description format
3. **Include Co-Author** - Every commit must include Co-Authored-By footer
4. **Atomic Commits** - One logical change per commit, never mix concerns
5. **No Secrets** - Never commit credentials, keys, or sensitive data
6. **No Force Push** - Never force push to main/master (blocking rule)

**NEVER**:
- Skip verification steps
- Amend already-pushed commits
- Force push without explicit approval
</critical_rules>

<output_format>
After successful commit, output:
```
Commit created:
- Type: {type}
- Scope: {scope}
- Message: {subject}
- Files: {count} files staged
- Hash: {commit_hash}

Verification: ✓ All checks passed
```
</output_format>

## Safety Rules

**NEVER**:
- Force push to main/master
- Skip hooks without explicit request
- Amend pushed commits
- Commit secrets or credentials
- Commit without verification

**ALWAYS**:
- Use conventional commit format
- Include Co-Authored-By
- Verify with git status after commit

## Commit Message Guidelines

- **Subject**: Imperative mood, <50 chars
- **Body**: Explain what and why, not how
- **Scope**: Optional but helpful (component name)

<success_criteria>
Commit is complete when:
- [ ] Changes analyzed (git status, diff reviewed)
- [ ] Commit type determined (feat/fix/docs/etc)
- [ ] Message generated and reviewed
- [ ] Files staged with git add
- [ ] Commit created with conventional format
- [ ] Status verified (git status shows clean)
- [ ] Output formatted and confirmed
</success_criteria>

## References

- @core-docs/RULES.md - Git workflow rules
- @skills/delivery-release-management/ - Safe release operations
