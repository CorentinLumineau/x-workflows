---
title: Agent Patterns for Workflows
type: meta
version: "1.0.0"
---

# Workflow Agent Patterns

> Agent-agnostic capability patterns for workflow skill execution

These patterns describe agent capabilities that workflow skills can leverage. Implementations vary by AI tool (Claude Code, Cursor, Cline, Windsurf, etc.).

## Quick Reference (80/20)

| Pattern | Purpose | Key Capabilities | Used By |
|---------|---------|------------------|---------|
| [Testing](#testing-agent) | Test execution & fixing | Edit, Execute, Search | x-verify, x-implement |
| [Review](#review-agent) | Read-only quality analysis | Read, Search, LSP | x-review |
| [Explorer](#explorer-agent) | Fast codebase navigation | Glob, Grep, Read | x-plan, x-implement |
| [Documentation](#documentation-agent) | Doc generation & sync | Read, Write, Search | x-docs |
| [Refactor](#refactor-agent) | Safe code restructuring | Edit, LSP, Search | x-implement |
| [Debug](#debug-agent) | Issue investigation | Read, Execute, Search | x-troubleshoot |

## Testing Agent

**Purpose**: Execute tests, fix failures, improve coverage

**Required Capabilities**:
- File reading (test files, source code)
- File editing (fix failing tests)
- Command execution (run test commands)
- Code search (find related tests)

**Behavioral Rules**:
- Never skip or disable failing tests - fix them
- Follow testing pyramid: 70% unit, 20% integration, 10% E2E
- Clean up test artifacts and data
- Report execution summary with pass/fail counts
- Use iterative fix pattern: analyze → fix → re-run

**When to Invoke**:
- After implementation changes (verification)
- When coverage needs improvement
- When tests fail in CI/CD

**Example Invocations**:
```markdown
## Agent Suggestions

If your agent supports subagents:
- Use a **Testing Agent** to run tests and fix failures
- Tools needed: file editing, command execution
```

**Implementation Examples**:

| Tool | Implementation | Notes |
|------|----------------|-------|
| Claude Code | `ccsetup:x-tester` agent | Full testing pyramid support |
| Cursor | Custom testing rule | Configure in .cursorrules |
| Cline | Test-focused context | Use test-specific prompts |
| Windsurf | Testing workflow | Built-in test runner integration |

## Review Agent

**Purpose**: Read-only code quality analysis

**Required Capabilities**:
- File reading (full codebase access)
- Code search (pattern finding)
- LSP integration (type checking, references)
- **No file editing** (read-only by design)

**Behavioral Rules**:
- Apply SOLID principles in analysis
- Check OWASP security patterns
- Prioritize findings: Critical > High > Medium > Low
- Provide actionable recommendations
- Reference specific file:line locations

**When to Invoke**:
- Before merging pull requests
- After significant changes
- During security audits

**Example Invocations**:
```markdown
## Agent Suggestions

If your agent supports subagents:
- Use a **Review Agent** for quality assessment
- Tools needed: file reading, search (no editing)
```

**Implementation Examples**:

| Tool | Implementation | Notes |
|------|----------------|-------|
| Claude Code | `ccsetup:x-reviewer` agent | Read-only, systematic checklist |
| Cursor | Review rule | Use @codebase for context |
| Cline | Analysis context | Constrain to read operations |

## Explorer Agent

**Purpose**: Fast codebase navigation and pattern discovery

**Required Capabilities**:
- Glob pattern matching
- Grep content search
- File reading
- Directory traversal

**Behavioral Rules**:
- Speed over depth - return quickly
- Provide summaries, not full file contents
- Report location patterns and conventions
- Identify multiple relevant matches
- Note architectural patterns observed

**When to Invoke**:
- At the start of any task (context gathering)
- When searching for similar patterns
- During planning phases

**Example Invocations**:
```markdown
## Agent Suggestions

If your agent supports subagents:
- Use an **Explorer Agent** for codebase discovery
- Tools needed: glob, grep, read
```

**Implementation Examples**:

| Tool | Implementation | Notes |
|------|----------------|-------|
| Claude Code | `ccsetup:x-explorer` agent | Optimized for speed |
| Cursor | Search with @codebase | Built-in exploration |
| Cline | Navigation context | Use search-focused prompts |

## Documentation Agent

**Purpose**: Documentation generation and maintenance

**Required Capabilities**:
- Read source files
- Write documentation files
- Understand documentation formats (JSDoc, docstrings, markdown)
- Search for undocumented code

**Behavioral Rules**:
- Sync documentation with code changes
- Follow project documentation style
- Generate meaningful descriptions, not obvious comments
- Update existing docs rather than creating duplicates
- Maintain cross-references

**When to Invoke**:
- After implementation completion
- When documentation is stale
- During doc sync operations

**Example Invocations**:
```markdown
## Agent Suggestions

If your agent supports subagents:
- Use a **Documentation Agent** for doc generation
- Tools needed: file reading, file writing
```

**Implementation Examples**:

| Tool | Implementation | Notes |
|------|----------------|-------|
| Claude Code | `ccsetup:x-doc-writer` agent | JSDoc, API docs, comments |
| Cursor | Docs rule | Configure doc style |
| Cline | Writer context | Focus on documentation tasks |

## Refactor Agent

**Purpose**: Safe code restructuring with zero-regression guarantee

**Required Capabilities**:
- File editing
- LSP integration (find references, rename symbol)
- Code search
- Test execution (validation)

**Behavioral Rules**:
- Apply SOLID, DRY, KISS principles
- Make incremental, verifiable changes
- Run tests after each change
- Preserve all existing functionality
- For bug fixes, use Debug Agent instead

**When to Invoke**:
- When code quality needs improvement
- During technical debt reduction
- When patterns need standardization

**Example Invocations**:
```markdown
## Agent Suggestions

If your agent supports subagents:
- Use a **Refactor Agent** for structural improvements
- Tools needed: editing, LSP, search, test execution
```

**Implementation Examples**:

| Tool | Implementation | Notes |
|------|----------------|-------|
| Claude Code | `ccsetup:x-refactorer` agent | Zero-regression focus |
| Cursor | Refactor rule | Use symbol rename |
| Cline | Refactoring context | Incremental approach |

## Debug Agent

**Purpose**: Issue investigation and root cause analysis

**Required Capabilities**:
- File reading
- Command execution (run debuggers, logs)
- Code search
- File editing (apply fixes)

**Behavioral Rules**:
- Use hypothesis testing: form → test → validate
- Expose thinking with introspection markers
- Fix root cause, not symptoms
- For test failures, use Testing Agent instead
- Document findings for future reference

**When to Invoke**:
- When runtime errors occur
- During production bug investigation
- When behavior doesn't match expectations

**Example Invocations**:
```markdown
## Agent Suggestions

If your agent supports subagents:
- Use a **Debug Agent** for issue investigation
- Tools needed: reading, execution, search
```

**Implementation Examples**:

| Tool | Implementation | Notes |
|------|----------------|-------|
| Claude Code | `ccsetup:x-debugger` agent | Hypothesis-driven |
| Cursor | Debug rule | Use terminal integration |
| Cline | Investigation context | Step-by-step analysis |

## Using These Patterns in Skills

When writing SKILL.md files, reference agent patterns like this:

```markdown
## Agent Suggestions

If your agent supports subagents, consider:
- A **Testing Agent** for verification (see agents.md#testing-agent)
- A **Review Agent** for quality checks (see agents.md#review-agent)

Note: Agent availability varies by tool. Check your tool's documentation
for specific implementation details.
```

## Creating Custom Agent Patterns

When defining new agent patterns, include:

1. **Purpose**: One-line description of the agent's role
2. **Required Capabilities**: Tools and permissions needed
3. **Behavioral Rules**: Guidelines for consistent behavior
4. **When to Invoke**: Trigger conditions
5. **Implementation Examples**: How different tools implement it

## Cross-References

- See `x-verify/SKILL.md` for Testing Agent usage
- See `x-review/SKILL.md` for Review Agent usage
- See `x-plan/SKILL.md` for Explorer Agent usage
- See `x-docs/SKILL.md` for Documentation Agent usage
- See `x-implement/SKILL.md` for Refactor Agent usage
- See `x-troubleshoot/SKILL.md` for Debug Agent usage

---

**Version**: 1.0.0
**Compatibility**: skills.sh, Claude Code, Cursor, Cline, Windsurf
