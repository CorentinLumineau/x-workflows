# Documentation Conventions Template

> Adapts to: Any project (detection based on existing doc patterns)

## Template

```markdown
# Documentation Conventions

## Doc Tool: {doc_tool}

## README Structure

Every project README includes these sections:
{readme_sections}

## Inline Documentation

- Document the WHY, not the WHAT -- code should be self-explanatory
- Public functions and methods require doc comments
- Use `{api_doc_format}` format for API documentation
- Complex algorithms include a brief explanation above the implementation
- TODO comments include an issue reference: `// TODO(#123): description`

## API Documentation

- All public endpoints documented with request/response examples
- Include error responses and edge cases
- Keep docs next to the code -- not in a separate wiki
- Update docs in the same PR as the code change

## File-Level Documentation

- Each module has a brief header comment explaining its purpose
- Configuration files include comments for non-obvious settings
- Scripts include usage instructions in a comment block at the top

## Maintenance Rules

- Treat stale docs as bugs -- outdated docs are worse than no docs
- Review documentation in every PR that changes behavior
- Automated doc generation runs in CI where applicable
```

## Placeholder Resolution

| Placeholder | JSDoc / TSDoc (JS/TS) | Sphinx (Python) | Rustdoc (Rust) |
|------------|----------------------|-----------------|----------------|
| `{doc_tool}` | JSDoc / TSDoc | Sphinx + reStructuredText | Rustdoc |
| `{api_doc_format}` | `/** @param {type} name - description */` | `:param name: description\n:type name: type` | `/// # Arguments\n/// * \`name\` - description` |
| `{readme_sections}` | Overview, Install, Quick Start, API, Contributing, License | Overview, Install, Quick Start, API Reference, Contributing, License | Overview, Install, Usage, Examples, API, Contributing, License |
