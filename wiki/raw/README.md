---
title: Raw Sources
type: raw-sources-index
updated: 2026-04-16
---

# Raw Sources

This directory is the **immutable source-of-truth layer** of the wiki, per Karpathy's LLM Wiki pattern.

Everything in here was captured from an original, external source (official Roblox docs, Luau spec, community tutorials, DevForum threads, Reddit posts, etc.). The LLM reads from this layer but **never modifies files here** during normal wiki operations.

When new information is needed, new files are added to this layer. When existing sources are superseded, old files stay (for provenance) and newer files are added alongside.

The LLM synthesizes from `wiki/raw/` into the curated wiki pages in `wiki/services/`, `wiki/concepts/`, etc. via `/wiki-ingest`.

---

## Directory Map

```
wiki/raw/
├── roblox-creator-docs/       # Official Roblox Creator Documentation
│   ├── services/              # Class/service API reference pages
│   ├── luau/                  # Luau language docs (as published by Roblox)
│   ├── tutorials/             # Official tutorials (scripting, building, UI)
│   └── best-practices/        # Security, perf, monetization, publishing
├── luau-spec/                 # Luau language spec from luau-lang.org + GitHub
├── community/
│   ├── devforum/              # devforum.roblox.com threads and tutorials
│   ├── reddit/                # r/robloxgamedev, r/ROBLOXDev posts
│   ├── articles/              # Blog posts, Medium, GitHub READMEs
│   ├── performance/           # Performance profiling and optimization guides
│   └── monetization/          # GamePass, DevProduct, Open Cloud, live-ops
└── assets/                    # Images, diagrams, screenshots
```

---

## Research Agent Assignments (initial dispatch)

Ten research agents were dispatched in parallel to populate this layer:

| # | Agent | Scope | Output |
|---|-------|-------|--------|
| 1 | creator-docs-services | Roblox service class references | `roblox-creator-docs/services/` |
| 2 | creator-docs-luau | Roblox's Luau language docs | `roblox-creator-docs/luau/` |
| 3 | creator-docs-tutorials | Official tutorials | `roblox-creator-docs/tutorials/` |
| 4 | creator-docs-best-practices | Security, perf, publishing guides | `roblox-creator-docs/best-practices/` |
| 5 | luau-spec | luau-lang.org + github.com/luau-lang/luau | `luau-spec/` |
| 6 | devforum-scripting | devforum.roblox.com scripting tutorials | `community/devforum/` |
| 7 | reddit-guides | r/robloxgamedev, r/ROBLOXDev guides | `community/reddit/` |
| 8 | community-articles | DataStore/networking/security deep dives | `community/articles/` |
| 9 | performance-research | MicroProfiler, optimization, memory | `community/performance/` |
| 10 | monetization-research | GamePass/DevProduct/EBP/Open Cloud | `community/monetization/` |

Each agent was given:
- A specific scope with explicit non-overlapping boundaries
- A fetch budget (~20-30 WebFetch calls)
- An output format with YAML frontmatter
- Instructions to produce an `INDEX.md` listing every file captured

---

## File Format

Every file in `wiki/raw/` follows this format:

```markdown
---
title: <descriptive title>
type: raw-source
source_url: <original URL>
source_type: official-roblox-docs | luau-spec | devforum | reddit | article | github | video-transcript
captured_at: YYYY-MM-DD
captured_by: <agent name>
category: service | luau | tutorial | best-practice | article | thread | guide
tags: [...]
---

# <title>

[content — preserved from source with light editing only. NO synthesis.]

## Source

Original URL: <URL>
Captured: YYYY-MM-DD
```

---

## Rules

1. **Immutability**: Never modify a captured file during normal wiki operations. If a source has been updated, add a new file alongside the old one and flag the old one as stale in its frontmatter.
2. **Provenance**: Every file must carry its source URL.
3. **Light editing only**: Strip nav/ads/boilerplate, but preserve the substance verbatim. No LLM synthesis at this layer — that happens in `wiki/services/` etc.
4. **No orphans**: Every file should be referenced from at least one `INDEX.md` in its parent directory.
5. **Freshness tracking**: `captured_at` date lets us flag stale sources during `/wiki-lint`.

---

## How to Add New Sources

### Via `/wiki-ingest`
Drop a new source file in the appropriate `wiki/raw/` subdirectory, then run:
```
/wiki-ingest wiki/raw/community/articles/my-new-article.md
```
The `wiki-curator` agent will read it and propose updates to affected wiki pages.

### Via `tools/wiki-bootstrap.sh`
For bulk capture of canonical sources (Roblox creator-docs repo, luau-lang repo):
```bash
bash tools/wiki-bootstrap.sh
```

### Via Obsidian Web Clipper
If you use Obsidian, configure the Web Clipper extension to save clipped articles directly into `wiki/raw/community/articles/`. Set the default vault to this repo and the target folder accordingly.

---

## INDEX Files

Each subdirectory should contain an `INDEX.md` listing every file captured within, with:
- Filename
- Title
- Source URL
- One-line summary
- `captured_at` date

Research agents create these automatically. The `/wiki-lint` skill validates they stay up to date.
