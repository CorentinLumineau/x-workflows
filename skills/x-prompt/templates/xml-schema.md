# XML Prompt Schema

<purpose>
Modular XML template for structured prompts. Sections can be included or omitted based on prompt complexity and user preferences.
</purpose>

## Section Reference

| Section | Required | Purpose |
|---------|----------|---------|
| `<purpose>` | Yes | Clear, single-sentence goal statement |
| `<context>` | Standard | Background information and relevant details |
| `<role>` | Optional | Persona or expertise the LLM should adopt |
| `<instructions>` | Yes | Step-by-step actions to perform |
| `<constraints>` | Standard | Boundaries, limitations, and requirements |
| `<output_format>` | Yes | Expected response structure |
| `<examples>` | Optional | Few-shot input/output demonstrations |
| `<success_criteria>` | Standard | Validation checkpoints |
| `<thinking_guidance>` | Optional | Chain-of-thought scaffolding |

## Detail Level Mapping

| Level | Sections Included |
|-------|-------------------|
| Concise | purpose, instructions, output_format |
| Standard | + context, constraints, success_criteria |
| Comprehensive | + role, examples, thinking_guidance |

---

## Section Templates

### `<purpose>` (Required)

Clear goal statement in one sentence.

```xml
<purpose>
[Action verb] [specific outcome] [for whom/what context].
</purpose>
```

**Example:**
```xml
<purpose>
Generate a comprehensive test suite for a user authentication module that covers all edge cases.
</purpose>
```

---

### `<context>` (Standard)

Background information the LLM needs.

```xml
<context>
[Domain/project description]
[Relevant constraints or assumptions]
[Any prerequisite knowledge needed]
</context>
```

**Example:**
```xml
<context>
This is a Node.js Express application using JWT for authentication.
The auth module handles login, logout, and token refresh operations.
Tests should use Jest and follow the existing test patterns in the codebase.
</context>
```

---

### `<role>` (Optional)

Persona for specialized expertise.

```xml
<role>
You are a [expertise] with experience in [specific domain].
[Any behavioral traits or approach]
</role>
```

**Example:**
```xml
<role>
You are a senior security engineer with 10 years of experience in web application security.
Approach this task with a defensive mindset, considering both common and sophisticated attack vectors.
</role>
```

---

### `<instructions>` (Required)

Step-by-step actions to perform.

```xml
<instructions>
1. [First action with clear outcome]
2. [Second action with clear outcome]
3. [Continue as needed]

If [condition], then [alternative action].
</instructions>
```

**Example:**
```xml
<instructions>
1. Identify all public endpoints in the authentication module
2. For each endpoint, list the expected inputs and outputs
3. Generate test cases for:
   - Happy path scenarios
   - Invalid input handling
   - Authentication failures
   - Edge cases (expired tokens, malformed requests)
4. Include setup and teardown code for each test suite
</instructions>
```

---

### `<constraints>` (Standard)

Boundaries and requirements.

```xml
<constraints>
- [Limitation or boundary]
- [Required standard or format]
- [What to avoid]
- [Performance or size requirements]
</constraints>
```

**Example:**
```xml
<constraints>
- Do not mock the database; use the test database configuration
- Each test must be independent and idempotent
- Avoid testing implementation details; focus on behavior
- Tests should complete in under 30 seconds total
</constraints>
```

---

### `<output_format>` (Required)

Expected response structure.

```xml
<output_format>
[Description of format]

Structure:
[Template or example of expected output]
</output_format>
```

**Example:**
```xml
<output_format>
Provide the test code in a single file with clear section comments.

Structure:
- Import statements
- Test configuration
- Describe block for each endpoint
- Individual test cases with descriptive names
- Helper functions at the bottom
</output_format>
```

---

### `<examples>` (Optional)

Few-shot demonstrations.

```xml
<examples>
<example>
<input>
[Sample input]
</input>
<output>
[Expected output for that input]
</output>
</example>

<example>
<input>
[Another sample input]
</input>
<output>
[Expected output]
</output>
</example>
</examples>
```

**Example:**
```xml
<examples>
<example>
<input>
POST /auth/login with valid credentials
</input>
<output>
describe('POST /auth/login', () => {
  it('should return 200 and JWT token for valid credentials', async () => {
    const response = await request(app)
      .post('/auth/login')
      .send({ email: 'test@example.com', password: 'validPassword' });

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('token');
  });
});
</output>
</example>
</examples>
```

---

### `<success_criteria>` (Standard)

Validation checkpoints.

```xml
<success_criteria>
- [ ] [Measurable criterion 1]
- [ ] [Measurable criterion 2]
- [ ] [Quality gate]
</success_criteria>
```

**Example:**
```xml
<success_criteria>
- [ ] All happy path scenarios covered
- [ ] Error cases return appropriate status codes
- [ ] No test depends on execution order
- [ ] Test descriptions clearly explain what is being tested
</success_criteria>
```

---

### `<thinking_guidance>` (Optional)

Chain-of-thought scaffolding for complex tasks.

```xml
<thinking_guidance>
Before generating output:
1. [Analysis step]
2. [Evaluation step]
3. [Planning step]

Consider:
- [Important factor 1]
- [Important factor 2]
</thinking_guidance>
```

**Example:**
```xml
<thinking_guidance>
Before writing tests:
1. Map out all code paths in the authentication flow
2. Identify which paths have the highest risk if untested
3. Consider what failures would be most impactful to users

Consider:
- Race conditions in token refresh
- Session fixation vulnerabilities
- Timing attacks on password comparison
</thinking_guidance>
```

---

## Complete Template

```xml
<purpose>
[Single-sentence goal statement]
</purpose>

<context>
[Background information]
[Relevant constraints]
[Prerequisites]
</context>

<role>
[Optional persona/expertise]
</role>

<instructions>
1. [Step 1]
2. [Step 2]
3. [Step 3]
</instructions>

<constraints>
- [Boundary 1]
- [Boundary 2]
- [What to avoid]
</constraints>

<output_format>
[Format description]
[Structure template]
</output_format>

<examples>
<example>
<input>[Sample]</input>
<output>[Expected]</output>
</example>
</examples>

<success_criteria>
- [ ] [Criterion 1]
- [ ] [Criterion 2]
</success_criteria>

<thinking_guidance>
[Analysis steps]
[Considerations]
</thinking_guidance>
```

---

## Usage Notes

1. **Omit empty sections** - Don't include sections with no content
2. **Order matters** - Follow the template order for consistency
3. **Be specific** - Vague sections reduce prompt effectiveness
4. **Test iteratively** - Use refine mode to improve based on LLM output
