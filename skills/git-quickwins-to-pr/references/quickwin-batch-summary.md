# Quick Wins Batch Summary Report Template

Generate this report after all PRs are created (or skipped). The report has three layers: a **scan overview**, an **aggregate implementation summary**, then **per-quickwin detail sections**.

## Scan Overview

```markdown
# Quick Wins to PR — Summary

## Scan
- **Path**: {scanned_path}
- **Quick wins found**: {total_found}
- **Quick wins selected**: {total_selected}
- **Quick wins completed**: {completed_count}
- **Execution mode**: {worktree_parallel | direct_sequential}
- **Parallelization groups**: {group_count} groups ({parallel_rounds} parallel rounds)
```

## Aggregate Implementation Summary

```markdown
**Batch Status**: ✅ All Complete / ⚠️ Partial / 🚨 Failures

`{implemented_count}` implemented · `{pr_count}` PRs created · `{failed_count}` failed · `{skipped_count}` skipped

| # | Quick Win | Score | Category | Issue | Implementation | PR |
|---|-----------|-------|----------|-------|---------------|-----|
| 1 | {title} | {score} | {category} | #{issue} | DONE | PR #{pr} |
| 2 | {title} | {score} | {category} | #{issue} | PARTIAL | skipped |
| 3 | {title} | {score} | {category} | #{issue} | FAILED | — |
```

**Batch status rules:**
- ✅ **All Complete** — every quickwin DONE with PR created
- ⚠️ **Partial** — some DONE, some PARTIAL or skipped PRs
- 🚨 **Failures** — any quickwin FAILED

## Per-Quickwin Detail Sections

For each implemented quickwin (not failed), include a brief section:

```markdown
---

## Quick Win #{issue_number}: {title}

**Status**: DONE · **Category**: {category} · **Score**: {score}
**Branch**: feature-branch.{issue_number} · **PR**: #{pr_number}

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
- Retry failed quickwins: re-run `/git-quickwins-to-pr` with the specific path
- Check CI status: `/git-check-ci {pr_number}` for individual PRs
```

## Chaining Suggestions

- If ALL DONE with PRs → offer batch review via `git-review-multiple-pr`
- If MIXED → list created PRs for selective review
- If FAILURES → suggest individual retry or manual fix
