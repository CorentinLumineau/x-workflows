---
name: git-implement-issue
description: Use when implementing a feature or fix tracked by a Gitea issue.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
user-invocable: true
argument-hint: "[issue-number]"
metadata:
  author: ccsetup contributors
  version: "1.2.0"
  category: workflow
chains-to:
  - skill: x-auto
    condition: "default routing"
  - skill: x-plan
    condition: "complex issue"
  - skill: x-implement
    condition: "simple issue"
  - skill: git-review-pr
    condition: "existing PR found for issue"
  - skill: git-check-ci
    condition: "after PR created"
  - skill: git-create-pr
    condition: "direct mode PR recovery"
chains-from:
  - skill: git-create-issue
  - skill: git-merge-pr
  - skill: git-quickwins-to-pr
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

> **Reference**: See `references/branch-setup-gates.md` for full branch strategy selection (feature vs direct), base branch detection, and existing branch handling gates.

### Phase 3: Implementation

Delegate to x-auto for implementation.

1. **Chain to x-auto** for implementation routing:

Invoke x-auto with the routing context:
```
skill: "x-auto"
args: "Implement issue #$ISSUE_NUMBER: $ISSUE_TITLE\n\n$ISSUE_BODY"
```

x-auto will assess complexity and route to the appropriate workflow chain (APEX, ONESHOT, DEBUG, etc.).

**IMPORTANT**: After x-auto and its downstream chain complete, execution returns here for Phase 4.

### Phase 4: PR Creation (Conditional)

> **Reference**: See `references/pr-creation-flow.md` for complete PR creation logic (direct mode recovery, feature mode push + PR + post-PR gates).

</instructions>

## Human-in-Loop Gates

| Decision Level | Action | Example |
|----------------|--------|---------|
| **Critical** | ALWAYS ASK | PR creation, branch recreation |
| **High** | ALWAYS ASK | Issue selection, branch strategy, base branch selection, PR-awareness (existing PR found) |
| **Medium** | ALWAYS ASK | Post-PR action (check CI / return / stay), direct-mode PR recovery |
| **Low** | PROCEED | Fetching issue details, pushing branch |

## Workflow Chaining

<chaining-instruction>

<workflow-chain on="implement" skill="x-auto" args="Implement issue #$ISSUE_NUMBER: $ISSUE_TITLE\n\n$ISSUE_BODY" />
<workflow-chain on="pr-create" action="phase4" />
<workflow-chain on="existing-pr-review" skill="git-review-pr" args="$PR_NUMBER" />
<workflow-chain on="post-pr-action" skill="git-check-ci" args="$PR_NUMBER" condition="after PR created" />
<workflow-chain on="direct-mode-pr" skill="git-create-pr" args="" condition="direct mode PR recovery" />
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
- Verify working tree is clean before direct-on-branch implementation

## Critical Rules

1. **Issue First** — Always fetch and display the issue before any action
2. **Branch Convention** — Feature branches MUST follow `feature-branch.N` naming
3. **Human Gates** — PR creation, issue selection, and branch strategy require explicit approval
4. **Context Passing** — Pass full issue context (title + body) to x-auto
5. **Strategy Awareness** — Respect branch strategy throughout; never create a PR in direct mode

## Output Format

> See [references/pr-description-guide.md](references/pr-description-guide.md) for output format and examples.

## Navigation

| Direction | Verb | When |
|-----------|------|------|
| Delegates to | `/x-auto` | Implementation routing |
| Chains to | `/git-check-ci` | After PR created (user choice) |
| Chains to | `/git-create-pr` | Direct mode PR recovery (user choice) |
| Terminal | Stop | PR created + user stays, direct-mode done, or cancelled |

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
- [ ] Post-PR action gate offered (check CI / return to base / stay) (feature mode)
- [ ] Direct mode offers PR recovery when commits exist (direct mode)
- [ ] Clean exit state — user is on expected branch after workflow ends

## References

- @skills/x-auto/ - Task routing and complexity assessment
- @skills/complexity-detection/ - Shared complexity detection logic
- [references/issue-selection-guide.md](references/issue-selection-guide.md) - Issue discovery API and scoring
- [references/pr-description-guide.md](references/pr-description-guide.md) - PR description template
