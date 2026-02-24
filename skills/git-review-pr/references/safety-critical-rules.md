# Safety & Critical Rules

## Safety Rules

1. **Never auto-approve PRs** without explicit human gate confirmation
2. **Never skip security review** even if user requests "quick review"
3. **Never force-push** during review process
4. **Never modify PR branch** without explicit user instruction
5. **Always verify hard gate** (references/enforcement-audit.md) before generating verdict
6. **Always require explicit confirmation** for approve-with-issues scenarios

## Critical Rules

- **CRITICAL**: Test failures ALWAYS trigger REQUEST_CHANGES verdict unless user explicitly overrides
- **CRITICAL**: Security vulnerabilities ALWAYS flagged as Critical severity
- **CRITICAL**: Secrets exposure (API keys, passwords) ALWAYS blocks approval without force-approve gate
- **CRITICAL**: Review submission is IRREVERSIBLE once posted - always confirm before submission

## Agent Delegation

| Role | Agent Type | Model | When | Purpose |
|------|------------|-------|------|---------|
| Change scope analyzer | `ccsetup:x-explorer` | haiku | Phase 1b | Categorize PR diff by file type |
| Code reviewer | `ccsetup:x-reviewer` | sonnet | Phase 2b | Review code quality, design, maintainability |
| Security reviewer | `ccsetup:x-security-reviewer` | sonnet | Phase 2b | Review for OWASP vulnerabilities and security issues |
| Test runner | `ccsetup:x-tester` | sonnet | Phase 3a | Execute test suite and report results |
| Regression detector | `ccsetup:x-tester` | sonnet | Phase 3b | Detect coverage regressions and removed tests |
