---
template: fullstack-diagram
type: architecture
stack-type: fullstack
variables:
  - frontend-framework: Frontend framework name
  - backend-framework: Backend framework name
  - database: Database name
  - orm: ORM name
  - state-management: State management library
  - styling: CSS framework
  - auth-library: Authentication library
  - validation: Validation library
---

# Project Architecture

> Full-stack application architecture
> Stack: {{frontend-framework}} + {{backend-framework}} + {{database}}

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                            │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   Browser   │  │  Mobile App │  │    CLI      │             │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘             │
└─────────┼────────────────┼────────────────┼─────────────────────┘
          │                │                │
          ▼                ▼                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                         │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    {{frontend-framework}}               │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐              │   │
│  │  │  Pages   │  │Components│  │  Hooks   │              │   │
│  │  └──────────┘  └──────────┘  └──────────┘              │   │
│  │                                                         │   │
│  │  State: {{state-management}}  │  Styling: {{styling}}  │   │
│  └─────────────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────────────┘
                             │ HTTP/REST/GraphQL
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                         API LAYER                               │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                   {{backend-framework}}                 │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐              │   │
│  │  │  Routes  │  │Middleware│  │Controllers│              │   │
│  │  └──────────┘  └──────────┘  └──────────┘              │   │
│  │                                                         │   │
│  │  Auth: {{auth-library}}  │  Validation: {{validation}} │   │
│  └─────────────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                       SERVICE LAYER                             │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   Business  │  │  Domain     │  │  External   │             │
│  │   Logic     │  │  Services   │  │  Integrations│            │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘             │
└─────────┼────────────────┼────────────────┼─────────────────────┘
          │                │                │
          ▼                ▼                ▼
┌─────────────────────────────────────────────────────────────────┐
│                     DATA ACCESS LAYER                           │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                       {{orm}}                           │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐              │   │
│  │  │  Models  │  │ Queries  │  │Migrations│              │   │
│  │  └──────────┘  └──────────┘  └──────────┘              │   │
│  └─────────────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DATABASE LAYER                             │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                     {{database}}                        │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐              │   │
│  │  │  Tables  │  │  Indexes │  │  Views   │              │   │
│  │  └──────────┘  └──────────┘  └──────────┘              │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## Layer Responsibilities

### Client Layer
- User interfaces (web browser, mobile apps, CLI)
- User interaction and input handling

### Presentation Layer ({{frontend-framework}})
- UI components and pages
- State management ({{state-management}})
- User experience and styling ({{styling}})

### API Layer ({{backend-framework}})
- HTTP request handling
- Authentication and authorization
- Input validation
- Response formatting

### Service Layer
- Business logic implementation
- Domain rules and workflows
- External service integrations

### Data Access Layer ({{orm}})
- Database queries and mutations
- Data models and schemas
- Migrations and versioning

### Database Layer ({{database}})
- Data persistence
- Indexing and optimization
- Data integrity constraints

## Data Flow

```
User Action → UI Component → API Request → Route Handler
    → Service → Repository → Database
    → Response → UI Update → User Feedback
```

## Technologies

| Layer | Technology | Purpose |
|-------|------------|---------|
| Frontend | {{frontend-framework}} | UI framework |
| State | {{state-management}} | Client state |
| Styling | {{styling}} | CSS framework |
| API | {{backend-framework}} | HTTP server |
| ORM | {{orm}} | Database access |
| Database | {{database}} | Data storage |
