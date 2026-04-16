---
title: Wiki Schema
type: schema
version: 1.0
updated: 2026-04-16
---

# Wiki Schema — FoG Roblox Studio Command

This document is the **schema** for the project's Roblox/Luau wiki, following Karpathy's [LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f). It teaches Claude Code (and any agent that loads it) how to read, write, update, and maintain the wiki as a persistent, compounding artifact.

Read this file whenever you are asked to ingest, query, lint, or update the wiki. Follow it strictly.

---

## 1. Purpose

The wiki is a **persistent, interlinked knowledge base** for Roblox game development in Luau. It sits between the raw source material in `wiki/raw/` (Roblox Creator Docs, Luau spec, community articles, DevForum threads, etc.) and the daily work of designing, coding, and shipping Roblox games.

The wiki is **LLM-maintained**, not hand-written. Agents write it; humans read it. Users are in charge of sourcing and direction; agents do the summarizing, cross-referencing, filing, and bookkeeping.

The wiki is the source of truth for **deep Roblox/Luau knowledge**. Rules in `.claude/rules/` still specify prescriptive "do this / don't do that" standards. The wiki provides the descriptive, conceptual backing — *why* the rule exists, *what* the underlying API is, *which* alternatives exist, *when* the rule might not apply.

---

## 2. Three-Layer Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  Layer 1: Raw Sources (immutable)                            │
│  wiki/raw/                                                   │
│  - roblox-creator-docs/                                      │
│  - luau-spec/                                                │
│  - community/{devforum,reddit,articles,performance,          │
│                monetization}/                                │
│  Captured verbatim from external sources. Agents READ only. │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ (synthesis via /wiki-ingest)
┌─────────────────────────────────────────────────────────────┐
│  Layer 2: Curated Wiki (LLM-owned)                           │
│  wiki/                                                       │
│  - services/   (Roblox class/service pages)                  │
│  - concepts/   (architectural patterns)                      │
│  - luau/       (language features)                           │
│  - anti-patterns/                                            │
│  - exploits/   (Roblox attack catalog)                       │
│  - performance/                                              │
│  - monetization/                                             │
│  - studio/     (Studio-specific workflows)                   │
│  - patterns/   (game patterns like FTUE, daily rewards)      │
│  Structured, interlinked, cross-referenced. LLM writes.     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ (consulted during operations)
┌─────────────────────────────────────────────────────────────┐
│  Layer 3: Schema (this file + CLAUDE.md)                     │
│  wiki/SCHEMA.md                                              │
│  Teaches the LLM how to maintain Layer 2 from Layer 1.      │
└─────────────────────────────────────────────────────────────┘
```

**Immutability rule for Layer 1**: Never modify files in `wiki/raw/` during normal operations. If a source has been updated externally, add a new file alongside the old one and flag the old one as `superseded_by:` in its frontmatter.

---

## 3. Directory Layout

```
wiki/
├── README.md                # Entry point for humans
├── SCHEMA.md                # This file
├── index.md                 # Content catalog (LLM-maintained)
├── log.md                   # Chronological log (append-only)
├── raw/                     # Layer 1 (immutable sources)
├── services/                # Roblox class/service reference pages
├── concepts/                # Architectural patterns
├── luau/                    # Luau language features
├── anti-patterns/           # Things NOT to do
├── exploits/                # Roblox attack catalog
├── performance/             # Performance topics
├── monetization/            # Monetization topics
├── studio/                  # Studio-specific workflows
└── patterns/                # Game design patterns
```

### Page-type categories

| Directory | Page type | Example filenames |
|-----------|-----------|-------------------|
| `services/` | `service` | `DataStoreService.md`, `RemoteEvent.md`, `ProximityPrompt.md` |
| `concepts/` | `concept` | `session-locking.md`, `server-authority.md`, `trove-cleanup.md` |
| `luau/` | `luau-feature` | `type-annotations.md`, `task-library.md`, `buffer-type.md` |
| `anti-patterns/` | `anti-pattern` | `deprecated-wait.md`, `client-trust.md`, `magic-numbers.md` |
| `exploits/` | `exploit` | `speed-hack.md`, `item-duplication.md`, `remote-spam.md` |
| `performance/` | `performance` | `heartbeat-budget.md`, `microprofiler.md`, `object-pooling.md` |
| `monetization/` | `monetization` | `game-pass.md`, `process-receipt-idempotency.md` |
| `studio/` | `studio` | `rojo-mapping.md`, `collection-service-tags.md`, `attributes.md` |
| `patterns/` | `pattern` | `ftue-design.md`, `daily-rewards.md`, `atomic-trading.md` |

**Filename convention**: `PascalCase` for Roblox class names (`DataStoreService.md`) — match the Roblox identifier. `kebab-case` for concepts and patterns (`session-locking.md`, `ftue-design.md`). No spaces.

---

## 4. Page Format

Every wiki page (Layer 2) uses this format. No exceptions.

### Frontmatter

```yaml
---
title: <Page Title>               # required — matches H1
type: service | concept | luau-feature | anti-pattern | exploit | performance | monetization | studio | pattern
category: <top-level category>    # required
subcategory: <optional>
owner: <agent-name>               # which agent maintains this page
status: stub | draft | complete | needs-review | superseded
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources: [path/to/raw/file-1.md, path/to/raw/file-2.md]
related: [[[page-1]], [[page-2]]]
tags: [tag-1, tag-2]
severity: critical | high | medium | low    # exploits and anti-patterns only
---
```

Required fields: `title`, `type`, `category`, `owner`, `status`, `created`, `updated`.

### Body structure

Each page type has a required skeleton. The LLM fills in each section from raw sources.

#### `service` (Roblox class pages)

```markdown
# <ClassName>

> One-sentence summary from the docs. [[[related-service]]]

## Summary

2-3 paragraphs: what it is, when you use it, how it fits into the Roblox architecture.

## API Surface

### Properties
- `PropertyName: Type` — description

### Methods
- `:MethodName(args) -> ReturnType` — description

### Events
- `.EventName:Connect(fn)` — description

## Budgets and Limits

Any hard limits, rate limits, size limits, or quotas that matter at runtime.

## Common Patterns

Code examples showing idiomatic use. Must be server-authoritative where applicable.

## Pitfalls

Known gotchas, deprecation warnings, exploit vectors.

## Related

- [[concept-page]]
- [[anti-pattern-page]]
- [[related-service-page]]

## Sources

- [Roblox Creator Docs](wiki/raw/roblox-creator-docs/services/<ClassName>.md)
- [DevForum thread: "..."](wiki/raw/community/devforum/<file>.md)
- [Community article: "..."](wiki/raw/community/articles/<file>.md)
```

#### `concept` (architectural patterns)

```markdown
# <Concept>

> One-sentence summary.

## What It Is

Plain-language explanation of the concept and the problem it solves.

## When to Use It

Situations where this pattern applies, and situations where it doesn't.

## Implementation

Code example(s). Minimal, copy-pasteable, annotated.

## Variants

If there are multiple accepted ways to implement this, list them with trade-offs.

## Pitfalls

Common mistakes when applying this pattern.

## Related

- [[service-used-by-this-concept]]
- [[anti-pattern-this-concept-avoids]]

## Sources
```

#### `luau-feature`

```markdown
# <Feature>

> One-sentence summary.

## Syntax

Exact syntax with type annotations.

## Semantics

How it behaves. Deviations from Lua 5.1 noted explicitly.

## Examples

Idiomatic use. Strict mode preferred.

## Pitfalls

Edge cases, surprising behaviors, common mistakes.

## Related

## Sources
```

#### `anti-pattern`

```markdown
# <Anti-pattern>

> One-sentence summary of the bad thing.

**Severity:** critical | high | medium | low

## What It Looks Like

Code example showing the anti-pattern.

## Why It's Bad

The underlying issue — what breaks, who gets hurt, what the risk is.

## How to Fix It

The correct replacement. Code example.

## Detection

How to find this in a codebase (grep patterns, common signatures).

## Related

- [[concept-this-violates]]
- [[rule-that-enforces-this]]

## Sources
```

#### `exploit`

```markdown
# <Exploit Name>

> One-sentence summary of the attack.

**Severity:** critical | high | medium | low

## Attack Vector

How the exploit is performed, step by step.

## Affected Systems

Which game systems are vulnerable (combat, economy, movement, etc.).

## Impact

What an attacker can achieve. Data loss? Currency dupe? Admin escalation? Movement cheat?

## Mitigation

Server-side defenses. Code example of the fix.

## Detection

How to identify the attack in logs or player behavior.

## Related

- [[related-exploit]]
- [[concept-that-defends]]
- [[service-involved]]

## Sources
```

#### `performance`, `monetization`, `studio`, `pattern`

Follow a similar skeleton: Summary → Details → Examples → Pitfalls → Related → Sources. Each type may have an extra required section (e.g., `performance` has a **Measurements / Budgets** section with concrete numbers; `monetization` has an **Ethical Check** section; `studio` has a **Workflow** section).

---

## 5. Linking

Use **Obsidian-style wikilinks**: `[[Page Title]]` or `[[filename|Display Text]]`. Obsidian and most markdown viewers render these.

### Rules

1. **Every page must have ≥1 inbound link** from another page (no orphans, except `index.md` itself).
2. **Every page must have ≥1 outbound link** in its `## Related` section, unless there is genuinely nothing related (rare).
3. **Links to raw sources** use standard markdown links with relative paths: `[source](wiki/raw/...)` — NOT wikilinks. This is how we distinguish "wiki-internal" from "raw citation."
4. **Bidirectional** — if page A links to page B under "Related", page B should link to page A. `/wiki-lint` checks this.
5. **Prefer more specific links** — if you can link to a specific section, do: `[[DataStoreService#Session Locking]]`.

### Cross-category links are encouraged

- A `service` page links to `concepts` that explain the patterns used with it.
- A `concept` page links to `services` it uses and `anti-patterns` it replaces.
- An `exploit` page links to `concepts` that defend against it and `services` involved.
- A `rule` file in `.claude/rules/` can be linked from a wiki page as `[[../.claude/rules/datastores.md|DataStore Rules]]` (markdown link, not wikilink — because it's outside `wiki/`).

---

## 6. Operations

### 6.1 Ingest (`/wiki-ingest <source>`)

**Purpose**: Integrate a new or updated raw source into the wiki.

**Trigger**: User drops a file into `wiki/raw/` and runs the skill, OR a research agent completes and reports new files.

**Workflow**:

1. **Read the source** fully — every word.
2. **Identify affected wiki pages** by scanning the source for mentions of:
   - Roblox class names → `wiki/services/<ClassName>.md`
   - Concept names → `wiki/concepts/*.md`
   - Luau feature names → `wiki/luau/*.md`
   - Exploit names → `wiki/exploits/*.md`
   - etc.
3. **For each affected page**:
   - Read the current page
   - Determine what needs to change (add info, correct a claim, add a cross-reference, flag a contradiction)
   - Draft the update
4. **Determine if new pages should be created**:
   - If the source introduces a concept/service/pattern that has no wiki page yet, draft a stub page.
5. **Delegate to domain specialist** when appropriate:
   - DataStore changes → `datastore-architect`
   - Remote changes → `remotes-networking-specialist`
   - Exploit additions → `exploit-security-specialist`
   - Performance findings → `performance-analyst`
   - Monetization items → `monetization-lead`
   - etc.
6. **Present the full changeset to the user**:
   - List of pages to update (with per-page diff summary)
   - List of pages to create
   - Any contradictions flagged between the new source and existing pages
7. **Wait for approval** before writing.
8. **Apply approved changes**.
9. **Update `wiki/index.md`** to list any new pages.
10. **Append to `wiki/log.md`**:
    ```
    ## [YYYY-MM-DD] ingest | <source-title>
    - Added pages: [...]
    - Updated pages: [...]
    - Contradictions flagged: [...]
    - Delegated to: [agents]
    ```

**Golden rule for ingest**: A single source might touch 10-15 pages. Scan broadly, update consistently, present as one coherent changeset — not one page at a time.

### 6.2 Query (`/wiki-query <question>`)

**Purpose**: Answer a question by reading the wiki.

**Workflow**:

1. **Read `wiki/index.md`** first to find candidate pages.
2. **Read those pages** fully.
3. **Follow links** to related pages that look relevant.
4. **Synthesize an answer** citing specific pages by `[[wikilink]]`.
5. **If the answer is valuable beyond this query**, offer to file it back as a new wiki page (a `concept`, `pattern`, or `anti-pattern` typically). This is how the wiki compounds — good answers become part of the knowledge base.
6. **If information is missing**, flag it for `/wiki-lint` or offer to `/wiki-ingest` a new source that would fill the gap.
7. **Append to `wiki/log.md`**:
    ```
    ## [YYYY-MM-DD] query | <short question>
    - Pages read: [...]
    - Answer filed as: [[new-page]] (if applicable)
    ```

### 6.3 Lint (`/wiki-lint`)

**Purpose**: Health-check the wiki.

**Checks**:

1. **Frontmatter validity** — every page has required fields (`title`, `type`, `category`, `owner`, `status`, `created`, `updated`).
2. **Broken wikilinks** — every `[[Page]]` resolves to an actual file.
3. **Orphans** — pages with no inbound wikilinks.
4. **Stubs** — `status: stub` pages that have been stubs for > 30 days.
5. **Stale claims** — pages whose `updated` is > 180 days old.
6. **Bidirectional links** — if A links to B in Related, B should link to A.
7. **Required sections** — each page type has required sections (see Section 4); flag pages missing them.
8. **Contradictions** — pages that make conflicting claims (best-effort; flag for human review).
9. **Missing cross-references** — pages that mention a concept that has its own page but don't link to it.
10. **INDEX.md drift** — `wiki/index.md` lists every page that exists on disk (no missing, no extras).
11. **Raw source coverage** — raw files with no inbound references from Layer 2 (candidates for `/wiki-ingest`).

**Output**: A report grouped by severity. Critical items block; warnings are noted.

**Append to log**:
```
## [YYYY-MM-DD] lint
- Checked: X pages
- Critical issues: X
- Warnings: X
- Top findings: [...]
```

### 6.4 Update (`/wiki-update <page> [note]`)

**Purpose**: Targeted update to a single page (not source-driven like `ingest`).

**Workflow**:

1. Read the page.
2. Read related pages (follow Related links).
3. Make the requested update.
4. Check that Related links still make sense; add/remove as needed.
5. Update `updated:` in frontmatter.
6. Present diff for approval.
7. On approval, write.
8. Append to log:
    ```
    ## [YYYY-MM-DD] update | <page-name>
    - Reason: <note>
    ```

### 6.5 Seed (`/wiki-seed`)

**Purpose**: One-time bootstrap of the wiki from existing repo content. Only run at project setup.

Extracts Luau/Roblox knowledge from:
- `.claude/agents/*.md` (domain knowledge in agent prompts)
- `.claude/rules/*.md` (anti-patterns and required patterns)
- `.claude/docs/roblox-architecture-guide.md`
- `.claude/docs/luau-style-guide.md`
- `.claude/docs/coding-standards.md`

...and creates initial wiki pages with proper frontmatter, cross-references, and stubs for topics mentioned but not yet deeply documented.

---

## 7. Index and Log

### `wiki/index.md`

Content-oriented catalog, organized by category. Rewritten fully on every ingest. Format:

```markdown
# Wiki Index

**Last updated:** YYYY-MM-DD
**Page count:** X
**Status breakdown:** complete: X, draft: X, stub: X

## Services

- [[DataStoreService]] — Persistent player data store. `owner: datastore-architect` `status: complete`
- [[RemoteEvent]] — Fire-and-forget client-server messaging. `owner: remotes-networking-specialist` `status: complete`
- ...

## Concepts

- [[session-locking]] — Prevents data duplication across servers. `owner: datastore-architect` `status: complete`
- ...

## Luau Features
...

## Anti-patterns
...

## Exploits
...

## Performance
...

## Monetization
...

## Studio
...

## Patterns
...
```

### `wiki/log.md`

Chronological, append-only. Format:

```markdown
# Wiki Log

## [2026-04-16] seed | Initial wiki bootstrap
- Seeded from: .claude/agents/, .claude/rules/, .claude/docs/
- Pages created: 124 (complete: 38, stub: 86)
- Top categories: services (35), concepts (24), exploits (12), performance (15), monetization (14), anti-patterns (11), luau (8), studio (5)

## [2026-04-17] ingest | Roblox Creator Docs bulk capture (research-agent-1)
- Source: wiki/raw/roblox-creator-docs/services/*.md (26 new raw files)
- Pages updated: 26
- New concepts discovered: [[Roblox-signal-semantics]], [[attribute-replication]]

...
```

**Log entry prefix format**: `## [YYYY-MM-DD] <operation> | <short description>`

This makes the log parseable with simple unix tools:
```bash
grep "^## \[" wiki/log.md | tail -20    # last 20 entries
grep "^## \[" wiki/log.md | grep ingest # all ingests
```

---

## 8. Ownership Model

Each wiki page has an `owner:` field in its frontmatter. This is the agent primarily responsible for keeping the page current. The owner field maps to an agent in `.claude/agents/`.

### Ownership assignments

| Wiki area | Primary owner | Backup owner |
|-----------|---------------|--------------|
| `services/` (DataStore, MemoryStore, OrderedDataStore) | `datastore-architect` | `technical-director` |
| `services/` (RemoteEvent, RemoteFunction, etc.) | `remotes-networking-specialist` | `technical-director` |
| `services/` (MarketplaceService, GamePass/DevProduct APIs) | `monetization-lead` | `economy-designer` |
| `services/` (Humanoid, Character, Animation) | `luau-gameplay-programmer` | `lead-programmer` |
| `services/` (UI — ScreenGui, BillboardGui, UIListLayout etc.) | `ui-programmer` | `ux-designer` |
| `services/` (SoundService, Sound, SoundGroup) | `sound-designer` | `audio-director` |
| `services/` (CollectionService, Attributes, Rojo-related) | `roblox-studio-specialist` | `technical-director` |
| `services/` (Workspace, Terrain, Lighting, StreamingEnabled) | `level-designer` | `technical-artist` |
| `services/` (MessagingService, MemoryStoreService) | `live-ops-specialist` | `datastore-architect` |
| `services/` (HttpService, TeleportService, general-purpose) | `luau-systems-programmer` | `lead-programmer` |
| `concepts/` | varies by topic | `technical-director` |
| `luau/` | `luau-systems-programmer` | `lead-programmer` |
| `anti-patterns/` | `lead-programmer` | per-domain specialist |
| `exploits/` | `exploit-security-specialist` | `technical-director` |
| `performance/` | `performance-analyst` | `technical-director` |
| `monetization/` | `monetization-lead` | `economy-designer` |
| `studio/` | `roblox-studio-specialist` | `devops-engineer` |
| `patterns/` (FTUE, daily rewards, codes) | `game-designer` | `live-ops-specialist` |
| `patterns/` (atomic trading, cross-server) | `economy-designer` + `datastore-architect` | `technical-director` |
| `wiki/index.md`, `log.md`, `SCHEMA.md` | `wiki-curator` | — |

When an ingest touches a page, the `wiki-curator` **delegates** the update draft to the owner, receives the draft, and presents the combined changeset to the user.

---

## 9. Contradiction Handling

When a new source says something that contradicts an existing wiki claim:

1. **Do not silently overwrite.**
2. Add a contradiction block to the page:
   ```markdown
   > **⚠️ Contradiction flagged 2026-04-16:** The new source [[raw/community/articles/datastore-new-patterns]] claims session locks should use `UpdateAsync` with a check-and-set approach. This page currently says to use `SetAsync` after a separate lock acquisition. Both are viable; `datastore-architect` to resolve.
   ```
3. Log it in `wiki/log.md` under the ingest entry.
4. `/wiki-lint` will list unresolved contradictions until a human (via an agent) reviews.
5. When resolving, update the page, remove the block, and log the resolution.

---

## 10. Stubs and Progressive Disclosure

Not every page needs to be complete on day one. **Stubs are first-class citizens.**

A stub page has:
- `status: stub` in frontmatter
- A short `## Summary` (even 1 sentence is fine)
- A `## TODO` section listing what needs to be filled in
- The normal Frontmatter + Related + Sources sections

Stubs exist so that:
- Other pages can link to them (no broken `[[link]]`)
- `/wiki-lint` tracks the gap
- The next `/wiki-ingest` that touches the topic can flesh them out

Never leave a link dangling. If you mention something on page A that deserves its own page, either link to an existing page OR create a stub.

---

## 11. Style Guidelines for Wiki Content

1. **Write for a Roblox developer, not a beginner programmer.** Assume Luau literacy.
2. **Prefer code over prose.** Show, don't tell. One good example beats three paragraphs.
3. **Numbers, not adjectives.** "4 MB" not "large". "30 FPS" not "smooth enough".
4. **Source everything** in the `## Sources` section with path to the raw file.
5. **Short over long.** A page is complete when it answers "what is it, when to use it, how to use it, what breaks it" — not when it has exhausted every corner case.
6. **Neutral voice.** "The server validates" not "You should validate." The wiki is a reference, not a lecture.
7. **Bias toward Roblox-specific insight** over general programming knowledge. "`wait()` is deprecated" is wiki-worthy; "loops can be infinite" is not.
8. **Admit uncertainty.** If sources disagree, document the disagreement. If a number is approximate, say so.

---

## 12. Interaction with Existing Repo Files

The wiki does not replace any existing file. It complements them:

- **`.claude/rules/*.md`** — Prescriptive rules stay as-is. Link to wiki pages that explain the underlying concept: `See [[DataStoreService]] and [[session-locking]] for full context.`
- **`.claude/docs/roblox-architecture-guide.md`** — Stays as the high-level tour. Wiki pages are the drilldowns.
- **`.claude/docs/luau-style-guide.md`** — Stays as the style authority. Wiki `luau/*` pages cover the language itself.
- **`design/gdd/*.md`** — Project-specific. Wiki is platform-general.
- **`.claude/agents/*.md`** — Each agent gets a `## Wiki Ownership` section referencing their pages.
- **`.claude/skills/*/SKILL.md`** — Domain skills (e.g., `/datastore-review`) should read relevant wiki pages before running their checks, so they're always working from the current state of knowledge.

---

## 13. Quality Bar

A wiki page is **complete** (not stub) when:

- [ ] All required frontmatter fields present and valid
- [ ] H1 matches `title:` in frontmatter
- [ ] Summary section answers "what is it?" in 1-3 sentences
- [ ] All type-specific required sections present
- [ ] At least one code example (for pages where code is relevant)
- [ ] At least 2 outbound `[[wikilinks]]` in Related
- [ ] At least 1 raw source cited in Sources
- [ ] No dangling concepts mentioned that lack their own page or stub
- [ ] Has been reviewed by its owner agent at least once

`/wiki-lint` reports any "complete" pages that fail these checks.

---

## 14. When in Doubt

- **Can't decide if a page should exist?** Make a stub. Stubs are cheap; missed concepts are expensive.
- **Can't decide which category?** Ask the user or put it in the most specific category.
- **Two sources contradict?** Flag it, don't choose.
- **A concept spans multiple owners?** Assign the primary owner to the most relevant specialist; list the secondary in Related.
- **Unsure if a source is worth ingesting?** Ingest the provenance (file + frontmatter) but skip the wiki update; `/wiki-lint` will later flag it as uncovered raw material.

---

## 15. Meta: Updating This Schema

This file is version-controlled and updated deliberately. To propose a schema change:

1. Run `/wiki-update wiki/SCHEMA.md "reason for change"`
2. Present the diff to the user
3. Get explicit approval
4. Log the schema change in `wiki/log.md` with version bump:
   ```
   ## [YYYY-MM-DD] schema-update | v1.1
   - Changed: [...]
   - Reason: [...]
   ```
5. Bump `version:` in the frontmatter above.

Schema versions are backwards-compatible within a major version. If a breaking change is needed, run `/wiki-lint` to identify affected pages and update them in the same PR as the schema change.

---

**End of schema.**

The wiki is a living artifact. It should get richer every time you touch it. Never let a session close with the wiki in a worse state than you found it.
