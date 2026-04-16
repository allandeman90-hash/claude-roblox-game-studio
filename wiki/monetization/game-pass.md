---
title: game-pass
type: monetization
category: monetization
subcategory: gamepass
owner: monetization-lead
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/monetization/gamepass/pricing-strategy.md
  - wiki/raw/community/monetization/gamepass/gamepass-setup-and-verification.md
related:
  - "[[MarketplaceService]]"
  - "[[dev-product]]"
  - "[[robux-price-tiers]]"
  - "[[ethical-monetization]]"
tags: [monetization]
---

# GamePass

**Status:** stub

## Summary

Permanent, one-time purchases. Best for VIP passes, cosmetic bundles, convenience features. Typical prices: 49, 99, 199, 499, 999, 1999, 4999 Robux. Check ownership with `MarketplaceService:UserOwnsGamePassAsync`.

Pricing charm values (from captured research): 49 / 99 / 199 / 499 / 999 / 4999 Robux are the "sweet spots" — above common Robux balances after a purchase tier.

## TODO

- Full dual-path grant pattern (UserOwnsGamePassAsync on join + PromptGamePassPurchaseFinished on live purchase)
- Pricing strategy deep dive
- Pay-to-win checks
- Cache UserOwnsGamePassAsync results
- Relation to Premium Benefits

## Related

- [[MarketplaceService]]
- [[dev-product]]
- [[robux-price-tiers]]
- [[ethical-monetization]]

## Sources

- [wiki/raw/community/monetization/gamepass/pricing-strategy.md](../raw/community/monetization/gamepass/pricing-strategy.md)
- [wiki/raw/community/monetization/gamepass/gamepass-setup-and-verification.md](../raw/community/monetization/gamepass/gamepass-setup-and-verification.md)
