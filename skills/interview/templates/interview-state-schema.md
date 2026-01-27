# Interview State Schema

> **Purpose**: JSON persistence schema for interview state.

## Overview

Interview state is persisted to `.claude/interview-state.json` for cross-session continuity, audit trail, and preventing re-asking validated questions.

## Full Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Interview State",
  "description": "Persistent state for interview behavioral skill",
  "type": "object",
  "properties": {
    "version": {
      "type": "string",
      "description": "Schema version for migrations",
      "default": "1.0.0"
    },
    "topic": {
      "type": "string",
      "description": "Human-readable topic identifier",
      "examples": ["implement-sso-login", "fix-auth-bug"]
    },
    "topicHash": {
      "type": "string",
      "description": "Hash for topic matching"
    },
    "workflow": {
      "type": "string",
      "description": "Active workflow skill",
      "examples": ["x-implement", "x-plan", "x-deploy"]
    },
    "mode": {
      "type": "string",
      "description": "Active mode within workflow",
      "examples": ["implement", "brainstorm", "deploy"]
    },
    "status": {
      "type": "string",
      "enum": ["gathering", "researching", "validating", "complete", "skipped"],
      "description": "Current interview phase"
    },
    "confidence": {
      "type": "object",
      "description": "Confidence scores per dimension",
      "properties": {
        "problem": {
          "type": "integer",
          "minimum": 0,
          "maximum": 100
        },
        "context": {
          "type": "integer",
          "minimum": 0,
          "maximum": 100
        },
        "technical": {
          "type": "integer",
          "minimum": 0,
          "maximum": 100
        },
        "scope": {
          "type": "integer",
          "minimum": 0,
          "maximum": 100
        },
        "risk": {
          "type": "integer",
          "minimum": 0,
          "maximum": 100
        },
        "composite": {
          "type": "number",
          "minimum": 0,
          "maximum": 100
        },
        "weights": {
          "type": "object",
          "properties": {
            "problem": { "type": "number" },
            "context": { "type": "number" },
            "technical": { "type": "number" },
            "scope": { "type": "number" },
            "risk": { "type": "number" }
          }
        }
      }
    },
    "triggers": {
      "type": "array",
      "description": "Detected triggers that activated interview",
      "items": {
        "type": "object",
        "properties": {
          "type": {
            "type": "string",
            "enum": ["ambiguity", "missing", "risk", "confidence"]
          },
          "description": { "type": "string" },
          "source": { "type": "string" },
          "keyword": { "type": "string" },
          "priority": {
            "type": "string",
            "enum": ["CRITICAL", "HIGH", "MEDIUM"]
          }
        }
      }
    },
    "questions": {
      "type": "array",
      "description": "Questions asked and answers received",
      "items": {
        "type": "object",
        "properties": {
          "number": { "type": "integer" },
          "question": { "type": "string" },
          "answer": { "type": "string" },
          "timestamp": { "type": "string", "format": "date-time" },
          "targetDimension": {
            "type": "string",
            "enum": ["problem", "context", "technical", "scope", "risk"]
          },
          "research": {
            "type": "object",
            "properties": {
              "type": {
                "type": "string",
                "enum": ["context7", "codebase", "websearch", "none"]
              },
              "query": { "type": "string" },
              "findings": { "type": "string" },
              "sources": {
                "type": "array",
                "items": { "type": "string" }
              },
              "timestamp": { "type": "string", "format": "date-time" }
            }
          },
          "confidenceImpact": {
            "type": "object",
            "additionalProperties": { "type": "string" }
          }
        }
      }
    },
    "reformulation": {
      "type": "object",
      "description": "3-format validation content",
      "properties": {
        "summary": { "type": "string" },
        "userStories": {
          "type": "array",
          "items": { "type": "string" }
        },
        "diagram": { "type": "string" },
        "analogies": {
          "type": "array",
          "items": { "type": "string" }
        },
        "validatedAt": { "type": "string", "format": "date-time" },
        "validationResponse": {
          "type": "string",
          "enum": ["yes_proceed", "minor_corrections", "significant_gaps"]
        },
        "corrections": { "type": "string" }
      }
    },
    "researchCache": {
      "type": "object",
      "description": "Cached research findings",
      "additionalProperties": {
        "type": "object",
        "properties": {
          "findings": { "type": "string" },
          "timestamp": { "type": "string", "format": "date-time" },
          "expiresAt": { "type": "string", "format": "date-time" }
        }
      }
    },
    "bypassLog": {
      "type": "array",
      "description": "Log of interview bypasses",
      "items": {
        "type": "object",
        "properties": {
          "timestamp": { "type": "string", "format": "date-time" },
          "reason": {
            "type": "string",
            "enum": ["explicit_user_request", "trivial_action", "already_interviewed", "continuation"]
          },
          "request": { "type": "string" },
          "confidence": { "type": "integer" },
          "warningShown": { "type": "boolean" },
          "warningText": { "type": "string" },
          "assumptions": {
            "type": "array",
            "items": { "type": "string" }
          }
        }
      }
    },
    "gateStatus": {
      "type": "string",
      "enum": ["blocked", "open"],
      "description": "Whether workflow can proceed"
    },
    "createdAt": {
      "type": "string",
      "format": "date-time"
    },
    "updatedAt": {
      "type": "string",
      "format": "date-time"
    },
    "expiresAt": {
      "type": "string",
      "format": "date-time"
    },
    "sessionId": {
      "type": "string",
      "description": "Session identifier for continuation"
    }
  },
  "required": ["version", "workflow", "mode", "status", "confidence", "gateStatus"]
}
```

## Example State File

```json
{
  "version": "1.0.0",
  "topic": "implement-sso-login",
  "topicHash": "a1b2c3d4e5f6",
  "workflow": "x-implement",
  "mode": "implement",
  "status": "validating",
  "confidence": {
    "problem": 95,
    "context": 90,
    "technical": 85,
    "scope": 90,
    "risk": 80,
    "composite": 88,
    "weights": {
      "problem": 0.25,
      "context": 0.20,
      "technical": 0.30,
      "scope": 0.15,
      "risk": 0.10
    }
  },
  "triggers": [
    {
      "type": "ambiguity",
      "description": "Multiple authentication approaches possible",
      "source": "user_request",
      "keyword": "add login",
      "priority": "HIGH"
    },
    {
      "type": "missing",
      "description": "Auth provider not specified",
      "source": "analysis",
      "priority": "HIGH"
    }
  ],
  "questions": [
    {
      "number": 1,
      "question": "Which authentication provider should we use?",
      "answer": "We use Auth0 for SSO",
      "timestamp": "2024-01-15T10:00:00Z",
      "targetDimension": "technical",
      "research": {
        "type": "context7",
        "query": "Auth0 SDK integration patterns",
        "findings": "Auth0 recommends @auth0/nextjs-auth0 for Next.js...",
        "sources": ["context7:/auth0/nextjs-auth0"],
        "timestamp": "2024-01-15T10:00:30Z"
      },
      "confidenceImpact": {
        "technical": "+25",
        "context": "+15"
      }
    },
    {
      "number": 2,
      "question": "Which login methods should be supported?",
      "answer": "Email/password and Google OAuth",
      "timestamp": "2024-01-15T10:02:00Z",
      "targetDimension": "scope",
      "research": {
        "type": "codebase",
        "query": "existing auth patterns",
        "findings": "Found existing OAuth setup in src/auth/...",
        "sources": ["src/auth/providers.ts", "src/auth/config.ts"],
        "timestamp": "2024-01-15T10:02:30Z"
      },
      "confidenceImpact": {
        "scope": "+30",
        "technical": "+10"
      }
    },
    {
      "number": 3,
      "question": "What should happen after successful login?",
      "answer": "Redirect to dashboard",
      "timestamp": "2024-01-15T10:04:00Z",
      "targetDimension": "problem",
      "research": {
        "type": "none"
      },
      "confidenceImpact": {
        "problem": "+20"
      }
    }
  ],
  "reformulation": {
    "summary": "## Understanding Summary\n\n**Goal**: Implement SSO login using Auth0...",
    "userStories": [
      "As an enterprise user, I want to log in with my Google work account, so that I don't need to remember another password."
    ],
    "diagram": "┌──────────┐     ┌──────────┐     ┌──────────┐\n│   User   │────→│  Auth0   │────→│ Dashboard│\n└──────────┘     └──────────┘     └──────────┘",
    "analogies": [
      "This is similar to 'Sign in with Google' on other apps"
    ],
    "validatedAt": null,
    "validationResponse": null,
    "corrections": null
  },
  "researchCache": {
    "auth0-patterns": {
      "findings": "Auth0 recommends @auth0/nextjs-auth0...",
      "timestamp": "2024-01-15T10:00:30Z",
      "expiresAt": "2024-01-16T10:00:30Z"
    }
  },
  "bypassLog": [],
  "gateStatus": "blocked",
  "createdAt": "2024-01-15T10:00:00Z",
  "updatedAt": "2024-01-15T10:04:00Z",
  "expiresAt": "2024-01-16T10:00:00Z",
  "sessionId": "session-abc123"
}
```

## State Operations

### Initialize State

```json
{
  "version": "1.0.0",
  "workflow": "x-implement",
  "mode": "implement",
  "status": "gathering",
  "confidence": {
    "problem": 0,
    "context": 0,
    "technical": 0,
    "scope": 0,
    "risk": 0,
    "composite": 0,
    "weights": {}
  },
  "triggers": [],
  "questions": [],
  "reformulation": null,
  "researchCache": {},
  "bypassLog": [],
  "gateStatus": "blocked",
  "createdAt": "2024-01-15T10:00:00Z",
  "updatedAt": "2024-01-15T10:00:00Z",
  "expiresAt": "2024-01-16T10:00:00Z",
  "sessionId": "session-xyz789"
}
```

### Complete Interview

```json
{
  "status": "complete",
  "confidence": {
    "composite": 100
  },
  "gateStatus": "open",
  "reformulation": {
    "validatedAt": "2024-01-15T11:00:00Z",
    "validationResponse": "yes_proceed"
  }
}
```

### Skip Interview

```json
{
  "status": "skipped",
  "gateStatus": "open",
  "bypassLog": [
    {
      "timestamp": "2024-01-15T10:00:00Z",
      "reason": "explicit_user_request",
      "request": "just do it",
      "confidence": 60,
      "warningShown": true,
      "warningText": "⚠️ Interview bypassed - proceeding with assumptions",
      "assumptions": [
        "Using default configuration",
        "Targeting current branch"
      ]
    }
  ]
}
```

## File Location

Default: `.claude/interview-state.json`

The file is:
- Created when interview activates
- Updated after each question/answer
- Cleared when workflow completes successfully
- Preserved on failure for debugging
