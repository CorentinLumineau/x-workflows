---
name: git-create-issue
description: Use when you need to create a new issue on the forge to track a bug, feature, or task.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash AskUserQuestion
user-invocable: true
argument-hint: "<title>"
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
chains-to:
  - skill: git-implement-issue
    condition: "after issue creation"
  - skill: git-implement-multiple-issue
    condition: "batch implementation"
chains-from:
  - skill: git-quickwins-to-pr
---

# /git-create-issue

Create a new issue on the forge (GitHub/Gitea) to track a bug, feature request, or task.

## Workflow Context

| Attribute | Value |
|-----------|-------|
| **Type** | META (lifecycle) |
| **Position** | Start of issue-to-merge flow |
| **Typical Flow** | **`git-create-issue`** → `git-implement-issue` |
| **Human Gates** | Content review (High), issue creation (Critical) |
| **State Tracking** | Creates issue_context with issue number and URL |

## Intention

Create a well-structured issue on the detected forge with:
- Clear title describing the bug/feature/task
- Detailed description with context
- Appropriate labels (bug/enhancement/documentation/etc.)
- Milestone assignment (if applicable)
- Template adherence (if repository has issue templates)

**Arguments**: `$ARGUMENTS` (required) = issue title (can be refined during interview)

## Behavioral Skills

This workflow activates:
- **forge-awareness** - Detects forge type and uses appropriate CLI
- **interview** - Gathers issue details through conversation

## Instructions

<instructions>

### Phase 0: Forge Detection and Template Check

<context-query tool="project_context">
  <fallback>
  1. `git remote -v` → detect forge type (GitHub/Gitea)
  2. `gh --version 2>/dev/null || tea --version 2>/dev/null` → verify CLI availability
  </fallback>
</context-query>

2. Check for issue templates in repository:
   - Look for `.github/ISSUE_TEMPLATE/` or `.gitea/ISSUE_TEMPLATE/`
   - Parse available templates (bug_report.md, feature_request.md, etc.)
3. Store initial title from `$ARGUMENTS` in `issue_context.title`

### Phase 1: Gather Issue Details via Interview

1. Activate `interview` behavioral skill to gather:
   - Issue type (bug/feature/task/documentation/question)
   - If templates exist, ask user to select template or use blank
2. Based on type, gather structured details:

   **For bugs**:
   - Expected behavior
   - Actual behavior
   - Steps to reproduce
   - Environment (OS, version, etc.)

   **For features**:
   - Problem statement (why is this needed?)
   - Proposed solution
   - Alternatives considered
   - Additional context

   **For tasks/docs**:
   - Description of work needed
   - Acceptance criteria
   - Related issues/PRs

3. If template selected, pre-fill description with template structure
4. Fetch available metadata from forge:
   - Labels: `gh label list --json name,description` / `tea labels ls`
   - Milestones: `gh api repos/{owner}/{repo}/milestones --jq '.[].title'` / `tea milestones ls`
   - If fetch fails or returns empty, skip the corresponding gate below

5. **Present metadata selection** — build AskUserQuestion options dynamically from fetched data:

   **Labels gate** (multi-select):
   - Parse the label names from the CLI output in step 4
   - Determine a type-appropriate label based on issue type: bug → `type:bug`, feature → `type:feature`, task → `type:chore`, docs → `type:chore`
   - Build an `AskUserQuestion` call with `multiSelect: true` where:
     - The first option is the auto-suggested type label with `(Recommended)` appended to its label text
     - All remaining fetched labels are listed as additional options
     - Each option has `label` = the label name and `description` = the label description (or "Repository label" if no description)
   - Set `question` = "Which labels should be applied to this issue?" and `header` = "Labels"
   - **If no labels were fetched** (empty output or fetch failed), skip this gate entirely and proceed without labels

   **Milestone gate** (single-select):
   - Parse the milestone titles from the CLI output in step 4
   - Build an `AskUserQuestion` call with `multiSelect: false` where:
     - The first option is `label: "No milestone", description: "Skip milestone assignment"`
     - Each fetched milestone is an additional option with `label` = milestone title and `description` = milestone due date or "No due date"
   - Set `question` = "Assign to a milestone?" and `header` = "Milestone"
   - **If no milestones were fetched** (empty output or fetch failed), skip this gate entirely and set milestone to none

   **Assignee gate** (multi-select):
   - Fetch collaborators/members:
     - GitHub: `gh api repos/{owner}/{repo}/collaborators --jq '.[].login'`
     - Gitea: `tea organizations members ls` or skip if not available
   - Build an `AskUserQuestion` call with `multiSelect: true` where:
     - The first option is `label: "No assignees (Recommended)", description: "Leave unassigned for now"`
     - Each fetched collaborator is an additional option with `label` = username and `description` = "Repository collaborator"
   - Set `question` = "Assign to anyone? (optional)" and `header` = "Assignees"
   - **If no collaborators were fetched** (empty output or fetch failed), skip this gate entirely and leave unassigned

### Phase 2: Review Issue Content

1. Construct full issue description following template or structured format:
   ```markdown
   ## Description
   {user-provided description}

   ## Additional Context
   {any extra details}

   {template-specific sections if applicable}
   ```
2. Present complete issue to user for review:
   ```
   Title: {title}
   Labels: bug, needs-triage
   Milestone: v1.2.0

   Description:
   ---
   {full description}
   ---
   ```
<workflow-gate type="choice" id="review-approval">
  <question>Review the issue content above. How would you like to proceed?</question>
  <header>Review</header>
  <option key="approve" recommended="true">
    <label>Approve</label>
    <description>Issue content looks good — proceed to creation</description>
  </option>
  <option key="edit">
    <label>Edit</label>
    <description>Make changes to title, description, labels, or milestone</description>
  </option>
  <option key="cancel">
    <label>Cancel</label>
    <description>Discard and abort issue creation</description>
  </option>
</workflow-gate>
3. Allow user to edit title, description, labels, or milestone

### Phase 3: Create Issue via Forge CLI

1. Construct issue creation command:
   - GitHub: `gh issue create --title "{title}" --body "{description}" --label {labels} --milestone {milestone}`
   - Gitea: `tea issue create --title "{title}" --description "{description}" --labels {labels} --milestone {milestone}`
2. Present command to user for final approval
<workflow-gate type="choice" id="creation-approval">
  <question>Ready to create this issue on the forge?</question>
  <header>Create</header>
  <option key="create" recommended="true">
    <label>Create issue</label>
    <description>Execute the issue creation command shown above</description>
  </option>
  <option key="cancel">
    <label>Cancel</label>
    <description>Abort — no issue will be created</description>
  </option>
</workflow-gate>
3. Execute command and capture issue number and URL from output
4. Store result in `issue_context.created_issue`

### Phase 4: Post-Creation Actions

1. Update workflow state:
   ```json
   {
     "issue_number": 456,
     "issue_url": "https://github.com/owner/repo/issues/456",
     "type": "bug",
     "labels": ["bug", "needs-triage"],
     "milestone": "v1.2.0",
     "created_at": "ISO-8601"
   }
   ```
2. If assignees specified, assign via:
   - GitHub: `gh issue edit {issue} --add-assignee {user}`
   - Gitea: `tea issue edit {issue} --assignees {user}`
3. Present success message with issue URL

### Phase 5: Suggest Next Steps

1. Suggest workflow continuation:
   <!-- <workflow-chain next="git-implement-issue" condition="issue is ready to implement"> -->
   - "Start implementation with `/git-implement-issue {issue_number}`"
2. If issue needs triage:
   - "Issue created. Team will triage and prioritize."

</instructions>

## Human-in-Loop Gates

| Gate | Criticality | Trigger Condition | Default Action |
|------|-------------|-------------------|----------------|
| Content review | High | After all details gathered | Wait for approval/edits |
| Issue creation | Critical | Before executing create command | Wait for explicit confirmation |

## Workflow Chaining

<chaining-instruction>
**Chains from**: None (start of lifecycle)
**Chains to**: `git-implement-issue`

**Forward chaining**:
- Always suggest `git-implement-issue` after successful creation
- User can defer implementation if issue needs triage

**Issue lifecycle**:
- This is the entry point for tracked work
- Creates foundation for issue → branch → PR → merge flow
</chaining-instruction>

## Safety Rules

1. **Never create issues without approval** - Always gate creation with explicit confirmation
2. **Respect repository templates** - Use templates when available unless user opts out
3. **Validate labels and milestones** - Check labels/milestones exist before applying
4. **Preserve user privacy** - Never auto-assign issues without permission
5. **Handle API failures gracefully** - If creation fails, preserve gathered data for retry

## Critical Rules

1. **Interview must gather minimum viable issue**:
   - Title is required (non-empty)
   - Description must have meaningful content
   - Type must be determined (bug/feature/task/etc.)
2. **Template adherence**:
   - If template exists, strongly suggest using it
   - If user opts out, still gather template-equivalent information
3. **Label inference**:
   - Always suggest type-appropriate label (bug → "bug", feature → "enhancement")
   - Verify labels exist in repository before applying
4. **State persistence**:
   - Store issue metadata even if post-creation actions fail
   - Allow retry of assignee/label edits without recreating issue

## Success Criteria

- [ ] Forge type detected and CLI validated
- [ ] Issue type determined (bug/feature/task/docs/question)
- [ ] Issue details gathered via interview
- [ ] Template used (if available and user approves)
- [ ] Title and description reviewed by user
- [ ] Labels and milestone validated and applied
- [ ] Issue created successfully via forge CLI
- [ ] Issue number and URL captured
- [ ] Workflow state updated with issue metadata
- [ ] Next step suggested (git-implement-issue)

## References

- GitHub issue templates: https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests
- GitHub CLI issues: https://cli.github.com/manual/gh_issue_create
- Gitea issue templates: https://docs.gitea.com/usage/issue-pull-request-templates
- Gitea Tea CLI: https://gitea.com/gitea/tea
