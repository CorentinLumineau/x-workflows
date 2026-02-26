# Git State Machine Validation Checklist

> Reference for F33-F35 audit features and the `git-state-machine.sh` coherence validator.
> Canonical source — also synced to `git-merge-pr/references/`.

## FSM State Table

10 states in the git lifecycle:

| State ID | State Name | Description |
|----------|-----------|-------------|
| S1 | BASE_CLEAN | On base branch, clean working tree |
| S2 | ISSUE_ASSIGNED | Issue identified, not yet branched |
| S3 | BRANCH_CREATED | Feature branch created from base |
| S4 | IMPLEMENTATION_WIP | Active development on feature branch |
| S5 | CHANGES_COMMITTED | All changes committed on feature branch |
| S6 | PR_CREATED | Pull request open on forge |
| S7 | PR_REVIEWED | PR has passed review (approved) |
| S8 | PR_MERGED | PR merged to base branch |
| S9 | CONFLICT | Merge conflict detected (transient) |
| S10 | DIRECT_MODE | Working directly on base branch (no PR) |

## Transition Table

| From | To | Skill | Pre-condition | Post-condition |
|------|----|-------|---------------|----------------|
| S1 | S2 | git-create-issue | Clean tree | Issue number assigned |
| S1/S2 | S3 | git-implement-issue (Phase 1) | Issue exists, clean tree | Feature branch checked out |
| S3 | S4 | git-implement-issue (Phase 2+) | On feature branch | Code changes present |
| S4 | S5 | git-commit | Dirty working tree | Clean tree, commits on branch |
| S5 | S6 | git-create-pr | Commits pushed, on feature branch | PR number assigned |
| S6 | S7 | git-review-pr | PR exists | Review verdict recorded |
| S6 | S9 | git-merge-pr (conflict) | PR exists, CI pass | Conflict markers in files |
| S9 | S5 | git-resolve-conflict | Conflict markers present | Conflicts resolved, committed |
| S7 | S8 | git-merge-pr | PR approved, CI pass | PR merged |
| S8 | S1 | git-merge-pr (Phase 5) | PR merged | On base branch, clean tree |
| S1/S2 | S10 | git-implement-issue (direct) | On base branch | Working on base directly |
| S10 | S5 | git-commit | Changes on base | Committed to base |
| S8 | S2 | git-implement-issue (next) | Previous issue done | Next issue started |
| S7 | S4 | git-fix-pr | Review requested changes | Back to implementation |
| S6 | S4 | git-fix-pr | CI failures on PR | Back to implementation |

## Per-Skill Pre/Post Condition Contracts

Each of the 14 git-* skills has defined FSM entry and exit conditions. Authors modifying these skills MUST preserve these contracts.

| Skill | Pre-conditions (entry states) | Post-conditions (exit states) | Critical Invariant |
|-------|-------------------------------|-------------------------------|-------------------|
| **git-create-issue** | S1 (clean tree) | S2 (issue assigned) | Issue number must be returned to caller |
| **git-implement-issue** | S1/S2 (clean tree, issue exists) | S3→S4 (branch + WIP) or S10 (direct) | Must detect existing PRs before creating branch |
| **git-commit** | S4/S10 (dirty tree) | S5 (clean, committed) | Protected branch warning on main/master |
| **git-create-pr** | S5 (pushed, on feature branch) | S6 (PR open) | Must include `Closes #N` in PR body |
| **git-review-pr** | S6 (PR exists) | S7 (approved) or S6 (changes requested) | Never auto-approve |
| **git-fix-pr** | S6/S7 (review feedback or CI failure) | S4 (back to WIP) | Must chain back to git-commit |
| **git-merge-pr** | S7 (approved, CI pass) | S8→S1 (merged, return to base) | Must return to base branch (Phase 5b) |
| **git-resolve-conflict** | S9 (conflict markers) | S5 (resolved, committed) | Must set `resume_from_conflict` for merge-pr |
| **git-check-ci** | S6 (PR exists) | S6 (status reported) | Read-only — no state change |
| **git-cleanup-branches** | S1 (on base branch) | S1 (cleaned) | Never delete current branch |
| **git-create-release** | S1 (on base, CI pass) | S1 (tagged) | Verify all tests pass before tagging |
| **git-implement-multiple-issue** | S1 (clean tree) | S4×N (parallel WIP) | Worktree cleanup after batch |
| **git-review-multiple-pr** | S6×N (PRs exist) | S7×N (reviewed) | Worktree cleanup after batch |
| **git-quickwins-to-pr** | S1 (clean tree) | S6 (PR created) | One PR per quick win |

## Issue Lifecycle Matrix

| Phase | Skill | Action | Evidence Pattern |
|-------|-------|--------|-----------------|
| Create | git-create-issue | Create issue on forge | `tea issue create` or `gh issue create` |
| PR-Awareness | git-implement-issue (Phase 0) | Check for existing PRs | Cross-reference algorithm, `tea pr ls` |
| Linking | git-create-pr (Phase 4) | Auto-link via "Closes #N" | `Closes #` in PR body |
| Closure (PR path) | git-merge-pr (Phase 5d) | Verify issue closed after merge | `tea issue read` status check |
| Closure (direct) | git-implement-issue (Phase 4B) | Close issue without PR | `tea issue close` or `gh issue close` |
| Batch tracking | git-implement-multiple-issue | Track per-issue lifecycle | Issue status dashboard |

## Worktree Lifecycle Matrix

| Phase | Skill | Action | Evidence Pattern |
|-------|-------|--------|-----------------|
| Creation | git-implement-multiple-issue (Phase 2) | `isolation: "worktree"` on Task | Agent spawn with worktree isolation |
| Creation | git-review-multiple-pr (Phase 2) | `isolation: "worktree"` on Task | Agent spawn with worktree isolation |
| Use | Subagents | Work in isolated worktree | File changes in worktree path |
| Cleanup | git-implement-multiple-issue (Phase 3.5) | Worktree cleanup gate | `git worktree remove` or `git worktree prune` |
| Cleanup | git-review-multiple-pr (Phase 3.5) | Worktree cleanup gate | `git worktree remove` or `git worktree prune` |
| Stale detection | worktree-awareness behavioral | Detect stale worktrees at session start | `git worktree list` check |
| Single-skill | git-implement-issue | Optional worktree isolation | Phase 2 worktree option |
| Merge context | git-merge-pr | Handle worktree context | Phase 5b worktree awareness |

## Required Patterns Per Skill

Grep patterns that MUST exist in each skill's SKILL.md (used by `git-state-machine.sh` validator):

| Skill | Required Pattern (case-insensitive) | Check # |
|-------|-------------------------------------|---------|
| git-merge-pr | `git switch` or `return.*base` or `switch.*back` | Check 3 |
| git-merge-pr | `close.*issue` or `issue.*clos` or `issue closure` | Check 4 |
| git-commit | `protected.*branch` or `branch.*protect` or `commits.*to.*main` | Check 5 |
| git-implement-multiple-issue | `worktree.*clean` or `worktree.*prun` | Check 6 |
| git-review-multiple-pr | `worktree.*clean` or `worktree.*prun` | Check 6 |
| git-create-pr | frontmatter `chains-to` includes `git-review-pr` | Check 8 |
| All git-* | ≤400 lines (warn at 350) | Check 7 |
| git-fix-pr | frontmatter `chains-to` includes `git-commit` or `git-create-pr` | Check 8 |
| All git-* with chains-to | Target skill directory exists | Check 1 |

## Common Skill Author Mistakes

Derived from Gap-to-Check mapping (G1-G20). Check this list before modifying any git-* skill:

| Mistake | Impact | Prevention |
|---------|--------|------------|
| Adding inline `tea pr create` / `gh pr create` in a skill that chains-to git-create-pr | Bypasses forge-agnostic PR creation; dual code paths | Validator Check 2 catches this — delegate via chain, don't inline |
| Forgetting return-to-base after merge | User left on wrong branch, stale state | Ensure `git switch $BASE_BRANCH` + `git pull` in post-merge phase |
| Missing issue closure verification | Issues stay open after merge, clutters backlog | Add `tea issue read` / `gh issue view` check in post-merge |
| No protected branch warning in commit skills | Accidental direct commits to main/master | Add branch check: `if [[ "$branch" == "main" \|\| "$branch" == "master" ]]` |
| Worktree leak in batch skills | Stale worktrees consume disk, confuse subsequent operations | Always add worktree cleanup gate after batch operations |
| Exceeding 400-line budget | Context window pollution, slower loading | Extract to `references/*.md` — validator Check 7 enforces |
| Breaking chains-to contract | Downstream skill expects state not provided | Check transition table: pre/post conditions must match |
| Missing `Closes #N` in PR body | Issue not auto-closed on merge, requires manual closure | Template enforces `Closes #$ISSUE_NUMBER` pattern |

## Gap-to-Check Mapping

Maps each gap from the Issue #12 analysis to the validator check or audit criterion that catches it.

| Gap ID | Gap Description | Caught By | Type |
|--------|----------------|-----------|------|
| G1 | Inline PR creation in chain-delegating skills | Validator Check 2 | Mechanical |
| G2 | No "Review PR" chain from git-create-pr | Validator Check 8 + F33 transition coverage | Mechanical + Semantic |
| G3 | Direct mode no issue closure | Validator Check 4 + F34 direct mode criterion | Mechanical + Semantic |
| G4 | Commits to main without warning | Validator Check 5 | Mechanical |
| G5 | Skill size bloat | Validator Check 7 | Mechanical |
| G6 | Return to base not recommended after merge | F33 pre/post condition audit | Semantic |
| G7 | No git switch error handling | F33 error recovery paths | Semantic |
| G8 | No worktree awareness in merge-pr | F35 merge-aware cleanup | Semantic |
| G9 | Stale worktree not enforced at session start | F35 stale detection | Semantic |
| G10 | Single implement-issue no worktree option | F35 single-skill support | Semantic |
| G11 | Batch implement-multiple-issue size | Validator Check 7 | Mechanical |
| G12 | Batch review-multiple-pr size | Validator Check 7 | Mechanical |
| G13 | Branch naming not validated | F33 pre-condition guards | Semantic |
| G14 | No post-merge closure verification | F34 issue closure | Semantic |
| G15 | git pull not verified before push | F33 error recovery paths | Semantic |
| G16 | cleanup-branches no worktree awareness | F35 cleanup enforcement | Semantic |
| G17 | quickwins-to-pr no return-to-base | F33 transition coverage | Semantic |
| G18 | Missing chains-from fields | Validator Check 1 + chain-consistency.sh | Mechanical |
| G19 | WORKFLOW_CHAINS.md missing batch skills | F33 transition coverage + F14 cross-check | Semantic |
| G20 | git-fix-pr fix cycle (review/CI → re-implementation) | Validator Check 8 + F33 transition coverage | Mechanical + Semantic |

## Classification

- **Mechanical checks** (Validator): Can be verified by grep/pattern matching. Automated, runs on every `coherence-check.sh` execution. Catches regressions immediately.
- **Semantic checks** (F33-F35 audit): Require reading and understanding skill content in context. Run during `/prj-audit-ecosystem` execution. Catches design-level gaps.

---

**Version**: 2.0.0
