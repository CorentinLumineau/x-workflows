# Mode: build

> **Invocation**: `/x-review quick "build"` or `/x-review build`
> **Legacy Command**: `/x:build`

## Purpose

<purpose>
Intelligent build management with automatic system detection, build orchestration, and deployment artifact preparation.
</purpose>

## Behavioral Skills

This mode activates:
- `testing` - Pre-build validation
- `code-quality` - Build quality enforcement

## Agent Delegation

| Role | When | Characteristics |
|------|------|-----------------|
| **test runner** | Pre-build verification | Can edit and run commands |

## MCP Servers

| Server | When |
|--------|------|
| `context7` | Build tool documentation |

## Instructions

<instructions>

### Phase 0: Interview Check (REQUIRED)

Before proceeding, verify confidence using `interview` behavioral skill:

1. **Load interview state** - Check `.claude/interview-state.json`
2. **Assess confidence** - Calculate composite score (weights: problem 20%, context 25%, technical 30%, scope 15%, risk 10%)
3. **If confidence < 100%**:
   - Identify lowest dimension
   - Research relevant sources (Context7, codebase, web)
   - Ask clarifying question with reformulation if > 80%
   - Loop until 100%
4. **If confidence = 100%** - Proceed to Phase 1

**Triggers for this mode**: Build target unclear, multiple build configurations available.

---

### Phase 1: Build System Detection

Detect build system from project:

| File | Build System |
|------|--------------|
| `package.json` + `pnpm-lock.yaml` | pnpm |
| `package.json` + `yarn.lock` | yarn |
| `package.json` + `package-lock.json` | npm |
| `Makefile` | make |
| `Cargo.toml` | cargo |
| `go.mod` | go |
| `pyproject.toml` | python |

### Phase 2: Pre-Build Validation

Run quick checks before build:
```bash
pnpm type-check  # Catch type errors early
pnpm lint        # Catch lint issues
```

### Phase 3: Build Execution

Execute build based on detected system:

**Node.js (pnpm/yarn/npm)**:
```bash
pnpm build
# or
pnpm run build
```

**Make**:
```bash
make build
# or
make all
```

### Phase 4: Build Verification

Verify build artifacts:
- [ ] Build completed without errors
- [ ] Expected output files exist
- [ ] Bundle size within limits
- [ ] No build warnings (or documented)

### Phase 5: Workflow Transition

Present next step:
```json
{
  "questions": [{
    "question": "Build successful. Continue?",
    "header": "Next",
    "options": [
      {"label": "/x-review quick (Recommended)", "description": "Run full quality gates"},
      {"label": "/git-commit", "description": "Commit build changes"},
      {"label": "Stop", "description": "Build complete"}
    ],
    "multiSelect": false
  }]
}
```

## Build Configurations

### Development Build
```bash
NODE_ENV=development pnpm build
```

### Production Build
```bash
NODE_ENV=production pnpm build
```

### Watch Mode
```bash
pnpm build --watch
```


</instructions>

## Critical Rules

<critical_rules>
1. **Pre-validate** - Run type-check and lint first
2. **Clean Build** - Use clean build when issues occur
3. **Verify Output** - Check artifacts exist
4. **Cache Aware** - Clear cache if stale
</critical_rules>

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Stale cache | `rm -rf .cache node_modules/.cache` |
| Type errors | Run `pnpm type-check` for details |
| Memory issues | `NODE_OPTIONS=--max-old-space-size=4096` |
| Missing deps | `pnpm install` |

## Decision Making

<decision_making>
**Execute autonomously when**:
- Standard build command
- No errors in pre-validation

**Use AskUserQuestion when**:
- Multiple build targets
- Build configuration choice
- Deploy target selection
</decision_making>

## References

- @core-docs/DOCUMENTATION-FRAMEWORK.md - Project structure
- Documentation/reference/ - Stack-specific docs

## Success Criteria

<success_criteria>
- [ ] Build system detected
- [ ] Pre-validation passed
- [ ] Build completed successfully
- [ ] Artifacts verified
</success_criteria>
