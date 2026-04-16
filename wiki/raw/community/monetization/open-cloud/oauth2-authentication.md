---
title: Open Cloud OAuth 2.0 Authentication and Scopes
type: raw-source
source_url: https://github.com/Roblox/creator-docs/blob/main/content/en-us/cloud/auth/oauth2-overview.md
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-10
category: open-cloud
subcategory: api
tags: [oauth2, authentication, scopes, pkce, openid, creator-hub]
---

# Open Cloud OAuth 2.0 Authentication and Scopes

Roblox supports OAuth 2.0 for third-party apps that need to act on
behalf of users rather than under a single API key. Use OAuth when:

- You're building an app multiple creators will connect to their own
  Roblox accounts
- You need user-granted, revocable permissions
- You need to read a creator's identity for a SaaS dashboard

Use an API key instead when:

- It's your own CI/CD pipeline
- The operations are owned by a single creator account you control
- You don't need a per-user consent flow

## Roles in the protocol

| Role | Party |
|------|-------|
| Resource Owner | The creator authorizing access |
| Resource Server | Roblox (the backend) |
| Client | Your third-party app |
| Authorization Server | Roblox identity infrastructure |

## Supported flows

- **Authorization Code Flow** — classic web server flow
- **Authorization Code Flow with PKCE** — required for public clients
  (SPAs, native apps, mobile apps). Uses `code_verifier` + SHA-256
  `code_challenge` to prevent code interception.

## Identity layer — OpenID Connect

Roblox implements OIDC on top of OAuth 2.0. Include the `openid` scope
to receive an **ID token** (JWT) containing:

- `sub` (user id)
- `name` (username)
- `preferred_username` (display name)
- `profile` (profile URL)

If you select `profile`, you must also select `openid`.

## Supported scopes (partial list)

| Scope | Purpose |
|-------|---------|
| `openid` | Required for ID tokens / authentication |
| `profile` | Username, display name, profile URL |
| `email` | Email address (restricted) |
| `verification` | ID verification state |
| `credentials` | Account credential status |
| `age` | Age bracket |
| `premium` | Premium status |
| `roles` | Group roles |
| `asset:read` | Read assets |
| `asset:write` | Upload / update assets |
| `universe-messaging-service:publish` | Publish cross-server messages |
| `universe-datastores.objects:read` | Read datastore entries |
| `universe-datastores.objects:write` | Write datastore entries |
| `universe-datastores.versions:read` | List/read entry versions |
| `universe-places:write` | Publish place updates |

Many scopes are third-party-available; some are reserved for official
Roblox apps.

## Endpoints

| Purpose | Endpoint |
|---------|----------|
| Authorization | `https://apis.roblox.com/oauth/v1/authorize` |
| Token exchange | `https://apis.roblox.com/oauth/v1/token` |
| User info | `https://apis.roblox.com/oauth/v1/userinfo` |
| Token introspection | `https://apis.roblox.com/oauth/v1/token/introspect` |
| Token revoke | `https://apis.roblox.com/oauth/v1/token/resources` |

## Registration flow

1. Roblox account must be **13+** to authorize apps.
2. App developers must be **ID-verified** to register and publish an app.
3. Register at Creator Hub → **OAuth 2.0 Apps**.
4. Configure redirect URIs, scopes, client type (confidential or public).
5. Receive `client_id` and (for confidential apps) `client_secret`.
6. Submit for review to increase quotas.

## Authorization Code Flow with PKCE (recommended)

### 1. Generate PKCE pair

```python
import base64, hashlib, secrets

verifier = base64.urlsafe_b64encode(secrets.token_bytes(32)).decode().rstrip("=")
challenge = base64.urlsafe_b64encode(
    hashlib.sha256(verifier.encode()).digest()
).decode().rstrip("=")
```

### 2. Redirect the user to the authorize endpoint

```
https://apis.roblox.com/oauth/v1/authorize
  ?client_id={CLIENT_ID}
  &redirect_uri={REDIRECT_URI}
  &scope=openid+profile+asset:write
  &response_type=code
  &state={RANDOM_STATE}
  &code_challenge={CHALLENGE}
  &code_challenge_method=S256
```

### 3. Exchange code for tokens

```bash
curl -X POST https://apis.roblox.com/oauth/v1/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=authorization_code" \
  -d "code=${CODE}" \
  -d "redirect_uri=${REDIRECT_URI}" \
  -d "client_id=${CLIENT_ID}" \
  -d "code_verifier=${VERIFIER}"
```

Response includes `access_token`, `refresh_token`, `id_token` (JWT),
`token_type`, `expires_in`, `scope`.

### 4. Use the access token

```bash
curl -H "Authorization: Bearer $ACCESS_TOKEN" \
  https://apis.roblox.com/oauth/v1/userinfo
```

## Best practices

- **Minimize scopes.** Request only what you need.
- **Use PKCE** for public clients even when not strictly required.
- **Store refresh tokens securely** — treat as passwords.
- **Rotate secrets** periodically.
- **Handle scope changes** — adding scopes requires re-consent from users.
- **Validate `state`** to block CSRF.
- **Validate `id_token`** signature against Roblox's JWKS.

## Concrete Numbers / Examples

- Creator Hub OAuth Apps console to register
- Age requirement: **13+** to authorize
- Developer requirement: **ID verification** to publish an app
- Identity scopes: `openid`, `profile`, `email`
- Required for DataStore writes: `universe-datastores.objects:write`
- Required for place publishing: `universe-places:write`

## Source

Original URL: https://github.com/Roblox/creator-docs/blob/main/content/en-us/cloud/auth/oauth2-overview.md
Captured: 2026-04-16
