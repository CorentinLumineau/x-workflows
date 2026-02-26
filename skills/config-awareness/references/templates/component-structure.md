# Component Structure Template

> Adapts to: React, Vue, Angular

## Template

```markdown
# Component Structure

## Framework: {framework}

## File Organization

- Component files use `{file_extension}` extension
- Components live in `{component_dir}` with co-located assets
- One component per file -- no multi-component files
- Group by feature, not by type:
  ```
  {component_dir}/
    auth/
      LoginForm{file_extension}
      LoginForm.test{file_extension}
      useAuth{file_extension}
    dashboard/
      Dashboard{file_extension}
      DashboardWidget{file_extension}
  ```

## Naming Conventions

- Components: PascalCase (`UserProfile`, `OrderList`)
- Utilities/hooks: camelCase (`useAuth`, `formatDate`)
- Constants: UPPER_SNAKE_CASE (`MAX_RETRIES`, `API_BASE_URL`)
- Directories: kebab-case (`user-profile/`, `order-list/`)

## Styling: {style_approach}

- Styles are scoped to the component -- no global style leaks
- Use design tokens for colors, spacing, typography
- Responsive breakpoints defined in shared config

## State Management: {state_management}

- Local state for UI-only concerns (modals, form inputs, toggles)
- Shared state for cross-component data (user session, cart, notifications)
- Server state managed separately from client state
- Avoid prop drilling beyond 2 levels -- lift state or use context

## Component Guidelines

- Keep components under 150 lines -- extract sub-components when larger
- Separate logic from presentation (container/presenter or composable pattern)
- Define prop types explicitly -- no implicit any
- Default exports for page-level components, named exports for shared components
```

## Placeholder Resolution

| Placeholder | React | Vue | Angular |
|------------|-------|-----|---------|
| `{framework}` | React | Vue | Angular |
| `{file_extension}` | `.tsx` | `.vue` | `.ts` |
| `{component_dir}` | `src/components/` | `src/components/` | `src/app/` |
| `{style_approach}` | CSS Modules / Tailwind | Scoped styles (`<style scoped>`) | Component styles (`styleUrls`) |
| `{state_management}` | Hooks + Context / Zustand | Composition API + Pinia | Services + RxJS |
