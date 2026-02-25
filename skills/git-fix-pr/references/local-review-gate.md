# Local Review Gate

> Phase 3.5: Shift-left verification — review fixes locally before committing to catch regressions early and avoid expensive remote fix → push → review → fix round-trips.

## Iteration Tracking

Initialize `LOCAL_FIX_ITERATION = 0`, `MAX_LOCAL_FIX_ITERATIONS = 3`.

## 3.5.1: Run Local Review

Increment `LOCAL_FIX_ITERATION`.

Review the changes produced by x-auto. Show the diff summary to the user:
```bash
git diff --stat
```

Run x-review on the local changes — focus on correctness of the fixes relative to the review feedback being addressed:

```
Invoke x-review in quick mode:
- Scope: uncommitted changes only (git diff)
- Focus: Do these changes correctly address the review feedback for PR #{PR_NUMBER}?
- Check for: regressions, incomplete fixes, new issues introduced
```

## 3.5.2: Assess Review Findings

**If x-review finds no issues**: proceed directly to Phase 4.

**If x-review finds issues**:

<workflow-gate type="choice" id="local-review-result">
  <question>Local review found issues in the fixes (iteration {LOCAL_FIX_ITERATION}/{MAX_LOCAL_FIX_ITERATIONS}). How should we proceed?</question>
  <header>Review gate</header>
  <option key="fix" recommended="true">
    <label>Fix issues locally</label>
    <description>Re-delegate to x-auto to address review findings before committing</description>
  </option>
  <option key="override">
    <label>Proceed anyway</label>
    <description>Accept current changes and continue to commit/push (Phase 4)</description>
  </option>
  <option key="abort">
    <label>Abort</label>
    <description>Stop — keep changes uncommitted for manual review</description>
  </option>
</workflow-gate>

**If "Proceed anyway"**: proceed to Phase 4.
**If "Abort"**: end workflow — changes remain in working tree for manual intervention.

**If "Fix issues locally"**:
- **If `LOCAL_FIX_ITERATION >= MAX_LOCAL_FIX_ITERATIONS`** (safety valve):

<workflow-gate type="choice" id="max-iterations-reached">
  <question>Reached maximum local fix iterations ({MAX_LOCAL_FIX_ITERATIONS}). The remaining issues may need manual attention.</question>
  <header>Safety valve</header>
  <option key="push-current">
    <label>Commit current state</label>
    <description>Proceed to Phase 4 with changes as-is</description>
  </option>
  <option key="abort">
    <label>Abort</label>
    <description>Keep changes uncommitted for manual intervention</description>
  </option>
</workflow-gate>

- **If iterations remain**:

<skill-delegate skill="x-auto" mandatory="true">
  <args>Address local review findings for PR #{number}: {x-review findings}</args>
  <context>Re-delegation after local review found issues</context>
  <enforcement>Do NOT fix issues directly. Re-delegate to x-auto for proper complexity routing.</enforcement>
</skill-delegate>

After x-auto completes, return to step 3.5.1.
