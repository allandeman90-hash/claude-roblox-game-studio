---
title: missing-schema-version
type: anti-pattern
category: anti-patterns
subcategory: persistence
owner: datastore-architect
status: stub
created: 2026-04-16
updated: 2026-04-16
severity: medium
related:
  - "[[schema-versioning]]"
  - "[[DataStoreService]]"
tags: [anti-pattern, persistence]
---

# Missing Schema Version

**Severity:** Medium
**Status:** stub

Persistent player data without a `version` field. Makes migration impossible later; any change to data shape risks crashes or data loss.

## Fix

Wrap all data in `{ version = N, data = {...} }` and maintain a migration chain. See [[schema-versioning]].

## Related

- [[schema-versioning]]
- [[DataStoreService]]
