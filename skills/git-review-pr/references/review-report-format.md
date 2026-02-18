# Review Report Format

Structured format for comprehensive PR review reports.

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

**REQUEST_CHANGES** if:
- Any Critical findings exist
- Tests failed
- Security vulnerabilities found

**APPROVE** if:
- No Critical findings
- All tests passed
- No security vulnerabilities
- Warnings/Suggestions are acceptable

**COMMENT** if:
- Only Suggestions exist
- User wants to approve with minor comments

## Forge Submission Commands

**GitHub**:
```bash
gh pr review {number} \
  --approve | --request-changes | --comment \
  --body "{review report markdown}"
```

**Gitea**:
```bash
tea pr review {number} \
  --approve | --reject | --comment \
  --comment "{review report markdown}"
```

**GitLab**:
```bash
glab mr review {number} \
  --approve | --approve=false \
  --comment "{review report markdown}"
```

Verify submission:
- Check CLI exit code
- Fetch PR again to confirm review appears
- Display review URL to user

## Safety Rules

1. **Never auto-approve PRs** without explicit human gate confirmation
2. **Never skip security review** even if user requests "quick review"
3. **Never force-push** during review process
4. **Never modify PR branch** without explicit user instruction
5. **Always capture full review** in state checkpoint before submission
6. **Always require explicit confirmation** for approve-with-issues scenarios

## Critical Rules

- **CRITICAL**: Test failures ALWAYS trigger REQUEST_CHANGES verdict unless user explicitly overrides
- **CRITICAL**: Security vulnerabilities ALWAYS flagged as Critical severity
- **CRITICAL**: Secrets exposure (API keys, passwords) ALWAYS blocks approval without force-approve gate
- **CRITICAL**: Review submission is IRREVERSIBLE once posted - always confirm before submission

## Success Criteria

- PR fetched locally and checked out successfully
- Both code and security review completed with findings captured
- Tests executed with results captured
- Structured review report generated with verdict
- Review submitted to forge with correct verdict
- User informed of next steps (merge or wait for changes)
