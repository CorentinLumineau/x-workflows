---
name: git-resolve-conflict
description: Use when git reports merge conflicts during merge, rebase, or cherry-pick operations.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
user-invocable: true
argument-hint: "[file or path]"
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
chains-to:
  - skill: git-merge-pr
    condition: "conflict resolved"
  - skill: git-commit
    condition: "conflict during rebase/impl"
chains-from:
  - skill: git-merge-pr
  - skill: x-implement
---

# /git-resolve-conflict

## Workflow Context

| Attribute | Value |
|-----------|-------|
| Type | UTILITY |
| Position | During merge/rebase operations |
| Flow | `git-merge-pr` or `x-implement` → **`git-resolve-conflict`** → `git-merge-pr` or `git-commit` |

---

## Intention

Resolve git merge conflicts through guided analysis and user-approved resolution strategies:
- Detect conflict context (merge, rebase, cherry-pick)
- Parse and analyze conflict markers in each file
- Recommend resolution strategies based on semantic analysis
- Apply resolutions with explicit human approval
- Verify resolution via test execution
- Chain back to original workflow

**Arguments**: None (detects conflict state automatically)

---

## Behavioral Skills

| Skill | When | Purpose |
|-------|------|---------|
| `forge-awareness` | Phase 0 | Detect forge context for PR-related conflicts |

---

<instructions>

## Phase 0: Detect Conflict Context

**Detect conflict context** via `git status --porcelain` and check for `.git/MERGE_HEAD`, `.git/rebase-merge/`, or `.git/CHERRY_PICK_HEAD` to determine operation type (merge/rebase/cherry-pick).

<context-query tool="project_context">
  <fallback>
  **Activate forge-awareness** if conflict appears PR-related:
  1. `git remote -v` → detect forge type
  2. `gh --version 2>/dev/null || tea --version 2>/dev/null` → verify CLI availability
  </fallback>
</context-query>

Display conflict context (operation type, source/target branch, file count) to user.

> **Detection scripts**: See `references/conflict-detection.md`

---

## Phase 1: Inventory Conflicting Files

List all files with conflict markers:
```bash
git diff --name-only --diff-filter=U
```

For each conflicting file, count conflict regions:
```bash
grep -c '^<<<<<<< ' {file}
```

Generate conflict inventory table:

| File | Conflict Regions | Size | Type |
|------|------------------|------|------|
| src/app.js | 3 | 245 lines | Source code |
| package.json | 1 | 42 lines | Config |
| README.md | 2 | 156 lines | Documentation |

Present inventory to user and ask:
"Found {total} conflict regions across {count} files. Proceed with resolution analysis?"

---

## Phase 2: Analyze Each Conflict

**For EACH conflicting file** (iterate in order of criticality: source code → config → docs):

### 2.1 Read File Content
Read the entire file content.

### 2.2 Parse and Analyze Conflicts

Parse conflict markers (`<<<<<<<`/`=======`/`>>>>>>>`) to extract ours/theirs content with surrounding context. Classify each conflict (content/addition/deletion/structural/whitespace) and recommend a strategy (accept ours/theirs/manual merge/rewrite) with confidence level (high/medium/low).

> **Conflict types, strategies, and recommendation criteria**: See `references/conflict-analysis.md`

---

## Phase 3: Human-Approved Resolution

**For EACH conflict region** (iterating through all conflicts):

<workflow-gate id="resolve-conflict-{file}-{region}" severity="critical">
Display conflict with context:

```
File: {path}
Region: {line_start}-{line_end}
Conflict type: {type}
Confidence: {high|medium|low}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OURS (current branch):
{ours content with syntax highlighting}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
THEIRS (incoming branch):
{theirs content with syntax highlighting}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RECOMMENDATION: {strategy}
Reason: {explanation}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Present options:
1. Accept ours (keep current branch)
2. Accept theirs (keep incoming branch)
3. Manual merge (combine both sides)
4. Custom resolution (provide your own)
5. Skip (decide later)

Wait for user choice.
</workflow-gate>

**Apply chosen resolution**:

- **Option 1/2**: Replace conflict region with chosen side
- **Option 3**: Present proposed merge, ask for confirmation
- **Option 4**: Request custom content from user, then apply
- **Option 5**: Mark for later, continue to next conflict

**Apply the resolution** by replacing the conflict markers:
```
old_string: <<<<<<< HEAD\n{ours}\n=======\n{theirs}\n>>>>>>> {branch}
new_string: {resolved content}
```

After each resolution, verify:
- Conflict markers removed
- File syntax remains valid (for code files)
- No orphaned markers left

Track resolution progress:
```
Resolved: {count}/{total} conflicts
Remaining: {file1: 2 regions, file2: 1 region}
```

---

## Phase 4: Verify Resolution

Once ALL conflicts resolved:

**Syntax check** for code files (eslint, py_compile, go build, cargo check). If syntax errors found, report to user and offer to re-open affected conflicts.

**Run tests** to verify resolution doesn't break functionality:

<agent-delegate id="post-resolution-tests" subagent="x-tester" model="sonnet">
Task: Execute test suite after conflict resolution
Instructions:
- Run full test suite
- Focus on tests related to modified files
- Report failures with context

Expected output:
- Test summary (pass/fail counts)
- Failed test details if any
</agent-delegate>

If tests fail:
<workflow-gate id="tests-failed-after-resolution" severity="high">
Tests failed after conflict resolution:
{failed test details}

This suggests resolution introduced bugs. Options:
1. Re-open conflicts to adjust resolution
2. Abort resolution (git merge --abort / git rebase --abort)
3. Proceed anyway (tests may be outdated)

Choose action:
</workflow-gate>

If user chooses abort: run `git merge --abort`, `git rebase --abort`, or `git cherry-pick --abort` based on operation type.

---

## Phase 5: Finalize Resolution

Stage resolved files (`git add`), verify with `git status` (all conflicts resolved, no unmerged paths).

---

## Phase 6: Chain Back to Caller

Accept `resume_context` from the calling workflow if provided (e.g., PR number, merge strategy from `git-merge-pr`).

- **Merge conflict** (from `git-merge-pr`):
  - Set `resume_from_conflict: true` in workflow state along with preserved caller context (`pr_number`, `merge_strategy`, `feature_branch`, `base_branch`)
  - Chain to `git-merge-pr $PR_NUMBER` — the flag tells git-merge-pr to skip Phase 0–1 validation and resume at merge execution
  <!-- <workflow-chain next="git-merge-pr" condition="conflict resolved, resume merge"> -->
- **Merge conflict** (standalone or from `git-commit`):
  - Chain to `git-commit`
- **Rebase conflict**: Run `git rebase --continue`; if more conflicts appear, re-enter this skill
- **Cherry-pick conflict**: Run `git cherry-pick --continue`, chain to `git-commit`

</instructions>

---

## Human-in-Loop Gates

| Gate ID | Severity | Trigger | Required Action |
|---------|----------|---------|-----------------|
| `resolve-conflict-{file}-{region}` | Critical | EACH conflict region | Choose resolution strategy (ours/theirs/manual/custom) |
| `tests-failed-after-resolution` | High | Tests fail after resolution applied | Decide whether to re-open, abort, or proceed |

---

## Workflow Chaining

| Relationship | Target Skill | Condition |
|--------------|--------------|-----------|
| chains-to | `git-merge-pr` | Merge conflict resolved, ready to complete merge |
| chains-to | `git-commit` | Rebase/cherry-pick conflict resolved, ready to commit |
| chains-from | `git-merge-pr` | Merge operation encountered conflicts |
| chains-from | `x-implement` | Implementation changes caused merge conflict |

---

## Safety Rules

1. **Never auto-resolve conflicts** without explicit human approval for each region
2. **Never accept "theirs"** blindly for critical files (config, security, dependencies)
3. **Never skip syntax validation** after resolution
4. **Never commit** resolved conflicts without test verification
5. **Always preserve conflict context** in checkpoints for potential re-opening
6. **Always offer abort option** if resolution seems too risky

---

## Critical Rules

- **CRITICAL**: Each conflict region requires explicit human gate - NEVER batch-approve
- **CRITICAL**: Test failures after resolution MUST be addressed before finalizing
- **CRITICAL**: Configuration file conflicts (package.json, Cargo.toml, go.mod) require extra scrutiny
- **CRITICAL**: Aborting resolution MUST fully restore pre-conflict state
- **CRITICAL**: Recursive conflicts (during rebase continuation) MUST be handled gracefully

---

## Success Criteria

- All conflict markers removed from all files
- Syntax validation passes for all code files
- Test suite passes (or user explicitly accepts failures)
- Resolved files staged for commit
- Workflow chained back to caller successfully
- No residual conflict state in git repository

---

## Agent Delegation

| Role | Agent Type | Model | When | Purpose |
|------|------------|-------|------|---------|
| Test runner | `ccsetup:x-tester` | sonnet | Phase 4 | Verify resolution doesn't break tests |

---

## References

- Behavioral skill: `@skills/forge-awareness/` (PR context detection)
- Knowledge skill: `@skills/vcs-git-workflows/` (conflict resolution patterns)
- Knowledge skill: `@skills/code-code-quality/` (semantic code analysis)

---

## When to Load References

- **For detection scripts**: See `references/conflict-detection.md`
- **For conflict types and strategies**: See `references/conflict-analysis.md`
