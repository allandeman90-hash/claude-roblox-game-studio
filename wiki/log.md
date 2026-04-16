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
