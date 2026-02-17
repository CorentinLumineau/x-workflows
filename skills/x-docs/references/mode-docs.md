# Mode: docs

> **Invocation**: `/x-docs` or `/x-docs docs`
> **Legacy Command**: `/x:docs`

<purpose>
Documentation router that analyzes documentation state and routes to appropriate sub-mode (generate, sync, cleanup).
</purpose>

## References

See `doc-sync-patterns.md` for documentation patterns.

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 25%, context 30%, technical 20%, scope 20%, risk 5%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Target audience unclear, documentation type undefined.

---

### Phase 1: Documentation State Analysis

Analyze current documentation:

```bash
# Check documentation structure
ls -la documentation/

# Check for staleness
find documentation/ -name "*.md" -mtime +30

# Check code changes
git diff --name-only HEAD~10 -- '*.ts' '*.tsx' '*.js'
```

### Phase 2: Issue Detection

Detect documentation issues:

| Issue Type | Detection | Route To |
|------------|-----------|----------|
| Missing docs | Code without docs | generate mode |
| Stale docs | Doc older than code | sync mode |
| Broken links | Dead references | cleanup mode |
| No issues | All current | Report status |

### Phase 3: Route or Report

**If issues found**:
```json
{
  "questions": [{
    "question": "Documentation analysis complete. Found: {issue_summary}. What to do?",
    "header": "Action",
    "options": [
      {"label": "/x-docs {recommended_mode} (Recommended)", "description": "{description}"},
      {"label": "/x-docs {other_mode}", "description": "{description}"},
      {"label": "Stop", "description": "Review findings first"}
    ],
    "multiSelect": false
  }]
}
```

**If no issues**:
```markdown
## Documentation Status: ✅ Current

- Structure complete
- All docs synced with code
- No broken references

No action needed.
```

</instructions>

## Documentation Structure Check

Expected structure:
```
documentation/
├── CLAUDE.md           ✓/✗
├── config.yaml         ✓/✗
├── domain/             ✓/✗
├── development/        ✓/✗
├── implementation/     ✓/✗
├── milestones/         ✓/✗
└── reference/          ✓/✗
```

## Additional References

- @core-docs/DOC_FRAMEWORK_ENFORCEMENT.md - Doc structure
- `doc-sync-patterns.md` - Doc patterns

<critical_rules>

## Critical Rules

1. **Analyze Before Routing** - Always assess documentation state before suggesting action
2. **Single Mode Per Session** - Route to one mode only, don't chain modes
3. **Report No Issues** - When docs are current, report status without suggesting unnecessary work
4. **User Choice** - Present routing options via AskUserQuestion, don't auto-route

</critical_rules>

<success_criteria>

- [ ] Documentation analyzed
- [ ] Issues identified
- [ ] Appropriate action taken or reported

</success_criteria>
