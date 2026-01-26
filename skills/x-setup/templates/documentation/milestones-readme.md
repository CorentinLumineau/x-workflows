---
template: milestones-readme
type: documentation
section: milestones
variables:
  - project-name: Project name
---

# Milestones Documentation

> Initiative planning, roadmaps, and progress tracking

## Overview

This folder contains initiative and milestone documentation:
- **Active Initiatives**: Currently in-progress work
- **Planned Initiatives**: Upcoming work
- **Archived Initiatives**: Completed or cancelled work

## Structure

```
milestones/
├── README.md               # This file (initiative index)
├── {initiative-name}/      # Each initiative gets a folder
│   ├── README.md           # Initiative overview
│   ├── milestone-1-*.md    # Milestone documents
│   ├── milestone-2-*.md
│   └── DECISIONS.md        # Architecture decisions
└── _archived/              # Completed/cancelled initiatives
```

## Creating Initiatives

Use the `/x:initiative` command to create new initiatives:

```bash
/x:initiative "Feature Name"
```

This will:
1. Guide you through requirements gathering
2. Create Pareto ROI milestone breakdown
3. Generate all documentation files
4. Update this index

## Pareto ROI Approach

All initiatives follow the Pareto 80/20 principle:
- Milestones ordered by value/effort ratio (ROI)
- Highest-value work completed first
- Each milestone independently releasable
- Flexible milestone count based on scope

## Related

- [Implementation](../implementation/) - Technical details
- [Domain](../domain/) - Business context
- [Playbooks](@skills/x-initiative/playbooks/) - Initiative methodology
