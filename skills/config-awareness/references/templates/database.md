# Database Conventions Template

> Adapts to: Prisma, TypeORM, Sequelize, SQLAlchemy

## Template

```markdown
# Database Conventions

## ORM: {orm}

## Schema & Migrations

- Schema location: `{schema_location}`
- Migration naming: `{migration_naming}`
- Always create a migration for schema changes -- never modify the database directly
- Run migrations: `{migration_command}`
- Seed data: `{seed_command}`

## Migration Rules

- Migrations are append-only -- never edit an existing migration
- Each migration does one thing (add table, add column, add index)
- Include a rollback/down migration for every up migration
- Test migrations against a copy of production data before deploying
- Name migrations descriptively: `add_status_column_to_orders`

## Query Patterns

- Use the ORM for standard CRUD operations -- avoid raw SQL unless necessary
- Add database indexes for columns used in WHERE, JOIN, and ORDER BY
- Use transactions for multi-step writes that must be atomic
- Paginate all list queries -- never return unbounded result sets
- Use eager loading for known associations, lazy loading for optional ones

## Naming Conventions

- Tables: plural snake_case (`user_profiles`, `order_items`)
- Columns: singular snake_case (`created_at`, `user_id`)
- Foreign keys: `{referenced_table_singular}_id` (`user_id`, `order_id`)
- Indexes: `idx_{table}_{column}` (`idx_users_email`)
- Constraints: `uq_{table}_{column}` for unique, `chk_{table}_{rule}` for check

## Seed Data

- Seed scripts are idempotent -- safe to run multiple times
- Separate dev seeds (fake data) from prod seeds (reference data)
- Never seed sensitive data (passwords, API keys) -- use environment variables
```

## Placeholder Resolution

| Placeholder | Prisma | TypeORM | Sequelize | SQLAlchemy |
|------------|--------|---------|-----------|------------|
| `{orm}` | Prisma | TypeORM | Sequelize | SQLAlchemy + Alembic |
| `{migration_command}` | `npx prisma migrate dev` | `npx typeorm migration:run` | `npx sequelize db:migrate` | `alembic upgrade head` |
| `{schema_location}` | `prisma/schema.prisma` | `src/entities/` | `db/models/` | `app/models/` |
| `{migration_naming}` | Timestamp-based (auto) | Timestamp-based (`{timestamp}-MigrationName`) | Timestamp-based (`{timestamp}-migration-name`) | Revision-hash (`alembic revision --autogenerate`) |
| `{seed_command}` | `npx prisma db seed` | `npx typeorm migration:run` (seed migration) | `npx sequelize db:seed:all` | `python -m app.seeds` |
