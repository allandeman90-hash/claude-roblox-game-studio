---
title: dev-product
type: monetization
category: monetization
subcategory: devproduct
owner: monetization-lead
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/monetization/devproduct/processreceipt-idempotency-pattern.md
  - wiki/raw/community/monetization/devproduct/devproduct-setup-and-lifecycle.md
related:
  - "[[MarketplaceService]]"
  - "[[process-receipt-idempotency]]"
  - "[[transaction-replay]]"
tags: [monetization]
---

# DevProduct

**Status:** stub

## Summary

Consumable, repeatable purchases. Best for currency packs, revives, boosts. Processed via `MarketplaceService.ProcessReceipt` — must be idempotent (see [[process-receipt-idempotency]]). Price range: 1 R$ to 1,000,000,000 R$.

## TODO

- Setup workflow via Creator Dashboard
- Pricing strategy
- ReceiptInfo fields reference
- Retry semantics
- Test mode on Studio
- Per-product grant functions

## Related

- [[MarketplaceService]]
- [[process-receipt-idempotency]]
- [[transaction-replay]]

## Sources

- [wiki/raw/community/monetization/devproduct/processreceipt-idempotency-pattern.md](../raw/community/monetization/devproduct/processreceipt-idempotency-pattern.md)
