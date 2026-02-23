# Review Report Template

## Plugin Intelligence (when ccsetup plugin is loaded)

If you have the ccsetup plugin available, leverage its knowledge for deeper review:

- Use the **code-code-quality** skill knowledge (SOLID, DRY, KISS, YAGNI) to identify quality violations. Reference violation IDs (V-SOLID-01 through V-SOLID-05, V-DRY-01 through V-DRY-03, V-KISS-01/02, V-YAGNI-01/02) in findings when applicable.
- Use the **security-secure-coding** skill knowledge (OWASP Top 10, input validation, API security) to identify security issues. Reference OWASP categories (A01-A10) in findings.
- Use the **quality-testing** skill knowledge (testing pyramid, coverage) to assess test quality.
- Use the **code-design-patterns** skill knowledge to identify anti-patterns (V-PAT-01 through V-PAT-04).

Include violation IDs in the `category` field of findings when a match exists (e.g., "V-SOLID-01: SRP" instead of just "CODE QUALITY").

## Context Discovery

1. Read CLAUDE.md at the repo root if it exists — it contains the tech stack, conventions, and review guidelines specific to this project.
2. If no CLAUDE.md exists, scan for project markers: go.mod, package.json, Cargo.toml, requirements.txt, pom.xml, Makefile, tsconfig.json, pyproject.toml, build.gradle, Gemfile.
3. Note the language, framework, testing tools, and conventions before reviewing.

## Review Focus Areas

1. **Bugs & Logic Errors** — incorrect conditions, off-by-one errors, nil/null dereferences, missing return after error, unchecked error values, race conditions
2. **Security** — injection vulnerabilities (SQL, command, XSS), missing authentication/authorization checks, hardcoded secrets, insecure cryptographic usage, OWASP Top 10
3. **Code Quality** — SOLID principle violations, DRY violations, dead code, overly complex logic, poor naming, missing error handling
4. **Testing** — new public functions without tests, removed test coverage, untested edge cases
5. **Breaking Changes** — API contract changes, database schema changes without migration, removed public interfaces, changed default behavior

## Output Format (MANDATORY — follow exactly)

Start with a verdict summary:

```
**Verdict**: ✅ LGTM / ⚠️ Needs Changes / 🚨 Critical Issues

`N` files reviewed · `N` critical · `N` warnings · `N` suggestions
```

Then list findings grouped by severity. **Omit empty groups entirely.**

---

### 🚨 Critical

For each critical finding:

```
#### 🚨 CATEGORY — Short Title

**File:** `path/to/file.ext:line-range`

​```lang
// Comment explaining the bug or vulnerability
<relevant code snippet (5-10 lines max)>
​```

**Issue:** One or two sentences explaining why this matters and what to do.
```

---

### ⚠️ Warnings

For each warning:

```
#### ⚠️ CATEGORY — Short Title

**File:** `path/to/file.ext:line`

Brief explanation of the concern and recommended fix.
```

---

### 💡 Suggestions

Compact format:

```
- **`file:line`** — **Short title.** One sentence explanation.
```

---

### ✅ Good

```
- Bullet per positive observation (brief)
```

---

### Test Results

Always include:

```
- Tests: {passed} passed / {failed} failed / {skipped} skipped
- Coverage: {overall}% (diff: {diff_coverage}%)
- Failed tests: {details or "none"}
```

## Category Tags

CATEGORY must be one of: SECURITY, BUG, LOGIC, PERFORMANCE, TESTING, BREAKING CHANGE, CODE QUALITY.

When violation IDs apply:
- CODE QUALITY: `V-SOLID-01`–`V-SOLID-05`, `V-DRY-01`–`V-DRY-03`, `V-KISS-01/02`, `V-YAGNI-01/02`, `V-PAT-01`–`V-PAT-04`
- SECURITY: OWASP `A01`–`A10`

## Verdict Logic

- **🚨 Critical Issues** (REQUEST_CHANGES): any Critical finding, test failures, or security vulnerabilities
- **✅ LGTM** (APPROVE): no Critical findings, all tests pass, no security issues (Warnings acceptable)
- **⚠️ Needs Changes** (COMMENT): only Warnings and/or Suggestions, no Critical

## Rules

- Use fenced code blocks with the correct language tag to show problematic code.
- Keep code snippets short (5-10 lines) — just enough to show the issue in context.
- Add a `// comment` inside the snippet pointing to the exact problem.
- Be terse outside of code blocks. One sentence per explanation — two max for critical issues.
- Always include exact `file:line` or `file:line-range`. No vague references.
- Only flag real issues — skip nitpicks and linter-catchable style.
- If the PR is clean, just write the verdict line and a few ✅ Good bullets.

## Forge Submission Commands

**CRITICAL: Never use string interpolation for the review body.** Use `--body-file` or single-quoted heredoc to prevent shell injection.

### GitHub (safe pattern)
```bash
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

### GitLab (safe pattern)
```bash
TMPFILE=$(mktemp /tmp/review-body-XXXXXX.md)
printf '%s' "$REPORT_BODY" > "$TMPFILE"
glab mr review "$MR_NUMBER" --approve --body-file "$TMPFILE"
rm -f "$TMPFILE"
```

## Verification

- Check CLI exit code after submission
- Fetch PR again to confirm review appears
- Display review URL to user
