---
template: reference-claude-md
type: navigation
section: reference
variables:
  - stack-framework: Primary framework
---

# Reference Documentation

> Stack-specific documentation, architecture, and AI-optimized project guides

## Project-Specific Docs (AI Enhancement)

These documents help AI understand YOUR project:

| Document | Purpose | When AI Uses It |
|----------|---------|-----------------|
| [conventions.md](conventions.md) | Coding standards | Generating code in your style |
| [patterns.md](patterns.md) | Implementation patterns | Following YOUR patterns |
| [glossary.md](glossary.md) | Domain terminology | Using correct terms |
| [api-contracts.md](api-contracts.md) | API standards | Consistent endpoints |
| [testing-patterns.md](testing-patterns.md) | Testing guide | Writing tests |
| [dependencies.md](dependencies.md) | Package guide | Choosing tools |
| [security-checklist.md](security-checklist.md) | Security rules | Secure code |
| [performance-guidelines.md](performance-guidelines.md) | Performance | Performant code |

## Architecture & Stack Docs

- [architecture.md](architecture.md) - Project layers overview (DB → API → UI)
- {stack}-{framework}.md - Stack documentation (Context7)
- {technology}.md - Technology documentation (Context7)

## When to Look Here

- **Before coding**: Check conventions.md and patterns.md
- **For terminology**: Check glossary.md
- **For APIs**: Check api-contracts.md
- **For tests**: Check testing-patterns.md
- **For packages**: Check dependencies.md
- **For security**: Check security-checklist.md
- **For architecture**: Check architecture.md

## Refresh Stack Docs

```bash
/x:setup --refresh
```

## Related

- [Implementation](../implementation/) - How we use these patterns
- [config.yaml](../config.yaml) - Stack configuration
- [Core Docs](~/.claude/core-docs/) - Universal best practices
