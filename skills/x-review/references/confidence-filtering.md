# Confidence-Based Review Filtering

> Report what matters — suppress noise, surface signals.

Adapted from everything-claude-code (MIT, Copyright 2026 Affaan Mustafa).

## Confidence Model

Every review finding has an implicit confidence level. Report only findings above the threshold to reduce noise and improve reviewer trust.

### Confidence Thresholds

| Confidence | Range | Action |
|-----------|-------|--------|
| **HIGH** | >80% | Report in main findings |
| **MEDIUM** | 50-80% | Include in appendix with caveat |
| **LOW** | <50% | Suppress (do not report) |

### Confidence Signals

| Signal | Increases Confidence | Decreases Confidence |
|--------|---------------------|---------------------|
| Pattern matches known vulnerability | +30% | — |
| Static analysis confirms finding | +25% | — |
| Finding is in test code only | — | -20% |
| Similar code exists elsewhere without issues | — | -15% |
| Multiple indicators point to same root cause | +20% | — |
| Finding depends on runtime context | — | -25% |

## Severity Consolidation

Group related findings under a single parent issue rather than reporting each instance separately:

```
❌ 5 separate "missing input validation" findings
✅ 1 "Missing input validation" with 5 affected locations
```

### Consolidation Rules

1. **Same root cause** → Single finding with locations list
2. **Same file, related lines** → Merged finding with line range
3. **Same pattern, different files** → Pattern finding with file list
4. **Different patterns, same function** → Separate findings (different root causes)

## Approval Matrix

The review verdict uses a severity-based decision matrix:

| CRITICAL Count | HIGH Count | Verdict | Action |
|---------------|------------|---------|--------|
| 0 | 0 | **APPROVE** | Proceed to commit |
| 0 | 1+ | **WARNING** | Flag for human decision |
| 1+ | any | **BLOCK** | Must fix before proceeding |

### Verdict Rules

- **APPROVE**: No CRITICAL or HIGH findings → auto-approve (with MEDIUM/LOW in appendix)
- **WARNING**: HIGH findings present → present findings, recommend fixes, let human decide
- **BLOCK**: CRITICAL findings present → must fix, return to implementation

## Integration with x-review Phases

| Phase | Confidence Filtering Role |
|-------|--------------------------|
| Phase 3a (Spec Compliance) | N/A — spec compliance is binary (pass/fail) |
| Phase 3b (Code Quality) | Apply confidence thresholds to SOLID/DRY findings |
| Phase 3b (Security) | Apply to security findings (never suppress CRITICAL) |
| Phase 5 (Regression) | Apply to regression indicators |
| Phase 6 (Report) | Use approval matrix for verdict |

## Output Format

### Main Findings (>80% confidence)

```markdown
### Critical Issues (BLOCK)
1. **SQL Injection** in `api/users.ts:45` [confidence: 95%]
   - Evidence: unsanitized user input in query template
   - Fix: Use parameterized query

### Warnings (HIGH)
1. **Missing rate limiting** on `/api/auth/login` [confidence: 85%]
   - Evidence: No rate limiter middleware in route chain
   - Fix: Add express-rate-limit with 5 req/min window
```

### Appendix (50-80% confidence)

```markdown
### Potential Issues (review recommended)
1. **Possible memory leak** in WebSocket handler [confidence: 65%]
   - Caveat: Only occurs if connections exceed 10K concurrent
```

## Anti-Patterns

| Anti-Pattern | Fix |
|-------------|-----|
| Reporting everything found | Apply >80% threshold |
| Suppressing CRITICAL findings | Never suppress CRITICAL regardless of confidence |
| No confidence reasoning | Always include evidence for confidence level |
| Treating all findings equally | Use severity consolidation |
| Reporting same root cause 5 times | Consolidate under single parent finding |
