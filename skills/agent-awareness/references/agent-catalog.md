# Agent Catalog Reference

Detailed specifications for all specialized agents, including standard and variant agents.

## Standard Agents

---

### x-reviewer

**Purpose**: Code review with SOLID enforcement

**Model**: sonnet

**Capabilities**: file reading, code search, pattern matching, command execution, language server analysis (read-only, no file modification)

**Skills**: code-quality, analysis

**Delegation**:
```markdown
Delegate to a **code reviewer** agent (sonnet):
> "Review the changes to src/auth for SOLID compliance"
```

**Best For**:
- Post-implementation review
- Pre-merge validation
- SOLID principle enforcement
- Code quality assessment

**Not For**:
- Making code changes
- Security-focused review (use x-security-reviewer)
- Test execution

---

### x-security-reviewer

**Purpose**: Security-focused code review with OWASP expertise

**Model**: sonnet

**Capabilities**: file reading, code search, pattern matching, command execution, language server analysis (read-only, no file modification)

**Skills**: All security-* skills (owasp, auth, authorization, input-validation, secrets, etc.)

**Delegation**:
```markdown
Delegate to a **security auditor** agent (sonnet):
> "Audit the authentication flow for vulnerabilities"
```

**Best For**:
- Security audits
- Vulnerability detection
- OWASP Top 10 checks
- Auth flow review
- Secrets scanning

**Not For**:
- General code quality
- Making changes
- Performance review

---

### x-deployer

**Purpose**: Deployment verification and rollback planning

**Model**: sonnet

**Capabilities**: file reading, code search, pattern matching, command execution, language server analysis (read-only, no file modification)

**Skills**: delivery-ci-cd, delivery-release-management, delivery-infrastructure

**Delegation**:
```markdown
Delegate to a **deployment verifier** agent (sonnet):
> "Verify deployment readiness for v1.2.0"
```

**Best For**:
- Deployment verification
- Rollback planning
- Infrastructure validation
- Release readiness checks

**Not For**:
- Code changes
- Test execution
- Security review

---

### x-debugger

**Purpose**: Root cause analysis and bug investigation

**Model**: sonnet

**Capabilities**: file reading, file editing, command execution, code search, pattern matching, language server analysis

**Skills**: quality-debugging

**Delegation**:
```markdown
Delegate to a **debugger** agent (sonnet):
> "Investigate the race condition in UserService"
```

**Best For**:
- Complex bug investigation
- Race condition analysis
- Performance issues
- Root cause analysis

**Not For**:
- Simple fixes (handle directly)
- Code review
- Test writing

---

### x-tester

**Purpose**: Test execution and coverage improvement

**Model**: sonnet

**Capabilities**: file reading, file editing, command execution, code search, pattern matching, language server analysis

**Skills**: quality-testing

**Delegation**:
```markdown
Delegate to a **test runner** agent (sonnet):
> "Fix failing tests in auth module and improve coverage"
```

**Best For**:
- Test failures
- Coverage improvement
- Test writing
- TDD workflow

**Not For**:
- Production bugs (use x-debugger)
- Code review
- Documentation

---

### x-doc-writer

**Purpose**: Documentation generation and maintenance

**Model**: sonnet

**Capabilities**: file reading, file writing, file editing, code search, pattern matching, language server analysis

**Skills**: documentation

**Delegation**:
```markdown
Delegate to a **documentation writer** agent (sonnet):
> "Generate JSDoc for the PaymentService module"
```

**Best For**:
- JSDoc generation
- README updates
- API documentation
- Code comments

**Not For**:
- Code changes
- Test writing
- Review

---

### x-explorer

**Purpose**: Fast codebase exploration

**Model**: haiku (faster, cheaper)

**Capabilities**: file reading, code search, pattern matching, language server analysis (read-only, no file modification)

**Delegation**:
```markdown
Delegate to a **codebase explorer** agent (haiku):
> "Find all files that handle authentication"
```

**Best For**:
- Quick file searches
- Codebase understanding
- Pattern discovery
- Initial exploration

**Not For**:
- Making changes
- Complex analysis
- Review tasks

---

### x-refactorer

**Purpose**: Safe refactoring with SOLID enforcement

**Model**: sonnet

**Capabilities**: file reading, file editing, command execution, code search, pattern matching, language server analysis

**Skills**: code-quality

**Delegation**:
```markdown
Delegate to a **refactoring agent** (sonnet):
> "Refactor UserService to follow SRP"
```

**Best For**:
- SOLID refactoring
- Code cleanup
- Technical debt reduction
- Safe restructuring

**Not For**:
- Bug fixes (use x-debugger)
- Feature implementation
- Review (use x-reviewer)

---

## Variant Agents

Variant agents provide cost optimization (haiku variants) or capability escalation (opus variants) compared to their standard counterparts.

---

### x-designer

**Purpose**: Architecture design, system modeling, and trade-off analysis

**Model**: opus (maximum reasoning depth)

**Capabilities**: file reading, file editing, command execution, code search, pattern matching, language server analysis

**Skills**: meta-architecture-patterns, meta-decision-making, code-quality

**Delegation**:
```markdown
Delegate to an **architect** agent (opus):
> "Design the microservice boundary for the payment system"
```

**Best For**:
- Complex architecture decisions
- System design and modeling
- Trade-off analysis
- Cross-service boundaries
- Technology selection

**Not For**:
- Simple refactoring (use x-refactorer)
- Code review
- Bug fixing

**Variant of**: x-refactorer (escalation — deeper reasoning for architectural decisions)

---

### x-debugger-deep

**Purpose**: Deep root cause analysis for elusive and cross-service bugs

**Model**: opus (maximum reasoning depth)

**Capabilities**: file reading, file editing, command execution, code search, pattern matching, language server analysis

**Skills**: quality-debugging, quality-performance

**Delegation**:
```markdown
Delegate to a **deep debugger** agent (opus):
> "Investigate the intermittent timeout in the payment-to-inventory service chain"
```

**Best For**:
- Elusive, hard-to-reproduce bugs
- Cross-service debugging
- Performance root cause analysis
- Race conditions across distributed systems
- Memory leak investigation

**Not For**:
- Simple bugs with clear errors (use x-debugger)
- Test failures (use x-tester)
- Code review

**Variant of**: x-debugger (escalation — deeper reasoning for complex bugs)

---

### x-tester-fast

**Purpose**: Quick test validation and smoke testing

**Model**: haiku (fast, cheap)

**Capabilities**: file reading, command execution, code search, pattern matching (reporter only, no file modification)

**Skills**: quality-testing

**Delegation**:
```markdown
Delegate to a **fast test runner** agent (haiku):
> "Run smoke tests for the auth module"
```

**Best For**:
- Fast smoke tests
- Quick test verification
- Simple assertion fixes
- Rapid CI feedback

**Not For**:
- Complex test failures (use x-tester)
- Test architecture decisions
- Coverage strategy

**Variant of**: x-tester (cost optimization — faster and cheaper for simple tests)

---

### x-reviewer-quick

**Purpose**: Rapid code scan for low-risk changes

**Model**: haiku (fast, cheap)

**Capabilities**: file reading, code search, pattern matching, command execution, language server analysis (read-only, no file modification)

**Skills**: code-quality

**Delegation**:
```markdown
Delegate to a **quick reviewer** agent (haiku):
> "Quick scan of the 3 changed files for obvious issues"
```

**Best For**:
- Quick sanity checks
- Low-risk change validation
- Pre-push quick scan
- Formatting/style review

**Not For**:
- Security-critical code (use x-security-reviewer)
- Complex architectural changes (use x-reviewer)
- In-depth SOLID analysis (use x-reviewer)

**Variant of**: x-reviewer (cost optimization — faster and cheaper for low-risk reviews)

---

## Escalation Rules

For escalation rules between agent variants, see the canonical Escalation Table in the parent SKILL.md (@skills/agent-awareness/).

---

## Delegation History

Agent delegation decisions are tracked for learning and optimization.

### Storage

| Layer | Location | Content |
|-------|----------|---------|
| **L2** | MEMORY.md | Summary patterns (e.g., "x-tester succeeds 90% for test tasks") |

### Acceptance Rate Tracking

Over time, the delegation history reveals patterns:
- Which agents succeed for which task types
- Which suggestions users consistently override
- Which escalations are most common

This data informs future agent-awareness suggestions.
