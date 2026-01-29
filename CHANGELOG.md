# Changelog

All notable changes to x-workflows will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

---

## [0.3.1] - 2026-01-29

### Removed
- **x-deploy skill** - orphan skill with no command routing
- **x-monitor skill** - orphan skill with no command routing
- x-deploy/x-monitor triggers from interview skill

### Added
- **Security review mode** for x-review (`/x-review security`)
- OWASP Top 10 checklist in mode-security.md

### Fixed
- Broken references to non-existent core-docs subdirectories
- Interview confidence-model.md example now uses x-git release

---

## [0.3.0] - 2026-01-28

### Added
- validate-rules.sh script and project context
- Core Workflow vs Behavioral skill type documentation
- Modular `.claude/rules/` directory structure
- x-prompt skill for prompt enhancement

### Changed
- Pareto optimization: reduce redundancy and clarify structure
- Integrate Phase 0 interview check in all mode references

---

## [0.1.0] - 2026-01-26

### Added
- **19 workflow skills** for AI-assisted development:
  - x-implement, x-plan, x-verify, x-review, x-git, x-improve, and more
- Mode references and agent documentation
- Explicit workflow-to-knowledge skill mapping
- 3-repo Swiss Watch design reference documentation
- Universal Interview System behavioral skill

### Changed
- Consolidate x-improve duplication via delegation
- Make workflow skills self-contained (M8)

---

[Unreleased]: https://github.com/CorentinLumineau/x-workflows/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/CorentinLumineau/x-workflows/releases/tag/v0.1.0
