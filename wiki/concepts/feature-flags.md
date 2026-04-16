---
title: feature-flags
type: concept
category: concepts
subcategory: live-ops
owner: live-ops-specialist
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/monetization/live-ops/configs-and-experiments.md
  - wiki/raw/community/monetization/live-ops/feature-flag-pattern-github-json.md
related:
  - "[[cross-server-events]]"
  - "[[code-redemption]]"
tags: [concept, live-ops]
---

# Feature Flags

**Status: stub** — flesh out from captured monetization/live-ops raw sources.

## Summary

Remote-configurable toggles that enable/disable features without a code deploy. Roblox now provides first-party Configs + Experiments; community pattern uses `HttpService` + a GitHub raw JSON file for emergency kill-switches independent of Roblox backend.

## TODO

- Roblox Configs API
- GitHub JSON + HttpService polling pattern
- When to use first-party vs community
- Client-side vs server-side flags
- Safe rollout strategies (percentage, whitelist, canary)
- Flag lifecycle (create → roll out → retire)

## Related

- [[cross-server-events]]
- [[code-redemption]]

## Sources

- [wiki/raw/community/monetization/live-ops/configs-and-experiments.md](../raw/community/monetization/live-ops/configs-and-experiments.md)
- [wiki/raw/community/monetization/live-ops/feature-flag-pattern-github-json.md](../raw/community/monetization/live-ops/feature-flag-pattern-github-json.md)
