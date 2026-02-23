# Forge Commands for Batch PR Review

## Input Validation (MANDATORY)

Before any forge CLI call, validate all inputs:
```bash
# PR number: must be pure integer
[[ "$PR_NUMBER" =~ ^[0-9]+$ ]] || { echo "Invalid PR number: $PR_NUMBER"; exit 1; }

# Branch name: alphanumeric, hyphens, underscores, slashes, dots only — reject '..' traversal
[[ "$BRANCH_NAME" =~ ^[a-zA-Z0-9._/-]+$ ]] && [[ "$BRANCH_NAME" != *".."* ]] || { echo "Invalid branch name: $BRANCH_NAME"; exit 1; }

# Owner/repo: alphanumeric, hyphens, underscores, dots only
[[ "$OWNER" =~ ^[a-zA-Z0-9._-]+$ ]] || { echo "Invalid owner: $OWNER"; exit 1; }
```

## Auto-Fetch Unreviewed PRs

### GitHub
```bash
gh pr list --search "review:none" --state open --json number,title,author,headRefName,baseRefName --limit 20
```

### Gitea
```bash
# Gitea lacks native "unreviewed" filter — fetch open PRs with limit
tea pr list --state open --output json | head -20

# For each PR, check if reviews exist (two-tier check):

# Tier 1: Check formal PR reviews
tea api "repos/${OWNER}/${REPO}/pulls/${PR_NUMBER}/reviews"
# Non-empty array = reviewed (formal review exists)

# Tier 2: If formal reviews empty, check issue comments for review patterns
# Reviews may be posted as comments by CI bots (gitea-actions), by developers
# using /git-review-pr or /git-review-multiple-pr, or handwritten reviews.
# Match on content patterns, not author — any user can post a review comment.
tea api "repos/${OWNER}/${REPO}/issues/${PR_NUMBER}/comments" | \
  python3 -c "
import json, sys, re
comments = json.load(sys.stdin)
# Match skill-generated reviews (Verdict pattern) and common review indicators
REVIEW_PATTERNS = re.compile(
    r'\*{0,2}Verdict\*{0,2}\s*:' # **Verdict**: from skill-generated reviews
    r'|LGTM'                      # common approval shorthand
    r'|REQUEST_CHANGES'           # formal verdict keyword
    r'|Needs Changes'             # skill verdict
    r'|Critical Issues'           # skill verdict
)
review_comments = [c for c in comments
    if REVIEW_PATTERNS.search(c.get('body', ''))]
print(len(review_comments))
"
# If count > 0 = reviewed (review comment exists, from any author)
# A PR is "unreviewed" only if BOTH tier 1 AND tier 2 return empty/zero
```

**Limit**: Cap at 20 candidates for both forges. If >20 unreviewed PRs exist, inform user and suggest filtering by author or label.

## PR Metadata Fetch (for dependency ordering)

### GitHub
```bash
gh pr list --state open --json number,title,headRefName,baseRefName,author
```

### Gitea
```bash
tea api "repos/${OWNER}/${REPO}/pulls?state=open&limit=20"
# Extract: number, title, head.ref, base.ref, user.login
```

## Review Submission

**CRITICAL: Never use string interpolation for the review body.** Use `--body-file` or single-quoted heredoc to prevent shell injection from LLM-generated or forge-sourced content.

### GitHub (safe pattern)
```bash
# Write report to secure temp file — no shell expansion
TMPFILE=$(mktemp /tmp/review-body-XXXXXX.md)
printf '%s' "$REPORT_BODY" > "$TMPFILE"
gh pr review "$PR_NUMBER" --request-changes --body-file "$TMPFILE"
rm -f "$TMPFILE"
```

### Gitea (safe pattern)
```bash
# CRITICAL: tea CLI lacks --body-file. Use API endpoint to avoid shell expansion.
TMPFILE=$(mktemp /tmp/review-body-XXXXXX.md)
printf '%s' "$REPORT_BODY" > "$TMPFILE"
tea api "repos/${OWNER}/${REPO}/pulls/${PR_NUMBER}/reviews" \
  --method POST --input "$TMPFILE"
rm -f "$TMPFILE"
```

## Verification
- Check CLI exit code after submission
- Fetch PR again to confirm review appears
- Display review URL to user

## Force-Approve Audit Trail

When user force-approves despite Critical findings, prepend to review body:
```
> NOTICE: Approved at {ISO-8601 timestamp} with {count} blocking finding(s) detected.
> Human reviewer explicitly overrode the REQUEST_CHANGES recommendation.
```
