# Readiness Report Template

> Loaded on demand by x-review Phase 6. Template for generating the readiness report with actionable findings.

## Template

Start with a verdict summary:

```
**Verdict**: APPROVED / CHANGES REQUESTED / BLOCKED

`N` files reviewed · `N` critical · `N` warnings · `N` suggestions
```

Then produce the full report:

```markdown
## Readiness Report

### Mode: {mode}
### Scope: {file_count} files, {lines_added}+ / {lines_removed}-

---

### Quality Gates (Phase 2)

| Gate | Status | Evidence |
|------|--------|----------|
| Lint | PASS/FAIL | {quoted command output summary} |
| Types | PASS/FAIL | {quoted command output summary} |
| Tests | PASS/FAIL | {pass_count} passed, {fail_count} failed |
| Build | PASS/FAIL | {quoted command output summary} |
| Coverage | PASS/WARN/FAIL | {percentage}% on changed files (threshold: 80%) |

---

### Spec Compliance (Phase 3a)

| Check | Status | Detail |
|-------|--------|--------|
| Requirements complete | PASS/FAIL | {detail} |
| No scope creep | PASS/FAIL | {detail} |
| Edge cases handled | PASS/FAIL | {detail} |
| Constraints met | PASS/FAIL/N/A | {detail} |

---

### Code Review Findings (Phase 3b)

> Omit empty severity groups entirely.

#### Critical

For each critical finding:

```
#### CATEGORY (V-CODE) — Short Title

**File:** `path/to/file.ext:line-range`

​```lang
// Comment explaining the issue
<relevant code snippet (5-10 lines max)>
​```

**Issue:** One or two sentences explaining why this matters.
**Fix:** Concrete recommendation.
```

#### Warnings

For each warning:

```
#### CATEGORY (V-CODE) — Short Title

**File:** `path/to/file.ext:line`

Brief explanation of the concern and recommended fix.
```

#### Suggestions

Compact format:

```
- **`file:line`** — **Short title.** One sentence explanation.
```

#### Positive Observations

```
- Bullet per positive observation (brief)
```

---

### Documentation (Phase 4)

| Check | Status | Detail |
|-------|--------|--------|
| API docs match signatures | PASS/FAIL | {V-DOC-XX if applicable} |
| Examples current | PASS/WARN | {detail} |
| Internal links valid | PASS/FAIL | {detail} |
| README updated | PASS/WARN/N/A | {detail} |
| CHANGELOG entry | PASS/WARN/N/A | {detail} |
| Initiative docs | PASS/WARN/N/A | {detail} |

---

### Regression (Phase 5)

| Check | Status | Detail |
|-------|--------|--------|
| Coverage delta | {+/-N}% | base: {base}%, current: {current}% |
| Removed tests | {count} | {list or "none"} |
| Disabled tests | {count} | {list or "none"} |
| Removed assertions | {count} | {list or "none"} |
| Behavioral regressions | {count} | {list or "none"} |

---

### Enforcement Summary (Phase 6)

| Practice | Status | Violations | Action |
|----------|--------|------------|--------|
| Spec Compliance | PASS/FAIL | — | {action} |
| SOLID | PASS/FAIL | V-SOLID-XX | {action} |
| DRY | PASS/FAIL | V-DRY-XX | {action} |
| Security | PASS/FAIL | OWASP AXX | {action} |
| Testing | PASS/WARN | V-TEST-XX | {action} |
| Documentation | PASS/FAIL | V-DOC-XX | {action} |
| Patterns | PASS/WARN | V-PAT-XX | {action} |
| Pareto | PASS/WARN | V-PARETO-XX | {action} |

---

### Verdict: {APPROVED / CHANGES REQUESTED / BLOCKED}

**ANY CRITICAL or unexempted HIGH violation = cannot proceed to /git-commit.**
```

---

### Fix Section

> Only include this section when verdict is NOT APPROVED.

Generate a copyable codeblock containing a self-contained `/x-implement` invocation with all Critical and Warning findings. **Omit Suggestions** — they are optional.

```
> Copy and run this to address all findings:

​```
/x-implement fix review findings
CATEGORY (V-CODE):
- file:line — description and fix direction
​```
```

**Rules for Fix generation:**
- Only include findings with severity Critical or Warning
- Group findings by CATEGORY tag
- Only include categories that have findings (omit empty categories)
- Each finding on one line: `file:line — description` (no code snippets)
- Use the same file:line references from the findings above
- Description is one sentence summarizing the issue and fix direction
- If verdict is APPROVED → skip this entire section

---

## Category Tags

CATEGORY must include the V-code or OWASP ID:
- `V-SOLID-01` through `V-SOLID-05` — SOLID violations
- `V-DRY-01` through `V-DRY-03` — DRY violations
- `V-KISS-01/02` — KISS violations
- `V-YAGNI-01/02` — YAGNI violations
- `V-PAT-01` through `V-PAT-04` — Design pattern violations
- `V-TEST-01` through `V-TEST-07` — Test violations
- `V-DOC-01` through `V-DOC-04` — Documentation violations
- `V-PARETO-01` through `V-PARETO-03` — Pareto violations
- OWASP `A01` through `A10` — Security findings

**MANDATORY**: Every finding MUST include its V-code or OWASP ID. Findings without violation IDs are incomplete and must be revised.

## Verdict Logic

- **BLOCKED**: any CRITICAL violation (V-SOLID-01, V-SOLID-03, V-TEST-01, V-TEST-05, V-TEST-06, V-DOC-02, V-PAT-01) or wrong requirement implemented
- **CHANGES REQUESTED**: any HIGH violation without documented user exception, or test failures, or security issues
- **APPROVED**: zero CRITICAL, zero unexempted HIGH, all MEDIUM flagged, tests pass with evidence, coverage >= 80%

## STOP — Review Approval Hard Gate

> **You MUST verify all violations before generating the verdict.**

**Checklist** (ALL must be true for APPROVED):
- [ ] Zero CRITICAL violations
- [ ] Zero HIGH violations without documented user-approved exception
- [ ] All MEDIUM violations flagged in report
- [ ] All test findings backed by execution evidence (see `references/verification-protocol.md`)

## Usage

Phase 6 MUST produce this report regardless of mode. Fill in actual values from prior phases. The verdict determines workflow chaining:
- APPROVED → chain to `/git-commit`
- CHANGES REQUESTED → chain to `/x-implement`
- BLOCKED → require fix before proceeding
