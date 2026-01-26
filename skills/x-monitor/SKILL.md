---
name: x-monitor
description: |
  Monitoring setup and alerting configuration. Set up observability, define alerts.
  Activate when setting up monitoring, configuring alerts, or analyzing metrics.
  Triggers: monitor, monitoring, alert, metrics, observability, dashboard, slo.
license: Apache-2.0
compatibility: Works with Claude Code, Cursor, Cline, and any skills.sh agent.
allowed-tools: Read Write Edit Grep Glob Bash
metadata:
  author: ccsetup contributors
  version: "1.0.0"
  category: workflow
---

# x-monitor

Monitoring setup and alerting configuration for observability.

## Modes

| Mode | Description |
|------|-------------|
| setup (default) | Set up monitoring infrastructure |
| alert | Configure alerting rules |
| dashboard | Create monitoring dashboards |

## Mode Detection

Scan user input for keywords:

| Keywords | Mode |
|----------|------|
| "alert", "alerting", "notify", "pagerduty" | alert |
| "dashboard", "visualization", "grafana" | dashboard |
| (default) | setup |

## Execution

1. **Detect mode** from user input
2. **If no valid mode detected**, use default (setup)
3. **If no arguments provided**, analyze current monitoring state
4. **Load mode instructions** from `references/`
5. **Follow instructions** completely

## Behavioral Skills

This workflow activates these knowledge skills:

### Always Active
- `monitoring` - Golden signals, SLOs, observability

### Context-Triggered
| Skill | Trigger Conditions |
|-------|-------------------|
| `incident-response` | Alert configuration, runbooks |

## Three Pillars of Observability

| Pillar | Purpose | Tools |
|--------|---------|-------|
| Metrics | Numerical measurements | Prometheus, Datadog |
| Logs | Event records | ELK, Loki |
| Traces | Request flows | Jaeger, Zipkin |

## Golden Signals

Monitor these signals for every service:

| Signal | What to Measure |
|--------|-----------------|
| Latency | Response time (p50, p95, p99) |
| Traffic | Requests per second |
| Errors | Error rate percentage |
| Saturation | Resource utilization |

## SLO Framework

| Term | Definition | Example |
|------|------------|---------|
| SLI | Service Level Indicator | p99 latency = 200ms |
| SLO | Service Level Objective | 99.9% requests < 200ms |
| SLA | Service Level Agreement | Contractual SLO |

## Alerting Strategy

| Alert Type | When | Action |
|------------|------|--------|
| Page | Service degraded | Immediate response |
| Notify | Needs attention | Review during hours |
| Log | Informational | No action required |

## Alert Best Practices

**DO:**
- Alert on symptoms (user impact)
- Include runbook link
- Make alerts actionable

**DON'T:**
- Alert on causes (underlying metrics)
- Create noisy alerts (alert fatigue)
- Page for non-urgent issues

## Dashboard Essentials

| Dashboard | Metrics |
|-----------|---------|
| Service health | Error rate, latency, traffic |
| Infrastructure | CPU, memory, disk, network |
| Business | Conversions, active users |
| Dependencies | External service health |

## Setup Checklist

- [ ] Golden signals monitored
- [ ] SLOs defined and tracked
- [ ] Alerts configured and actionable
- [ ] Runbooks linked to alerts
- [ ] Dashboards created
- [ ] Log aggregation set up
- [ ] Tracing enabled

## When to Load References

- **For setup mode**: See `references/mode-setup.md`
- **For alert mode**: See `references/mode-alert.md`
- **For dashboard mode**: See `references/mode-dashboard.md`
