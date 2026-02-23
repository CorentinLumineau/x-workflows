# Batch Review Summary Report Template

Generate this report after all reviews are submitted. The report has two layers: an **aggregate summary** across all PRs, then **per-PR detail sections** using the standard review output format.

## Aggregate Summary

```markdown
# Batch PR Review — Summary

**Batch Verdict**: ✅ All Approved / ⚠️ Mixed Verdicts / 🚨 Critical Issues Found

`{reviewed_count}` PRs reviewed · `{critical_total}` critical · `{warning_total}` warnings · `{suggestion_total}` suggestions

| PR | Title | Author | Verdict | Findings | Status |
|----|-------|--------|---------|----------|--------|
| #{number} | {title} | @{author} | ✅ LGTM | 0C/2W/1S | submitted |
| #{number} | {title} | @{author} | 🚨 Critical Issues | 3C/1W/0S | submitted |
| #{number} | {title} | @{author} | — | — | skipped |
```

**Batch verdict rules:**
- ✅ **All Approved** — every reviewed PR got APPROVE
- ⚠️ **Mixed Verdicts** — some APPROVE, some REQUEST_CHANGES
- 🚨 **Critical Issues Found** — any PR has Critical findings or test failures

## Per-PR Detail Sections

For each reviewed PR (not skipped), output a section following the standard review format:

```markdown
---

## PR #{number}: {title}

**Verdict**: ✅ LGTM / ⚠️ Needs Changes / 🚨 Critical Issues

`{files_changed}` files reviewed · `{critical}` critical · `{warnings}` warnings · `{suggestions}` suggestions
```

Then list findings grouped by severity. **Omit empty groups entirely.**

### Critical findings format

```markdown
### 🚨 Critical

#### 🚨 CATEGORY — Short Title

**File:** `path/to/file.ext:line-range`

​```lang
// Comment explaining the bug or vulnerability
<relevant code snippet (5-10 lines max)>
​```

**Issue:** One or two sentences explaining why this matters and what to do.
```

### Warning findings format

```markdown
### ⚠️ Warnings

#### ⚠️ CATEGORY — Short Title

**File:** `path/to/file.ext:line`

Brief explanation of the concern and recommended fix.
```

### Suggestion findings format

```markdown
### 💡 Suggestions

- **`file:line`** — **Short title.** One sentence explanation.
```

### Positive observations

```markdown
### ✅ Good

- Bullet per positive observation (brief)
```

### Quick Fix

For each per-PR detail section where the verdict is NOT ✅ LGTM, include the Quick Fix codeblock produced by the review agent. This provides a copyable `/x-auto` prompt with all Critical and Warning findings for that PR.

The agent output already contains this section (see `review-agent-prompt.md`). Include it verbatim in the per-PR detail — do not regenerate or modify the findings.

If the PR verdict is ✅ LGTM, omit the Quick Fix section for that PR.

## Category Tags

Use these categories in findings. When ccsetup plugin knowledge skills apply, include violation IDs:

| Category | When | With Plugin |
|----------|------|-------------|
| SECURITY | Injection, auth, secrets, OWASP | `A01`–`A10` references |
| BUG | Logic errors, nil deref, race conditions | — |
| LOGIC | Incorrect conditions, off-by-one | — |
| PERFORMANCE | N+1 queries, unbounded loops, memory | — |
| TESTING | Missing tests, removed coverage | — |
| BREAKING CHANGE | API contract, schema, removed interfaces | — |
| CODE QUALITY | SOLID, DRY, complexity, naming | `V-SOLID-01`–`V-SOLID-05`, `V-DRY-01`–`V-DRY-03`, `V-KISS-01/02`, `V-YAGNI-01/02`, `V-PAT-01`–`V-PAT-04` |

## Excluded PRs Section

If any PRs were excluded due to stacked dependencies, append:

```markdown
---

## Excluded (Stacked PRs)

| PR | Title | Blocked By | Reason |
|----|-------|------------|--------|
| #{number} | {title} | #{dep_number} | Base PR still open |
```

## Next Steps Section

Always append:

```markdown
---

## Next Steps

- Merge approved PRs: `/git-merge-pr {number}` for each ✅ PR
- Re-review after changes: `/git-review-pr {number}` for ⚠️/🚨 PRs
- Review stacked PRs after base merges: `/git-review-multiple-pr {excluded_numbers}`
```

## Chaining Suggestions

- If ALL ✅ → offer "Merge first approved PR" via `git-merge-pr`
- If MIXED → list approved PRs for individual merge
- If stacked PRs excluded → suggest re-running after base PR merges

## Rules for Per-PR Sections

- Use fenced code blocks with the correct language tag to show problematic code.
- Keep code snippets short (5-10 lines) — just enough to show the issue in context.
- Add a `// comment` inside the snippet pointing to the exact problem.
- Be terse outside of code blocks. One sentence per explanation — two max for critical issues.
- Always include exact `file:line` or `file:line-range`. No vague references.
- Only flag real issues — skip nitpicks and linter-catchable style.
- If a PR is clean, just write the verdict line and a few ✅ Good bullets.
