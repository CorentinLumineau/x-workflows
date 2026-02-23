---
name: git-implement-issue
description: Use when implementing a feature or fix tracked by a Gitea issue.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
user-invocable: true
metadata:
  author: ccsetup contributors
  version: "1.2.0"
  category: workflow
  argument-hint: "[issue-number]"
chains-to:
  - skill: x-auto
    condition: "default routing"
  - skill: x-plan
    condition: "complex issue"
  - skill: x-implement
    condition: "simple issue"
  - skill: git-review-pr
    condition: "existing PR found for issue"
chains-from:
  - skill: git-create-issue
---

# /git-implement-issue

> Issue-driven development: from Gitea issue to pull request in a single workflow.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | META (lifecycle) |
| **Phase** | orchestration |
| **Position** | 0 (entry point) |

**Flow**: **`git-implement-issue`** → `x-auto` → `{routed workflow}` → `[PR creation]`

## Intention

**Issue**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Fetch open issues without active PRs, group by milestone, and present interactive selection (Phase 0.5).
{{/if}}

## Behavioral Skills

This skill activates:
- `forge-awareness` - Detect forge type for issue fetching and PR creation
- `complexity-detection` - Workflow intent and complexity assessment (via x-auto delegation)
- `context-awareness` - Project context

<instructions>

### Phase 0: Validation

Verify prerequisites before proceeding.

1. **Forge CLI availability**:
```bash
# Try tea first, fall back to gh
tea --version 2>/dev/null || gh --version 2>/dev/null
```
If neither is found, stop and instruct: "Neither `tea` nor `gh` CLI found. Install one to use this workflow."

2. **Issue number validation**:
   - Extract the issue number from `$ARGUMENTS`
   - Must be a positive integer
   - If not provided or invalid, proceed to **Phase 0.5** for interactive selection

3. **Git repository check**:
```bash
git rev-parse --is-inside-work-tree
```
If not in a git repo, stop and instruct: "Run this command from inside a git repository."

4. **PR-awareness check** (only when a valid issue number was provided in step 2):

   Fetch open PRs to check for existing work on this issue:
   ```bash
   # Gitea
   tea pulls ls -o tsv -f index,title,head,state --state open --limit 50

   # GitHub
   gh pr list --state open --limit 50 --json number,title,headRefName,body
   ```

   Cross-reference the provided issue number against open PRs using the 3-condition algorithm from [references/issue-selection-guide.md](references/issue-selection-guide.md):
   - Branch-name match: open PR head is `feature-branch.$ISSUE_NUMBER`
   - Body-reference match: PR body contains `close #$ISSUE_NUMBER`, `closes #$ISSUE_NUMBER`, `fix #$ISSUE_NUMBER`, `fixes #$ISSUE_NUMBER`, or `resolve #$ISSUE_NUMBER` (case-insensitive)
   - Title-reference match: PR title contains `#$ISSUE_NUMBER` preceded by a word boundary

   **If match found** — present a workflow gate:

   <workflow-gate type="choice" id="pr-awareness">
     <question>Issue #$ISSUE_NUMBER already has an active PR (#$PR_NUMBER: $PR_TITLE). What would you like to do?</question>
     <header>Existing PR</header>
     <option key="continue">
       <label>Continue anyway</label>
       <description>Proceed with implementation (may create a second PR for this issue)</description>
     </option>
     <option key="review">
       <label>Switch to PR review</label>
       <description>Review the existing PR #$PR_NUMBER instead</description>
     </option>
     <option key="cancel">
       <label>Cancel</label>
       <description>Abort the workflow</description>
     </option>
   </workflow-gate>

   - If "Switch to PR review" → chain to `/git-review-pr $PR_NUMBER` and end this workflow
   - If "Cancel" → end workflow
   - If "Continue anyway" → proceed to Phase 1

   **If no match** → proceed normally to Phase 1.

### Phase 0.5: Issue Discovery & Selection

> Only entered when no valid issue number was provided. See [references/issue-selection-guide.md](references/issue-selection-guide.md) for API commands, scoring, and edge cases.

1. **Fetch open issues and open PRs** using the detected forge CLI (tea or gh)

2. **Filter** out issues that already have PRs (see [references/issue-selection-guide.md](references/issue-selection-guide.md) for full algorithm):
   - Branch-name match: open PR head is `feature-branch.N`
   - Body-reference match: PR body contains `close #N`, `closes #N`, `fix #N`, `fixes #N`, or `resolve #N` (case-insensitive)
   - Title-reference match: PR title contains `#N` preceded by a word boundary

3. **Score and sort** candidates using prioritization heuristic:
   - Has milestone (+30), urgency label (+20), priority/high (+15), bug (+10), age (+1/week), comments (+2/each)

4. **Group by milestone** (ordered by due date), then backlog for unassigned issues

5. **Present numbered list**:
```
No issue number provided. Open issues without active PRs:

## Milestone: v2.0.0 (due 2026-03-01) -- 2 issues
  [1] #12 git-skills should validate a complete state machine (14d)
  [2] #10 Add criteria verification for ecosystem audit (21d)

## Backlog -- 3 issues
  [3] #9  Refactor to use exclusively native memory system (28d)
  [4] #7  git-implement-issue should be aware of existing PRs (35d)
  [5] #6  Improve the PR review workflow (42d)
```

6. **User selection**:

<workflow-gate type="choice" id="issue-selection">
  <question>Which issue would you like to implement?</question>
  <header>Issue</header>
  <option key="pick">
    <label>Pick from list</label>
    <description>Select a number from the list above</description>
  </option>
  <option key="manual">
    <label>Enter issue number</label>
    <description>Type an issue number directly</description>
  </option>
  <option key="cancel">
    <label>Cancel</label>
    <description>Abort the workflow</description>
  </option>
</workflow-gate>

7. **Edge cases**:
   - 0 open issues: "No open issues found."
   - 0 candidates (all have PRs): "All open issues already have active PRs. Consider `/git-create-issue`."
   - 50+ candidates: show top 15, note "Showing top 15. Enter an issue number directly for others."

### Phase 1: Issue Context

Fetch and display the issue metadata.

1. **Fetch issue details**:
```bash
# Get issue title and body
tea issues details $ISSUE_NUMBER
```

2. **Fetch issue labels** (for context):
```bash
tea issues ls -o tsv -f index,title,labels --limit 200 | grep "^\"$ISSUE_NUMBER\""
```

3. **Display issue summary** to the user:
```
## Issue #$ISSUE_NUMBER

**Title**: $ISSUE_TITLE
**Labels**: $LABELS

### Description
$ISSUE_BODY
```

4. **Store metadata** for later phases:
   - `ISSUE_NUMBER` — the issue number
   - `ISSUE_TITLE` — the issue title
   - `ISSUE_BODY` — the issue body/description
   - `ISSUE_LABELS` — labels (if any)
   - `issue_selection` — `"argument"` (provided directly) or `"interactive"` (from Phase 0.5)

### Phase 2: Branch Setup

Select branch strategy and create or switch to the working branch.

1. **Branch strategy selection**:

<workflow-gate type="choice" id="branch-strategy">
  <question>How should changes be organized for issue #$ISSUE_NUMBER?</question>
  <header>Strategy</header>
  <option key="feature" recommended="true">
    <label>Feature branch (recommended)</label>
    <description>Create feature-branch.$ISSUE_NUMBER from a base branch</description>
  </option>
  <option key="direct">
    <label>Directly on current branch</label>
    <description>Implement on $CURRENT_BRANCH without creating a feature branch (skips PR)</description>
  </option>
</workflow-gate>

**If "direct" is chosen:**
   - Check for uncommitted changes:
```bash
git status --porcelain
```
   - If dirty working tree, offer stash/proceed/cancel
   - Store `branch_strategy = "direct"`, `feature_branch = null`, `pr_pending = false`
   - Skip to Phase 3

**If "feature" is chosen** (default):

2. **Detect base branch** — find the closest release branch:
```bash
# List remote release branches
git fetch --prune
git branch -r --list 'origin/release-branch.*'
```

If release branches exist, determine the best base via merge-base distance (closest wins). If no release branches exist, fall back to `main` or `master`.

3. **Present branch options**:

<workflow-gate type="choice" id="branch-setup">
  <question>Which base branch should the feature branch target?</question>
  <header>Base branch</header>
  <option key="auto">
    <label>$DETECTED_BASE (auto-detected)</label>
    <description>Closest release branch by merge-base distance</description>
  </option>
  <option key="main">
    <label>main</label>
    <description>Use main branch as base</description>
  </option>
  <option key="custom">
    <label>Other</label>
    <description>Specify a different base branch</description>
  </option>
</workflow-gate>

4. **Create and switch to feature branch**:
```bash
# Ensure we have latest
git fetch origin $BASE_BRANCH

# Create feature branch from the chosen base
git checkout -b feature-branch.$ISSUE_NUMBER origin/$BASE_BRANCH
```

If `feature-branch.$ISSUE_NUMBER` already exists, ask the user:

<workflow-gate type="choice" id="existing-branch">
  <question>Branch feature-branch.$ISSUE_NUMBER already exists. What should we do?</question>
  <header>Branch exists</header>
  <option key="switch">
    <label>Switch to it</label>
    <description>Continue working on the existing branch</description>
  </option>
  <option key="recreate">
    <label>Recreate it</label>
    <description>Delete and recreate from the base branch (loses uncommitted work)</description>
  </option>
  <option key="cancel">
    <label>Cancel</label>
    <description>Abort the workflow</description>
  </option>
</workflow-gate>

### Phase 3: Implementation

Set up workflow state and delegate to x-auto for implementation.

1. **Write workflow state** to `.claude/workflow-state.json`:
```json
{
  "active_workflow": "git-implement-issue",
  "issue_number": $ISSUE_NUMBER,
  "issue_title": "$ISSUE_TITLE",
  "issue_selection": "$ISSUE_SELECTION",
  "branch_strategy": "$BRANCH_STRATEGY",
  "base_branch": "$BASE_BRANCH",
  "feature_branch": "feature-branch.$ISSUE_NUMBER",
  "phases": {
    "context": "completed",
    "branch": "completed",
    "implement": "in_progress",
    "pr": "pending"
  },
  "pr_pending": true,
  "started_at": "$TIMESTAMP"
}
```

When `branch_strategy == "direct"`:
- `feature_branch`: `null`
- `base_branch`: `$CURRENT_BRANCH`
- `pr_pending`: `false`

2. **Chain to x-auto** for implementation routing:

Invoke x-auto with the routing context:
```
skill: "x-auto"
args: "Implement issue #$ISSUE_NUMBER: $ISSUE_TITLE\n\n$ISSUE_BODY"
```

x-auto will assess complexity and route to the appropriate workflow chain (APEX, ONESHOT, DEBUG, etc.).

**IMPORTANT**: After x-auto and its downstream chain complete, execution returns here for Phase 4.

### Phase 4: PR Creation (Conditional)

After implementation is complete, create a pull request or show completion summary.

**If `branch_strategy == "direct"`**: Skip PR creation, show completion summary:
```
## Issue #$ISSUE_NUMBER Complete (Direct Mode)

| Step | Status |
|------|--------|
| Issue fetched | Done |
| Branch strategy | Direct (on $CURRENT_BRANCH) |
| Implementation | Completed via x-auto |
| PR | Skipped (direct mode) |

Changes committed directly to $CURRENT_BRANCH.
To create a PR later: `git checkout -b feature-branch.$ISSUE_NUMBER` + `/git-create-pr`
```
Update workflow state to `"completed"` and clean up.

**If `branch_strategy == "feature"`**:

1. **Confirm PR creation**:

<workflow-gate type="choice" id="pr-creation">
  <question>Implementation complete. Ready to create a pull request?</question>
  <header>Create PR</header>
  <option key="create" recommended="true">
    <label>Create PR</label>
    <description>Push branch and create a pull request on Gitea</description>
  </option>
  <option key="skip">
    <label>Skip PR</label>
    <description>Skip PR creation — branch is ready for manual PR</description>
  </option>
  <option key="cancel">
    <label>Cancel</label>
    <description>Abort — no PR created</description>
  </option>
</workflow-gate>

2. **Push the branch**:
```bash
git push -u origin feature-branch.$ISSUE_NUMBER
```

3. **Analyze the diff** for PR description:
```bash
# Summary of changes
git diff origin/$BASE_BRANCH...HEAD --stat

# Full diff for understanding
git diff origin/$BASE_BRANCH...HEAD
```

For large diffs, focus on the most impactful files. Read modified source files if needed.

4. **Write PR description** (LLM-generated):

> See [references/pr-description-guide.md](references/pr-description-guide.md) for PR description template and guidelines.

5. **Create the PR**:
```bash
tea pulls create \
  --title "$ISSUE_TITLE" \
  --description "$(cat <<'EOF'
$PR_DESCRIPTION
EOF
)" \
  --base "$BASE_BRANCH" \
  --head "feature-branch.$ISSUE_NUMBER"
```

6. **Update workflow state**:
   - Mark `pr` phase as `"completed"`
   - Mark workflow as `"completed"`
   - Clean up `.claude/workflow-state.json` per git-commit cleanup protocol

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | PR creation, branch recreation |
| **High** | ALWAYS ASK | Issue selection, branch strategy, base branch selection, PR-awareness (existing PR found) |
| **Medium** | ASK IF UNCERTAIN | Issue interpretation |
| **Low** | PROCEED | Fetching issue details, pushing branch |

## Workflow Chaining

<chaining-instruction>

<workflow-chain on="implement" skill="x-auto" args="Implement issue #$ISSUE_NUMBER: $ISSUE_TITLE\n\n$ISSUE_BODY" />
<workflow-chain on="pr-create" action="phase4" />
<workflow-chain on="existing-pr-review" skill="git-review-pr" args="$PR_NUMBER" />
<workflow-chain on="cancel" action="end" />
<workflow-chain on="skip" action="end" />

</chaining-instruction>

## Safety Rules

**NEVER:**
- Auto-create PRs without explicit user confirmation
- Force push to any branch
- Delete remote branches without user approval
- Modify the base branch directly
- Skip the implementation phase
- Implement on main/release without explicit branch strategy selection

**ALWAYS:**
- Validate issue exists before creating branches
- Confirm base branch selection with the user
- Push feature branch before creating PR
- Include `close #N` in PR description (feature branch mode)
- Clean up workflow state after completion
- Verify working tree is clean before direct-on-branch implementation

## Critical Rules

1. **Issue First** — Always fetch and display the issue before any action
2. **Branch Convention** — Feature branches MUST follow `feature-branch.N` naming
3. **Human Gates** — PR creation, issue selection, and branch strategy require explicit approval
4. **Context Passing** — Pass full issue context (title + body) to x-auto
5. **State Tracking** — Maintain `.claude/workflow-state.json` throughout
6. **Clean Exit** — Update workflow state on completion or cancellation
7. **Strategy Awareness** — Respect branch strategy throughout; never create a PR in direct mode

## Output Format

> See [references/pr-description-guide.md](references/pr-description-guide.md) for output format and examples.

## Navigation

| Direction | Verb | When |
|-----------|------|------|
| Delegates to | `/x-auto` | Implementation routing |
| Terminal | Stop | PR created, direct-mode complete, or cancelled |

## Success Criteria

- [ ] Issue fetched and displayed to user
- [ ] PR-awareness check catches issues with active PRs (explicit issue number)
- [ ] Interactive selection works when no issue number provided
- [ ] Branch strategy choice presented (feature vs direct)
- [ ] Feature branch created from correct base (feature mode)
- [ ] Working tree verified clean (direct mode)
- [ ] Implementation completed (via x-auto chain)
- [ ] Branch pushed to remote (feature mode)
- [ ] PR created with proper description and `close #N` (feature mode)
- [ ] Completion summary with recovery path shown (direct mode)
- [ ] Workflow state cleaned up

## References

- @skills/x-auto/ - Task routing and complexity assessment
- @skills/git-commit/ - Workflow state management patterns
- @skills/complexity-detection/ - Shared complexity detection logic
- [references/issue-selection-guide.md](references/issue-selection-guide.md) - Issue discovery API and scoring
- [references/pr-description-guide.md](references/pr-description-guide.md) - PR description template
