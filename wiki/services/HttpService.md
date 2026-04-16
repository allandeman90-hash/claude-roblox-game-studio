---
title: HttpService
type: service
category: services
subcategory: networking
owner: luau-systems-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/HttpService.md
related:
  - "[[open-cloud-api]]"
  - "[[RemoteEvent]]"
tags: [roblox-class, networking, server-only]
---

# HttpService

**Status:** stub

Server-only service for outbound HTTP requests and JSON utilities. Must be explicitly enabled per experience (Game Settings → Security → Allow HTTP Requests).

Key methods: `RequestAsync`, `GetAsync`, `PostAsync`, `JSONEncode`, `JSONDecode`, `GenerateGUID`.

Always wrap calls in `pcall`. Never expose HttpService access to the client (ReplicatedStorage path).

## Related

- [[open-cloud-api]]
- [[RemoteEvent]]

## Sources

- [wiki/raw/roblox-creator-docs/services/HttpService.md](../raw/roblox-creator-docs/services/HttpService.md)
