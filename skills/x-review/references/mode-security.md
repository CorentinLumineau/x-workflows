# Mode: security

> **Invocation**: `/x-review security` or `/x-review security "scope"`
> **Legacy Command**: `/x:security-review`

<purpose>
OWASP Top 10 security assessment with comprehensive vulnerability scanning. Focused security review with actionable remediation guidance.
</purpose>

## Behavioral Skills

This mode activates:
- `owasp` - OWASP Top 10 vulnerability check
- `input-validation` - Injection prevention
- `authentication` - Auth pattern review
- `authorization` - Access control check

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **security auditor** | Security assessment | OWASP, security analysis |
| **codebase explorer** | Attack surface analysis | Fast, read-only |

## MCP Servers

| Server | When |
|--------|------|
| `sequential-thinking` | Vulnerability analysis |

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 15%, context 20%, technical 25%, scope 10%, risk **30%**)
3. **If confidence < 100%**:
   - Identify lowest dimension (often risk for security reviews)
   - Research relevant sources (OWASP, CVE databases, codebase)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Security scope undefined, threat model unclear, compliance requirements unknown.

---

## Instructions

### Phase 1: Scope Definition

Determine security review scope:

| Scope | Target | Typical Effort |
|-------|--------|----------------|
| File | Single file (auth, crypto) | Quick |
| Module | Directory (API layer) | Medium |
| Feature | Related code (auth flow) | Medium |
| Full | Entire codebase | Extensive |

Identify sensitive areas:
- Authentication/authorization code
- Input handling (forms, APIs)
- Database queries
- File operations
- External service calls
- Cryptographic operations

### Phase 2: OWASP Top 10 Checklist

Systematically check each category:

#### A01: Broken Access Control
- [ ] Missing authorization checks
- [ ] IDOR (Insecure Direct Object References)
- [ ] Privilege escalation paths
- [ ] Missing CORS configuration
- [ ] JWT validation bypasses

#### A02: Cryptographic Failures
- [ ] Hardcoded secrets
- [ ] Weak algorithms (MD5, SHA1 for passwords)
- [ ] Missing encryption at rest/transit
- [ ] Improper key management
- [ ] Cleartext sensitive data

#### A03: Injection
- [ ] SQL injection vectors
- [ ] Command injection
- [ ] XSS (Cross-Site Scripting)
- [ ] LDAP/NoSQL injection
- [ ] ORM injection patterns

#### A04: Insecure Design
- [ ] Missing threat modeling
- [ ] Lack of rate limiting
- [ ] Missing input validation
- [ ] Business logic flaws
- [ ] Insufficient logging

#### A05: Security Misconfiguration
- [ ] Debug mode enabled
- [ ] Default credentials
- [ ] Unnecessary features enabled
- [ ] Missing security headers
- [ ] Verbose error messages

#### A06: Vulnerable Components
- [ ] Outdated dependencies
- [ ] Known CVEs in packages
- [ ] Unmaintained libraries
- [ ] Missing security patches

#### A07: Authentication Failures
- [ ] Weak password policies
- [ ] Missing MFA
- [ ] Session fixation
- [ ] Credential stuffing vulnerabilities
- [ ] Insecure password storage

#### A08: Software and Data Integrity
- [ ] Missing integrity checks
- [ ] Insecure deserialization
- [ ] CI/CD pipeline security
- [ ] Supply chain vulnerabilities

#### A09: Logging and Monitoring
- [ ] Missing audit logs
- [ ] Sensitive data in logs
- [ ] No alerting for security events
- [ ] Insufficient log retention

#### A10: Server-Side Request Forgery (SSRF)
- [ ] Unvalidated URLs
- [ ] Internal service exposure
- [ ] Cloud metadata access

### Phase 3: Generate Security Report

```markdown
## Security Review Report

**Scope**: {scope}
**Date**: {date}
**Reviewer**: AI-Assisted

### Executive Summary

| Severity | Count |
|----------|-------|
| Critical | {count} |
| High | {count} |
| Medium | {count} |
| Low | {count} |

**Overall Risk Level**: {Critical/High/Medium/Low}

### OWASP Top 10 Coverage

| Category | Status | Findings |
|----------|--------|----------|
| A01 Broken Access Control | {Pass/Fail} | {count} |
| A02 Cryptographic Failures | {Pass/Fail} | {count} |
| A03 Injection | {Pass/Fail} | {count} |
| A04 Insecure Design | {Pass/Fail} | {count} |
| A05 Security Misconfiguration | {Pass/Fail} | {count} |
| A06 Vulnerable Components | {Pass/Fail} | {count} |
| A07 Authentication Failures | {Pass/Fail} | {count} |
| A08 Integrity Failures | {Pass/Fail} | {count} |
| A09 Logging Failures | {Pass/Fail} | {count} |
| A10 SSRF | {Pass/Fail} | {count} |

### Critical Findings

#### Finding 1: {Title}
- **Severity**: {Critical/High/Medium/Low}
- **OWASP Category**: {A01-A10}
- **Location**: `{file}:{line}`
- **Description**: {description}
- **Impact**: {what could happen}
- **Remediation**: {how to fix}
- **References**: {CWE, OWASP links}

### Recommendations

#### Immediate Actions (Critical/High)
1. {Actionable fix for critical issue}

#### Short-term (Medium)
1. {Fix for medium severity}

#### Long-term (Low/Hardening)
1. {Security improvements}
```

### Phase 4: Workflow Transition

```json
{
  "questions": [{
    "question": "Security review complete. Risk level: {level}. Continue?",
    "header": "Next",
    "options": [
      {"label": "/x-implement fix (Recommended)", "description": "Fix critical/high findings"},
      {"label": "Export Report", "description": "Save for team review"},
      {"label": "Stop", "description": "Review report first"}
    ],
    "multiSelect": false
  }]
}
```

</instructions>

## Severity Classification

| Severity | Criteria | SLA |
|----------|----------|-----|
| Critical | Remote code execution, auth bypass, data breach | Immediate |
| High | Privilege escalation, sensitive data exposure | 24-48h |
| Medium | Information disclosure, missing hardening | 1 week |
| Low | Best practice violations, hardening suggestions | Backlog |

<critical_rules>

## Critical Rules

1. **Never dismiss security findings** - All findings documented
2. **Risk-based prioritization** - Critical/High first
3. **Actionable remediation** - Every finding has a fix
4. **No false positives** - Verify before reporting
5. **Context awareness** - Consider threat model

</critical_rules>

## References

- @skills/security-owasp/ - OWASP Top 10 details
- @skills/security-input-validation/ - Injection prevention
- @skills/security-authentication/ - Auth patterns
- @skills/security-authorization/ - Access control

<success_criteria>

## Success Criteria

- [ ] All OWASP categories checked
- [ ] All findings documented with severity
- [ ] Remediation provided for each finding
- [ ] Report generated
- [ ] Critical findings highlighted

</success_criteria>
