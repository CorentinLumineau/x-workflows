# Reformulation Templates

> **Purpose**: 3-format validation to prove understanding before action.

## Overview

At 80%+ confidence, the agent must demonstrate understanding by presenting requirements in three complementary formats. This catches misunderstandings before any action is taken.

## The 3 Formats

### 1. Executive Summary

Structured bullet points capturing key requirements:

```markdown
## Understanding Summary

**Goal**: [One sentence describing the objective]

**Key Requirements**:
- [Requirement 1]
- [Requirement 2]
- [Requirement 3]

**Constraints**:
- [Constraint 1]
- [Constraint 2]

**Success Criteria**:
- [Criterion 1]
- [Criterion 2]

**Out of Scope**:
- [Exclusion 1]
- [Exclusion 2]
```

### 2. User Stories

"As X, I want Y, so that Z" format:

```markdown
## User Stories

**Primary Story**:
As a [user type],
I want [functionality],
so that [benefit].

**Secondary Stories**:
1. As a [user], I want [feature], so that [value].
2. As a [admin], I want [capability], so that [outcome].

**Acceptance Criteria**:
- Given [context], when [action], then [result]
- Given [context], when [action], then [result]
```

### 3. Concept Diagram

ASCII visualization of system/flow:

```markdown
## Concept Diagram

┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   [Actor]   │────→│  [Action]   │────→│  [Result]   │
└─────────────┘     └─────────────┘     └─────────────┘
       │                   │                   │
       │                   ▼                   │
       │            ┌─────────────┐            │
       └───────────→│ [Component] │←───────────┘
                    └─────────────┘
```

## Analogies

Add analogies to demonstrate understanding:

```markdown
## Analogies

- "So this is similar to [familiar concept]..."
- "If I understand correctly, it's like [analogy] because [reason]..."
- "This reminds me of [pattern] where [similarity]..."
```

## Validation Question

After presenting the 3 formats, ask for validation:

```json
{
  "question": "I've summarized my understanding above. Is this accurate?",
  "header": "Validate",
  "options": [
    {
      "label": "Yes, proceed",
      "description": "Understanding is correct, continue with the task"
    },
    {
      "label": "Minor corrections",
      "description": "Mostly correct, I'll note the small corrections"
    },
    {
      "label": "Significant gaps",
      "description": "Major misunderstanding, let's clarify further"
    }
  ],
  "multiSelect": false
}
```

## Response Handling

### "Yes, proceed"
- Set confidence to 100%
- Update state: `gateStatus: "open"`
- Proceed to workflow Phase 1

### "Minor corrections"
- Record corrections
- Update affected dimensions
- Re-present reformulation with corrections
- Re-validate

### "Significant gaps"
- Reset confidence to 70% (not lower to preserve validated parts)
- Identify which dimensions need work
- Continue interview loop

## Full Reformulation Example

```markdown
---

## My Understanding

### Executive Summary

**Goal**: Implement SSO login using Auth0 for enterprise users

**Key Requirements**:
- Use existing Auth0 tenant configuration
- Support both email/password and Google OAuth
- Redirect to dashboard after successful login
- Show appropriate error messages for failures

**Constraints**:
- Must work with existing session management
- Cannot modify the Auth0 tenant settings
- Must support IE11 (legacy requirement)

**Success Criteria**:
- User can log in with Google in under 3 clicks
- Session persists across browser refresh
- Failed logins show clear error messages

**Out of Scope**:
- Password reset flow (Phase 2)
- Multi-factor authentication (Phase 2)
- Admin user management

### User Stories

**Primary Story**:
As an enterprise user,
I want to log in with my Google work account,
so that I don't need to remember another password.

**Secondary Stories**:
1. As a user, I want to see a clear error when login fails, so that I know what went wrong.
2. As a returning user, I want my session to persist, so that I don't have to log in repeatedly.

**Acceptance Criteria**:
- Given I'm on the login page, when I click "Sign in with Google", then I'm redirected to Google OAuth
- Given I complete Google OAuth, when I'm redirected back, then I see my dashboard
- Given I have an invalid session, when I try to access protected routes, then I'm redirected to login

### Concept Diagram

┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│   User   │────→│  Login   │────→│  Auth0   │────→│ Dashboard│
└──────────┘     │   Page   │     │   SSO    │     └──────────┘
                 └──────────┘     └──────────┘
                      │                │
                      │   On Error     │
                      │◄───────────────┘
                      ▼
                 ┌──────────┐
                 │  Error   │
                 │ Message  │
                 └──────────┘

### Analogies

- This is similar to "Sign in with Google" on other apps, but scoped to your Auth0 tenant
- It's like a doorman who checks your Google badge before letting you into the building

---

**Is this understanding correct?**
```

## State Update After Validation

```json
{
  "reformulation": {
    "summary": "...",
    "userStories": ["..."],
    "diagram": "...",
    "analogies": ["..."],
    "validatedAt": "2024-01-15T11:00:00Z",
    "validationResponse": "yes_proceed",
    "corrections": null
  },
  "confidence": {
    "composite": 100
  },
  "gateStatus": "open"
}
```
