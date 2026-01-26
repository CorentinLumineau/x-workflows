---
template: domain-readme
type: documentation
section: domain
variables:
  - project-name: Project name
---

# Domain Documentation

> Business logic, entities, workflows, and rules

## Overview

This folder contains documentation about the business domain:
- **Entities**: Core domain objects and their relationships
- **Workflows**: Business processes and state transitions
- **Rules**: Validation rules and business constraints
- **Glossary**: Domain-specific terminology

## Structure

```
domain/
├── README.md        # This file
├── entities/        # Domain entities (create as needed)
├── workflows/       # Business processes (create as needed)
├── rules/           # Business rules (create as needed)
└── glossary.md      # Term definitions (create as needed)
```

## Best Practices

- Use ubiquitous language from domain experts
- Keep documentation close to the code it describes
- Update when business rules change
- Link to implementation docs for technical details

## Related

- [Implementation](../implementation/) - Technical implementation details
- [Milestones](../milestones/) - Planned domain changes
- [Reference](../reference/) - Framework patterns
