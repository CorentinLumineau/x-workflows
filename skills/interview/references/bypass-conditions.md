# Bypass Conditions

> **Purpose**: Define when interview is not required.

## Overview

While the Zero-Doubt Policy encourages thorough validation, some scenarios genuinely don't require the full interview loop. This document defines those conditions and the safeguards around them.

## Bypass Categories

### 1. Explicit Skip

**Condition**: User explicitly requests to skip interview

**Detection phrases**:
- "skip interview"
- "just do it"
- "don't ask questions"
- "I know what I want"

**Safeguards**:
- Log warning: "Interview bypassed by user request"
- Record bypass reason in state
- Proceed with best-effort interpretation
- Note assumptions made

**State update**:
```json
{
  "status": "skipped",
  "bypassReason": "explicit_user_request",
  "bypassTimestamp": "2024-01-15T10:00:00Z",
  "warning": "Interview bypassed - proceeding with assumptions",
  "assumptions": [
    "Using default configuration",
    "Targeting current branch"
  ]
}
```

### 2. Trivial Action

**Condition**: Single-line fix with unambiguous error

**Criteria** (ALL must be met):
- Error message is specific and clear
- Fix is deterministic (only one valid solution)
- Change is single-line or equivalent
- No user data affected
- Easily reversible

**Examples**:
- Typo in variable name
- Missing import statement
- Syntax error with clear fix
- Adding missing comma/bracket

**Non-examples** (require interview):
- "Fix the typo" without specifying which
- Error could be fixed multiple ways
- Fix requires understanding context

**State update**:
```json
{
  "status": "skipped",
  "bypassReason": "trivial_action",
  "bypassTimestamp": "2024-01-15T10:00:00Z",
  "trivialityCheck": {
    "singleLine": true,
    "deterministicFix": true,
    "noUserData": true,
    "reversible": true
  }
}
```

### 3. Already Interviewed

**Condition**: Previous interview complete for this exact topic

**Criteria** (ALL must be met):
- State shows `status: "complete"` or `gateStatus: "open"`
- Topic hash matches current request
- State is not expired (< 24 hours or same session)
- No context invalidation detected

**Topic matching**:
```javascript
// Simple hash of key elements
topicHash = hash(workflow + mode + keyEntities)
```

**Context invalidation triggers**:
- User says "actually" or "but now"
- Significant time gap (> 24 hours)
- Different files mentioned
- Scope explicitly changed

**State check**:
```json
{
  "status": "complete",
  "topic": "implement-sso-login",
  "topicHash": "a1b2c3d4",
  "validatedAt": "2024-01-15T10:00:00Z",
  "expiresAt": "2024-01-16T10:00:00Z"
}
```

### 4. Continuation

**Condition**: Resuming previous validated work

**Detection**:
- User says "continue" or "keep going"
- User references previous conversation
- State shows partial progress on same topic

**Criteria**:
- Previous interview was validated (100% confidence)
- Same topic/scope
- No new requirements introduced

**State check**:
```json
{
  "continuation": true,
  "previousSessionId": "abc123",
  "previousConfidence": 100,
  "resumePoint": "Phase 2, Step 3"
}
```

## Non-Bypass Scenarios

These scenarios always require interview regardless of other factors:

### High-Risk Actions

- Production deployments
- Version releases
- Data deletion
- Permission changes
- Public-facing changes

### New Context

- First request in session
- Different project/repository
- New user (no history)

### Explicit Uncertainty

- User expresses doubt ("I'm not sure if...")
- User asks for options ("should I...")
- Request contains contradictions

## Bypass Decision Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    Check Bypass Conditions                   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌───────────────────┐
                    │ Is this HIGH RISK?│
                    └───────────────────┘
                              │
                    ┌─────────┴─────────┐
                   YES                  NO
                    │                    │
                    ▼                    ▼
            ┌───────────────┐  ┌───────────────────┐
            │ ALWAYS        │  │ Explicit skip     │
            │ INTERVIEW     │  │ requested?        │
            └───────────────┘  └───────────────────┘
                                        │
                              ┌─────────┴─────────┐
                             YES                  NO
                              │                    │
                              ▼                    ▼
                    ┌───────────────┐   ┌───────────────────┐
                    │ BYPASS        │   │ Trivial action?   │
                    │ (log warning) │   └───────────────────┘
                    └───────────────┘            │
                                      ┌─────────┴─────────┐
                                     YES                  NO
                                      │                    │
                                      ▼                    ▼
                            ┌───────────────┐   ┌───────────────────┐
                            │ BYPASS        │   │ Already           │
                            └───────────────┘   │ interviewed?      │
                                                └───────────────────┘
                                                        │
                                              ┌─────────┴─────────┐
                                             YES                  NO
                                              │                    │
                                              ▼                    ▼
                                    ┌───────────────┐   ┌───────────────┐
                                    │ BYPASS        │   │ INTERVIEW     │
                                    └───────────────┘   └───────────────┘
```

## Logging Requirements

All bypasses must be logged:

```json
{
  "bypassLog": [
    {
      "timestamp": "2024-01-15T10:00:00Z",
      "reason": "trivial_action",
      "request": "Fix typo in variable name",
      "confidence": 85,
      "warningShown": false
    },
    {
      "timestamp": "2024-01-15T10:05:00Z",
      "reason": "explicit_user_request",
      "request": "Just deploy it",
      "confidence": 60,
      "warningShown": true,
      "warningText": "⚠️ Interview bypassed - proceeding with assumptions"
    }
  ]
}
```

## Warning Messages

When interview is bypassed, appropriate warnings should be shown:

**Explicit skip (high risk)**:
```
⚠️ Warning: Interview bypassed for high-risk action.
Proceeding with assumptions:
- [assumption 1]
- [assumption 2]
```

**Trivial action**:
```
ℹ️ Trivial fix detected - proceeding directly.
```

**Already interviewed**:
```
ℹ️ Using previous interview results (validated 2 hours ago).
```

**Continuation**:
```
ℹ️ Continuing from previous session - requirements validated.
```
