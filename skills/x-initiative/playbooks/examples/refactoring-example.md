---
type: example
audience: [developers, llms]
scope: playbook-example
initiative-type: refactoring
last-updated: 2025-11-03
status: reference
---

# Example: Component Refactoring Initiative

**Purpose**: Real-world example of using playbooks for a large-scale refactoring

**Source**: Based on actual god component extraction and DRY violation resolution

---

## Initiative Overview

**Problem**: Single "Admin" component with 1500+ lines, multiple responsibilities, DRY violations

**Goal**: Extract into focused, single-responsibility components following SOLID principles

**Estimated Effort**: 30-40 hours total

**Approach**: Pareto 80/20 + Incremental refactoring

---

## Problem Analysis

### Code Smells Identified
1. **God Component** (1500 lines)
   - User management
   - Parking spot management
   - Reservation management
   - Settings management
   - All mixed in one file

2. **DRY Violations**
   - Duplicate validation logic
   - Repeated API calls
   - Copy-pasted state management

3. **Tight Coupling**
   - Direct database access from UI
   - Business logic in components
   - No testability

### Pareto Analysis
| Refactoring | Effort | Impact | ROI |
|-------------|--------|--------|-----|
| Extract user management | 6h | High | 🟢 High |
| Extract parking spots | 5h | High | 🟢 High |
| DRY validation | 3h | High | 🟢 High |
| Extract reservations | 6h | Medium | 🟡 Medium |
| Extract settings | 4h | Low | 🔴 Low |

**Pareto Decision**: Focus on user management + parking spots + validation (14h → 80% improvement)

---

## Milestone Breakdown

### Phase 1: Extract User Management (6 hours) ✅
**Status**: Complete
**Actual Time**: 4h 30m

**Deliverables**:
- ✅ `UserManager` component extracted
- ✅ `useUsers` hook for data fetching
- ✅ Shared `UserValidator` utility
- ✅ All tests passing
- ✅ Zero regressions

**Success Criteria Met**:
- ✅ Component < 300 lines
- ✅ Single responsibility (user management only)
- ✅ 100% test coverage
- ✅ No duplicate validation logic

**Patterns Established**:
```typescript
// Service layer for business logic
const service = await ServiceFactory.getUserService()

// Repository for data access
const repo = await RepositoryFactory.getUserRepository()

// React Query for state management
const { data, isLoading } = useUsers()

// Shared validation utilities
UserValidator.validate(data)
```

### Phase 2: Extract Parking Spots (5 hours) ✅
**Status**: Complete
**Actual Time**: 5h

**Deliverables**:
- ✅ `ParkingSpotManager` component
- ✅ `useParkingSpots` hook
- ✅ Shared `SpotValidator` utility
- ✅ Service layer for business logic
- ✅ Repository for data access

**Reused Patterns**: Same patterns from Phase 1

### Phase 3: Consolidate Validation (3 hours) ✅
**Status**: Complete
**Actual Time**: 2h

**Deliverables**:
- ✅ Single `validators/` directory
- ✅ All validation logic centralized
- ✅ DRY violations eliminated
- ✅ Reusable across components

### Phase 4: Reservations & Settings (Deferred)
**Status**: ⏳ Planned
**Decision**: Phases 1-3 achieved 80% improvement
**Next**: Only proceed when new features require it

---

## Architecture Improvements

### Before (God Component)
```
AdminPanel.tsx (1500 lines)
├─ User management logic
├─ Parking spot logic
├─ Reservation logic
├─ Settings logic
├─ Validation (duplicated 5x)
├─ API calls (duplicated 3x)
└─ State management (messy)
```

### After (Clean Architecture)
```
components/features/admin/
├─ UserManager.tsx (250 lines)
├─ ParkingSpotManager.tsx (280 lines)
└─ [future: ReservationManager, SettingsManager]

lib/services/
├─ UserService.ts (business logic)
└─ ParkingSpotService.ts

lib/repositories/
├─ UserRepository.ts (data access)
└─ ParkingSpotRepository.ts

lib/validators/
├─ UserValidator.ts (shared)
└─ SpotValidator.ts (shared)

hooks/
├─ useUsers.ts (React Query)
└─ useParkingSpots.ts
```

---

## Lessons Learned

### What Worked ✅
1. **Incremental Approach**: Refactored one feature at a time
2. **Pattern Consistency**: Established patterns in Phase 1, reused in Phase 2
3. **Testing First**: Wrote tests before refactoring
4. **Service Layer**: Abstracted business logic from components
5. **Pareto Focus**: 14h work achieved 80% improvement

### What Could Improve 🔄
1. **Initial Design**: Should have started with this architecture
2. **Code Reviews**: More frequent reviews could have caught issues earlier
3. **Documentation**: Document patterns sooner to guide team

### Metrics

**Before**:
- AdminPanel.tsx: 1500 lines
- Duplicate validation: 5 places
- Test coverage: 40%
- Cyclomatic complexity: 45

**After**:
- Largest component: 280 lines
- Duplicate validation: 0
- Test coverage: 95%
- Cyclomatic complexity: 8 (avg)

**Improvement**:
- 81% line reduction
- 100% DRY improvement
- 137% test coverage increase
- 82% complexity reduction

---

## SOLID Principles Applied

### Single Responsibility
```typescript
// ❌ Before: One component does everything
<AdminPanel />

// ✅ After: Each component has one job
<UserManager />
<ParkingSpotManager />
```

### Dependency Inversion
```typescript
// ❌ Before: Component depends on concrete implementation
const [users, setUsers] = useState([])
fetch('/api/users').then(...)

// ✅ After: Component depends on abstraction
const { data: users } = useUsers()  // Hook abstracts data fetching
```

### Open/Closed
```typescript
// ✅ Can add new managers without modifying existing
<AdminDashboard>
  <UserManager />
  <ParkingSpotManager />
  <ReservationManager />  // Add new without changing others
</AdminDashboard>
```

---

## Applying to Your Project

### Identifying God Components
1. **Line Count**: Component > 500 lines
2. **Multiple Responsibilities**: Handles 3+ different domains
3. **Low Test Coverage**: Hard to test due to complexity
4. **High Cyclomatic Complexity**: >20 decision points

### Refactoring Checklist
- [ ] Identify code smells (god components, DRY violations)
- [ ] Create ROI matrix for potential refactorings
- [ ] Apply Pareto 80/20 to focus on high-impact work
- [ ] Write tests BEFORE refactoring
- [ ] Extract one feature at a time
- [ ] Establish patterns in Phase 1
- [ ] Reuse patterns in subsequent phases
- [ ] Track metrics (lines, coverage, complexity)
- [ ] Document decisions and learnings

### Success Criteria Template
```markdown
✅ Component < 300 lines
✅ Single responsibility only
✅ 95%+ test coverage
✅ No duplicate logic
✅ Service layer for business logic
✅ Repository for data access
✅ All existing tests passing
```

---

**Related**:
- [SOLID Principles](../../core/principles/solid.md)
- [DRY Principle](../../core/principles/dry-kiss-yagni.md)
- [Service Layer Pattern](../../core/architecture/service-layer-pattern.md)
- [Repository Pattern](../../core/architecture/repository-pattern.md)
- [God Component Refactoring](../../core/patterns/god-component-refactoring.md)

---

**Last Updated**: 2025-11-03
**Framework**: @ccsetup/documentation
