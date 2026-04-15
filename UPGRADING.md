# Upgrading Guide

This document tracks migration instructions for FoG Roblox Studio Command between versions.

## Current Version: 1.0.0

Initial release. No upgrade path needed yet.

## Version Philosophy

FoG Roblox Studio Command follows semantic versioning:

- **MAJOR** (1.x.x → 2.x.x) — Breaking changes to agent structure, skill contracts, or hook signatures
- **MINOR** (1.0.x → 1.1.x) — New agents, skills, templates, or non-breaking enhancements
- **PATCH** (1.0.0 → 1.0.1) — Bug fixes, documentation improvements, small tweaks

## Future Upgrade Format

Each version bump will add a section here documenting:

1. **What Changed** — List of agents/skills/hooks/rules added, modified, or removed
2. **Migration Steps** — Concrete actions to take in your existing project
3. **Breaking Changes** — Anything that requires updating project-specific configuration
4. **Deprecations** — Features marked for removal in future versions

## How to Upgrade

1. **Back up your project** — Commit everything first
2. **Review the changelog** — Understand what changed
3. **Update `.claude/` files** — Replace agents/skills/hooks/rules with new versions
4. **Preserve project-specific files** — Your `design/`, `src/`, `production/session-state/` stay intact
5. **Test a session** — Run `/start` or a common skill to verify the upgrade worked
6. **Commit the upgrade** — `chore: upgrade FoG Roblox Studio Command to vX.Y.Z`

## Getting Help

If you encounter issues upgrading:

- Check the release notes on GitHub
- Compare your `.claude/` directory against the template repo
- File an issue with the version numbers (from → to) and the error encountered
