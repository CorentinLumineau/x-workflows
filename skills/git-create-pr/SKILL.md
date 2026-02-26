---
name: git-create-pr
description: Use when code changes are on a feature branch and ready to submit as a pull request.
version: "1.0.0"
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
user-invocable: true
argument-hint: "[branch-name]"
metadata:
  author: ccsetup contributors
  category: workflow
chains-to:
  - skill: git-check-ci
    condition: "after PR created"
  - skill: git-review-pr
    condition: "PR needs local review"
  - skill: git-review-multiple-pr
    condition: "batch review"
chains-from:
  - skill: git-commit
  - skill: git-implement-issue
  - skill: git-quickwins-to-pr
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

### Phase 0-1: Context Gathering and Branch Analysis

<context-query tool="project_context">
  <fallback>
  1. `git remote -v` → detect forge type (GitHub/Gitea) and CLI availability
  2. `gh --version 2>/dev/null || tea --version 2>/dev/null` → verify CLI
  3. `git symbolic-ref --short refs/remotes/origin/HEAD` → detect default branch
  </fallback>
</context-query>

<context-query tool="git_context" params='{"mode":"pr_create"}'>
  <fallback>
  1. `git rev-parse --abbrev-ref HEAD` → current branch
  2. `git log origin/{base}..HEAD --oneline` → commits ahead of base
  3. `git diff origin/{base}...HEAD --stat` → diff summary
  4. `git diff origin/{base}...HEAD --name-status` → changed files
  </fallback>
</context-query>

1. Verify current branch is not the default branch (main/master/develop)
2. If `$ARGUMENTS` provided, checkout that branch first
3. If no commits found ahead of base, explain situation and exit (nothing to PR)
4. Check if current branch is worktree-managed:
    - If branch name matches `worktree-*` pattern OR inside `.claude/worktrees/` → worktree session
    - Extract task context from worktree name or branch name
    - Note worktree origin for PR description enrichment
5. Categorize changes (feat/fix/refactor/docs/test/chore) based on files and commits
6. Store analysis in `pr_context.analysis` state

### Phase 2: Generate PR Title and Description

1. Generate conventional PR title following pattern: `{type}({scope}): {description}`
   - Extract type from commit prefixes (feat/fix/etc.)
   - Infer scope from primary directory changed
   - If worktree branch detected, use branch name to infer PR scope:
     - `worktree-feature-auth` → type `feat`, scope `auth`
     - `feature/auth-backend` → type `feat`, scope `auth`
     - `fix/memory-leak-api` → type `fix`, scope `api`
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
<workflow-gate type="human-approval" criticality="medium" prompt="Review PR title and description. Approve or provide edits?">
</workflow-gate>

### Phase 3: Create Pull Request

1. Execute PR creation via forge CLI:
   - GitHub: `gh pr create --title "{title}" --body "{description}" --base {base_branch}`
   - Gitea: `tea pr create --title "{title}" --description "{description}" --base {base_branch}`
2. Present PR creation command to user for approval
<workflow-gate type="human-approval" criticality="critical" prompt="Create pull request with these details?">
</workflow-gate>
3. Execute command and capture PR URL and number
4. Store PR metadata in `pr_context.created_pr`

### Phase 4: Link Issue and Add Labels

1. Check if branch name matches `feature-branch.N` pattern
2. If match found:
   - Extract issue number N
   - Add "Closes #N" to PR description via forge CLI edit command
   <workflow-gate type="human-approval" criticality="medium" prompt="Link PR to issue #{N}?">
   </workflow-gate>
3. Infer labels from changes:
   - `feat:` → `enhancement`
   - `fix:` → `bug`
   - `docs:` → `documentation`
   - `test:` → `testing`
4. Add labels via forge CLI (e.g., `gh pr edit {PR} --add-label {label}`)

### Phase 5: Update State and Present Results

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
4. If PR was created from a worktree branch:
   - Suggest: "This PR was created from a worktree. After merge, run `git worktree remove` and `git worktree prune` to clean up."
   - Do NOT auto-prune — user may want to keep the worktree for follow-up work

</instructions>

## Human-in-Loop Gates

| Gate | Criticality | Trigger Condition | Default Action |
|------|-------------|-------------------|----------------|
| Title/description review | Medium | Always before creation | Wait for approval |
| PR creation | Critical | After title/description approved | Wait for explicit confirmation |
| Issue linking | Medium | Branch matches feature-branch.N | Wait for confirmation |

## Workflow Chaining

<chaining-instruction>
**Chains from**: `git-commit`, `x-review`, `git-implement-issue`, `git-quickwins-to-pr`
**Chains to**: `git-check-ci`, `git-review-pr`

<workflow-gate type="choice" id="post-pr-next">
  <question>PR created. What would you like to do next?</question>
  <header>After PR</header>
  <option key="check-ci" recommended="true">
    <label>Check CI</label>
    <description>Monitor CI pipeline status for this PR</description>
  </option>
  <option key="review">
    <label>Review PR locally</label>
    <description>Run local code review on the PR</description>
  </option>
  <option key="done">
    <label>Done</label>
    <description>PR created — no further action needed</description>
  </option>
</workflow-gate>

<workflow-chain on="check-ci" skill="git-check-ci" args="$PR_NUMBER" />
<workflow-chain on="review" skill="git-review-pr" args="$PR_NUMBER" />
<workflow-chain on="done" action="end" />
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
