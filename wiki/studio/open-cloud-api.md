---
title: open-cloud-api
type: studio
category: studio
subcategory: deployment
owner: devops-engineer
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/monetization/open-cloud/datastore-api-v1-reference.md
  - wiki/raw/community/monetization/open-cloud/place-publishing-cicd-github-actions.md
related:
  - "[[DataStoreService]]"
  - "[[MessagingService]]"
tags: [studio, deployment, api]
---

# Open Cloud API

**Status:** stub

## Summary

REST APIs that let external tools interact with Roblox experiences without running inside the game:

- **Place Publishing API** — `POST /universes/v1/{universeId}/places/{placeId}/versions` — publish from CI/CD
- **DataStore API v1/v2** — read/write DataStores from outside Studio
- **Messaging Service API** — publish to `MessagingService` topics from external scripts
- **Assets API** — upload images, meshes, audio
- **Luau Execution API** — run Luau in a cloud sandbox

Authentication via API keys with scoped permissions.

## TODO

- Authentication (API keys, OAuth2 PKCE)
- Rate limits per API
- Example curl for common operations
- CI/CD integration with GitHub Actions + Rojo

## Related

- [[DataStoreService]]
- [[MessagingService]]

## Sources

- [wiki/raw/community/monetization/open-cloud/datastore-api-v1-reference.md](../raw/community/monetization/open-cloud/datastore-api-v1-reference.md)
- [wiki/raw/community/monetization/open-cloud/place-publishing-cicd-github-actions.md](../raw/community/monetization/open-cloud/place-publishing-cicd-github-actions.md)
