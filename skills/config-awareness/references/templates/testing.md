# Testing Conventions Template

> Adapts to: Jest, Vitest, pytest, Mocha

## Template

```markdown
# Testing Conventions

## Test Structure

- Follow the testing pyramid: 70% unit, 20% integration, 10% E2E
- Test files live in `{test_dir}` alongside or mirroring source structure
- Name test files: `{naming_pattern}`

## Test Runner: {runner}

- Run tests: `{run_command}`
- Run single file: `{single_command}`
- Run with coverage: `{coverage_command}`

## Conventions

- Each test has exactly one assertion focus (single responsibility)
- Use descriptive test names: "should {expected behavior} when {condition}"
- Arrange-Act-Assert pattern for all tests
- Mock external dependencies, not internal modules
- No test interdependencies -- each test runs independently

## Coverage

- Minimum coverage target: 80% line coverage
- Critical paths (auth, payments, data mutations): 95% coverage
- New code must include tests -- no untested features merged
```

## Placeholder Resolution

| Placeholder | Jest | Vitest | pytest | Mocha |
|------------|------|--------|--------|-------|
| `{runner}` | Jest | Vitest | pytest | Mocha |
| `{test_dir}` | `__tests__/` or `*.test.js` | `__tests__/` or `*.test.ts` | `tests/` | `test/` |
| `{naming_pattern}` | `*.test.js` / `*.test.ts` | `*.test.ts` / `*.spec.ts` | `test_*.py` / `*_test.py` | `*.test.js` / `*.spec.js` |
| `{run_command}` | `npx jest` | `npx vitest` | `pytest` | `npx mocha` |
| `{single_command}` | `npx jest path/to/test` | `npx vitest path/to/test` | `pytest path/to/test.py` | `npx mocha path/to/test` |
| `{coverage_command}` | `npx jest --coverage` | `npx vitest --coverage` | `pytest --cov` | `npx nyc mocha` |
