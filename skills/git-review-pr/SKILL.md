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
  version: "2.0.0"
  category: workflow
chains-to:
  - skill: git-merge-pr
    condition: "review approved"
  - skill: git-fix-pr
    condition: "review requested changes"
chains-from:
  - skill: git-create-pr
  - skill: git-implement-issue
  - skill: git-fix-pr
    condition: "fixes implemented, re-review"
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

> **Reference**: See `references/review-scope-selection.md` for scope gate (full/quick/deep), worktree isolation decision, and depth routing table.

---

## Phase 1: Fetch PR Locally

**If `USE_WORKTREE=true`**: Use the `EnterWorktree` tool with name `review-pr-{number}` before fetching. This creates an isolated working copy so the review does not affect the user's current branch or uncommitted work.

Fetch PR branch locally using forge-appropriate checkout command (gh/tea/glab). Verify checkout success and capture base branch merge-base.

---

## Phase 1b: Change Scoping

> Skipped in Quick mode.

<agent-delegate role="change scope analyzer" subagent="x-explorer" model="haiku">
  <prompt>Analyze PR diff (`git diff origin/$BASE...HEAD`). Categorize each changed file as: production code, test code, documentation, configuration, or infrastructure. Report file count per category and identify the primary change area. List all new public API surfaces.</prompt>
  <context>PR change scoping — categorize diff for targeted review</context>
</agent-delegate>

Use scoping results to focus subsequent phases on the most impactful changes.

---

## Phase 2a: Spec Compliance Check

> Skipped in Quick mode. **BLOCKING** — failures prevent APPROVE verdict.

Fetch the linked issue from the forge (extract from PR description or branch name):
- **GitHub**: `gh issue view {issue-number} --json title,body`
- **Gitea**: `tea issue read {issue-number}`

**4-Point Spec Compliance Checklist**:
1. [ ] All acceptance criteria from the issue are addressed in the diff
2. [ ] No scope creep — changes are limited to what the issue describes
3. [ ] Edge cases mentioned in the issue are handled
4. [ ] If issue specifies constraints (performance, compatibility), they are met

Flag unmet criteria as spec violations. See `references/enforcement-audit.md` for severity classification.

---

## Phase 2b: Parallel Code and Security Review

<parallel-delegate strategy="concurrent">
  <agent role="code quality reviewer" subagent="x-reviewer" model="sonnet">
    <prompt>Review code changes for design patterns, SOLID principles, maintainability, readability, performance concerns, test coverage gaps, and documentation completeness. Scope: `git diff origin/$BASE...HEAD`. Output structured findings with severity (Critical/Warning/Suggestion). **MANDATORY: Include V-code IDs for all quality findings.** See enforcement-audit.md for V-code definitions.</prompt>
    <context>PR code quality review — SOLID, DRY, performance, test coverage, documentation</context>
  </agent>
  <agent role="security reviewer" subagent="x-security-reviewer" model="sonnet">
    <prompt>Review code changes for OWASP Top 10 vulnerabilities, authentication/authorization flaws, input validation issues, secrets exposure (hardcoded credentials, API keys), and dependency vulnerabilities. Scope: `git diff origin/$BASE...HEAD`. Output structured security findings with CVE references where applicable. **MANDATORY: Include OWASP category IDs (A01-A10) for all security findings.**</prompt>
    <context>PR security review — OWASP, auth, input validation, secrets, dependencies</context>
  </agent>
</parallel-delegate>

**Aggregate findings**:
- Merge findings from both reviewers
- Deduplicate overlapping issues
- Sort by severity: Critical → Warning → Suggestion
- Tag each finding with source (code-quality / security) and V-code ID

> **Enforcement reference**: See `references/enforcement-audit.md` for V-code definitions and severity classification.

---

## Phase 3a: Local Test Execution

<agent-delegate role="test runner" subagent="x-tester" model="sonnet">
  <prompt>Execute full test suite on PR branch. Detect test framework (pytest, jest, go test, cargo test, etc.). Run all tests with coverage report. Capture failures, errors, and coverage metrics. Compare coverage vs. base branch if possible. Return test summary (passed/failed/skipped counts), coverage percentage (overall and diff), and failed test details with stack traces.</prompt>
  <context>PR test execution phase — run all tests and report results with coverage</context>
</agent-delegate>

If tests fail, flag as blocking issue in review findings (severity: Critical).

> **Verification evidence**: All test claims must follow `references/verification-protocol.md` 5-step sequence.

---

## Phase 3b: Regression Detection

> Skipped in Quick mode.

<agent-delegate role="regression detector" subagent="x-tester" model="sonnet">
  <prompt>Analyze PR diff for regressions: coverage delta vs base branch, removed/disabled tests, removed assertions, weakened validation, API signature changes without test updates. Scope: `git diff origin/$BASE...HEAD`. Report findings with severity classification.</prompt>
  <context>PR regression detection — coverage delta, removed tests, behavioral changes</context>
</agent-delegate>

> **Regression checklist**: See `references/pr-regression-checks.md` for full detection criteria and severity.

---

## Phase 4a: Documentation Check

> Lightweight check — runs before report compilation. Skipped in Quick mode.

Verify:
- [ ] New public APIs have JSDoc/docstrings
- [ ] README is updated if user-facing behavior changed
- [ ] CHANGELOG entry exists for user-visible changes
- [ ] Inline comments exist for non-obvious logic

Flag missing documentation as V-DOC violations (see `references/enforcement-audit.md`).

---

## Phase 4b: Compile Structured Review Report

**STOP — Review Approval Hard Gate**: Before generating the verdict, verify all violations against `references/enforcement-audit.md` hard gate checklist. Zero CRITICAL and zero unexcepted HIGH violations required for APPROVE.

Generate comprehensive review report with sections:

Sections: Executive Summary (verdict + counts), Critical/Warning/Suggestion findings (with V-code IDs, location, and recommendation), Regression Findings (coverage delta, removed tests), Documentation Findings (missing docs), Test Results (counts + coverage with evidence), Security Assessment (OWASP + secrets check), Quick Fix (copyable `/git-fix-pr` prompt — only for non-APPROVE verdicts).

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

> **Reference**: See `references/post-review-chaining.md` for cleanup logic and chaining paths (approve→merge, request-changes→fix).

</instructions>

---

## Human-in-Loop Gates

| Gate ID | Severity | Trigger | Required Action |
|---------|----------|---------|-----------------|
| `confirm-review-scope` | Medium | Before fetching PR | Confirm review scope and PR number |
| `submit-review` | Critical | Before submitting review | Approve review submission with chosen verdict |
| `force-approve` | Critical | User wants to approve despite blocking issues | Explicit confirmation with phrase match |

<human-approval-framework>
Structure approval questions with: context (findings summary + verdict), options (submit/modify/edit/cancel), recommendation (auto-determined verdict), and escape path (save draft locally).
</human-approval-framework>

---

## Safety Rules

1. **Never auto-approve PRs** without explicit human gate confirmation
2. **Never skip security review** even if user requests "quick review"
3. **Never force-push** during review process
4. **Never modify PR branch** without explicit user instruction
5. **Always verify hard gate** (references/enforcement-audit.md) before generating verdict
6. **Always require explicit confirmation** for approve-with-issues scenarios

---

## Critical Rules

- **CRITICAL**: Test failures ALWAYS trigger REQUEST_CHANGES verdict unless user explicitly overrides
- **CRITICAL**: Security vulnerabilities ALWAYS flagged as Critical severity
- **CRITICAL**: Secrets exposure (API keys, passwords) ALWAYS blocks approval without force-approve gate
- **CRITICAL**: Review submission is IRREVERSIBLE once posted - always confirm before submission

---

## Success Criteria

- PR fetched and reviewed (code + security + tests) with structured findings
- Review report generated with V-code IDs, verdict, and submitted to forge
- User informed of next steps (merge or wait for changes)

---

## Agent Delegation

| Role | Agent Type | Model | When | Purpose |
|------|------------|-------|------|---------|
| Change scope analyzer | `ccsetup:x-explorer` | haiku | Phase 1b | Categorize PR diff by file type |
| Code reviewer | `ccsetup:x-reviewer` | sonnet | Phase 2b | Review code quality, design, maintainability |
| Security reviewer | `ccsetup:x-security-reviewer` | sonnet | Phase 2b | Review for OWASP vulnerabilities and security issues |
| Test runner | `ccsetup:x-tester` | sonnet | Phase 3a | Execute test suite and report results |
| Regression detector | `ccsetup:x-tester` | sonnet | Phase 3b | Detect coverage regressions and removed tests |

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
- **For V-code definitions, audit checklists, and hard gate**: See `references/enforcement-audit.md`
- **For test verification evidence protocol**: See `references/verification-protocol.md`
- **For PR regression detection criteria**: See `references/pr-regression-checks.md`
