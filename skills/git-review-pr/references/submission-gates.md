# Review Submission Gates

> Detailed workflow gates for Phase 5 review submission. Loaded by SKILL.md when review report is complete.

## Gate 1: APPROVE Verdict

Present full review report to user before this gate.

**If verdict is APPROVE:**

<workflow-gate type="choice" id="submit-review-approve">
  <question>Submit this review to PR #{number} with verdict: APPROVE?</question>
  <header>Submit review</header>
  <option key="submit" recommended="true">
    <label>Submit as shown</label>
    <description>Post review with current verdict and findings</description>
  </option>
  <option key="modify-verdict">
    <label>Modify verdict</label>
    <description>Change verdict to REQUEST_CHANGES or COMMENT</description>
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

## Gate 2: Non-APPROVE Verdict

**If verdict is NOT APPROVE (REQUEST_CHANGES or COMMENT):**

<workflow-gate type="choice" id="submit-review-changes">
  <question>Review of PR #{number} found issues (verdict: {REQUEST_CHANGES/COMMENT}). How would you like to proceed?</question>
  <header>Action</header>
  <option key="fix-first">
    <label>Fix issues first (Recommended)</label>
    <description>Run /git-fix-pr to auto-fix findings before submitting the review</description>
  </option>
  <option key="submit">
    <label>Submit as shown</label>
    <description>Post review with current verdict and findings to the forge</description>
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

## Gate 3: Fix Scope Selection

**If user selects "fix-first"** → present fix scope gate:

<workflow-gate type="choice" id="fix-scope">
  <question>Which findings should /git-fix-pr address?</question>
  <header>Fix scope</header>
  <option key="critical-and-warnings" recommended="true">
    <label>Critical + Warnings</label>
    <description>Fix all Critical and Warning findings (standard scope)</description>
  </option>
  <option key="critical-only">
    <label>Critical only</label>
    <description>Fix only Critical findings, leave Warnings for later</description>
  </option>
  <option key="all">
    <label>All findings</label>
    <description>Fix Critical, Warnings, and Suggestions</description>
  </option>
  <option key="skip">
    <label>Skip — post review as-is</label>
    <description>Changed my mind, submit the review without fixing</description>
  </option>
</workflow-gate>

**If user selects "skip"** in fix-scope gate → submit review as-is (same as "submit" in the first gate).

**If user selects a fix scope** (critical-only, critical-and-warnings, or all):
1. Do NOT submit the review to the forge
2. Filter findings to the selected scope and chain to `/git-fix-pr {number}` passing the filtered findings
3. After fixes complete, git-fix-pr chains back to `/git-review-pr {number}` for re-review
4. The re-review generates a fresh verdict — the original review is discarded

<workflow-chain on="critical-and-warnings" skill="git-fix-pr" args="{number}" />
<workflow-chain on="critical-only" skill="git-fix-pr" args="{number}" />
<workflow-chain on="all" skill="git-fix-pr" args="{number}" />

## Gate 4: Force Approve Override

**If user selects "modify-verdict"** (APPROVE gate), or types "modify verdict" via Other (non-APPROVE gate) to force-approve despite blocking issues:

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

## Forge Submission

**Submit review via forge CLI** (gh/tea/glab) with chosen verdict and review body. Verify submission via exit code and confirm review appears.

> **Forge submission commands**: See `references/review-report-template.md`
