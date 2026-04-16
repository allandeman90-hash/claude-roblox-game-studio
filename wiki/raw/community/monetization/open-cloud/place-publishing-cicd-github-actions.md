---
title: Place Publishing CI/CD with GitHub Actions
type: raw-source
source_url: https://devforum.roblox.com/t/how-to-automate-place-publishing-with-partially-managed-rojo/2443196
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-10
category: open-cloud
subcategory: api
tags: [cicd, github-actions, open-cloud, rojo, rbxcloud, publishing, automation]
---

# Place Publishing CI/CD with GitHub Actions

A production-ready GitHub Actions pipeline for Roblox experiences uses:

- **Rojo** — syncs local scripts to a place file
- **rbxcloud** — CLI wrapper around Roblox Open Cloud
- **Selene + StyLua** — lint and format gates
- **Aftman** — versioned toolchain manager (replaces Foreman)

The flow below mirrors the pattern documented on DevForum, adapted for
partially-managed Rojo setups (script-only sync with a human-managed
asset base place).

## Repository structure

```
project-root/
  .github/
    workflows/
      ci.yaml
      deploy_staging.yaml
      deploy_prod.yaml
  src/
    server/
    client/
    shared/
  aftman.toml
  selene.toml
  rojo.project.json
  game.rbxl         # base place with assets, not in .gitignore
```

## aftman.toml — pinned tool versions

```toml
[tools]
stylua   = "JohnnyMorganz/StyLua@0.18.0"
selene   = "Kampfkarren/selene@0.25.0"
rojo     = "rojo-rbx/rojo@7.3.0"
rbxcloud = "Sleitnick/rbxcloud@0.5.0"
```

## selene.toml

```toml
std = "roblox"
```

## Branch strategy

| Branch / tag | Action |
|--------------|--------|
| `dev`        | Lint + format check on every push |
| `main`       | Merge from `dev` → auto-deploy to **staging place** |
| `v*` tag     | Tagged release → auto-deploy to **production place** |

## ci.yaml — lint + format

```yaml
name: CI
on:
  push:
    branches: [ dev ]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: ok-nick/setup-aftman@v0.3.0
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
      - name: Lint with Selene
        run: selene ./src
  style:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: JohnnyMorganz/stylua-action@v3
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          version: latest
          args: --check ./src
```

## deploy_staging.yaml

```yaml
name: Deploy to Staging
on:
  push:
    branches: [ main ]
jobs:
  deploy:
    runs-on: ubuntu-latest
    concurrency: stage     # serialize deploys, avoid Open Cloud 429s
    steps:
      - uses: actions/checkout@v3
      - uses: ok-nick/setup-aftman@v0.3.0
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
      - name: Build place with Rojo
        run: rojo build -o build.rbxl default.project.json
      - name: Publish
        run: |
          rbxcloud experience publish \
            -f build.rbxl \
            -p ${{ vars.STAGING_PLACE_ID }} \
            -u ${{ vars.STAGING_UNIVERSE_ID }} \
            -t published \
            -a ${{ secrets.ROBLOX_API_KEY }}
```

## deploy_prod.yaml

```yaml
name: Deploy to Production
on:
  push:
    tags: [ 'v*' ]
jobs:
  deploy:
    runs-on: ubuntu-latest
    concurrency: prod
    steps:
      - uses: actions/checkout@v3
      - uses: ok-nick/setup-aftman@v0.3.0
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
      - name: Build place with Rojo
        run: rojo build -o build.rbxl default.project.json
      - name: Publish
        run: |
          rbxcloud experience publish \
            -f build.rbxl \
            -p ${{ vars.PROD_PLACE_ID }} \
            -u ${{ vars.PROD_UNIVERSE_ID }} \
            -t published \
            -a ${{ secrets.ROBLOX_API_KEY_PROD }}
```

## API key setup

1. Obtain **PlaceId** and **UniverseId** for both staging and production:
   ```lua
   print(game.PlaceId, game.GameId)  -- game.GameId is the UniverseId
   ```
2. [create.roblox.com/dashboard/credentials](https://create.roblox.com/dashboard/credentials)
   → Create API key
3. Enable permission: **universe-places:Write**
4. Scope the key to the exact universe (or both universes)
5. Set IP allowlist: `0.0.0.0/0` for GitHub Actions, or specific
   ranges for hardened setups
6. Store as GitHub Actions secret `ROBLOX_API_KEY`
7. **Best practice**: separate keys for staging vs prod so a compromised
   staging key can't ship to production

## Instance types that block API publishing

The Open Cloud publish API does NOT re-upload these instance types.
If your experience contains any of them AND they've changed, you need
to publish from Studio at least once before the API will accept them:

- `EditableImage`
- `EditableMesh`
- `PartOperation`
- `SurfaceAppearance`
- `BaseWrap`

The usual workaround: publish the asset-heavy base place from Studio
when assets change, and let CI/CD only ship script updates.

## Luau Execution concurrency limit

If you extend the pipeline to run integration tests via the Open Cloud
Luau Execution API (as the official `place-ci-cd-demo` does), note:

- The Engine Open Cloud Luau Execution API is currently limited to
  **2 concurrent requests per universe**.
- Use GitHub Actions `concurrency:` groups to serialize workflow runs
  against the same universe or they will 429.

## rbxcloud common commands

```bash
# Publish
rbxcloud experience publish -f build.rbxl -p <place> -u <universe> \
    -t published -a "$ROBLOX_API_KEY"

# Read a DataStore key
rbxcloud datastore entry get \
    --api-key "$ROBLOX_API_KEY" \
    --universe-id "$UNIVERSE_ID" \
    --datastore-name PlayerData \
    --key Player_1234

# Publish a MessagingService message
rbxcloud messaging publish \
    --api-key "$ROBLOX_API_KEY" \
    --universe-id "$UNIVERSE_ID" \
    --topic liveops:flags \
    --message '{"feature":"doubleXP","on":true}'
```

## Concrete Numbers / Examples

- Required API permission: `universe-places:Write`
- Luau Execution API concurrency cap: **2** per universe
- Recommended: separate API keys per environment
- `default.project.json` file for Rojo
- Branch triggers: `dev` for CI, `main` → staging, `v*` tags → prod

## Source

Original URL: https://devforum.roblox.com/t/how-to-automate-place-publishing-with-partially-managed-rojo/2443196
Related: https://github.com/Roblox/place-ci-cd-demo
Related: https://github.com/Sleitnick/rbxcloud
Captured: 2026-04-16
