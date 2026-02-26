# API Design Conventions Template

> Adapts to: Express, Fastify, Hono, Django, Flask, FastAPI

## Template

```markdown
# API Conventions

## Framework: {framework}

## Resource Naming
- Use plural nouns for resources: `/users`, `/orders`, `/products`
- Use kebab-case for multi-word resources: `/user-profiles`
- Nest related resources: `/users/{id}/orders`
- Maximum nesting depth: 2 levels

## HTTP Methods
- GET: Read (safe, idempotent)
- POST: Create
- PUT: Full update (idempotent)
- PATCH: Partial update
- DELETE: Remove (idempotent)

## Response Format
- Always return JSON with consistent envelope:
  ```json
  { "data": {...}, "meta": {...} }
  ```
- Error responses include code and message:
  ```json
  { "error": { "code": "VALIDATION_ERROR", "message": "..." } }
  ```

## Status Codes
- 200: Success
- 201: Created
- 400: Bad request / validation error
- 401: Unauthorized
- 403: Forbidden
- 404: Not found
- 409: Conflict
- 500: Internal server error

## Validation
- Validate request body at the controller/route level
- Use schema validation ({validation_library})
- Return 400 with specific field errors

## Pagination
- Use cursor-based pagination for large datasets
- Default page size: 20, maximum: 100
- Include `next_cursor` in response meta
```

## Placeholder Resolution

| Placeholder | Express | Fastify | Django REST | FastAPI |
|------------|---------|---------|-------------|---------|
| `{framework}` | Express | Fastify | Django REST Framework | FastAPI |
| `{validation_library}` | Zod / Joi | Fastify schemas (JSON Schema) | DRF serializers | Pydantic models |
