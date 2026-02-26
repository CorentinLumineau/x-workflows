# TDD Hard Gate Reference

> Extracted from x-implement SKILL.md Phase 2 — mandatory verification before writing production code.

## STOP — TDD Hard Gate

> **You MUST stop here and verify before writing any production code.**

**Checklist** (ALL must be true to proceed):
- [ ] A failing test exists for the new behavior
- [ ] The test was written BEFORE the production code
- [ ] All tests currently pass (run them, read the output — not "should pass")

## Common Rationalizations

If you're thinking any of these, STOP:

| Excuse | Reality |
|--------|---------|
| "The code is trivial" | Trivial code gets trivial tests. Still mandatory. (V-TEST-02) |
| "I will add tests after" | TDD means tests FIRST. "After" is not TDD. (V-TEST-02) |
| "Running low on context" | Stop coding. Write the test. Resume after. (V-TEST-01) |
| "This is just a refactor" | Refactors need tests to prove behavior unchanged. (V-TEST-01) |

> **Foundational principle**: Violating the letter of this gate IS violating its spirit. There is no "technically compliant" shortcut.

See `@skills/code-code-quality/references/anti-rationalization.md` for the full excuse/reality reference.

## Phase 2 Exit Gate

After each Red-Green-Refactor cycle, verify:
- [ ] Tests exist for all new production code (V-TEST-01)
- [ ] Tests written before production code (V-TEST-02)
- [ ] All tests pass
- [ ] No CRITICAL SOLID violations introduced (V-SOLID-01, V-SOLID-03)

**BLOCK if any exit gate fails.**
