---
name: git-review-pr
description: Use when a pull request needs local code review, security analysis, and test verification before merge.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
user-invocable: true
argument-hint: "<pr-number> [--worktree]"
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
chains-to:
  - skill: git-merge-pr
    condition: "review approved"
chains-from:
  - skill: git-create-pr
---

# /git-review-pr

## Workflow Context

| Attribute | Value |
|-----------|-------|
| Type | UTILITY |
| Position | After PR creation, before merge |
| Flow | `git-create-pr` → **`git-review-pr`** → `git-merge-pr` |

---

## Intention

Perform comprehensive local code review of a pull request including:
- Security analysis via dedicated security reviewer
- Code quality review via code reviewer
- Local test execution and verification
- Structured findings compilation
- Forge-native review submission with verdict

**Arguments**: `$ARGUMENTS` contains PR number (e.g., "123" or "#123")

**Flags**:
- `--worktree`: Run the entire review in an isolated git worktree. Prevents branch switching in the user's working tree. If omitted, user is prompted during Phase 0.

---

## Behavioral Skills

| Skill | When | Purpose |
|-------|------|---------|
| `forge-awareness` | Phase 0 | Detect GitHub/Gitea/GitLab context and adapt commands |
| `interview` | Phase 0 | Confirm review scope if PR number ambiguous |

---

<instructions>

## Phase 0: Forge Detection and Validation

**Activate forge-awareness behavioral skill** to detect current forge (GitHub/Gitea/GitLab).

Parse `$ARGUMENTS`:
- Extract PR number: strip "#" prefix if present, validate numeric format
- Detect `--worktree` flag: set `USE_WORKTREE=true` if present
- If PR number ambiguous or missing, use **interview** skill to confirm

Verify PR exists via forge CLI:
- **GitHub**: `gh pr view {number} --json number,title,state,headRefName`
- **Gitea**: `tea pr show {number}`
- **GitLab**: `glab mr view {number}`

If PR not found, exit with error message.

<workflow-gate type="choice" id="confirm-review-scope">
  <question>Proceed with comprehensive review of PR #{number} (code quality, security, tests)?</question>
  <header>Review scope confirmation</header>
  <option key="proceed" recommended="true">
    <label>Full review</label>
    <description>Code quality + security analysis + test execution</description>
  </option>
  <option key="quick">
    <label>Quick review</label>
    <description>Code quality only, skip security and tests</description>
  </option>
  <option key="cancel">
    <label>Cancel</label>
    <description>Abort review</description>
  </option>
</workflow-gate>

Present PR details to user before gate:
- Title and description
- Author and branch
- File change count
- Review scope (full review with security + tests)

**Worktree decision** (skip if `USE_WORKTREE` already set by `--worktree` flag):

<workflow-gate type="choice" id="worktree-isolation">
  <question>Review in an isolated worktree? This avoids switching your current branch.</question>
  <header>Isolation mode</header>
  <option key="worktree" recommended="true">
    <label>Use worktree</label>
    <description>Isolated copy — your working tree stays untouched</description>
  </option>
  <option key="in-place">
    <label>In-place checkout</label>
    <description>Checkout PR branch directly (will switch your current branch)</description>
  </option>
</workflow-gate>

Set `USE_WORKTREE=true` if user selects "Use worktree".

---

## Phase 1: Fetch PR Locally

**If `USE_WORKTREE=true`**: Use the `EnterWorktree` tool with name `review-pr-{number}` before fetching. This creates an isolated working copy so the review does not affect the user's current branch or uncommitted work.

Fetch PR branch locally using forge-appropriate checkout command (gh/tea/glab). Verify checkout success and capture base branch merge-base.

---

## Phase 2: Parallel Code and Security Review

<parallel-delegate strategy="concurrent">
  <agent role="code quality reviewer" subagent="x-reviewer" model="sonnet">
    <prompt>Review code changes for design patterns, SOLID principles, maintainability, readability, performance concerns, test coverage gaps, and documentation completeness. Scope: `git diff origin/main...HEAD`. Output structured findings with severity (Critical/Warning/Suggestion).</prompt>
    <context>PR code quality review — SOLID, DRY, performance, test coverage, documentation</context>
  </agent>
  <agent role="security reviewer" subagent="x-security-reviewer" model="sonnet">
    <prompt>Review code changes for OWASP Top 10 vulnerabilities, authentication/authorization flaws, input validation issues, secrets exposure (hardcoded credentials, API keys), and dependency vulnerabilities. Scope: `git diff origin/main...HEAD`. Output structured security findings with CVE references where applicable.</prompt>
    <context>PR security review — OWASP, auth, input validation, secrets, dependencies</context>
  </agent>
</parallel-delegate>

**Aggregate findings**:
- Merge findings from both reviewers
- Deduplicate overlapping issues
- Sort by severity: Critical → Warning → Suggestion
- Tag each finding with source (code-quality / security)

---

## Phase 3: Local Test Execution

<agent-delegate role="test runner" subagent="x-tester" model="sonnet">
  <prompt>Execute full test suite on PR branch. Detect test framework (pytest, jest, go test, cargo test, etc.). Run all tests with coverage report. Capture failures, errors, and coverage metrics. Compare coverage vs. base branch if possible. Return test summary (passed/failed/skipped counts), coverage percentage (overall and diff), and failed test details with stack traces.</prompt>
  <context>PR test execution phase — run all tests and report results with coverage</context>
</agent-delegate>

If tests fail, flag as blocking issue in review findings (severity: Critical).

---

## Phase 4: Compile Structured Review Report

Generate comprehensive review report with sections:

Sections: Executive Summary (verdict + counts), Critical/Warning/Suggestion findings (with location and recommendation), Test Results (counts + coverage), Security Assessment (OWASP + secrets check), Quick Fix (copyable self-contained `/x-auto` prompt — only for non-APPROVE verdicts, see template).

**Verdict**: REQUEST_CHANGES if critical findings/test failures/security issues; APPROVE if none; COMMENT for suggestions only.

> **Full report template and verdict logic**: See `references/review-report-template.md`

---

## Phase 5: Submit Review to Forge

<workflow-gate type="choice" id="submit-review">
  <question>Submit this review to PR #{number} with verdict: {APPROVE/REQUEST_CHANGES/COMMENT}?</question>
  <header>Submit review</header>
  <option key="submit" recommended="true">
    <label>Submit as shown</label>
    <description>Post review with current verdict and findings</description>
  </option>
  <option key="modify-verdict">
    <label>Modify verdict</label>
    <description>Change verdict (e.g., approve despite warnings)</description>
  </option>
  <option key="edit-comments">
    <label>Edit comments</label>
    <description>Edit review comments before submission</description>
  </option>
  <option key="cancel">
    <label>Cancel</label>
    <description>Save draft locally without submitting</description>
  </option>
</workflow-gate>

Present full review report to user before this gate.

If user chooses option 2 (force approve with issues):
<workflow-gate type="choice" id="force-approve">
  <question>CRITICAL WARNING: Review found {count} blocking issues. Are you CERTAIN you want to APPROVE despite these issues?</question>
  <header>Force approve confirmation</header>
  <option key="force-approve">
    <label>APPROVE ANYWAY</label>
    <description>Override blocking issues and approve (requires exact confirmation phrase)</description>
  </option>
  <option key="back" recommended="true">
    <label>Go back</label>
    <description>Return to review submission options</description>
  </option>
</workflow-gate>

List blocking issues again before this gate. Require exact match of "APPROVE ANYWAY" confirmation phrase.

**Submit review via forge CLI** (gh/tea/glab) with chosen verdict and review body. Verify submission via exit code and confirm review appears.

> **Forge submission commands**: See `references/review-report-template.md`

---

## Phase 6: Cleanup and Chaining

**Cleanup local state**:
- **If worktree was used**: The worktree (`review-pr-{number}`) is automatically cleaned up on session exit. No branch switching needed — the user's original branch was never changed.
- **If in-place checkout**: Return to original branch (`git checkout -`) and optionally delete PR branch locally (`git branch -d pr-{number}`).

<chaining-instruction>

**Workflow chaining**:

If verdict is APPROVE and user wants to proceed with merge:

<workflow-gate type="choice" id="post-review-action">
  <question>Review approved. How would you like to proceed?</question>
  <header>Post-review action</header>
  <option key="merge" recommended="true">
    <label>Proceed to merge</label>
    <description>Chain to git-merge-pr to merge the approved PR</description>
  </option>
  <option key="done">
    <label>Done</label>
    <description>Review submitted, no further action needed</description>
  </option>
</workflow-gate>

<workflow-chain on="merge" skill="git-merge-pr" args="{pr-number}" />
<workflow-chain on="done" action="end" />

If verdict is REQUEST_CHANGES:
- Inform user: "Review submitted requesting changes. Use /git-review-pr {number} again after author addresses feedback."

</chaining-instruction>

</instructions>

---

## Human-in-Loop Gates

| Gate ID | Severity | Trigger | Required Action |
|---------|----------|---------|-----------------|
| `confirm-review-scope` | Medium | Before fetching PR | Confirm review scope and PR number |
| `submit-review` | Critical | Before submitting review | Approve review submission with chosen verdict |
| `force-approve` | Critical | User wants to approve despite blocking issues | Explicit confirmation with phrase match |

<human-approval-framework>

When approval needed, structure question as:
1. **Context**: Review findings summary with verdict and blocking issues
2. **Options**: Submit as-is, modify verdict, edit comments, or cancel
3. **Recommendation**: Submit with auto-determined verdict based on findings
4. **Escape**: "Cancel and save draft locally" option

</human-approval-framework>

---

## Workflow Chaining

| Relationship | Target Skill | Condition |
|--------------|--------------|-----------|
| chains-to | `git-merge-pr` | Review approved and user wants to merge |
| chains-from | `git-create-pr` | PR created and ready for review |

---

## Safety Rules

1. **Never auto-approve PRs** without explicit human gate confirmation
2. **Never skip security review** even if user requests "quick review"
3. **Never force-push** during review process
4. **Never modify PR branch** without explicit user instruction
5. **Always capture full review** in state checkpoint before submission
6. **Always require explicit confirmation** for approve-with-issues scenarios

---

## Critical Rules

- **CRITICAL**: Test failures ALWAYS trigger REQUEST_CHANGES verdict unless user explicitly overrides
- **CRITICAL**: Security vulnerabilities ALWAYS flagged as Critical severity
- **CRITICAL**: Secrets exposure (API keys, passwords) ALWAYS blocks approval without force-approve gate
- **CRITICAL**: Review submission is IRREVERSIBLE once posted - always confirm before submission

---

## Success Criteria

- PR fetched locally and checked out successfully
- Both code and security review completed with findings captured
- Tests executed with results captured
- Structured review report generated with verdict
- Review submitted to forge with correct verdict
- User informed of next steps (merge or wait for changes)

---

## Agent Delegation

| Role | Agent Type | Model | When | Purpose |
|------|------------|-------|------|---------|
| Code reviewer | `ccsetup:x-reviewer` | sonnet | Phase 2 | Review code quality, design, maintainability |
| Security reviewer | `ccsetup:x-security-reviewer` | sonnet | Phase 2 | Review for OWASP vulnerabilities and security issues |
| Test runner | `ccsetup:x-tester` | sonnet | Phase 3 | Execute test suite and report results |

---

## References

- Behavioral skill: `@skills/forge-awareness/` (forge detection and command adaptation)
- Behavioral skill: `@skills/interview/` (interactive confirmation)
- Knowledge skill: `@skills/security-secure-coding/` (security review guidelines)
- Knowledge skill: `@skills/quality-testing/` (test execution patterns)
- Knowledge skill: `@skills/code-code-quality/` (SOLID principles and design patterns)

---

## When to Load References

- **For report template and verdict logic**: See `references/review-report-template.md`
