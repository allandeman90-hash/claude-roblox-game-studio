---
title: Monetization, Live Ops, Publishing, Open Cloud - Index
type: index
captured_at: 2026-04-16
captured_by: research-agent-10
---

# Monetization, Live Ops, Publishing, Open Cloud — Index

Captured sources for Roblox monetization, live operations, publishing
workflow, Open Cloud APIs, analytics, community strategy, and ethics.
All files are in `raw/community/monetization/<subcategory>/`.

## gamepass/

- [gamepass-setup-and-verification.md](./gamepass/gamepass-setup-and-verification.md)
  — UserOwnsGamePassAsync + PromptGamePassPurchaseFinished dual-path
  pattern, caching, product info
- [pricing-strategy.md](./gamepass/pricing-strategy.md) — Charm pricing,
  tiered ladder (49 → 4999 R$), anchoring, 30% platform fee math,
  revenue parabola optimization

## devproduct/

- [processreceipt-idempotency-pattern.md](./devproduct/processreceipt-idempotency-pattern.md)
  — The canonical ProcessReceipt + DataStore-backed de-dup pattern,
  pcall ordering, NotProcessedYet retry semantics
- [devproduct-setup-and-lifecycle.md](./devproduct/devproduct-setup-and-lifecycle.md)
  — Create product, price limits (1 R$ – 1B R$), test mode, external
  sales, PromptProductPurchase, handler tables
- [receiptinfo-reference.md](./devproduct/receiptinfo-reference.md) —
  Full receiptInfo field reference (PurchaseId, PlayerId, ProductId,
  PlaceIdWherePurchased, CurrencySpent, CurrencyType), retry cadence,
  multi-place gotcha

## premium-payouts/

- [devex-rates-and-economics.md](./premium-payouts/devex-rates-and-economics.md)
  — Old ($0.0035) vs new ($0.0038) DevEx rate, 30,000 R$ cash-out min
  ($114 USD), 30% platform cut, regional pricing uplift, Paid Access
  revenue shares (60/70%)
- [engagement-based-payouts-and-creator-rewards.md](./premium-payouts/engagement-based-payouts-and-creator-rewards.md)
  — EBP deprecation (July 24, 2025), Creator Rewards replacement,
  5 R$ per Active Spender session, 35% audience expansion share
- [in-experience-subscriptions.md](./premium-payouts/in-experience-subscriptions.md)
  — GetUserSubscriptionStatusAsync, PromptSubscriptionPurchase, 70%
  month-1 / 100% month-2+ local-currency share, 70% always on Robux,
  50 subs max per experience

## live-ops/

- [configs-and-experiments.md](./live-ops/configs-and-experiments.md) —
  First-party remote config, 1000-config cap, 10 concurrent experiments,
  5-minute propagation, A/B testing framework, MDE
- [feature-flag-pattern-github-json.md](./live-ops/feature-flag-pattern-github-json.md)
  — HttpService + GitHub raw JSON pattern, FFlag vs DFFlag, 5-minute
  poll loop, MessagingService for instant invalidate
- [liveops-essentials-cadence.md](./live-ops/liveops-essentials-cadence.md)
  — Content cadence (weekly–monthly), 3-week max effort per drop,
  major-update categories, 12-month content calendar template
- [memorystore-cross-server-patterns.md](./live-ops/memorystore-cross-server-patterns.md)
  — Queue/SortedMap/HashMap patterns, code examples, TTL, use cases
- [memorystore-best-practices.md](./live-ops/memorystore-best-practices.md)
  — Partition-aware sharding (alphabetic, revolving queues, hot-key
  split), field-per-key HashMap, TTL guidance, quota model
- [messagingservice-in-game-patterns.md](./live-ops/messagingservice-in-game-patterns.md)
  — PublishAsync/SubscribeAsync, 80-char topics, 1 KiB payload,
  50 + 5 × player rate limit, fan-out patterns
- [promo-code-redemption.md](./live-ops/promo-code-redemption.md) —
  Two-DataStore pattern (codes + per-player), UpdateAsync atomic
  de-dup, global-cap increment, expiration, handler example

## publishing/

- [bindtoclose-deployment.md](./publishing/bindtoclose-deployment.md) —
  30-second hard budget, parallel saves, Studio gate, ProfileStore
  EndSession pattern, session-lock discipline
- [universe-place-structure.md](./publishing/universe-place-structure.md)
  — Experience vs Place, start place swap, 48-hour account gate,
  5 private→public per day, Beta mode, API-publish instance-type caveat
- [device-testing-emulator.md](./publishing/device-testing-emulator.md)
  — Studio Test/Test Here/Server & Clients, Device Emulator (iPhone
  /iPad/Android), Controller Emulator, VR Emulator (Meta Quest 2/3),
  Touch Simulation, Player Emulator, Team Test

## open-cloud/

- [datastore-api-v1-reference.md](./open-cloud/datastore-api-v1-reference.md)
  — REST endpoints (List/Get/Set/Increment/Delete/Versions), rate
  limits (300 rpm, 10/20 MB), content-md5 checksum, field constraints,
  matchVersion optimistic lock, curl + python examples
- [messaging-service-api.md](./open-cloud/messaging-service-api.md) —
  publishMessage endpoint, OAuth + API key auth, rate limit
  (50 + 5 × players/min), 80-char topic / 1 KiB payload limits
- [place-publishing-cicd-github-actions.md](./open-cloud/place-publishing-cicd-github-actions.md)
  — Complete Rojo + rbxcloud + StyLua + Selene pipeline, ci.yaml /
  deploy_staging / deploy_prod templates, Luau Execution 2-concurrent
  cap, API key setup, instance types that block API publish
- [assets-api-upload.md](./open-cloud/assets-api-upload.md) — Upload
  / update assets, per-type quotas (100 audio/mo, 20 video/day),
  20 MB per request, supported formats, operation polling, moderation
  states
- [oauth2-authentication.md](./open-cloud/oauth2-authentication.md) —
  PKCE flow, scope list (openid, profile, asset:read/write,
  universe-places:write, universe-datastores.objects:read/write),
  endpoints, registration flow

## analytics/

- [key-metrics-and-arpdau.md](./analytics/key-metrics-and-arpdau.md) —
  DAU/MAU, retention (D1/D7/D30), conversion rate, ARPPU, ARPDAU
  formula, benchmark table (0.1–8 R$), retention curves, platform
  stats (111.8M DAU, 380M MAU)
- [custom-events-analyticsservice.md](./analytics/custom-events-analyticsservice.md)
  — LogCustomEvent API, 100-event cap, server-only, custom fields
  over name proliferation, funnel logging, 7 dashboard aggregations

## community-strategy/

- [discover-algorithm-ranking-factors.md](./community-strategy/discover-algorithm-ranking-factors.md)
  — 8 ranking metrics (qPTR, Deep-PTR, 7D playtime capped at 60
  min/day, play-days, spend-days, co-play), organic-only attribution,
  metadata deranking rules, retrieval → ranking
- [discord-marketing-playbook.md](./community-strategy/discord-marketing-playbook.md)
  — Server structure, Discord targeting (3k–20k members),
  content-creator partnerships, TikTok / YT / Twitch / Reels rank,
  partnership economics ($10–25 CPM), CPA < LTV rule

## ethics/

- [ethical-monetization-principles.md](./ethics/ethical-monetization-principles.md)
  — Save-time-not-gate-content principle, 20–30% power-differential
  cap, healthy vs unhealthy FOMO, age-appropriate guardrails, COPPA
  context, why ethics is profitable
- [paid-random-items-policy.md](./ethics/paid-random-items-policy.md)
  — Roblox mandatory odds disclosure (30%+ example), direct + indirect
  payment rule, Belgium ban, UK 18+ restriction, weighted chance
  system Luau code, pity system wrapper

## Key cross-references

- `processreceipt-idempotency-pattern.md` ↔ `devproduct-setup-and-lifecycle.md`
  ↔ `receiptinfo-reference.md` — read together for complete DevProduct flow
- `ethical-monetization-principles.md` ↔ `paid-random-items-policy.md`
  ↔ `gamepass/pricing-strategy.md` — monetization design principles
- `memorystore-cross-server-patterns.md` ↔ `memorystore-best-practices.md`
  — start with patterns, then read best-practices before shipping
- `configs-and-experiments.md` ↔ `feature-flag-pattern-github-json.md`
  — Roblox-native vs self-managed feature flags; use both
- `discover-algorithm-ranking-factors.md` ↔ `key-metrics-and-arpdau.md`
  ↔ `discord-marketing-playbook.md` — growth and discovery loop
- `bindtoclose-deployment.md` ↔ `place-publishing-cicd-github-actions.md`
  ↔ `universe-place-structure.md` — full deployment chain
- `datastore-api-v1-reference.md` ↔ `oauth2-authentication.md` —
  auth + DataStore access for admin tools

## Total files: 29

Grouped: gamepass (2) · devproduct (3) · premium-payouts (3) ·
live-ops (7) · publishing (3) · open-cloud (5) · analytics (2) ·
community-strategy (2) · ethics (2) + INDEX.md
