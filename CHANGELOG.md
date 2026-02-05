# Changelog

All notable changes to x-workflows will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

---

## [1.0.1] - 2026-02-04

### Changed
- Convert multi-line skill descriptions to single-line format for better tool compatibility

---

## [1.0.0] - 2026-02-04

### Added
- **Verb-first refactoring** with 4 canonical workflows:
  - **APEX**: Full development cycle (analyze → plan → implement → verify)
  - **ONESHOT**: Quick implementation (plan → implement)
  - **DEBUG**: Issue resolution (troubleshoot → fix → verify)
  - **BRAINSTORM**: Ideation flow (brainstorm → research → design)

### Changed
- All x-skills now follow verb-first naming convention
- Workflow chaining patterns standardized across all skills

---

## [0.4.0] - 2026-02-03

### Added
- **Auto-routing** capabilities for intelligent skill selection
- **Doc-sync** enhancements for documentation lifecycle management

### Changed
- Improved skill delegation patterns

---

## [0.3.2] - 2026-01-30

### Added
- **Semantic action tags** to priority skills for improved categorization

### Changed
- Swiss Watch workflow layer now has 15 skills

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

## [0.3.0] - 2026-01-29

### Added
- Swiss Watch workflow layer with 15 skills

### Changed
- DRY consolidation and documentation updates
- Remove duplicate persistence refs from x-initiative, reference canonical patterns

---

## [0.2.0] - 2026-01-28

### Added
- validate-rules.sh script and project context
- Core Workflow vs Behavioral skill type documentation
- Modular `.claude/rules/` directory structure
- x-prompt skill for prompt enhancement
- Universal Interview System behavioral skill
- 3-repo Swiss Watch design reference documentation
- Explicit workflow-to-knowledge skill mapping

### Changed
- Pareto optimization: reduce redundancy and clarify structure
- Integrate Phase 0 interview check in all mode references
- Consolidate x-improve duplication via delegation
- Make workflow skills self-contained (M8)

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

[Unreleased]: https://github.com/CorentinLumineau/x-workflows/compare/v1.0.1...HEAD
[1.0.1]: https://github.com/CorentinLumineau/x-workflows/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/CorentinLumineau/x-workflows/compare/v0.4.0...v1.0.0
[0.4.0]: https://github.com/CorentinLumineau/x-workflows/compare/v0.3.2...v0.4.0
[0.3.2]: https://github.com/CorentinLumineau/x-workflows/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/CorentinLumineau/x-workflows/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/CorentinLumineau/x-workflows/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/CorentinLumineau/x-workflows/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/CorentinLumineau/x-workflows/releases/tag/v0.1.0
