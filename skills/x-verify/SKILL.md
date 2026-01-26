---
name: x-verify
description: |
  Quality verification with auto-fix enforcement. Testing, building, coverage improvement.
  Activate when running tests, verifying builds, checking coverage, or validating quality.
  Triggers: verify, test, build, coverage, quality, lint, check.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---

# x-verify

Context-aware quality verification with auto-fix enforcement. Zero-tolerance quality validation that continues until 100% passing.

## Modes

| Mode | Description |
|------|-------------|
| verify (default) | Full quality gate execution |
| build | Build management and artifact creation |
| coverage | Test coverage improvement |

## Mode Detection
| Keywords | Mode |
|----------|------|
| "build", "compile", "bundle", "artifact" | build |
| "coverage", "uncovered", "improve coverage" | coverage |
| (default) | verify |

## Execution
- **Default mode**: verify
- **No-args behavior**: Run full verification

## Behavioral Skills

This workflow activates these knowledge skills:
- `testing` - Testing pyramid enforcement
- `quality-gates` - CI quality checks

## Agent Suggestions

Consider delegating to specialized agents:
- **Testing**: Test execution, coverage analysis
- **Review**: Quality assessment, gate validation

## Quality Gates
All modes enforce: **Lint** | **Types** | **Tests** | **Build**

## Verification Workflow

```
1. Run all quality gates
2. If failures:
   a. Attempt auto-fix
   b. Re-run gate
   c. If still failing, report
3. Continue until 100% passing
```

## Coverage Targets

| Type | Target |
|------|--------|
| Unit | 70% |
| Integration | 20% |
| E2E | 10% |

## Checklist

- [ ] All linting passes
- [ ] Type checking passes
- [ ] All tests pass
- [ ] Build succeeds
- [ ] Coverage targets met

## When to Load References

- **For verify mode**: See `references/mode-verify.md`
- **For build mode**: See `references/mode-build.md`
- **For coverage mode**: See `references/mode-coverage.md`
