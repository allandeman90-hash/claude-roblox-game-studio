---
title: code-redemption
type: concept
category: concepts
subcategory: live-ops
owner: live-ops-specialist
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/monetization/live-ops/promo-code-redemption.md
related:
  - "[[DataStoreService]]"
  - "[[rate-limiting]]"
  - "[[feature-flags]]"
tags: [concept, live-ops, marketing]
---

# Code Redemption

**Status: stub**

## Summary

Server-validated promotional code system. Players enter a code, the server checks if it's valid and unused for this player, grants the reward, and marks it as redeemed.

## TODO

- Two-DataStore de-dup pattern (master code list + per-player redemption history)
- Server-side validation (never trust client that a code is valid)
- Rate limiting to prevent brute-force
- Limited-use codes (first N users)
- Time-gated codes
- Marketing integration

## Related

- [[DataStoreService]]
- [[rate-limiting]]
- [[feature-flags]]

## Sources

- [wiki/raw/community/monetization/live-ops/promo-code-redemption.md](../raw/community/monetization/live-ops/promo-code-redemption.md)
