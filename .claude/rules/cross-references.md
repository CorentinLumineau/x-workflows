# x-workflows Cross-Reference Rules

## Allowed References
- **CAN reference**: x-devsecops knowledge skills via `@skills/{category}/{skill}`
- **CAN reference**: ccsetup core-docs via `@core-docs/RULES.md`
- **CAN reference**: External authoritative sources (RFCs, official docs)

## Forbidden Dependencies
- **CANNOT depend on**: ccsetup commands (they depend on US)
- **CANNOT depend on**: ccsetup agents (they depend on US)
- **CANNOT have**: Circular references to other workflow skills

---

## Reference Syntax
```markdown
<!-- Referencing knowledge skill -->
See @x-devsecops/skills/security/owasp for security guidelines

<!-- Referencing core rules -->
Follow @ccsetup/core-docs/RULES.md for behavioral guidelines
```

---

## Version Sync

This repository is included as a submodule in ccsetup. When releasing:

1. Tag release in x-workflows
2. Update submodule reference in ccsetup
3. Coordinate breaking changes with ccsetup maintainers
