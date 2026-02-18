# Review Report Template

## Report Sections

### Executive Summary
- Overall verdict: APPROVE / REQUEST_CHANGES / COMMENT
- Total findings count by severity
- Test results summary
- Key blocking issues (if any)

### Critical Findings
List all Critical severity findings:
- Source: code-quality / security
- Location: file:line
- Description: what's wrong
- Recommendation: how to fix

### Warnings
List all Warning severity findings (same structure as Critical)

### Suggestions
List all Suggestion severity findings (same structure as Critical)

### Test Results
- Tests passed/failed/skipped
- Coverage: overall % and diff vs. base
- Failed tests details (if any)

### Security Assessment
- OWASP categories checked
- Vulnerabilities found (count)
- Secrets exposure check: PASS/FAIL
- Recommended security improvements

## Verdict Logic

Determine verdict based on:
- **REQUEST_CHANGES** if:
  - Any Critical findings exist
  - Tests failed
  - Security vulnerabilities found
- **APPROVE** if:
  - No Critical findings
  - All tests passed
  - No security vulnerabilities
  - Warnings/Suggestions are acceptable
- **COMMENT** if:
  - Only Suggestions exist
  - User wants to approve with minor comments

## Forge Submission Commands

### GitHub
```bash
gh pr review {number} \
  --approve | --request-changes | --comment \
  --body "{review report markdown}"
```

### Gitea
```bash
tea pr review {number} \
  --approve | --reject | --comment \
  --comment "{review report markdown}"
```

### GitLab
```bash
glab mr review {number} \
  --approve | --approve=false \
  --comment "{review report markdown}"
```

## Verification
- Check CLI exit code
- Fetch PR again to confirm review appears
- Display review URL to user

## Example Usage

```bash
# Review PR #42
/git-review-pr 42

# Review PR with hash prefix
/git-review-pr #156
```

### Expected Workflow
1. User invokes skill with PR number
2. Skill fetches PR locally
3. Parallel code + security review runs
4. Tests execute on PR branch
5. Structured report generated
6. User reviews findings and approves submission
7. Review posted to forge
8. User proceeds to merge (chains to git-merge-pr) or waits for author
