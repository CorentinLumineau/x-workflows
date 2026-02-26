# Iterative Retrieval Pattern

> Read small, verify, read more — avoid loading entire files when a targeted search suffices.

Adapted from everything-claude-code (MIT, Copyright 2026 Affaan Mustafa).

## Core Principle

Agents should retrieve information iteratively rather than loading large files wholesale. This preserves context window budget and improves response quality in long sessions.

## Retrieval Hierarchy

| Strategy | When to Use | Context Cost |
|----------|------------|--------------|
| **Grep** | Known keyword/pattern | Minimal (matching lines only) |
| **Glob** | Known file pattern | Minimal (file paths only) |
| **Read (targeted)** | Known file, specific section | Low (offset + limit) |
| **Read (full)** | Need complete file understanding | High (entire file) |
| **Agent delegation** | Complex multi-file search | Variable (agent context) |

## Decision Matrix

```
Need information from codebase?
│
├─ Know the exact pattern/keyword?
│  └─ Grep first → Read targeted section if needed
│
├─ Know the file name/path pattern?
│  └─ Glob to find → Read targeted section
│
├─ Know the file but not the section?
│  └─ Read with limit (first 100 lines) → Read more if needed
│
├─ Need broad codebase understanding?
│  └─ Delegate to x-explorer (preserves parent context)
│
└─ Need deep multi-file analysis?
   └─ Delegate to specialized agent (x-reviewer, x-tester)
```

## Anti-Patterns

| Anti-Pattern | Impact | Fix |
|-------------|--------|-----|
| Reading 2000-line file to find one function | Wastes ~2K tokens | Grep for function name first |
| Reading every file in a directory | Wastes context exponentially | Glob + targeted reads |
| Re-reading files already in context | Redundant token spend | Check conversation history first |
| Loading reference docs "just in case" | Premature context pollution | Load on-demand when referenced |

## Integration with Hooks

The `suggest-compact` hook monitors tool call count and suggests `/compact` after heavy usage. Iterative retrieval helps stay under the threshold by minimizing unnecessary reads.

## Agent-Specific Guidance

| Agent | Retrieval Pattern |
|-------|------------------|
| x-explorer | Grep → Glob → targeted Read (never full reads) |
| x-reviewer | git diff first → Read only changed files |
| x-tester | Read test file → Run tests → Read only failing files |
| x-debugger | Grep error pattern → Read stack trace files → targeted Read |
| x-doc-writer | Read existing docs → Grep for doc references → targeted Read |
