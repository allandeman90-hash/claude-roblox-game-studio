# Wiki Log

Append-only chronological log of wiki operations. Format:

```
## [YYYY-MM-DD] <operation> | <short description>
```

Parse with: `grep "^## \[" wiki/log.md | tail -N`

---

## [2026-04-16] seed | Initial wiki bootstrap

Bootstrapped the Roblox/Luau wiki from existing FoG-Roblox-Studio-Command content plus raw sources captured by 10 parallel research agents.

### Inputs
- Existing repo:
  - `.claude/agents/` (33 agent files)
  - `.claude/rules/` (11 rule files)
  - `.claude/docs/roblox-architecture-guide.md`
  - `.claude/docs/luau-style-guide.md`
  - `.claude/docs/coding-standards.md`
- Research agents (parallel, background):
  - agent-1: 43 Roblox service references (creator-docs)
  - agent-2: 28 Luau language topics (creator-docs)
  - agent-3: 25 official tutorials (creator-docs)
  - agent-4: 112 best-practices / security / publishing / monetization (creator-docs)
  - agent-5: 53 Luau spec files and RFCs (luau-lang)
  - agent-6: 42 DevForum scripting threads
  - agent-7: 22 Reddit guides (snippet-based due to reddit blocking)
  - agent-8: 34 community articles and library READMEs
  - agent-9: 31 performance/profiling resources
  - agent-10: 30 monetization/live-ops resources
  - **Total raw source files: ~378**

### Output — Wiki Pages Created: 108

By category:
- Services: 28 (5 complete, 23 stub)
- Concepts: 14 (7 complete, 7 stub)
- Luau: 10 (2 complete, 8 stub)
- Anti-patterns: 14 (3 complete, 11 stub)
- Exploits: 7 (2 complete, 5 stub)
- Performance: 6 (0 complete, 6 stub)
- Monetization: 8 (1 complete, 7 stub)
- Studio: 6 (0 complete, 6 stub)
- Patterns: 6 (0 complete, 6 stub)

**Completed pages** (substantive, ready to reference): [[DataStoreService]], [[RemoteEvent]], [[RemoteFunction]], [[UnreliableRemoteEvent]], [[MarketplaceService]], [[session-locking]], [[server-authority]], [[bind-to-close]], [[client-server-split]], [[rate-limiting]], [[schema-versioning]], [[trove-maid-cleanup]], [[type-annotations]], [[task-library]], [[deprecated-wait]], [[client-trust]], [[unvalidated-remote-args]], [[process-receipt-idempotency]], [[speed-hack]], [[item-duplication]].

### Meta-files created
- [[SCHEMA]] — wiki maintenance schema
- [[README]] — entry point
- [[index]] — content catalog
- [[log]] — this file
- `raw/README.md` — raw sources guide

### Schema compliance
All 108 pages have required frontmatter (title, type, category, owner, status, created, updated). Owner assignments match the ownership table in `SCHEMA.md` section 8. Cross-references via `[[wikilinks]]` throughout.

### Known gaps
- Many stubs need flesh-out from the captured raw sources via `/wiki-ingest`
- Physics exploits (e.g., weld exploit) not yet catalogued
- Animation system pages not yet created
- UI framework comparison pages (Roact / Fusion / native) not yet created
- Testing framework pages (TestEZ, Jest-Lua) not yet created
- Additional Roblox classes (Instance, BasePart, Model, etc.) not yet created as Tier 2 service refs

### Next steps
1. Run `/wiki-lint` to verify seed health
2. Run `/wiki-ingest wiki/raw/roblox-creator-docs/services/` to flesh out service stubs from captured YAMLs
3. Run `/wiki-ingest wiki/raw/community/performance/` to flesh out performance stubs with concrete numbers
4. Run `/wiki-ingest wiki/raw/community/monetization/` to flesh out monetization stubs
5. Set up Obsidian to browse the wiki (wiki directory as vault)

### Integration notes
- `CLAUDE.md` now references `@wiki/SCHEMA.md` alongside the existing docs
- `.claude/settings.json` registers `validate-wiki.sh` on Write/Edit
- New skills: `/wiki-seed`, `/wiki-ingest`, `/wiki-query`, `/wiki-lint`, `/wiki-update`
- New agent: `wiki-curator` (Tier 2, sonnet, coordinates wiki operations)
- New hook: `validate-wiki.sh` (frontmatter and wikilink checks)
- New tools: `tools/wiki-bootstrap.sh`, `tools/wiki-search.sh`, `tools/wiki-stats.sh`

## [2026-04-16] ingest | Phase 1 Luau pages from raw sources

Fleshed out 9 Luau stub pages to `status: draft` and created 3 new stub pages for major Luau topics discovered in raw sources.

### Updated pages (stub -> draft)
- [[strict-vs-nonstrict]] — Three type-checking modes, .luaurc config, cross-module interaction, migration patterns, new nonstrict RFC
- [[export-type]] — Export/import syntax, re-exporting, generic exports, OOP patterns, module-scoped semantics
- [[generic-types]] — Type aliases, generic functions, type packs, Rank-N polymorphism, no turbofish, tagged unions
- [[pcall-xpcall]] — Full signatures, yield-through-pcall, error objects, xpcall with debug.traceback, retry patterns
- [[coroutines]] — Full API (create/resume/yield/wrap/close/isyieldable), lifecycle states, producer pattern, deviation from Lua 5.1
- [[table-library]] — All functions including Luau extensions (create/find/clear/clone/freeze/isfrozen), deep clone/freeze patterns, deprecated functions
- [[string-library]] — All functions, pattern language reference, gsub replacement types, string.split, string.format specifiers, string.pack/unpack, interpolation syntax
- [[math-library]] — All functions and constants, Luau extensions (clamp/sign/round/noise/lerp/map/isfinite), Perlin noise usage, lerp precision guarantees
- [[buffer-type]] — Full API (integer/float/string/bit read-write), zero-based offsets, network serialization examples, platform support table, compression notes

### New stub pages created
- [[metatables]] — Metamethods, __index, __newindex, __call, OOP patterns, weak tables
- [[string-interpolation]] — Backtick syntax, escaping, comparison with string.format
- [[module-scripts]] — ModuleScript, require caching, circular dependencies, server/client environments

### Raw sources consumed
- `wiki/raw/roblox-creator-docs/luau/type-checking.md`
- `wiki/raw/roblox-creator-docs/luau/coroutine-library.md`
- `wiki/raw/roblox-creator-docs/luau/table-library.md`
- `wiki/raw/roblox-creator-docs/luau/tables.md`
- `wiki/raw/roblox-creator-docs/luau/string-library.md`
- `wiki/raw/roblox-creator-docs/luau/strings.md`
- `wiki/raw/roblox-creator-docs/luau/math-library.md`
- `wiki/raw/roblox-creator-docs/luau/buffer-library.md`
- `wiki/raw/roblox-creator-docs/luau/functions.md`
- `wiki/raw/roblox-creator-docs/luau/metatables.md`
- `wiki/raw/roblox-creator-docs/luau/module-scripts.md`
- `wiki/raw/luau-spec/types/types-intro.md`
- `wiki/raw/luau-spec/types/generics.md`
- `wiki/raw/luau-spec/types/unions-and-intersections.md`
- `wiki/raw/luau-spec/types/type-refinements.md`
- `wiki/raw/luau-spec/library/standard-library.md`
- `wiki/raw/luau-spec/rfcs/new-nonstrict.md`
- `wiki/raw/luau-spec/rfcs/config-luaurc.md`
- `wiki/raw/luau-spec/rfcs/generic-functions.md`
- `wiki/raw/luau-spec/rfcs/syntax-string-interpolation.md`
- `wiki/raw/luau-spec/rfcs/type-byte-buffer.md`
- `wiki/raw/luau-spec/rfcs/function-buffer-bits.md`
- `wiki/raw/luau-spec/rfcs/function-table-clone.md`
- `wiki/raw/luau-spec/rfcs/function-table-freeze.md`
- `wiki/raw/luau-spec/rfcs/function-math-lerp.md`
- `wiki/raw/luau-spec/rfcs/function-math-map.md`
- `wiki/raw/community/performance/network/luau-buffer-type.md`

### Index updated
- Luau section: 11 -> 14 pages (2 complete, 9 draft, 3 stub)
- Total pages: 122 -> 125
- Status breakdown: complete 33, draft 43, stub 47

## [2026-04-15] ingest | Phase 1 studio tooling pages from raw sources

Fleshed out 6 stub studio pages to `status: draft` and created 3 new studio pages from raw source material in `wiki/raw/community/articles/tooling/` and `wiki/raw/community/monetization/`.

### Updated pages (stub -> draft)
- [[rojo-mapping]] — Full project.json reference, file extension mapping, live sync workflow, build commands, typical project layout, Argon comparison, pitfalls
- [[wally-packages]] — wally.toml manifest format, core commands, realm system, lockfile, Rojo integration, publishing, private registries
- [[collection-service-tags]] — Full API surface, Binder pattern with cleanup, comparison with alternatives, replication caveats, practical uses
- [[attributes]] — API reference, supported types, designer-editable workflow, attributes vs tags vs value objects, limits
- [[open-cloud-api]] — All 5 APIs (Place Publishing, DataStore v1, MessagingService, Assets, Luau Execution), authentication (API key + OAuth2), rate limits, rbxcloud CLI, field constraints
- [[play-solo-team-test]] — All testing modes, client/server perspective toggle, device emulator, VR emulator, player emulator, real-device testing flows, universe/place structure, publishing workflow

### New pages created
- [[selene-linting]] — Selene linter: configuration, usage, what it catches, CI integration, comparison with Luacheck
- [[stylua-formatting]] — StyLua formatter: Roblox convention config, check mode, ignore directives, pre-commit hooks
- [[github-actions-cicd]] — Full CI/CD pipeline: lint/format gates, Rojo build, staging/production deploy, Luau Execution testing, branch strategy

### Raw sources consumed
- `wiki/raw/community/articles/tooling/rojo-readme.md`
- `wiki/raw/community/articles/tooling/wally-readme.md`
- `wiki/raw/community/articles/tooling/selene-readme.md`
- `wiki/raw/community/articles/tooling/stylua-readme.md`
- `wiki/raw/community/articles/tooling/github-actions-roblox-cicd.md`
- `wiki/raw/community/monetization/open-cloud/assets-api-upload.md`
- `wiki/raw/community/monetization/open-cloud/datastore-api-v1-reference.md`
- `wiki/raw/community/monetization/open-cloud/messaging-service-api.md`
- `wiki/raw/community/monetization/open-cloud/oauth2-authentication.md`
- `wiki/raw/community/monetization/open-cloud/place-publishing-cicd-github-actions.md`
- `wiki/raw/community/monetization/publishing/bindtoclose-deployment.md`
- `wiki/raw/community/monetization/publishing/device-testing-emulator.md`
- `wiki/raw/community/monetization/publishing/universe-place-structure.md`
- `wiki/raw/community/reddit/collectionservice-tags-pattern.md`
- `wiki/raw/community/reddit/rojo-vscode-workflow.md`
- `wiki/raw/roblox-creator-docs/services/CollectionService.md`

### Index updated
- Studio section: 6 -> 9 pages, all at `draft` status
- Total pages: 119 -> 122
- Status breakdown: complete 33, draft 34, stub 53
