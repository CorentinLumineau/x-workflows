# Research Loop

> **Purpose**: Document and research between every question to ask informed follow-ups.

## Overview

The research loop ensures the agent doesn't just ask questions blindly but actively investigates based on user answers. This creates more intelligent follow-up questions and demonstrates understanding.

## Core Protocol

```
┌─────────┐    ┌──────────┐    ┌──────────┐    ┌───────────┐
│   ASK   │───→│ DOCUMENT │───→│ RESEARCH │───→│ SYNTHESIZE│
└─────────┘    └──────────┘    └──────────┘    └───────────┘
     ↑                                               │
     └───────────────────────────────────────────────┘
```

### 1. ASK

- Target the lowest-confidence dimension
- Frame question to maximize information gain
- Use AskUserQuestion for structured choices when applicable

### 2. DOCUMENT

- Record exact answer in interview state
- Note timestamp and confidence impact
- Link to relevant previous answers

### 3. RESEARCH

- Investigate based on answer content
- Use appropriate research source
- Document findings in state

### 4. SYNTHESIZE

- Update confidence scores
- Identify remaining gaps
- Formulate next question OR proceed to reformulation

## Research Triggers by Answer Content

| User Mentions | Research Action | Tool/Source |
|---------------|-----------------|-------------|
| Library/framework name | Lookup documentation | Context7 |
| "Like we do in X file" | Find pattern in codebase | Grep/Glob |
| "Similar to X feature" | Analyze existing implementation | Read/Grep |
| Error message | Search for solutions | Codebase + WebSearch |
| Technology/service name | Get current best practices | Context7 + WebSearch |
| "In the Y module" | Map module structure | Glob + Read |
| Version number | Check compatibility | Context7 + WebSearch |
| API/endpoint name | Find existing usage | Grep |
| Competitor/product | Competitive analysis | WebSearch |
| Date/timeline | Check recent changes | Git log |

## Research Depth by Confidence Level

| Confidence | Research Depth |
|------------|----------------|
| 0-49% | **Light** - Quick lookup, surface-level |
| 50-79% | **Medium** - Deeper investigation, cross-reference |
| 80-94% | **Validation** - Verify assumptions, edge cases |
| 95-99% | **Confirmation** - Final checks only |

## Research Documentation Format

Each research action is recorded in interview state:

```json
{
  "questions": [
    {
      "number": 1,
      "question": "Which authentication library are you using?",
      "answer": "We use Auth0 for SSO",
      "research": {
        "type": "context7",
        "query": "Auth0 SDK integration patterns",
        "findings": "Auth0 recommends using @auth0/nextjs-auth0 for Next.js. Key patterns: handleAuth(), withApiAuthRequired, getSession(). Rate limits apply.",
        "sources": ["context7:/auth0/nextjs-auth0"],
        "timestamp": "2024-01-15T10:30:00Z"
      },
      "confidenceImpact": {
        "context": "+25",
        "technical": "+15"
      }
    }
  ]
}
```

## Research Source Selection

### Context7 (Libraries/Frameworks)

**When to use:**
- User mentions a library name
- Need API documentation
- Looking for best practices
- Version-specific guidance

**Example triggers:**
- "We're using React Query"
- "The Prisma schema"
- "Next.js 14 features"

### Codebase Search (Internal Patterns)

**When to use:**
- User references existing code
- Need to understand current architecture
- Looking for similar implementations
- Checking for conflicts

**Example triggers:**
- "Like the auth middleware"
- "In the utils folder"
- "The way we handle errors"

### WebSearch (External Knowledge)

**When to use:**
- General best practices
- Competitive analysis
- Error message lookup
- Technology comparisons

**Example triggers:**
- "Industry standard for..."
- "Error: [specific message]"
- "Like how Stripe does it"

## Research-Informed Questions

After research, questions become more specific:

**Before research:**
> "How should the authentication work?"

**After research (found Auth0 in codebase):**
> "I see you're using Auth0 with @auth0/nextjs-auth0. Should this new feature use the same SSO flow, or does it need a different authentication method?"

## Research Limits

- **Max research per question**: 2 sources
- **Max time per research**: 30 seconds
- **Skip research if**: Answer is a simple yes/no or selection from provided options

## State Persistence

Research findings persist across sessions:

```json
{
  "researchCache": {
    "auth0-patterns": {
      "findings": "...",
      "timestamp": "...",
      "expiresAt": "..."
    }
  }
}
```

Cache expires after 24 hours or when user indicates context has changed.
