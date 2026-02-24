---
name: verification-before-completion
description: "Use when about to claim task completion or commit code. Enforces fresh verification evidence."
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
user-invocable: false
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: behavioral
triggers:
  - completion_claim
  - pre_commit
  - pre_pr
  - task_complete
---

# Verification Before Completion

> **Iron Law**: NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE

Universal behavioral skill that enforces evidence-based completion. The agent must produce fresh, current verification output before any claim of task completion, code readiness, or workflow transition.

## Why This Exists

Agents rationalize skipping verification under time pressure, context limits, or false confidence. Research shows that **commitment to a verification protocol before starting** reduces skip rates by 40-60% (Meincke et al. 2025, N=28,000). This skill is the commitment device.

## Activation Triggers

| Trigger | Description | Examples |
|---------|-------------|----------|
| **Completion claim** | About to say "done", "complete", "ready" | "Implementation complete", "All tests pass" |
| **Pre-commit** | About to stage and commit changes | Any `git add` + `git commit` sequence |
| **Pre-PR** | About to create or update a pull request | PR creation, PR description update |
| **Task complete** | About to mark a task or milestone as finished | Initiative milestone update, issue close |

## Gate Function

Every completion claim MUST pass this 5-step gate:

```
1. IDENTIFY  → What needs verification? (tests, build, lint, requirements)
2. RUN       → Execute the verification commands NOW
3. READ      → Read the FULL output (not just exit code)
4. VERIFY    → State pass/fail with evidence (quote output)
5. CLAIM     → Only NOW make the completion claim
```

**Steps 1-4 MUST produce artifacts** (command output, test results, build logs). Step 5 is only permitted after steps 1-4 succeed.

## Red Flags

If you catch yourself using ANY of these phrases, STOP and run the gate:

- "should work" / "should pass" / "should be fine"
- "probably" / "likely" / "I believe"
- "based on the code" / "based on my analysis"
- "the same pattern worked before"
- expressing satisfaction before running tests
- claiming success without showing output

## Common Failures

| Domain | Failure | What Actually Happens |
|--------|---------|----------------------|
| **Tests** | Using stale test results | Tests were green 10 minutes ago; new code broke them |
| **Builds** | Assuming build passes | Type errors, missing imports, config issues |
| **Requirements** | Assuming completeness | Missing edge cases, untested paths, partial implementation |
| **Agent delegation** | Assuming agent succeeded | Agent may have errored, partial results, wrong scope |
| **Documentation** | Assuming docs are synced | API signatures changed but docs not updated |
| **Lint** | Assuming clean | New code introduced lint violations |

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Tests should pass" | "Should" is a prediction, not a verification. Run them. |
| "I only changed a small thing" | Small changes cause big breakages. Verify proportionally. |
| "I already verified earlier" | Earlier results are stale. Verify again with current state. |
| "Running tests would take too long" | Skipping tests costs more than running them. Every time. |
| "The build is probably fine" | "Probably" is not evidence. Run the build. |
| "Based on the code, this works" | Code reading is analysis, not verification. Execute it. |
| "I'll verify after the next change" | Deferred verification is skipped verification. Verify now. |
| "This is just documentation" | Doc changes can break builds, links, and parsers. Verify. |

## Integration Points

This skill is referenced by completion-adjacent workflows:

| Skill | Integration Point |
|-------|-------------------|
| `x-implement` | Phase 4 quality gates — evidence required before proceeding |
| `x-fix` | Phase 3 verification — tests must be run, output read |
| `git-commit` | Phase 0 confidence check — pre-commit verification gate |
| `x-review` | Phase 2 quality gates — evidence protocol is mandatory |

## Verification Scope by Context

| Context | Minimum Verification |
|---------|---------------------|
| Code change | Run affected tests + lint |
| Bug fix | Run failing test → verify green + run full suite |
| Feature implementation | Full test suite + build + lint |
| Documentation change | Build (catches broken links/imports) |
| Configuration change | Relevant service/build verification |
| Refactoring | Full test suite (behavior must be unchanged) |

## Protocol Compliance

Compliant verification:
```
Tests: 47 passed, 0 failed (output from `pnpm test`)
Build: success (output from `pnpm build`)
Lint: 0 errors (output from `pnpm lint`)
→ CLAIM: Implementation complete, all gates pass.
```

Non-compliant (BLOCKED):
```
Tests should pass based on the changes made.
→ BLOCKED: No execution evidence. Run the tests.
```

## References

- `@skills/x-review/references/verification-protocol.md` - Detailed 5-step evidence protocol
- `@skills/code-code-quality/references/anti-rationalization.md` - Full excuse/reality catalog
- `@skills/meta-persuasion-principles/` - Science behind commitment devices and pre-suasion
