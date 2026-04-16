---
title: client-to-server-remote-function
type: anti-pattern
category: anti-patterns
subcategory: security
owner: remotes-networking-specialist
status: stub
created: 2026-04-16
updated: 2026-04-16
severity: high
related:
  - "[[RemoteFunction]]"
  - "[[RemoteEvent]]"
tags: [anti-pattern, security]
---

# Client → Server RemoteFunction

**Severity:** High
**Status:** stub

Setting `.OnServerInvoke` on a `RemoteFunction`. The client can invoke it and never return, hanging the server thread indefinitely. Use `RemoteEvent` with a separate reply event instead. See [[RemoteFunction]] section "Why Client → Server RemoteFunction is Banned".

## Related

- [[RemoteFunction]]
- [[RemoteEvent]]
