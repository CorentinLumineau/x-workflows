---
name: x-deploy
description: |
  Deployment workflows with rollback support. Deploy to environments, manage rollbacks.
  Activate when deploying applications, managing environments, or handling rollbacks.
  Triggers: deploy, deployment, rollback, release to, push to production, staging.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---

# x-deploy

Deployment workflows with environment management and rollback support.

## Modes

| Mode | Description |
|------|-------------|
| deploy (default) | Deploy to environment |
| rollback | Rollback to previous version |
| status | Check deployment status |

## Mode Detection
| Keywords | Mode |
|----------|------|
| "rollback", "revert", "previous version" | rollback |
| "status", "check deployment", "what's deployed" | status |
| (default) | deploy |

## Execution
- **Default mode**: deploy
- **No-args behavior**: Ask for target environment

## Behavioral Skills

This workflow activates these behavioral skills:

### Always Active
- `interview` - Zero-doubt confidence gate (Phase 0, CRITICAL for production)
- `infrastructure` - IaC patterns, Docker, Terraform

### Context-Triggered
| Skill | Trigger Conditions |
|-------|-------------------|
| `container-security` | Container deployments |
| `ci-cd` | Pipeline deployments |

## Environments

| Environment | Purpose | Approval |
|-------------|---------|----------|
| development | Testing | None |
| staging | Pre-production | Optional |
| production | Live | Required |

## Deployment Workflow

```
1. Verify build passes
2. Identify target environment
3. Check for approval (if required)
4. Deploy to environment
5. Run smoke tests
6. Monitor for issues
7. Rollback if problems detected
```

## Safety Rules

**NEVER:**
- Deploy to production without explicit approval
- Skip verification steps
- Deploy untested code

**ALWAYS:**
- Run smoke tests after deployment
- Have rollback plan ready
- Monitor post-deployment

## Rollback Procedure

```
1. Identify failing deployment
2. Determine rollback target (previous stable)
3. Execute rollback
4. Verify system stability
5. Investigate root cause
```

## Pre-Deployment Checklist

- [ ] All tests pass
- [ ] Build succeeds
- [ ] Environment configured
- [ ] Approval obtained (if production)
- [ ] Rollback plan documented

## Post-Deployment Checklist

- [ ] Smoke tests pass
- [ ] Monitoring alerts clear
- [ ] Key functionality verified
- [ ] Stakeholders notified

## Environment Configuration

```yaml
environments:
  development:
    approval: none
    tests: basic
  staging:
    approval: optional
    tests: full
  production:
    approval: required
    tests: full + smoke
```

## When to Load References

- **For deploy mode**: See `references/mode-deploy.md`
- **For rollback mode**: See `references/mode-rollback.md`
- **For status mode**: See `references/mode-status.md`
