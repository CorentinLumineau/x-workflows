---
template: reference-readme
type: documentation
section: reference
variables:
  - project-name: Project name
  - stack-framework: Primary framework
---

# Reference Documentation

> Stack-specific documentation, patterns, and AI-optimized project guides

## Overview

This folder contains reference documentation to help AI understand YOUR project:

### Project-Specific Docs (AI Enhancement)
- **conventions.md** - Coding standards, naming patterns, style rules
- **patterns.md** - Project-specific implementation patterns
- **glossary.md** - Domain terminology and acronyms
- **api-contracts.md** - API standards, request/response formats
- **testing-patterns.md** - How to test in THIS project
- **dependencies.md** - Which packages to use for what
- **security-checklist.md** - Security requirements and rules
- **performance-guidelines.md** - Performance standards and patterns

### Generated Docs
- **architecture.md** - Project layer overview (DB → API → UI)
- **{stack}-{framework}.md** - Framework patterns (Context7)
- **{technology}.md** - Technology documentation (Context7)

## Structure

```
reference/
├── CLAUDE.md                    # Navigation
├── architecture.md              # Project architecture overview
├── conventions.md               # Coding standards
├── patterns.md                  # Implementation patterns
├── glossary.md                  # Domain terminology
├── api-contracts.md             # API standards
├── testing-patterns.md          # Testing guide
├── dependencies.md              # Package usage
├── security-checklist.md        # Security requirements
├── performance-guidelines.md    # Performance standards
├── {stack}-{framework}.md       # Stack docs (Context7)
└── {technology}.md              # Technology docs (Context7)
```

## Why These Documents?

These documents help AI:
- **conventions.md** - Generate code matching your exact style
- **patterns.md** - Learn YOUR patterns, not generic ones
- **glossary.md** - Use correct domain terminology
- **api-contracts.md** - Generate consistent API endpoints
- **testing-patterns.md** - Write tests matching your suite
- **dependencies.md** - Pick the right tools from your stack
- **security-checklist.md** - Generate secure code by default
- **performance-guidelines.md** - Write performant code automatically

## Generated Stack Docs

Stack documentation is generated from Context7 based on your project configuration.

To refresh stack documentation:

```bash
/x:setup --refresh
```

## Using Context7 Directly

For the latest framework information during development:

```
context7.getLibraryDocs('/vercel/next.js', { topic: 'routing' })
```

## Related

- [Implementation](../implementation/) - How we use these patterns
- [config.yaml](../config.yaml) - Stack configuration
- [Core Docs](~/.claude/core-docs/) - Universal best practices
