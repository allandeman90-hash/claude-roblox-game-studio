---
title: Wiki
type: wiki-root
updated: 2026-04-16
---

# FoG Roblox Studio Command — Wiki

This is the project's **Roblox/Luau knowledge base** — a persistent, LLM-maintained wiki built per [Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

## Structure

- **[[SCHEMA]]** — the schema teaching the LLM how to maintain this wiki
- **[[index]]** — the content catalog (all pages by category)
- **[[log]]** — chronological log of ingests, queries, updates, lints
- **[services/](services/)** — Roblox class and service reference pages
- **[concepts/](concepts/)** — architectural patterns (session locking, server authority, etc.)
- **[luau/](luau/)** — Luau language features
- **[anti-patterns/](anti-patterns/)** — things NOT to do, with fixes
- **[exploits/](exploits/)** — Roblox attack catalog with mitigations
- **[performance/](performance/)** — performance topics, budgets, profiling
- **[monetization/](monetization/)** — GamePass, DevProduct, EBP, ethics
- **[studio/](studio/)** — Studio workflows, Rojo, Attributes, Open Cloud
- **[patterns/](patterns/)** — game patterns (FTUE, daily rewards, trading)
- **[raw/](raw/)** — immutable source material (Roblox Creator Docs, Luau spec, community articles)

## How It Works

Three layers (see [[SCHEMA]] for full details):

1. **Raw sources** (`wiki/raw/`) — captured verbatim from external sources; immutable
2. **Curated wiki** (`wiki/services/`, `wiki/concepts/`, etc.) — LLM-owned markdown pages with `[[wikilinks]]`
3. **Schema** (`wiki/SCHEMA.md` + `CLAUDE.md`) — the config that teaches the LLM how to maintain Layer 2 from Layer 1

## Operations

- `/wiki-seed` — one-time bootstrap from existing repo content
- `/wiki-ingest <source>` — integrate a new raw source
- `/wiki-query <question>` — answer from the wiki
- `/wiki-lint` — health check
- `/wiki-update <page>` — targeted page edit

## Browsing

**Obsidian** is the recommended browser. Open this folder as a vault:
- Wikilinks `[[Page]]` will work natively
- The graph view shows the page link structure
- Frontmatter tags are indexed
- Web Clipper can add new sources directly into `wiki/raw/community/articles/`

You can also browse with any markdown viewer — `[[wikilinks]]` will show as plain text but are still usable via search.

## Ownership

Pages are owned by domain specialists (see [[SCHEMA]] section 8). When the wiki needs an update, the `wiki-curator` agent delegates to the page's owner.

## Compounding

The wiki is a **persistent, compounding artifact**. Every ingest integrates new knowledge; every query may file the answer back as a new page; every lint catches drift. It is never "done" — it grows with the project.
