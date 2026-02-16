---
name: git-resolve-conflict
description: Use when git reports merge conflicts during merge, rebase, or cherry-pick operations.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
user-invocable: true
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
chains-to:
  - skill: git-merge-pr
    condition: "conflict resolved"
    auto: true
  - skill: git-create-commit
    condition: "conflict during rebase/impl"
    auto: true
chains-from:
  - skill: git-merge-pr
    auto: true
  - skill: x-implement
    auto: false
---

# /git-resolve-conflict

## Workflow Context

| Attribute | Value |
|-----------|-------|
| Type | UTILITY |
| Position | During merge/rebase operations |
| Flow | `git-merge-pr` or `x-implement` → **`git-resolve-conflict`** → `git-merge-pr` or `git-create-commit` |

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

<state-checkpoint id="conflict-init">
Checkpoint captures: Git operation type, conflicting branch names, conflict file list
</state-checkpoint>

**Check git status** to determine conflict context:
```bash
git status --porcelain
```

Parse output to identify:
- **Merge conflict**: Both modified (UU), both added (AA), both deleted (DD)
- **Rebase conflict**: Look for `.git/rebase-merge/` or `.git/rebase-apply/` directory
- **Cherry-pick conflict**: Look for `.git/CHERRY_PICK_HEAD`

**Determine operation type**:
```bash
# Check for merge
if [ -f .git/MERGE_HEAD ]; then
  OPERATION="merge"
  SOURCE_BRANCH=$(git rev-parse --abbrev-ref MERGE_HEAD)
fi

# Check for rebase
if [ -d .git/rebase-merge ]; then
  OPERATION="rebase"
  SOURCE_BRANCH=$(cat .git/rebase-merge/head-name | sed 's#refs/heads/##')
fi

# Check for cherry-pick
if [ -f .git/CHERRY_PICK_HEAD ]; then
  OPERATION="cherry-pick"
  COMMIT_SHA=$(cat .git/CHERRY_PICK_HEAD)
fi
```

**Activate forge-awareness** if conflict appears PR-related:
- Check if current branch matches PR branch pattern
- Extract PR number if detectable from branch name

Display conflict context to user:
```
Conflict detected during: {merge|rebase|cherry-pick}
Source: {branch or commit}
Target: {current branch}
Files affected: {count}
```

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

<state-checkpoint id="conflict-inventory">
Checkpoint captures: File paths, conflict counts per file, file metadata
</state-checkpoint>

Present inventory to user and ask:
"Found {total} conflict regions across {count} files. Proceed with resolution analysis?"

---

## Phase 2: Analyze Each Conflict

**For EACH conflicting file** (iterate in order of criticality: source code → config → docs):

### 2.1 Read File Content
Use Read tool to load entire file content.

### 2.2 Parse Conflict Markers
Identify conflict regions using pattern:
```
<<<<<<< HEAD (or branch name)
[ours content]
=======
[theirs content]
>>>>>>> {branch/commit}
```

Extract:
- **Ours**: Content from HEAD/current branch
- **Theirs**: Content from merging branch/commit
- **Context**: 5 lines before and after conflict region

### 2.3 Semantic Analysis
Analyze both sides to determine conflict type:

**Conflict Types**:
1. **Content conflict**: Both sides modified same lines differently
2. **Addition conflict**: Both sides added content in same location
3. **Deletion conflict**: One side deleted, other modified
4. **Structural conflict**: Code structure changed (imports, class definitions)
5. **Whitespace conflict**: Only whitespace/formatting differs

**Resolution Strategies**:
- **Accept ours**: Keep HEAD version (use when current branch is authoritative)
- **Accept theirs**: Keep incoming version (use when merging authoritative changes)
- **Manual merge**: Combine both sides intelligently
- **Rewrite**: Neither side is correct, needs fresh implementation

### 2.4 Recommendation Generation
For each conflict region, generate recommendation based on:
- Semantic analysis of code changes
- Function/method context
- Variable usage and dependencies
- Comments and documentation hints

Present recommendation with confidence level:
- **High confidence**: Clear winner (e.g., one side is clearly newer/better)
- **Medium confidence**: Both sides have merit, suggests manual merge
- **Low confidence**: Complex conflict, requires human judgment

<state-checkpoint id="conflict-{file}-analyzed">
Checkpoint captures: Conflict regions parsed, recommendations generated, confidence levels
</state-checkpoint>

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

**Use Edit tool** to apply resolution:
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

**Syntax check** for code files:
- **JavaScript/TypeScript**: `npx eslint {file} --no-eslintrc` (syntax only)
- **Python**: `python -m py_compile {file}`
- **Go**: `go build {file}`
- **Rust**: `cargo check`

If syntax errors found, report to user and offer to re-open affected conflicts.

<state-checkpoint id="conflicts-resolved">
Checkpoint captures: All resolutions applied, files modified, syntax check results
</state-checkpoint>

**Run tests** to verify resolution doesn't break functionality:

<agent-delegate id="post-resolution-tests">
Delegate to: `ccsetup:x-tester`
Model: sonnet
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

If user chooses abort:
```bash
# Abort based on operation type
if [ "$OPERATION" = "merge" ]; then
  git merge --abort
elif [ "$OPERATION" = "rebase" ]; then
  git rebase --abort
elif [ "$OPERATION" = "cherry-pick" ]; then
  git cherry-pick --abort
fi
```

<state-cleanup id="resolution-aborted">
Clear all conflict checkpoints, restore original state
</state-cleanup>

Exit skill with abort message.

---

## Phase 5: Finalize Resolution

**Stage resolved files**:
```bash
git add {all resolved files}
```

**Verify staging**:
```bash
git status
```

Should show:
- All conflicts resolved
- Changes staged for commit
- No unmerged paths

<state-checkpoint id="resolution-finalized">
Checkpoint captures: Staged files, resolution summary, test results
</state-checkpoint>

---

## Phase 6: Chain Back to Caller

Determine caller workflow based on operation:

**If merge conflict**:
<workflow-chain id="return-to-merge">
Chain to: `git-merge-pr` (if PR-related) or `git-create-commit`
Context: Conflicts resolved, ready to complete merge
Message: "Conflicts resolved. Resuming merge operation."
</workflow-chain>

**If rebase conflict**:
```bash
git rebase --continue
```

If rebase completes successfully, chain to original caller.
If more conflicts appear, re-enter this skill (recursive).

**If cherry-pick conflict**:
```bash
git cherry-pick --continue
```

Chain to `git-create-commit` to finalize cherry-pick.

<state-cleanup id="resolution-complete">
Clear checkpoints: conflict-init, conflict-inventory, conflict-*-analyzed, conflicts-resolved, resolution-finalized
Retain resolution summary for audit
</state-cleanup>

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
| chains-to | `git-create-commit` | Rebase/cherry-pick conflict resolved, ready to commit |
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

## Example Usage

```bash
# Detect and resolve conflicts automatically
/git-resolve-conflict

# Typically invoked by another workflow when conflict detected
# Not usually invoked directly by user
```

Expected workflow:
1. User attempts merge/rebase that causes conflict
2. Calling workflow (git-merge-pr or x-implement) detects conflict
3. Skill activates automatically or user invokes manually
4. Skill analyzes each conflict and presents recommendations
5. User approves resolution strategy for each conflict
6. Skill applies resolutions and runs tests
7. Skill finalizes and chains back to original workflow
