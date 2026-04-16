---
title: "RFC: Deprecate getfenv/setfenv"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/deprecate-getfenv-setfenv.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, deprecation, environment]
---

# RFC: Deprecate getfenv/setfenv

## Motivation

These functions present several significant concerns:

**Performance Impact:** "They allow uncontrolled mutation of global environment, which results in deoptimization."

**Type Safety Issues:** Code utilizing these functions cannot be properly type-checked, particularly when introducing new globals, which generates warnings and compromises type soundness.

**Security Concerns:** While legitimate uses exist, these functions are statistically more often employed to obfuscate code with malicious intent.

## Proposed Solution

Mark both functions as deprecated, causing the linter to emit warnings during usage. Complete removal is deferred indefinitely due to significant backwards compatibility concerns.

## Trade-offs

Valid use cases include debugging/logging, testing with mocks, and custom module systems. The document identifies replacements:
- Logging → `debug.info`
- Module systems → `require`

> "We do not have an alternative for mocks."

Test frameworks must suppress warnings via linting directives.

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/deprecate-getfenv-setfenv.md
- Captured: 2026-04-16
