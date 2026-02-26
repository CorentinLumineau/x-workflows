---
name: worktree-awareness
description: Auto-triggered on worktree context or parallelizable work. Manages worktree lifecycle suggestions.
version: "1.0.0"
license: Apache-2.0
compatibility: Works with Claude Code. Worktree features require git and Claude Code EnterWorktree/Task isolation support.
allowed-tools: Read Grep Glob Bash
user-invocable: false
metadata:
  author: ccsetup contributors
  category: behavioral
---

# Worktree Awareness

Detect worktree context and manage worktree lifecycle for isolated parallel work.

## Purpose

Provide worktree lifecycle management for workflow skills:
1. **Detection** → Is session inside a worktree? (via context-awareness)
2. **Suggestion** → Should this task use worktree isolation?
3. **Lifecycle** → Create, work, merge-back, prune

This behavioral skill ensures worktrees are properly managed with human gates at every lifecycle transition.

---

## Activation Triggers

| Trigger | Condition |
|---------|-----------|
| Session start in worktree | context-awareness detects is_worktree=true |
| Parallelizable task | complexity-detection identifies parallel work |
| Parallel agent spawn | Feature or Refactor pattern with overlapping files |
| Explicit request | User mentions worktree or isolation |

worktree-awareness activates automatically when worktree context is relevant.

---

## Worktree Lifecycle

### Complete Lifecycle

```
1. SUGGEST  ─── Skill detects parallelizable task
                 │
2. CONFIRM  ─── Human approval gate
                 │
3. CREATE   ─── EnterWorktree / Task isolation: "worktree"
                 Branch naming: {type}/{descriptive-name}
                 │
4. WORK     ─── Agent(s) execute in worktree(s)
                 Independent commits per worktree
                 │
5. MERGE    ─── Merge worktree branch(es) back to source
                 Handle conflicts (delegate to git-resolve-conflict)
                 │
6. PRUNE    ─── git worktree remove + git worktree prune
                 Verify no stale references remain
```

### Human Validation Gates

| Step | Gate Type | When to Ask |
|------|-----------|-------------|
| Create worktree | **Always ask** | "This task could benefit from worktree isolation. Create worktree for {task}?" |
| Merge back | **Always ask** | "Worktree work complete. Merge {branch} back to {source}?" |
| Prune | **Auto if clean** | Only ask if uncommitted changes exist in the worktree |

---

## Contextual Triggers

When to SUGGEST worktree isolation:

| Context | Suggest Worktree | Rationale |
|---------|-----------------|-----------|
| Parallel Feature/Refactor pattern | Yes | Parallel agents benefit most from isolation |
| x-implement COMPLEX task | Yes | Long implementation avoids blocking main branch |
| x-implement SIMPLE task | No | Overhead exceeds benefit |
| x-fix (ONESHOT) | No | Quick fixes don't need isolation |
| x-review | No | Read-only, no conflict risk |
| x-analyze | No | Read-only |
| Multiple overlapping file sets | Yes | Worktrees resolve what file ownership can't |
| Single non-overlapping task | No | No parallelization benefit |

---

## Branch Naming Convention

When issue context is available (e.g., from `git-implement-issue` or `git-implement-multiple-issue`), use the **issue-based naming convention**:

| Pattern | Example | When |
|---------|---------|------|
| `feature-branch.{number}` | `feature-branch.42` | Issue-driven development (preferred) |

When no issue context exists, fall back to the **descriptive convention**:

| Type | Example | When |
|------|---------|------|
| `feature/` | `feature/auth-backend` | New feature development |
| `fix/` | `fix/memory-leak-api` | Bug fix implementation |
| `refactor/` | `refactor/split-user-service` | Restructuring |
| `test/` | `test/e2e-payment-flow` | Test infrastructure |

Avoid the default `worktree-<name>` pattern — it provides no context about the work being done.

---

## Merge-Back Protocol

When worktree work is complete:

```
1. Verify all quality gates pass in the worktree
2. Present merge confirmation to user:
   "Worktree work complete on {branch}. Merge back to {source}?"
3. If approved:
   a. Switch to source branch
   b. git merge {worktree-branch}
   c. If conflicts → delegate to @skills/git-resolve-conflict/
   d. Run tests after merge to verify
4. After successful merge:
   a. git worktree remove {path}
   b. git worktree prune
   c. Verify: git worktree list shows no stale entries
```

---

## Stale Worktree Detection

At session start, check for stale worktrees:

```
1. Run: git worktree list
2. For each worktree:
   - Check if directory still exists
   - Check if branch has been merged
   - Check last commit date
3. If stale (merged + older than 7d):
   - Report to user: "Found stale worktree: {name}. Prune?"
   - Auto-prune if user approves
```

---

## Integration Pattern

worktree-awareness is **automatically active** when worktree features are relevant. Other skills reference it for lifecycle management:

### Skill Integration

```markdown
## Worktree Support

Uses: @skills/worktree-awareness/

When isolation is beneficial:
1. Suggest worktree via worktree-awareness
2. Human confirms
3. Create worktree (EnterWorktree or Task isolation)
4. Execute work
5. Merge-back via worktree-awareness protocol
```

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Merge conflicts | Explicit merge-back phase with git-resolve-conflict delegation |
| Stale worktrees | Prune step + stale detection at session start |
| Missing build artifacts | Agent prompts include dependency install step |
| User confusion | context-awareness reports worktree state |
| Disk space | Recommend max 3-5 concurrent worktrees |

---

## References

- @skills/context-awareness/ - Worktree detection (environment context)
- @skills/git-resolve-conflict/ - Conflict resolution during merge-back
- @skills/complexity-detection/ - Task complexity triggers
