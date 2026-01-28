---
type: playbook
audience: [developers, architects, project-managers, llms]
scope: framework-agnostic
last-updated: 2026-01-27
status: current
related-docs:
  - templates/
---

# Initiative Playbooks

**Purpose**: Templates for creating, managing, and tracking project initiatives

**Audience**: Developers, Architects, Project Managers, **LLM Assistants**

**Scope**: Templates used by the x-initiative skill for initiative creation

---

## 📚 Directory Structure

```
playbooks/
├── README.md (this file)          # Overview
├── guides/                         # How-to guides
│   ├── quick-start.md             # Getting started with initiatives
│   └── llm-assistant-guide.md     # Guide for AI assistants
├── examples/                       # Example initiatives
│   ├── dependency-update-example.md  # Dependency update initiative
│   └── refactoring-example.md     # Codebase refactoring initiative
└── templates/                      # Reusable templates
    ├── initiative-template.md     # Template for new initiatives
    ├── milestone-template.md      # Template for milestone files
    └── phase-template.md          # Template for phases
```

## Related Documentation

Educational content has been moved to the documentation folder:
- **Guides**: `documentation/development/initiative-guides/`
- **Examples**: `documentation/examples/initiative-examples/`

---

## 🆕 Creating a New Initiative

### Step 1: Assess and Plan

**Questions to Answer**:
- What problem does this solve?
- What are the goals and success criteria?
- What's the estimated effort and timeline?
- What are the dependencies?
- What's the expected ROI/impact?

**Template**: Use `templates/initiative-template.md`

### Step 2: Create Initiative Directory

```bash
# Navigate to milestones in your project
cd documentation/milestones

# Create initiative directory
mkdir -p [initiative-name]

# Create README from template
cp ../../node_modules/@ccsetup/documentation/docs/playbooks/templates/initiative-template.md [initiative-name]/README.md
```

### Step 3: Define Milestones/Phases

Break the initiative into logical chunks following the **Pareto Principle (ROI ordering)**:
- Focus on high ROI (value/effort) work first
- Create as many milestones as needed (3, 5, 8, 10+ milestones - no fixed limit)
- Each milestone must be independently releasable to production
- Each milestone must be fully tested and documented
- Order milestones by ROI (highest value/effort ratio first)
- Keep milestones small (2-5 days each)

**Template**: Use `templates/milestone-template.md` or `templates/phase-template.md`

### Step 4: Document Initiative

Fill out the initiative README with:
- Overview and goals
- Milestone/phase breakdown
- Progress tracking table
- Dependencies and risks
- Success metrics

### Step 5: Create Detailed Milestone Files

For each milestone, create a detailed file:
```bash
# Create milestone file
touch [initiative-name]/[milestone-name].md

# Use template
cp ../../node_modules/@ccsetup/documentation/docs/playbooks/templates/milestone-template.md [initiative-name]/[milestone-name].md
```

### Step 6: Link from Central Hub

Update `milestones/README.md` in your project:
- Add initiative to "Active Initiatives" section
- Include status, timeline, and quick links
- Add progress overview table

---

## 📋 Initiative Planning Principles

### 1. Pareto Principle (ROI Ordering)

**Focus on high ROI (value/effort ratio) work first, delivered through multiple small milestones.**

Example:
```
❌ Bad: "Migrate entire codebase to new architecture (6 months, 3 phases)"
✅ Good: "Migrate to new architecture (8 milestones, ordered by ROI, each shippable)"
  M1 (3d): Core service migration - 🟢🟢🟢 Very High ROI
  M2 (2d): API adapter layer - 🟢🟢 High ROI
  M3 (4d): Authentication service - 🟢🟢 High ROI
  M4 (3d): Data access layer - 🟡🟢 Medium-High ROI
  M5 (5d): Background jobs - 🟡 Medium ROI
  M6 (3d): Admin UI migration - 🟡 Medium-Low ROI
  M7 (4d): Reporting system - 🔴 Low ROI
  M8 (2d): Legacy cleanup - 🔴 Low ROI
```

**How to Apply**:
1. List all potential work items
2. Estimate effort for each item (in days)
3. Estimate impact/value for each item (High/Medium/Low)
4. Calculate ROI (value/effort ratio)
5. Order by ROI (highest first)
6. Group into small, independently releasable milestones (2-5 days each)
7. Ship early (after first 2-3 high ROI milestones)
8. Gather feedback and adjust remaining milestones

### 2. Incremental Delivery

**Deliver value incrementally, not all at once.**

- Each milestone should be independently valuable
- Work should be releasable after each milestone
- Avoid "big bang" approaches
- Enable early feedback and course correction

### 3. Clear Success Criteria

**Define measurable completion criteria upfront.**

Good success criteria:
```markdown
✅ All tests passing (100% of existing test suite)
✅ Build time < 60 seconds
✅ Zero linting errors
✅ Performance metrics within targets
```

Bad success criteria:
```markdown
❌ Code is better organized
❌ System is more maintainable
❌ Performance is improved
```

### 4. Risk Management

**Identify and mitigate risks proactively.**

For each milestone, document:
- **Risks**: What could go wrong?
- **Mitigation**: How to prevent/reduce risk?
- **Rollback**: How to undo if needed?

### 5. Dependency Mapping

**Understand what depends on what.**

Document:
- **Prerequisites**: What must be done first?
- **Blockers**: What's blocking progress?
- **Downstream Impact**: What depends on this?

---

## 📊 Progress Tracking

### Status Indicators

Use consistent status indicators:

| Status | Icon | Meaning |
|--------|------|---------|
| Complete | ✅ | All success criteria met |
| In Progress | 🟡 | Active work ongoing |
| Blocked | 🔴 | Cannot proceed due to dependencies |
| Planned | ⏳ | Not started, scheduled for future |
| Ready | 🟢 | Ready to start, dependencies met |
| At Risk | ⚠️ | Timeline or scope concerns |
| Cancelled | ❌ | Deprioritized or replaced |

### Progress Tables

Maintain progress tables in initiative README.md:

```markdown
| Milestone | Status | Completion | Start Date | End Date |
|-----------|--------|------------|------------|----------|
| Phase 1   | ✅ Complete | 100% | 2025-09-01 | 2025-09-15 |
| Phase 2   | 🟡 In Progress | 65% | 2025-09-16 | - |
| Phase 3   | ⏳ Planned | 0% | - | - |
```

### Update Frequency

- **Daily**: Update milestone files with task completion
- **Weekly**: Update progress percentages in tables
- **Bi-weekly**: Review and adjust timelines if needed
- **Monthly**: Post-milestone retrospectives

### **🚨 CRITICAL: Documentation Update Workflow**

**MANDATORY**: When completing ANY milestone work, you **MUST** update documentation in this order:

#### 1. Update Milestone File (Most Detailed)
```markdown
# In [initiative]/[milestone].md
## Progress Update - 2025-11-03

### Completed
- ✅ Task 1 completed
- ✅ All tests passing
- ✅ Documentation updated

### Metrics
- Build time: 45s (target: <60s) ✅
- Test coverage: 95% ✅
- Linting errors: 0 ✅
```

#### 2. Update Initiative README (Summary)
```markdown
# In [initiative]/README.md
| Milestone 1 | ✅ Complete | 100% | 2025-11-01 | 2025-11-03 |
```

#### 3. Update milestones/README.md (Hub)
```markdown
# In milestones/README.md
**Status**: 🟡 33% → 67% Complete
| Phase 1 | ✅ Complete | 100% | 2h 15m | 80% |
```

#### 4. Update MASTER-PLAN.md (Orchestration)
```markdown
# In milestones/MASTER-PLAN.md
**Status**: 🟡 67% Complete (Phase 2-3 In Progress)
**Progress**:
- ✅ Phase 1: Complete (2h 15m) → 80% value
```

#### 5. Update CLAUDE.md (if major milestone)
```markdown
# Only for significant milestones affecting AI assistant behavior
- Initiative Name - Phase 1 Complete ✅
```

**Why This Matters**:
- ✅ Maintains accurate project state
- ✅ Enables proper tracking and reporting
- ✅ Helps future work understand what's complete
- ✅ Prevents duplicate work
- ✅ Provides historical record

**Example Complete Workflow**:
```bash
# 1. Complete work
git commit -m "feat: complete Phase 1"

# 2. Update milestone file
# Edit: [initiative]/phase-1.md
# Add: Progress Update section with completion notes

# 3. Update initiative README
# Edit: [initiative]/README.md
# Change: Phase 1 status from 🟡 → ✅

# 4. Update hub
# Edit: milestones/README.md
# Change: Overall % from 0% → 33%

# 5. Update master plan
# Edit: milestones/MASTER-PLAN.md
# Change: Status and add Phase 1 to completed list

# 6. Commit documentation updates
git commit -m "docs: update milestones for Phase 1 completion"
```

---

## 🤖 Guide for LLM Assistants

### When to Create an Initiative

Create a new initiative when:
- Work spans multiple weeks (>40 hours estimated)
- Work affects multiple system layers or domains
- Work has multiple phases or stages
- Work requires tracking dependencies
- User explicitly requests initiative tracking

**Don't** create for:
- Single-file changes
- Bug fixes (unless part of larger initiative)
- Documentation updates (unless comprehensive overhaul)
- Routine maintenance

### How to Structure for LLMs

When creating initiatives for LLM consumption:

1. **Clear Context**: Provide complete background and goals
2. **Explicit Steps**: Break down into actionable steps
3. **Success Criteria**: Define measurable completion criteria
4. **Code Examples**: Include code patterns and examples (stack-specific)
5. **Related Files**: Link to relevant codebase locations
6. **Common Pitfalls**: Document known issues and solutions

### LLM Workflow

```
User Request
    ↓
Multi-step initiative? → No → Direct implementation
    ↓ Yes
Read playbooks/README.md
    ↓
Use templates/initiative-template.md
    ↓
Create initiative directory
    ↓
Define milestones with templates
    ↓
Update milestones/README.md
    ↓
Begin implementation
    ↓
Update progress as work completes
```

### Progress Updates

As an LLM assistant, you should:
1. **Read** initiative README before starting work
2. **Follow** documented patterns and decisions
3. **Update** milestone files as tasks complete
4. **Mark** success criteria when met
5. **Document** decisions and learnings
6. **Link** commits/PRs to milestones

Example update:
```markdown
## Progress Update - 2025-11-03

### Completed
- ✅ Updated dependencies to latest
- ✅ Regenerated build artifacts
- ✅ All tests passing

### In Progress
- 🟡 Linting configuration migration (testing in progress)

### Blockers
- None

### Notes
- Build generation now 10x faster as expected
- Discovered minor compatibility issue (documented workaround)
```

---

## 📝 Templates

### Available Templates

1. **[Initiative Template](templates/initiative-template.md)**
   - Use for: New major initiatives
   - Contains: Goals, milestones, tracking tables

2. **[Milestone Template](templates/milestone-template.md)**
   - Use for: Detailed milestone documentation
   - Contains: Objectives, deliverables, testing, rollback

3. **[Phase Template](templates/phase-template.md)**
   - Use for: Phased rollouts (alternative to milestones)
   - Contains: Phase structure, dependencies, validation

### Template Usage

```bash
# Copy template (if using npm package)
cp node_modules/@ccsetup/documentation/docs/playbooks/templates/initiative-template.md \\
   documentation/milestones/my-initiative/README.md

# Edit with your content
# Replace [placeholders] with actual information
# Fill in all sections
```

---

## 🎓 Best Practices

### Planning
1. **Start with Why** - Clearly articulate the problem and value
2. **Pareto Thinking** - Focus on high-impact work
3. **Incremental Delivery** - Break into independently valuable chunks
4. **Risk First** - Identify and plan for risks upfront

### Execution
1. **One Thing at a Time** - Focus on current milestone
2. **Test Continuously** - Validate after each change
3. **Document Decisions** - Capture WHY, not just WHAT
4. **Update Progress** - Keep status current

### Communication
1. **Be Transparent** - Share progress and blockers openly
2. **Use Tables** - Visual progress is easy to understand
3. **Link Everything** - Connect milestones to commits/PRs
4. **Celebrate Wins** - Acknowledge milestone completions

### Quality
1. **Success Criteria** - Define upfront, validate before marking complete
2. **Test Coverage** - Maintain or improve with each milestone
3. **Performance** - Monitor and prevent degradation
4. **Documentation** - Update docs as part of milestone work

---

## 🔗 Related Resources

### Internal Documentation
- **[Core Principles](../core/principles/)** - SOLID, DRY, KISS, Pareto
- **[Architecture Patterns](../core/architecture/)** - Architecture guidelines
- **[Testing Patterns](../core/testing/)** - Testing strategies
- **[Stack-Specific Guides](../stacks/)** - Implementation patterns for your stack

### External Resources
- **Pareto Principle**: https://en.wikipedia.org/wiki/Pareto_principle
- **Incremental Development**: https://en.wikipedia.org/wiki/Iterative_and_incremental_development
- **SMART Goals**: https://en.wikipedia.org/wiki/SMART_criteria

---

## 📞 Getting Help

**For Developers**:
- Review existing initiatives in your project's `milestones/` for examples
- Use templates as starting point
- Consult with architects for large initiatives

**For LLM Assistants**:
- Read this entire playbook before creating initiatives
- Use templates exactly as provided
- Update project CLAUDE.md if new patterns emerge
- Reference existing initiatives for structure examples

---

**Last Updated**: 2025-11-03
**Maintainer**: ccsetup contributors
**Version**: 4.12.0
**Framework**: @ccsetup/documentation
