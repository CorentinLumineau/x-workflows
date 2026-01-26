# LLM Assistant Guide for Initiative Management

**Purpose**: Quick reference for AI assistants working with the milestone system

**Audience**: LLM Assistants (Claude, GPT, etc.)

---

## Quick Decision Tree

```
User Request
    ↓
Is this a multi-step initiative? (>40 hours, multiple layers, multiple phases)
    ↓ YES
Read playbooks/README.md
    ↓
Use templates/initiative-template.md
    ↓
Create initiative directory in milestones/
    ↓
Define milestones using templates/milestone-template.md or phase-template.md
    ↓
Update milestones/README.md with new initiative
    ↓
Begin implementation
    ↓
Update progress as work completes
```

---

## When to Create an Initiative

✅ **CREATE Initiative When**:
- Work spans multiple weeks (>40 hours estimated)
- Work affects multiple system layers or domains
- Work has multiple phases or stages
- Work requires tracking dependencies
- User explicitly requests initiative tracking

❌ **DON'T Create Initiative For**:
- Single-file changes
- Bug fixes (unless part of larger initiative)
- Documentation updates (unless comprehensive overhaul)
- Routine maintenance

---

## Initiative Structure for LLMs

### 1. Clear Context
Provide complete background:
- **Why**: Problem statement and business value
- **What**: Scope and deliverables
- **How**: Technical approach
- **When**: Timeline and dependencies

### 2. Explicit Steps
Break down into actionable steps:
```markdown
## Implementation Steps

1. **Database Migration**
   ```bash
   npx prisma migrate dev --name add-user-fields
   ```

2. **Create Repository Interface**
   - File: `lib/repositories/interfaces/IUserRepository.ts`
   - Pattern: Follow existing repository pattern

3. **Implement Service Layer**
   - File: `lib/services/user/UserService.ts`
   - Business logic: User validation and creation
```

### 3. Success Criteria
Define measurable completion:
```markdown
- [ ] All 2998+ tests passing
- [ ] Build time < 60 seconds
- [ ] Zero TypeScript errors
- [ ] Lighthouse PWA score > 90
```

### 4. Code Examples
Include patterns and examples:
```typescript
// Example: Repository interface pattern
export interface IUserRepository {
  findById(id: string): Promise<User | null>
  create(data: CreateUserData): Promise<User>
}
```

### 5. Related Files
Link to relevant codebase locations:
```markdown
**Example Initiatives**:
- [Audit Logging 2025](../../milestones/audit-logging-2025/)
- [Code Quality 2025](../../milestones/_archive/code-quality-2025/)

**Related Files**:
- `lib/services/ServiceFactory.ts:45` - Add to factory
- `lib/repositories/RepositoryFactory.ts:32` - Register repository
- `types/user/CreateUserData.type.ts` - Type definitions
```

### 6. Common Pitfalls
Document known issues:
```markdown
### Common Issues
- **Issue**: Prisma client not regenerated after migration
  **Solution**: Run `npx prisma generate` after migrations

- **Issue**: Circular dependency in service layer
  **Solution**: Use factory pattern for service instantiation
```

---

## Progress Update Pattern

As you work, update milestone files:

```markdown
## Progress Update - 2025-10-02

### Completed
- ✅ Created database migration for user fields
- ✅ Implemented IUserRepository interface
- ✅ All 2998 tests passing

### In Progress
- 🟡 Service layer implementation (50% complete)
  - UserService class created
  - Core methods implemented
  - Testing in progress

### Next Steps
- Implement remaining service methods
- Add integration tests
- Update API layer

### Blockers
- None

### Notes
- Discovered need for email validation utility
- Added to utils/validation.ts
```

---

## LLM Workflow Checklist

### Before Starting Work
- [ ] Read initiative README for context
- [ ] Check current milestone status
- [ ] Review related documentation
- [ ] Understand success criteria

### During Implementation
- [ ] Follow documented patterns
- [ ] Update milestone files as tasks complete
- [ ] Mark success criteria when met
- [ ] Document decisions and learnings

### After Completion
- [ ] Verify all success criteria met
- [ ] Update progress tables
- [ ] Link commits/PRs to milestones
- [ ] Document lessons learned

---

## File Naming Conventions

### Initiative Directories
```
milestones/
├── initiative-name/           # kebab-case
│   ├── README.md              # Always uppercase
│   ├── milestone-1.md         # Or M1-descriptive-name.md
│   └── phase-1.md             # Or phase-1-descriptive-name.md
```

### Template Usage
```bash
# Copy template
cp documentation/playbooks/templates/initiative-template.md \
   documentation/milestones/my-initiative/README.md

# Edit placeholders
# Replace [Initiative Name], YYYY-MM-DD, etc.
```

---

## Common Patterns

### Pareto Principle (80/20)
Always apply when planning:
```markdown
## Analysis
Total potential work: 100 hours
- High-impact items (20% effort): 20 hours → 80% value ✅
- Medium-impact items (30% effort): 30 hours → 15% value ⚠️
- Low-impact items (50% effort): 50 hours → 5% value ❌

## Recommendation
Focus on high-impact items first (20 hours of work)
```

### Incremental Delivery
Break into independently valuable chunks:
```markdown
❌ Bad: "Migrate entire codebase (6 months)"
✅ Good:
  - Phase 1: Migrate critical services (1 month, 80% benefit)
  - Phase 2: Migrate remaining services (2 weeks, 15% benefit)
  - Phase 3: Cleanup and optimization (1 week, 5% benefit)
```

### Risk-First Approach
Tackle high-risk items early:
```markdown
## Risk Assessment
- 🔴 High Risk: Database migration (tackle first)
- 🟡 Medium Risk: API changes (after database)
- 🟢 Low Risk: UI updates (last)

## Sequencing
Milestone 1: Database migration (high risk)
Milestone 2: API updates (medium risk)
Milestone 3: UI polish (low risk)
```

---

## Integration with Tools

### Git Integration
```bash
# Branch naming
git checkout -b feature/M3-dto-implementation

# Commit messages
git commit -m "feat: implement user DTO validation

Related to M3-dto-implementation milestone
Addresses success criterion: Zero TypeScript errors"
```

### Test Integration
```bash
# Always run tests after changes
pnpm run test:coverage

# Link test results to milestone
"All 2998+ tests passing ✅ (success criterion met)"
```

---

## Quick Reference

**Full Methodology**: See [playbooks/README.md](../README.md)

**Templates**:
- [Initiative Template](../templates/initiative-template.md)
- [Milestone Template](../templates/milestone-template.md)
- [Phase Template](../templates/phase-template.md)

**Current Active Initiatives**:
- [Admin Refactoring 2025](../../milestones/admin-refactoring-2025/README.md)
- [Audit Logging 2025](../../milestones/audit-logging-2025/)

**Archived Initiatives**:
- [Code Quality 2025](../../milestones/_archive/code-quality-2025/README.md)
- [REST API Alignment 2025](../../milestones/ARCHIVE.md#1-rest-api-alignment-2025-)

---

**Last Updated**: 2025-11-03
**For Questions**: Reference playbooks/README.md or CLAUDE.md
