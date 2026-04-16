---
title: GitHub Actions CI/CD
type: studio
category: studio
subcategory: deployment
owner: devops-engineer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/tooling/github-actions-roblox-cicd.md
  - wiki/raw/community/monetization/open-cloud/place-publishing-cicd-github-actions.md
related:
  - "[[rojo-mapping]]"
  - "[[wally-packages]]"
  - "[[selene-linting]]"
  - "[[stylua-formatting]]"
  - "[[open-cloud-api]]"
tags: [studio, deployment, cicd, github-actions, automation]
---

# GitHub Actions CI/CD

> A complete CI/CD pipeline for Roblox places using GitHub Actions, Rojo, Selene, StyLua, and the Open Cloud Place Publishing API. PRs run quality gates; merges deploy automatically.

## Summary

Before CI/CD, Roblox deployment meant a human opening Studio and clicking "Publish." The modern workflow ties together the OSS toolchain (Rojo, Selene, StyLua, Aftman) with the Open Cloud APIs to achieve:

1. **Pull-request quality gates** -- lint and format checks on every PR.
2. **Automated testing** -- optionally run tests via the Luau Execution API against an uploaded test place.
3. **Automated deployment** -- merges or tags publish a new place file to Roblox.

## Architecture

```
Git push / PR
    |
    +-- .github/workflows/ci.yaml triggers
    |
    +-> Lint step (Selene)
    +-> Format check (StyLua --check)
    |
    +-> Rojo build -> game.rbxlx
    |
    +-> Open Cloud: upload .rbxlx to test place
    |
    +-> Luau Execution API: run test script in test place
    |       |
    |       +-> Tests use TestEZ or Jest-Lua, report results
    |
    +-> If merged to production branch:
            Open Cloud: upload .rbxlx to production place
```

## Setup Requirements

### Two Roblox Places

- A **test place** for PR checks.
- A **production place** for live deployment.

Separation means a bad commit cannot destroy the live game.

### An Open Cloud API Key

1. Go to [create.roblox.com/dashboard/credentials](https://create.roblox.com/dashboard/credentials).
2. Create an API key with permissions:
   - `universe-places:Write` -- for uploading `.rbxlx` files.
   - `universe.place.luau-execution-session:Write` -- for running tests via the Luau Execution API (optional).
3. Scope the key to the exact universe(s).
4. Set IP allowlist to `0.0.0.0/0` for GitHub Actions runners.
5. **Best practice:** separate keys for staging vs. production.

### GitHub Actions Configuration

- Store the API key as a **repository secret**: `ROBLOX_API_KEY`.
- Store universe and place IDs as **repository variables** (not secrets): `UNIVERSE_ID`, `TEST_PLACE_ID`, `PROD_PLACE_ID`.

### Aftman Toolchain

```toml
# aftman.toml -- pinned tool versions
[tools]
stylua   = "JohnnyMorganz/StyLua@0.20.0"
selene   = "Kampfkarren/selene@0.27.1"
rojo     = "rojo-rbx/rojo@7.4.1"
rbxcloud = "Sleitnick/rbxcloud@0.5.0"
```

## Branch Strategy

| Branch / tag | Action |
|---|---|
| Feature branches / PRs | Lint + format check |
| `main` | Merge triggers auto-deploy to **staging** place |
| `v*` tag (or `production` branch) | Tagged release deploys to **production** place |

## Workflow: CI (Lint + Format)

```yaml
name: CI
on:
  pull_request:
    branches: [main]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: ok-nick/setup-aftman@v0.4.2
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
      - name: Lint with Selene
        run: selene src/
  style:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: JohnnyMorganz/stylua-action@v4
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          version: latest
          args: --check src/
```

These run in parallel and fail the build on any violation. See [[selene-linting]] and [[stylua-formatting]] for tool details.

## Workflow: Deploy to Staging

```yaml
name: Deploy to Staging
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    concurrency: staging    # serialize deploys, avoid Open Cloud 429s
    steps:
      - uses: actions/checkout@v3
      - uses: ok-nick/setup-aftman@v0.4.2
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
      - name: Build place with Rojo
        run: rojo build default.project.json --output build/game.rbxlx
      - name: Publish to staging
        run: |
          rbxcloud experience publish \
            -f build/game.rbxlx \
            -p ${{ vars.STAGING_PLACE_ID }} \
            -u ${{ vars.STAGING_UNIVERSE_ID }} \
            -t published \
            -a ${{ secrets.ROBLOX_API_KEY }}
```

## Workflow: Deploy to Production

```yaml
name: Deploy to Production
on:
  push:
    tags: ['v*']
jobs:
  deploy:
    runs-on: ubuntu-latest
    concurrency: production
    steps:
      - uses: actions/checkout@v3
      - uses: ok-nick/setup-aftman@v0.4.2
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
      - name: Build place with Rojo
        run: rojo build default.project.json --output build/game.rbxlx
      - name: Publish to production
        run: |
          rbxcloud experience publish \
            -f build/game.rbxlx \
            -p ${{ vars.PROD_PLACE_ID }} \
            -u ${{ vars.PROD_UNIVERSE_ID }} \
            -t published \
            -a ${{ secrets.ROBLOX_API_KEY_PROD }}
```

## Automated Testing via Luau Execution API

For teams that need in-engine test execution in CI:

```bash
# Upload test build
curl -X POST \
  -H "x-api-key: $ROBLOX_API_KEY" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @build/game.rbxlx \
  "https://apis.roblox.com/universes/v1/$UNIVERSE_ID/places/$TEST_PLACE_ID/versions?versionType=Published"

# Execute test script
curl -X POST \
  -H "x-api-key: $ROBLOX_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"script": "require(game.ServerScriptService.RunTests)"}' \
  "https://apis.roblox.com/cloud/v2/universes/$UNIVERSE_ID/places/$TEST_PLACE_ID/luau-execution-sessions"
```

The Luau Execution API posts a Luau script, executes it server-side, and returns stdout/stderr as structured JSON.

**Concurrency limit:** 2 concurrent requests per universe. Use GitHub Actions `concurrency:` groups:

```yaml
concurrency:
  group: luau-execution-${{ github.workflow }}
  cancel-in-progress: false
```

## Instance Types That Block API Publishing

The Open Cloud publish API does **not** upload these instance types:

- `EditableImage`
- `EditableMesh`
- `PartOperation`
- `SurfaceAppearance`
- `BaseWrap`

Workaround: publish the asset-heavy base place from Studio when assets change; let CI/CD ship script-only updates.

## Pitfalls

- **Luau Execution concurrency.** Only 2 concurrent sessions per universe. Without `concurrency:` groups, parallel PRs will 429.
- **API key security.** Never commit API keys. Use GitHub Actions secrets. Separate staging and production keys.
- **Stale lockfiles.** Use `wally install --locked` in CI so builds fail if `wally.lock` is out of date.
- **The `production` branch pattern.** Merges to `main` deploy to staging; only explicit merges to `production` (or `v*` tags) deploy to production. This gives a clean gate for human approval.

## Related

- [[rojo-mapping]]
- [[wally-packages]]
- [[selene-linting]]
- [[stylua-formatting]]
- [[open-cloud-api]]

## Sources

- [CI/CD for Roblox Places](../raw/community/articles/tooling/github-actions-roblox-cicd.md) -- `Roblox/place-ci-cd-demo`
- [Place Publishing CI/CD with GitHub Actions](../raw/community/monetization/open-cloud/place-publishing-cicd-github-actions.md)
- Official Open Cloud docs: https://create.roblox.com/docs/cloud
