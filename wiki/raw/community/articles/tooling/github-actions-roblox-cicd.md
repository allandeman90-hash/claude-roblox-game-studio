---
title: CI/CD for Roblox Places — GitHub Actions + Rojo + Open Cloud
type: raw-source
source_url: https://github.com/Roblox/place-ci-cd-demo
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: tooling
tags: [cicd, github-actions, open-cloud, rojo, deployment, luau-execution]
---

# CI/CD for Roblox Places — GitHub Actions + Rojo + Open Cloud

**Source:** Roblox's official `Roblox/place-ci-cd-demo` repository + community patterns

## What the demo shows

The `Roblox/place-ci-cd-demo` repository is an official reference for a complete CI/CD workflow for a Roblox place. It ties together the modern OSS Roblox toolchain (Rojo, Selene, StyLua) with the Open Cloud APIs (Place Publishing, Luau Execution) to achieve:

1. **Pull-request quality gates** — lint and format checks run on every PR
2. **Automated testing in a real Roblox runtime** — tests run via the Luau Execution API against an uploaded test place
3. **Automated deployment to production** — merges to the `production` branch publish a new place file to Roblox

This is the end-state every serious Roblox project eventually wants. Before this workflow existed, deployment meant a human opening Studio and clicking "Publish."

## Architecture at a glance

```
Git push / PR
    │
    ├── .github/workflows/cicd.yml triggers
    │
    ├─► Lint step (Selene)
    ├─► Format check (StyLua --check)
    │
    ├─► Rojo build → my-game.rbxlx
    │
    ├─► Open Cloud: upload .rbxlx to test place
    │
    ├─► Open Cloud Luau Execution API: run test script in test place
    │       │
    │       └─► Tests use TestEZ or Jest-Lua, report results
    │
    └─► If merged to `production` branch:
            Open Cloud: upload .rbxlx to production place
```

## Setup requirements

From the demo README, to run this workflow you need:

### Two Roblox places

- A **test place** where PR checks run
- A **production place** where merges to `production` deploy

Separating them means a bad commit can't accidentally destroy your live game.

### An Open Cloud API key

Generate via the Creator Dashboard. The key must have these specific permissions:

- `universe.places:write` — so the workflow can upload `.rbxlx` files
- `universe.place.luau-execution-session:write` — so the workflow can run the Luau Execution API against the uploaded test place

### GitHub Actions configuration

Store the API key as a repository secret named `ROBLOX_API_KEY`. Store universe and place IDs as repository variables (not secrets — they're not sensitive, and variables show up nicely in logs).

## Key workflow steps

### Lint and format (Selene + StyLua)

```yaml
- name: StyLua check
  uses: JohnnyMorganz/stylua-action@v4
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    version: latest
    args: --check src/

- name: Selene lint
  uses: NTBBloodbath/selene-action@v1.0.0
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    args: --display-style=quiet src/
```

These run in parallel and fail the build if the code isn't formatted or has lint violations.

### Rojo build

```yaml
- name: Install Rojo
  uses: ok-nick/setup-aftman@v0.4.2

- name: Build place file
  run: rojo build default.project.json --output build/game.rbxlx
```

The `rojo build` command is stateless — given a project and its source, it always produces the same place file. This is the property that makes CI-friendly builds possible.

### Upload to test place via Open Cloud

The demo calls the Open Cloud Place Publishing API with the built `.rbxlx`:

```bash
curl -X POST \
  -H "x-api-key: $ROBLOX_API_KEY" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @build/game.rbxlx \
  "https://apis.roblox.com/universes/v1/$UNIVERSE_ID/places/$TEST_PLACE_ID/versions?versionType=Published"
```

The call returns a version number. Subsequent steps can reference this version to make sure they're running against the freshly-uploaded build.

### Run tests via Luau Execution API

The Luau Execution API lets you POST a Luau script to a universe+place pair, execute it in a server-side sandbox, and receive stdout/stderr back as structured JSON. This is how the demo runs tests — it posts a script that requires TestEZ and your test modules, runs the suite, and prints results.

```bash
curl -X POST \
  -H "x-api-key: $ROBLOX_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"script": "require(game.ServerScriptService.RunTests)"}' \
  "https://apis.roblox.com/cloud/v2/universes/$UNIVERSE_ID/places/$TEST_PLACE_ID/luau-execution-sessions"
```

The demo wraps this in Python/shell scripts that poll for completion and parse results.

## The concurrency-limit gotcha

From the demo README: "the Engine Open Cloud API for Executing Luau is currently limited to two concurrent requests per universe." The demo handles this with a GitHub Actions `concurrency` group, so multiple in-flight PRs serialize their test runs rather than failing:

```yaml
concurrency:
  group: luau-execution-${{ github.workflow }}
  cancel-in-progress: false
```

Without this, a second PR opened while the first is still running tests will hit a 429 from the Luau Execution API and fail spuriously.

## The `production` branch pattern

The demo assumes a long-lived `production` branch. Commits land on `main` (or feature branches merge into `main`), run tests, and only deploy to production when someone explicitly merges `main` into `production`. This gives a clean place to gate on human approval and produces a clean deployment history in git.

## Alternative: SaveToRoblox action

For teams that don't need the Luau Execution API for tests, the community `SaveToRoblox` GitHub Action is simpler — it just uploads a `.rbxl`/`.rbxlx` via the Place Publishing Cloud API, no test execution step. Good starting point if you want CD without CI.

## Why this matters

Before this workflow existed:
- Every Roblox team had their own ad-hoc deployment process
- Tests had to be run manually by opening Studio
- There was no automated regression detection
- Branch-based workflows were impossible because "branching" meant "copying the place file"

With this workflow, a Roblox project becomes a normal software project: PRs run checks, tests run on real infrastructure, merges deploy automatically. This is the foundation that unlocks proper team-based development.

## Source

Original URL: https://github.com/Roblox/place-ci-cd-demo
Related tools:
- Rojo: https://github.com/rojo-rbx/rojo
- Selene: https://github.com/Kampfkarren/selene
- StyLua: https://github.com/JohnnyMorganz/StyLua
- Open Cloud docs: https://create.roblox.com/docs/cloud
Captured: 2026-04-15
