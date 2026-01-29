# Confidence Model

> **Purpose**: Adaptive dimension scoring with workflow-specific weights.

## Overview

The confidence model uses 5 dimensions to assess understanding. Each dimension is scored 0-100%, and a weighted composite determines overall confidence. Different workflows weight dimensions differently based on their risk profile.

## Dimensions

| Dimension | Description | Key Questions |
|-----------|-------------|---------------|
| **Problem Understanding** | What the user wants to achieve | What's the goal? What's the pain point? |
| **Context Completeness** | Background, constraints, dependencies | What exists? What can't change? What depends on this? |
| **Technical Clarity** | Implementation details, edge cases | How should it work? What about X scenario? |
| **Scope Definition** | Boundaries, in/out of scope | What's included? What's explicitly excluded? |
| **Risk Awareness** | Consequences, alternatives considered | What could go wrong? What's the rollback plan? |

## Workflow Weight Profiles

Different workflows prioritize different dimensions:

| Workflow | Problem | Context | Technical | Scope | Risk |
|----------|---------|---------|-----------|-------|------|
| **x-plan brainstorm** | 40% | 30% | 10% | 15% | 5% |
| **x-plan design** | 20% | 15% | 40% | 10% | 15% |
| **x-plan analyze** | 25% | 35% | 20% | 15% | 5% |
| **x-implement** | 25% | 20% | 30% | 15% | 10% |
| **x-implement fix** | 30% | 25% | 25% | 10% | 10% |
| **x-implement refactor** | 20% | 25% | 30% | 15% | 10% |
| **x-troubleshoot** | 30% | 30% | 25% | 5% | 10% |
| **x-git commit** | 20% | 25% | 20% | 25% | 10% |
| **x-git release** | 15% | 10% | 20% | 15% | **40%** |
| **x-verify** | 25% | 20% | 30% | 15% | 10% |
| **x-review** | 20% | 25% | 30% | 15% | 10% |
| **x-improve** | 25% | 25% | 25% | 15% | 10% |
| **x-initiative create** | 35% | 25% | 15% | 20% | 5% |
| **x-docs** | 25% | 30% | 20% | 20% | 5% |

## Confidence Thresholds

| Range | Status | Action |
|-------|--------|--------|
| **0-49%** | Insufficient | Basic discovery questions |
| **50-79%** | Partial | Research between questions |
| **80-94%** | High | Reformulation for validation |
| **95-99%** | Near-complete | Final confirmation |
| **100%** | Complete | Proceed with action |

## Composite Calculation

```
composite = Σ (dimension_score × dimension_weight)
```

Example for `x-git release`:
```
problem: 80 × 0.15 = 12.0
context: 90 × 0.10 =  9.0
technical: 85 × 0.20 = 17.0
scope: 75 × 0.15 = 11.25
risk: 60 × 0.40 = 24.0
─────────────────────────
composite = 73.25%
```

## Dimension Scoring Guidelines

### Problem Understanding (0-100%)

| Score | Indicator |
|-------|-----------|
| 0-25% | Only vague goal mentioned |
| 25-50% | Goal clear, success criteria unclear |
| 50-75% | Goal and criteria clear, motivation unclear |
| 75-100% | Full clarity on goal, criteria, and why |

### Context Completeness (0-100%)

| Score | Indicator |
|-------|-----------|
| 0-25% | No background provided |
| 25-50% | Some context, major gaps |
| 50-75% | Most context known, some dependencies unclear |
| 75-100% | Full context including constraints and dependencies |

### Technical Clarity (0-100%)

| Score | Indicator |
|-------|-----------|
| 0-25% | No technical details |
| 25-50% | High-level approach, implementation unclear |
| 50-75% | Implementation clear, edge cases uncertain |
| 75-100% | Full technical clarity including edge cases |

### Scope Definition (0-100%)

| Score | Indicator |
|-------|-----------|
| 0-25% | Scope completely undefined |
| 25-50% | Rough boundaries, many gray areas |
| 50-75% | Clear in-scope, out-of-scope partially defined |
| 75-100% | Explicit boundaries with documented exclusions |

### Risk Awareness (0-100%)

| Score | Indicator |
|-------|-----------|
| 0-25% | No risk consideration |
| 25-50% | Risks acknowledged, no mitigation |
| 50-75% | Major risks identified with basic mitigation |
| 75-100% | Full risk analysis with rollback plan |

## Updating Scores

After each user answer:

1. **Identify impacted dimensions** - Which dimensions does this answer inform?
2. **Calculate delta** - How much does confidence increase?
3. **Apply caps** - No single answer can increase a dimension by more than 30%
4. **Recalculate composite** - Apply workflow weights
5. **Determine next action** - Based on new threshold

## Confidence State Schema

```json
{
  "confidence": {
    "problem": 85,
    "context": 70,
    "technical": 60,
    "scope": 90,
    "risk": 50,
    "composite": 71,
    "weights": {
      "problem": 0.25,
      "context": 0.20,
      "technical": 0.30,
      "scope": 0.15,
      "risk": 0.10
    }
  }
}
```
