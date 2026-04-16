---
title: code-redemption
type: concept
category: concepts
subcategory: live-ops
owner: live-ops-specialist
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/monetization/live-ops/promo-code-redemption.md
  - wiki/raw/community/monetization/live-ops/liveops-essentials-cadence.md
related:
  - "[[DataStoreService]]"
  - "[[rate-limiting]]"
  - "[[feature-flags]]"
  - "[[code-redemption-system]]"
  - "[[ftue-design]]"
tags: [concept, live-ops, marketing, promo-codes]
---

# Code Redemption

> Server-validated promotional code system where players enter a code, the server verifies validity and uniqueness, grants the reward, and marks the code as redeemed for that player.

## What It Is

Code redemption is a live-ops tool that ties real-world marketing actions (watching a trailer, following on social media, attending a live event) to in-game rewards. The player enters a string code into a text input; the server validates it against a code list, checks that the player has not already redeemed it, and atomically grants the reward.

The concept is the "why and when." The implementation details are in [[code-redemption-system]].

## When to Use It

- **Social media campaigns.** "Follow us on Twitter, use code FOLLOW100 for 100 gems."
- **Content creator partnerships.** Each creator gets a unique code for their audience.
- **Milestone celebrations.** "We hit 1B visits! Use code BILLION for exclusive hat."
- **Event tie-ins.** Time-limited codes that expire after the event ends.
- **FTUE onboarding.** A starter code shown in the tutorial to teach the redemption UI and provide an immediate reward (see [[ftue-design]]).

## Key Design Decisions

### Two-DataStore De-Duplication

The standard architecture uses two DataStores:

1. **Code definitions** -- keyed by code string, value is reward metadata and active flag. Written by the developer, rarely changes.
2. **Per-player redemption history** -- keyed by `UserId:Code`, value is `true`. Written once per successful redemption.

This separation keeps code definitions independent of per-player history. The `UserId:Code` key format mirrors the `ProcessReceipt` idempotency pattern.

### Server-Side Validation

The server MUST validate every aspect of the code:

1. **Existence.** Is this a real code in the code list?
2. **Active flag.** Is the code currently enabled?
3. **Expiration.** Has the code expired (checked via `os.time()`)?
4. **Per-player uniqueness.** Has this player already redeemed this code (checked atomically via `UpdateAsync`)?
5. **Global cap.** Has the code reached its maximum total redemptions (optional, via a counter DataStore)?

The client NEVER determines whether a code is valid. It sends the raw string; the server does all checks.

### Rate Limiting

Without [[rate-limiting]], an exploiter can brute-force short codes. Limit the redemption remote to 1-2 attempts per second per player. Use 6-12 character alphanumeric codes to make brute-force infeasible.

### Code Management Approaches

| Approach | Pros | Cons |
|----------|------|------|
| **Hardcoded ModuleScript** | Simple, no external deps | Requires deploy to add codes |
| **DataStore-backed list** | Add codes via Open Cloud without restart | More complex, consumes budget |
| **HttpService + external API** | Most flexible, dashboard-ready | Requires external infrastructure |
| **Feature flag + code list** | Toggle codes live via [[feature-flags]] | Moderate complexity |

### Code Lifecycle

```
Create -> Publish (active=true) -> Redeem period -> Expire/Deactivate -> Archive
```

- **Create:** Developer adds code to the code list with reward definition.
- **Publish:** Code goes live (active flag set, optionally announced on social).
- **Redeem:** Players enter the code; server validates and grants.
- **Expire/Deactivate:** After the campaign ends, set `active = false` or let `expiresAt` pass.
- **Archive:** Old codes can be removed from the active list but redemption records persist.

## Pitfalls

- **Normalization.** Always normalize input (uppercase, strip whitespace) so `summer2026`, `SUMMER2026`, and ` Summer 2026 ` all resolve to the same code.
- **Global cap rollback.** If the global cap check succeeds but a subsequent step fails, roll back the cap counter. Otherwise, the code appears exhausted when it is not.
- **Hot-keying during spikes.** A viral code announcement causes thousands of simultaneous redemptions. The `UserId:Code` key format spreads writes across many DataStore keys, but the global cap counter is a single key. Use `UpdateAsync` for atomic increment.
- **Code length vs. guessability.** Short codes (3-4 chars) are easy to type but easy to brute-force. 8+ alphanumeric characters provide ~41 bits of entropy, making random guessing impractical even without rate limiting.

## Related

- [[code-redemption-system]] -- full implementation pattern with code examples
- [[DataStoreService]] -- persistence for redemption tracking
- [[rate-limiting]] -- prevents brute-force code enumeration
- [[feature-flags]] -- toggle codes active/inactive live
- [[ftue-design]] -- starter code as part of first-session experience

## Sources

- [wiki/raw/community/monetization/live-ops/promo-code-redemption.md](../raw/community/monetization/live-ops/promo-code-redemption.md)
- [wiki/raw/community/monetization/live-ops/liveops-essentials-cadence.md](../raw/community/monetization/live-ops/liveops-essentials-cadence.md)
