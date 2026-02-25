# Batch Issue Creation

## Phase 3.5c: Create Issues Upfront

Create all issues **before** any implementation begins. Use direct forge CLI calls (not `git-create-issue` skill) for batch efficiency.

### Input Sanitization (mandatory for both title AND body)

- **Title**: Strip control characters, escape single quotes, truncate to 255 chars
- **Body**: Write to temporary file to avoid shell interpolation — never use double-quoted `--body "{content}"` in shell commands

### Issue Template

```bash
# Write body to tmpfile (avoids shell interpolation)
BODY_FILE=$(mktemp)
cat > "$BODY_FILE" << 'ISSUE_BODY_EOF'
## Quick Win

**Category**: {category}
**File**: {file}:{line}
**Score**: {score} (impact: {impact}, effort: {effort})

## Problem
{quick_win_description}

## Suggested Fix
{suggested_fix}

---
*Created by git-quickwins-to-pr from x-quickwins scan.*
ISSUE_BODY_EOF

# Gitea (tea does not support --body-file; use tmpfile + cat)
# Note: $(cat ...) inside double quotes does NOT expand variables
# because the heredoc delimiter is single-quoted ('ISSUE_BODY_EOF').
# This is the safest portable pattern for tea CLI.
tea issue create \
  --repo {owner}/{repo} \
  --title '{sanitized_title}' \
  --body "$(cat "$BODY_FILE")" \
  --labels '{mapped_labels}'

# GitHub (preferred: --body-file avoids shell entirely)
gh issue create \
  --title '{sanitized_title}' \
  --body-file "$BODY_FILE" \
  --label '{mapped_labels}'

rm -f "$BODY_FILE"
```

### Type Inference

| Quick Win Category | Issue Type |
|--------------------|-----------|
| security | bug |
| dry, solid, kiss | enhancement |
| testing | enhancement |
| dead-code | chore |
| docs | documentation |

### Result Tracking

Capture each created issue number. Store the mapping: `{quickwin_index → issue_number}`.

### Error Handling

If any issue creation fails:
- Log the error with the quickwin index and title
- Ask user: retry / skip this quickwin / abort batch
- Do not continue batch blindly on failure
