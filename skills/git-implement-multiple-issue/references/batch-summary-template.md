# Batch Implementation Summary Report Template

Generate this report after all PRs are created (or skipped). The report has two layers: an **aggregate summary** across all issues, then **per-issue detail sections**.

## Aggregate Summary

```markdown
# Batch Implementation — Summary

**Batch Status**: ✅ All Complete / ⚠️ Partial / 🚨 Failures

`{implemented_count}` issues implemented · `{pr_count}` PRs created · `{failed_count}` failed

| Issue | Title | Implementation | Branch | PR |
|-------|-------|---------------|--------|-----|
| #{number} | {title} | DONE | feature-branch.{number} | PR #{pr_number} |
| #{number} | {title} | PARTIAL | feature-branch.{number} | skipped |
| #{number} | {title} | FAILED | — | — |
```

**Batch status rules:**
- ✅ **All Complete** — every issue DONE with PR created
- ⚠️ **Partial** — some DONE, some PARTIAL or skipped PRs
- 🚨 **Failures** — any issue FAILED

## Excluded Issues Section

If any issues were excluded due to existing PRs, append:

```markdown
---

## Excluded (Active PRs)

| Issue | Title | Existing PR | Match |
|-------|-------|------------|-------|
| #{number} | {title} | PR #{pr_number} | branch-name / body-reference / title-reference |
```

## Per-Issue Detail Sections

For each implemented issue (not failed), include a brief section:

```markdown
---

## Issue #{number}: {title}

**Status**: DONE · **Branch**: feature-branch.{number} · **PR**: #{pr_number}

### Changes
- Bullet summary from agent report

### Notes
- Any caveats or reviewer concerns
```

## Next Steps Section

Always append:

```markdown
---

## Next Steps

- Review created PRs: `/git-review-multiple-pr {pr_numbers}`
- Retry failed issues: `/git-implement-issue {number}` for each failed issue
- Review excluded issues' PRs: `/git-review-multiple-pr {excluded_pr_numbers}`
```

## Chaining Suggestions

- If ALL DONE with PRs → offer batch review via `git-review-multiple-pr`
- If MIXED → list created PRs for selective review
- If FAILURES → suggest individual retry with `/git-implement-issue`
