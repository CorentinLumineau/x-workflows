---
name: git-create-pr
description: Use when code changes are on a feature branch and ready to submit as a pull request.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
user-invocable: true
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
  argument-hint: "[branch-name]"
chains-to:
  - skill: git-check-ci
    condition: "after PR created"
    auto: true
  - skill: git-review-pr
    condition: "PR needs local review"
    auto: false
chains-from:
  - skill: git-commit
    auto: true
---

# /git-create-pr

Create a pull request from the current or specified branch to the base branch, with conventional title and structured description.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Type** | UTILITY |
| **Position** | After commit/review |
| **Typical Flow** | `git-commit` or `x-review` → **`git-create-pr`** → `git-check-ci` or `git-review-pr` |
| **Human Gates** | PR creation (Critical), title/description review (Medium) |
| **State Tracking** | Updates workflow state with PR number and URL |

## Intention

Create a pull request on the detected forge (GitHub/Gitea) from the current feature branch to the base branch, with:
- Conventional commit-style PR title
- Structured description (Summary, Changes, Impact)
- Automatic issue linking if branch follows `feature-branch.N` pattern
- Appropriate labels based on changes

**Arguments**: `$ARGUMENTS` (optional) = branch name to create PR from (defaults to current branch)

## Behavioral Skills

This workflow activates:
- **forge-awareness** - Detects forge type (GitHub/Gitea) and uses appropriate CLI
- **interview** (conditional) - If PR scope is unclear or branch has no commits

## Instructions

<instructions>

### Phase 0: Forge Detection and Confidence Check

1. Activate `forge-awareness` behavioral skill to detect forge type and validate CLI availability
2. Verify current branch is not the default branch (main/master/develop)
3. If `$ARGUMENTS` provided, checkout that branch first
4. Check branch has commits ahead of base branch via `git log origin/main..HEAD --oneline`
5. If no commits found, explain situation and exit (nothing to PR)

### Phase 1: Branch Analysis

<!-- <state-checkpoint id="pr-analysis" data="branch_name, base_branch, commit_count, file_changes"> -->
1. Identify base branch (typically `main` or `master`) via `git remote show origin`
2. Generate diff summary via `git diff origin/{base}...HEAD --stat`
3. Analyze commit messages via `git log origin/{base}..HEAD --pretty=format:"%s"`
4. Categorize changes (feat/fix/refactor/docs/test/chore) based on files and commits
5. Store analysis in `pr_context.analysis` state

### Phase 2: Generate PR Title and Description

1. Generate conventional PR title following pattern: `{type}({scope}): {description}`
   - Extract type from commit prefixes (feat/fix/etc.)
   - Infer scope from primary directory changed
   - Keep title under 72 characters
2. Generate PR description with structure:
   ```markdown
   ## Summary
   [High-level what and why]

   ## Changes
   - [List key changes from diff]

   ## Impact
   - [Affected components/users]
   ```
3. Present title and description to user for review
<!-- <workflow-gate type="human-approval" criticality="medium" prompt="Review PR title and description. Approve or provide edits?"> -->

### Phase 3: Create Pull Request

1. Execute PR creation via forge CLI:
   - GitHub: `gh pr create --title "{title}" --body "{description}" --base {base_branch}`
   - Gitea: `tea pr create --title "{title}" --description "{description}" --base {base_branch}`
2. Present PR creation command to user for approval
<!-- <workflow-gate type="human-approval" criticality="critical" prompt="Create pull request with these details?"> -->
3. Execute command and capture PR URL and number
4. Store PR metadata in `pr_context.created_pr`

### Phase 4: Link Issue and Add Labels

1. Check if branch name matches `feature-branch.N` pattern
2. If match found:
   - Extract issue number N
   - Add "Closes #N" to PR description via forge CLI edit command
   <!-- <workflow-gate type="human-approval" criticality="medium" prompt="Link PR to issue #{N}?"> -->
3. Infer labels from changes:
   - `feat:` → `enhancement`
   - `fix:` → `bug`
   - `docs:` → `documentation`
   - `test:` → `testing`
4. Add labels via forge CLI (e.g., `gh pr edit {PR} --add-label {label}`)

### Phase 5: Update State and Present Results

<!-- <state-checkpoint id="pr-created" data="pr_number, pr_url, linked_issue"> -->
1. Update workflow state with:
   ```json
   {
     "pr_number": 123,
     "pr_url": "https://...",
     "linked_issue": 456,
     "labels": ["enhancement"],
     "created_at": "ISO-8601"
   }
   ```
2. Present success message with PR URL
3. Suggest next steps:
   <!-- <workflow-chain next="git-check-ci" condition="CI pipeline exists"> -->
   - If CI detected: "Check CI status with `/git-check-ci {PR}`"
   <!-- <workflow-chain next="git-review-pr" condition="reviewers configured"> -->
   - If reviewers configured: "Request reviews with `/git-review-pr {PR}`"

</instructions>

## Human-in-Loop Gates

| Gate | Criticality | Trigger Condition | Default Action |
|------|-------------|-------------------|----------------|
| Title/description review | Medium | Always before creation | Wait for approval |
| PR creation | Critical | After title/description approved | Wait for explicit confirmation |
| Issue linking | Medium | Branch matches feature-branch.N | Wait for confirmation |

## Workflow Chaining

<chaining-instruction>
**Chains from**: `git-commit`, `x-review`
**Chains to**: `git-check-ci`, `git-review-pr`

**Forward chaining**:
- If CI pipeline detected → suggest `/git-check-ci`
- If reviewers configured → suggest `/git-review-pr`
- Always present both options

**Backward compatibility**:
- Accepts PR creation after any commit workflow
- Works with manual commits (not just git-commit)
</chaining-instruction>

## Safety Rules

1. **Never create PR without user approval** - Always gate PR creation with explicit confirmation
2. **Never force-push during PR creation** - Preserve commit history
3. **Never modify base branch** - PR creation is read-only on base
4. **Validate branch state** - Confirm branch has commits and is ahead of base
5. **Respect forge rate limits** - Add delays between API calls if needed

## Critical Rules

1. **Pre-flight checks are mandatory**:
   - Verify not on default branch
   - Confirm commits exist ahead of base
   - Validate forge CLI availability
2. **State isolation**:
   - Store PR context separately from commit context
   - Never overwrite existing PR data
3. **Atomic operations**:
   - If PR creation fails, do not proceed to linking/labeling
   - Rollback is not possible - inform user of partial state

## Success Criteria

- [ ] Branch validated (not default, has commits ahead)
- [ ] PR title follows conventional commit format
- [ ] PR description includes Summary, Changes, Impact sections
- [ ] PR created successfully via forge CLI
- [ ] PR URL and number captured and presented
- [ ] Issue linked if branch matches pattern (with approval)
- [ ] Labels added based on change categorization
- [ ] Workflow state updated with PR metadata
- [ ] Next steps suggested to user

## References

- Conventional Commits: https://www.conventionalcommits.org/
- GitHub CLI PR docs: https://cli.github.com/manual/gh_pr_create
- Gitea Tea CLI: https://gitea.com/gitea/tea
