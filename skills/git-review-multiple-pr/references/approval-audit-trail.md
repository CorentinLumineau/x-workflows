# Approval Audit Trail

## Phase 3: Sequential Approval Loop

Present each review report one-by-one for approval. For each reviewed PR (in dependency-safe order):

**Progress banner**: Show `Review {current}/{total}: PR #{number} — {title} | Verdict: {verdict} | {C}C/{W}W/{S}S`

Display the complete structured review report, then:

<workflow-gate type="choice" id="per-pr-approval">
  <question>Submit review for PR #{number} with verdict: {verdict}?</question>
  <header>PR #{number} verdict</header>
  <option key="submit" recommended="true">
    <label>Submit as shown</label>
    <description>Post review with {verdict} verdict to forge</description>
  </option>
  <option key="modify-verdict">
    <label>Modify verdict</label>
    <description>Change the verdict (e.g., approve despite warnings)</description>
  </option>
  <option key="skip">
    <label>Skip this PR</label>
    <description>Do not submit review — move to next PR</description>
  </option>
</workflow-gate>

If "Modify verdict" → present APPROVE / REQUEST_CHANGES / COMMENT options.
If overriding to APPROVE with Critical findings:

<workflow-gate type="choice" id="force-approve-batch">
  <question>WARNING: PR #{number} has {count} blocking issues. Are you CERTAIN you want to APPROVE?</question>
  <header>Force approve</header>
  <option key="force-approve">
    <label>APPROVE ANYWAY</label>
    <description>Override blocking issues and approve</description>
  </option>
  <option key="back" recommended="true">
    <label>Go back</label>
    <description>Return to verdict options</description>
  </option>
</workflow-gate>

**Submit** via forge CLI with confirmed verdict and the **complete agent report** as the review body. The `$REPORT_BODY` variable MUST contain the full structured output from the review agent — pass it through unchanged. **Do NOT manually reconstruct, summarize, or omit any sections.** This includes: verdict header, all finding groups (Critical/Warnings/Suggestions/Good), Test Results, AND the Quick Fix section (when verdict is not ✅ LGTM). Verify submission via exit code.

> **Forge submission commands**: See `references/forge-commands.md`
> **Force-approve audit trail**: If force-approving with Critical findings, prepend audit notice — see `references/forge-commands.md#force-approve-audit-trail`
