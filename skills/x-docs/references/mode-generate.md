# Mode: generate

> **Invocation**: `/x-docs generate` or `/x-docs generate "target"`
> **Legacy Command**: `/x:generate-docs`

<purpose>
Generate new documentation for undocumented code. Create docs from code analysis.
</purpose>

## Behavioral Skills

This mode activates:
- `documentation` - Doc patterns

## Agents

| Agent | When | Model |
|-------|------|-------|
| `ccsetup:x-reviewer` | Doc generation | haiku |
| `ccsetup:x-explorer` | Code analysis | haiku |

<instructions>

### Phase 1: Target Identification

Identify what needs documentation:

| Target | Documentation Type |
|--------|-------------------|
| Function | JSDoc comment |
| Class | Class documentation |
| Module | README in directory |
| API | API documentation |
| Feature | User guide |

### Phase 2: Code Analysis

Analyze code to understand:
- Purpose and responsibility
- Inputs and outputs
- Dependencies
- Usage patterns
- Edge cases

### Phase 3: Documentation Generation

Generate appropriate documentation:

#### JSDoc Template
```typescript
/**
 * Brief description of what the function does.
 *
 * @param {Type} paramName - Description of parameter
 * @returns {Type} Description of return value
 * @throws {ErrorType} When this error occurs
 *
 * @example
 * // Example usage
 * const result = functionName(input);
 */
```

#### README Template
```markdown
# Module Name

Brief description of the module.

## Purpose

What problem this solves.

## Usage

```typescript
import { thing } from './module';
```

## API

### functionName(params)

Description and parameters.

## Examples

Usage examples.
```

### Phase 4: Placement

Place documentation correctly:
- JSDoc: Above function/class
- README: In module directory
- API docs: In documentation/reference/

### Phase 5: Workflow Transition

```json
{
  "questions": [{
    "question": "Documentation generated for {target}. Continue?",
    "header": "Next",
    "options": [
      {"label": "/x-verify", "description": "Verify build"},
      {"label": "/x-docs sync", "description": "Sync other docs"},
      {"label": "Stop", "description": "Review docs first"}
    ],
    "multiSelect": false
  }]
}
```

</instructions>

## Documentation Standards

- **Clear**: Understandable by new developers
- **Concise**: No unnecessary words
- **Complete**: Cover all public APIs
- **Current**: Match actual behavior
- **Examples**: Show real usage

<critical_rules>

1. **Accuracy First** - Must match code behavior
2. **Public APIs** - Document all public interfaces
3. **Examples Required** - Show usage
4. **Keep Updated** - Doc changes with code

</critical_rules>

## References

- @core-docs/DOCUMENTATION-FRAMEWORK.md - Doc standards
- @skills/x-setup/templates/README.md - Templates

<success_criteria>

- [ ] Code analyzed
- [ ] Documentation generated
- [ ] Placed correctly
- [ ] Standards followed

</success_criteria>
