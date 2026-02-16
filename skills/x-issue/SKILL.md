---
name: x-issue
description: Use when implementing a feature or fix tracked by a Gitea issue.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
  user-invocable: true
  argument-hint: "<issue-number>"
---

# /x-issue

> Issue-driven development: from Gitea issue to pull request in a single workflow.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Workflow** | META (lifecycle) |
| **Phase** | orchestration |
| **Position** | 0 (entry point) |

**Flow**: **`x-issue`** → `x-auto` → `{routed workflow}` → `[PR creation]`

## Intention

**Issue**: $ARGUMENTS

{{#if not $ARGUMENTS}}
Ask user: "Which issue number would you like to work on?"
{{/if}}

## Behavioral Skills

This skill activates:
- `complexity-detection` - Workflow intent and complexity assessment (via x-auto delegation)
- `context-awareness` - Project context

<instructions>

### Phase 0: Validation

Verify prerequisites before proceeding.

1. **tea CLI availability**:
```bash
tea --version
```
If `tea` is not found, stop and instruct: "The `tea` CLI is required. Install it from https://gitea.com/gitea/tea and configure with `tea login add`."

2. **Issue number validation**:
   - Extract the issue number from `$ARGUMENTS`
   - Must be a positive integer
   - If not provided or invalid, ask: "Which issue number would you like to work on?"

3. **Git repository check**:
```bash
git rev-parse --is-inside-work-tree
```
If not in a git repo, stop and instruct: "Run this command from inside a git repository."

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

### Phase 2: Branch Setup

Create or switch to a feature branch for this issue.

1. **Detect base branch** — find the closest release branch:
```bash
# List remote release branches
git fetch --prune
git branch -r --list 'origin/release-branch.*'
```

If release branches exist, determine the best base via merge-base distance (closest wins). If no release branches exist, fall back to `main` or `master`.

2. **Present branch options**:

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

3. **Create and switch to feature branch**:
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
  "active_workflow": "x-issue",
  "issue_number": $ISSUE_NUMBER,
  "issue_title": "$ISSUE_TITLE",
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

2. **Chain to x-auto** for implementation routing:

Use the Skill tool to invoke x-auto with the issue context:
```
skill: "x-auto"
args: "Implement issue #$ISSUE_NUMBER: $ISSUE_TITLE\n\n$ISSUE_BODY"
```

x-auto will assess complexity and route to the appropriate workflow chain (APEX, ONESHOT, DEBUG, etc.).

**IMPORTANT**: After x-auto and its downstream chain complete, execution returns here for Phase 4.

### Phase 4: PR Creation

After implementation is complete, create a pull request linking back to the issue.

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

Structure the description as:

```markdown
## Summary
<2-3 sentences: what this PR does and why, referencing the issue context>

## Changes
<grouped bullet points by theme, NOT 1:1 with commits>

## Impact
<optional: breaking changes, migration notes, testing considerations>

close #$ISSUE_NUMBER
```

**Guidelines**:
- Be specific: mention component names, file counts, patterns used
- Group by theme, not by commit
- Highlight reviewer concerns: breaking changes, config changes, new dependencies
- Include metrics when relevant: line counts, component counts
- Skip trivial details
- The `Impact` section is optional — omit for straightforward PRs

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
   - Clean up `.claude/workflow-state.json` per git-create-commit cleanup protocol

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | PR creation confirmation |
| **Critical** | ALWAYS ASK | Branch recreation (data loss) |
| **High** | ALWAYS ASK | Base branch selection |
| **Medium** | ASK IF UNCERTAIN | Issue interpretation |
| **Low** | PROCEED | Fetching issue details, pushing branch |

<human-approval-framework>

When approval needed, structure question as:
1. **Context**: Current state and what's about to happen
2. **Options**: Clear choices with consequences
3. **Recommendation**: Highlight the suggested path
4. **Escape**: "Cancel" option always available

**CRITICAL**: PR creation requires explicit user approval. Never auto-create PRs.

</human-approval-framework>

## Workflow Chaining

**Next Verb**: `/x-auto` (delegates implementation routing)

| Trigger | Chain To | Auto? |
|---------|----------|-------|
| Phase 3 reached | `/x-auto` | Yes (with issue context) |
| Implementation complete | PR creation (Phase 4) | **HUMAN APPROVAL REQUIRED** |
| PR created | Stop | Yes |

<chaining-instruction>

After Phase 2 (branch setup):
1. Write workflow state with `pr_pending: true`
2. Use Skill tool to invoke x-auto with issue context
3. After x-auto chain completes, proceed to Phase 4 (PR creation)

<workflow-chain on="implement" skill="x-auto" args="Implement issue #$ISSUE_NUMBER: $ISSUE_TITLE\n\n$ISSUE_BODY" />
<workflow-chain on="pr-create" action="phase4" />
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

**ALWAYS:**
- Validate issue exists before creating branches
- Confirm base branch selection with the user
- Push feature branch before creating PR
- Include `close #N` in PR description
- Clean up workflow state after completion

## Critical Rules

1. **Issue First** — Always fetch and display the issue before any action
2. **Branch Convention** — Feature branches MUST follow `feature-branch.N` naming
3. **Human Gates** — PR creation and branch selection require explicit approval
4. **Context Passing** — Pass full issue context (title + body) to x-auto
5. **State Tracking** — Maintain `.claude/workflow-state.json` throughout
6. **Clean Exit** — Update workflow state on completion or cancellation

## Output Format

After successful PR creation:
```
## Issue #$ISSUE_NUMBER Complete

| Step | Status |
|------|--------|
| Issue fetched | Done |
| Branch created | feature-branch.$ISSUE_NUMBER |
| Implementation | Completed via x-auto |
| PR created | $PR_URL |

PR links to issue #$ISSUE_NUMBER and will auto-close on merge.
```

## Navigation

| Direction | Verb | When |
|-----------|------|------|
| Delegates to | `/x-auto` | Implementation routing |
| Terminal | Stop | PR created or cancelled |

## Success Criteria

- [ ] Issue fetched and displayed to user
- [ ] Feature branch created from correct base
- [ ] Implementation completed (via x-auto chain)
- [ ] Branch pushed to remote
- [ ] PR created with proper description and `close #N`
- [ ] Workflow state cleaned up

## Examples

**Standard feature** — `/x-issue 42`:
Fetches issue #42 → creates `feature-branch.42` → routes through x-auto (likely APEX) → creates PR with `close #42`.

**Bug fix** — `/x-issue 108`:
Fetches issue #108 → creates `feature-branch.108` → x-auto routes to ONESHOT/DEBUG → creates PR with `close #108`.

**Existing branch** — `/x-issue 42` (branch exists):
Detects existing `feature-branch.42` → asks user to switch or recreate → continues from current state.

## References

- @skills/x-auto/ - Task routing and complexity assessment
- @skills/git-create-commit/ - Workflow state management patterns
- @skills/complexity-detection/ - Shared complexity detection logic
