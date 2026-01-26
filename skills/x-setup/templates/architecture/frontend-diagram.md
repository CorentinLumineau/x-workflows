---
template: frontend-diagram
type: architecture
stack-type: frontend
variables:
  - frontend-framework: Frontend framework name
  - state-management: State management library
---

# Project Architecture

> Frontend application architecture
> Stack: {{frontend-framework}} + {{state-management}}

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         APPLICATION                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                      PAGES/VIEWS                          │ │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐     │ │
│  │  │  Home   │  │  About  │  │ Products│  │ Profile │     │ │
│  │  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘     │ │
│  └───────┼───────────┼───────────┼───────────┼───────────────┘ │
│          │           │           │           │                  │
│          ▼           ▼           ▼           ▼                  │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                     COMPONENTS                            │ │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐     │ │
│  │  │ Header  │  │  Card   │  │  Modal  │  │  Form   │     │ │
│  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘     │ │
│  └───────────────────────────────────────────────────────────┘ │
│          │           │           │           │                  │
│          ▼           ▼           ▼           ▼                  │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                    STATE MANAGEMENT                       │ │
│  │  ┌───────────────────────────────────────────────────┐   │ │
│  │  │              {{state-management}}                  │   │ │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐        │   │ │
│  │  │  │  Global  │  │  Local   │  │  Server  │        │   │ │
│  │  │  │  State   │  │  State   │  │  State   │        │   │ │
│  │  │  └──────────┘  └──────────┘  └──────────┘        │   │ │
│  │  └───────────────────────────────────────────────────┘   │ │
│  └───────────────────────────────────────────────────────────┘ │
│          │                                                      │
│          ▼                                                      │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                      SERVICES                             │ │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐                  │ │
│  │  │   API   │  │  Auth   │  │ Storage │                  │ │
│  │  │ Client  │  │ Service │  │ Service │                  │ │
│  │  └────┬────┘  └────┬────┘  └────┬────┘                  │ │
│  └───────┼───────────┼───────────┼───────────────────────────┘ │
└──────────┼───────────┼───────────┼──────────────────────────────┘
           │           │           │
           ▼           ▼           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    EXTERNAL SERVICES                            │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │  REST API   │  │   Auth0     │  │ LocalStorage│             │
│  │  (Backend)  │  │   (Auth)    │  │  (Cache)    │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└─────────────────────────────────────────────────────────────────┘
```

## Layer Responsibilities

| Layer | Purpose | Files |
|-------|---------|-------|
| Pages/Views | Route-level components | pages/, views/ |
| Components | Reusable UI elements | components/ |
| State Management | Application state | store/, context/ |
| Services | External communication | services/, api/ |

## Component Types

- **Pages**: Route-level containers
- **Features**: Domain-specific components
- **UI**: Generic, reusable components
- **Layout**: Structural components
