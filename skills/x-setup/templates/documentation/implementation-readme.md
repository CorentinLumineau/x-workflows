---
template: implementation-readme
type: documentation
section: implementation
variables:
  - project-name: Project name
---

# Implementation Documentation

> Technical architecture, ADRs, and design decisions

## Overview

This folder contains technical implementation documentation:
- **Architecture**: System design and component relationships
- **ADRs**: Architecture Decision Records
- **Integrations**: External system integrations
- **Security**: Security considerations and implementations

## Structure

```
implementation/
├── README.md           # This file
├── architecture.md     # System architecture (create as needed)
├── adrs/               # Architecture Decision Records (create as needed)
├── integrations/       # Integration docs (create as needed)
└── security.md         # Security documentation (create as needed)
```

## ADR Format

When creating ADRs, use this format:

```markdown
# ADR-XXX: Title

## Status
Proposed | Accepted | Deprecated | Superseded

## Context
What is the issue that we're seeing that is motivating this decision?

## Decision
What is the decision that we're proposing?

## Consequences
What becomes easier or more difficult to do because of this decision?
```

## Related

- [Domain](../domain/) - Business requirements
- [Development](../development/) - Implementation guides
- [Milestones](../milestones/) - Technical initiatives
