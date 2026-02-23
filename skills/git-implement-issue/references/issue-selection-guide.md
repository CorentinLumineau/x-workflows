# Issue Selection Guide

> Extracted from git-implement-issue SKILL.md — interactive issue discovery and selection.

## Fetching Open Issues

### Gitea (tea CLI)

```bash
# Fetch all open issues (TSV: index, title, labels, milestone, state, created)
tea issues ls -o tsv -f index,title,labels,milestone,state --state open --limit 200

# Fetch all open PRs (TSV: index, title, head, state)
tea pulls ls -o tsv -f index,title,head,state --state open --limit 200

# Fetch milestones with due dates
tea api /repos/{owner}/{repo}/milestones?state=open
```

### GitHub (gh CLI)

```bash
# Fetch open issues (JSON)
gh issue list --state open --limit 200 --json number,title,labels,milestone,createdAt

# Fetch open PRs (JSON)
gh pr list --state open --limit 200 --json number,title,headRefName,body

# Fetch milestones
gh api repos/{owner}/{repo}/milestones?state=open
```

## PR Cross-Referencing Algorithm

An issue is considered "already has a PR" if **any** of these match:

1. **Branch-name match**: An open PR's head branch is `feature-branch.N` where N equals the issue number
2. **Body-reference match**: An open PR's body contains `close #N`, `closes #N`, `fix #N`, `fixes #N`, or `resolve #N` (case-insensitive)
3. **Title-reference match**: An open PR's title contains `#N` preceded by a word boundary

Filter out any issue that matches at least one condition. These issues already have active work.

## Prioritization Scoring

| Signal | Points | Rationale |
|--------|--------|-----------|
| Has milestone | +30 | Planned work takes priority |
| Label: `urgency/*` or `priority/critical` | +20 | Explicit urgency |
| Label: `priority/high` | +15 | High priority |
| Label: `bug` or `type/bug` | +10 | Bugs before features |
| Age (days since creation) | +1 per 7 days | Older issues don't get forgotten |
| Comment count | +2 per comment | Community interest signal |

Sort descending by total score within each milestone group.

## Edge Case Handling

| Condition | Behavior |
|-----------|----------|
| 0 open issues | Show: "No open issues found." |
| 0 candidates (all have PRs) | Show: "All N open issues already have active PRs. Consider `/git-create-issue` to create a new one." |
| No milestones | Flat list (skip milestone grouping) |
| 50+ candidates | Show top 15 by score, note: "Showing top 15 of N candidates. Enter an issue number directly for others." |
| Issue fetch fails | Fall back to: "Could not fetch issues. Enter an issue number manually." |
| No forge CLI available | Stop: "Neither `tea` nor `gh` CLI found. Install one to use interactive selection." |

## Display Format

```
No issue number provided. Open issues without active PRs:

## Milestone: v2.0.0 (due 2026-03-01) -- 2 issues
  [1] #12 git-skills should validate a complete state machine (14d, score: 45)
  [2] #10 Add criteria verification for ecosystem audit (21d, score: 38)

## Backlog -- 3 issues
  [3] #9  Refactor to use exclusively native memory system (28d, score: 25)
  [4] #7  git-implement-issue should be aware of existing PRs (35d, score: 22)
  [5] #6  Improve the PR review workflow (42d, score: 18)
```

Each entry shows: `[index] #number title (age, score: N)`
