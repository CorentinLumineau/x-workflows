# Security Review Rules Template

> Adapts to: projects with auth/, security/ directories or security-related dependencies

## Template

```markdown
# Security Review Rules

## Sensitive Paths

The following directories contain security-sensitive code and require extra scrutiny:
{sensitive_paths_list}

## Review Requirements

### For changes to sensitive paths:
- All PRs touching these paths require security-focused review
- Check for OWASP Top 10 vulnerabilities
- Validate input sanitization on all user-facing endpoints
- Verify authentication/authorization checks are in place

### Authentication & Authorization
- Never store plaintext passwords or secrets
- Use environment variables for all credentials
- Validate JWT tokens on every protected route
- Implement rate limiting on authentication endpoints

### Data Handling
- Sanitize all user input before processing
- Use parameterized queries for database operations
- Encrypt sensitive data at rest and in transit
- Never log sensitive data (passwords, tokens, PII)

### Dependencies
- Review new dependencies for known vulnerabilities
- Keep security-related packages up to date
- Use `npm audit` / `pip audit` as part of CI
```

## Placeholder Resolution

| Placeholder | Detection | Example |
|------------|-----------|---------|
| `{sensitive_paths_list}` | Scan for auth/, security/, crypto/, middleware/ directories | `- src/auth/\n- src/middleware/\n- src/crypto/` |
