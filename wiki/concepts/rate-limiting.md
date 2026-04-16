---
title: rate-limiting
type: concept
category: concepts
subcategory: security
owner: remotes-networking-specialist
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - .claude/agents/remotes-networking-specialist.md
  - .claude/rules/remotes.md
related:
  - "[[server-authority]]"
  - "[[RemoteEvent]]"
  - "[[remote-spam]]"
  - "[[no-rate-limit]]"
tags: [concept, security, required]
---

# Rate Limiting

> The server-side pattern that caps how often a player can trigger a remote, preventing spam attacks and runaway operations.

## What It Is

Rate limiting is a per-player, per-remote cap: "player X can call remote Y at most N times per second." When exceeded, extra calls are silently dropped (no error, no response — just ignored).

It's one of the two security layers around every client → server `RemoteEvent`:
1. **Validation** — type, range, sanity
2. **Rate limit** — not too many of them

Both are required. Neither alone is sufficient.

## Why It Matters

Without rate limiting, an exploiter can spam a remote at tens of thousands of calls per second:
- **DoS the server**: each call may allocate, hit the DataStore, or run a heavy path
- **Burn DataStore budget**: save spam exhausts the quota for legitimate players
- **Exploit race conditions**: rapid-fire writes may bypass validation that assumes single-threaded access
- **Unbalance the economy**: even a valid remote can be used to farm 10,000 rewards in a second

Rate limiting closes all these attacks with one simple pattern.

## Implementation

### Sliding Window (simple, robust)

```lua
local RATE_LIMIT_PER_SECOND = 10
local playerCalls: {[Player]: {number}} = {}

local function isRateLimited(player: Player): boolean
    local now = os.clock()
    playerCalls[player] = playerCalls[player] or {}
    local calls = playerCalls[player]

    -- Remove calls older than 1 second
    while #calls > 0 and calls[1] < now - 1 do
        table.remove(calls, 1)
    end

    if #calls >= RATE_LIMIT_PER_SECOND then
        return true  -- limit hit, reject
    end

    table.insert(calls, now)
    return false
end

-- Usage in a remote handler
Remotes.PurchaseItem.OnServerEvent:Connect(function(player, itemId)
    if isRateLimited(player) then return end
    -- ... rest of validation and handler ...
end)

-- Cleanup on leave
game.Players.PlayerRemoving:Connect(function(player)
    playerCalls[player] = nil
end)
```

### Token Bucket (for bursty patterns)

For remotes where occasional bursts are legitimate (e.g., UI refreshes), a token bucket allows short bursts up to `burst`, then refills at `rate`:

```lua
local buckets: {[Player]: {tokens: number, last: number}} = {}
local BURST = 20
local REFILL_PER_SEC = 5

local function tryConsume(player: Player): boolean
    local now = os.clock()
    local b = buckets[player]
    if not b then
        b = { tokens = BURST, last = now }
        buckets[player] = b
    end
    -- Refill
    local elapsed = now - b.last
    b.tokens = math.min(BURST, b.tokens + elapsed * REFILL_PER_SEC)
    b.last = now
    -- Consume
    if b.tokens >= 1 then
        b.tokens -= 1
        return true
    end
    return false
end
```

### Per-Remote Limits

Different remotes have different budgets. A purchase remote may want 5/sec; a chat message remote may want 2/sec; a quest objective completion remote 20/sec. Maintain a table of limits:

```lua
local LIMITS = {
    PurchaseItem = 5,
    ChatMessage = 2,
    StartAttack = 10,
    UseAbility = 5,
    RequestInventory = 1,
}
```

Or, build a rate-limit helper that takes the remote name as a parameter.

## When to Use

**Every client → server RemoteEvent** must be rate-limited. There are no exceptions.

Server → client messages don't need rate limiting in this sense (the server controls the flow), but they may need **bandwidth budgeting** — which is a different concern (see [[bandwidth-budget]]).

## Variants

- **Sliding window** — tracks last-N call timestamps; accurate but stores state per call
- **Token bucket** — allows bursts, smoother for legitimate high-frequency workloads
- **Fixed window** — simpler but has boundary effects (2x rate near window edges)
- **Global + per-player** — layer two limits: per-player for individuals, global for the whole server

Use sliding window or token bucket for 99% of cases.

## Pitfalls

- **Forgetting cleanup on `PlayerRemoving`**: per-player tables leak memory over time. Always drop entries on leave.
- **Storing in `ReplicatedStorage` or a global table exposed to `LocalPlayer`**: defeats the point — exploiter could reset the counter. Keep rate-limit state in a server-only module.
- **Same limit for all remotes**: too tight on chat, too loose on purchase. Differentiate.
- **Error on limit hit**: don't `error()` or respond with a warning; silently drop. Errors leak information and break the handler.
- **No `task.wait` before retry**: exploiters iterate tight loops; silent drop is the right response.
- **Limit too generous**: allows enough throughput for an exploit. Err lower than you think.
- **Limit too tight**: legitimate player with lag or a queued click gets dropped. Test at expected peak usage.

## Related

- [[server-authority]] — the foundation this supports
- [[RemoteEvent]] — the primitive this protects
- [[remote-spam]] — the exploit this prevents
- [[no-rate-limit]] — anti-pattern: skipping this
- [Remotes Rules](../../.claude/rules/remotes.md)

## Sources

- [.claude/agents/remotes-networking-specialist.md](../../.claude/agents/remotes-networking-specialist.md)
- [.claude/rules/remotes.md](../../.claude/rules/remotes.md)
