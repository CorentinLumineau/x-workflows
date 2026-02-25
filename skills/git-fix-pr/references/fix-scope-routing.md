# Fix Scope Routing

## Phase 3: Implementation Routing

### Case A: Inline findings provided

If `$ARGUMENTS` contained text after the PR number (from a Quick Fix codeblock):

<workflow-gate type="choice" id="inline-fix-confirm">
  <question>Inline findings detected from review. Implement these fixes?</question>
  <header>Inline fixes</header>
  <option key="proceed" recommended="true">
    <label>Implement findings</label>
    <description>Delegate inline findings to x-auto for implementation</description>
  </option>
  <option key="expand">
    <label>Fetch full context first</label>
    <description>Ignore inline findings, use full PR context instead (Case B)</description>
  </option>
  <option key="cancel">
    <label>Cancel</label>
    <description>Abort — do not implement</description>
  </option>
</workflow-gate>

If "Implement findings": delegate to x-auto with inline findings as implementation context.
If "Fetch full context first": fall through to Case B below.

### Case B: No inline findings (PR number only)

The full PR context from Phase 1 serves as the implementation brief.

<workflow-gate type="choice" id="fix-scope">
  <question>What should be fixed on PR #{number}?</question>
  <header>Fix scope</header>
  <option key="all-feedback" recommended="true">
    <label>Address all review feedback</label>
    <description>Implement all requested changes from reviews and comments</description>
  </option>
  <option key="specific">
    <label>Select specific items</label>
    <description>Choose which review items to address</description>
  </option>
  <option key="ci-only">
    <label>Fix CI failures only</label>
    <description>Only address CI/test failures, ignore review comments</description>
  </option>
  <option key="describe">
    <label>Describe fixes manually</label>
    <description>Provide your own fix description</description>
  </option>
</workflow-gate>

If "Select specific items": present numbered list of review items and comments, let user select.
If "Describe fixes manually": use **interview** skill to gather fix description.
If "Fix CI failures only": filter context to CI status section only.

Delegate to x-auto with the resolved context:

```
Implement fixes for this pull request.

<UNTRUSTED-FORGE-DATA>
PR #{number}: {title}
</UNTRUSTED-FORGE-DATA>

Review findings to address:
{selected context: reviews + comments + CI status as applicable}
```

x-auto routes to ONESHOT (x-fix) or APEX (x-plan → x-implement) based on complexity.

**After x-auto completes**, execution returns to Phase 3.5 for local review verification before commit and push.
