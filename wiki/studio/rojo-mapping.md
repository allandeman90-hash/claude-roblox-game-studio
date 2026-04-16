---
title: rojo-mapping
type: studio
category: studio
subcategory: tooling
owner: devops-engineer
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/articles/tooling/rojo-readme.md
related:
  - "[[client-server-split]]"
tags: [studio, tooling]
---

# Rojo Mapping

**Status:** stub

## Summary

Rojo syncs a file system directory to Roblox Studio's DataModel. Files and folders become Scripts, LocalScripts, ModuleScripts, and Instances based on naming conventions.

File name suffixes:
- `foo.server.lua(u)` → Script
- `foo.client.lua(u)` → LocalScript
- `foo.lua(u)` → ModuleScript
- `init.lua(u)` in a folder → ModuleScript, folder becomes the instance
- `init.server.lua(u)` in a folder → Script, folder becomes the instance

Configured via `default.project.json` mapping `src/` subdirectories to Roblox services.

## TODO

- Full project.json reference
- Running `rojo serve` for live sync
- Building `.rbxlx` for publish
- Open Cloud publish via `rojo upload`
- Comparison with Argon

## Related

- [[client-server-split]]

## Sources

- [wiki/raw/community/articles/tooling/rojo-readme.md](../raw/community/articles/tooling/rojo-readme.md)
