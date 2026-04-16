---
title: Cloud API reference
type: raw-source
source_url: https://create.roblox.com/docs/cloud
github_source: https://github.com/Roblox/creator-docs/blob/main/content/en-us/cloud/index.md
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-4
category: best-practice
subcategory: open-cloud
tags: [open-cloud, overview]
---

# Cloud API reference

With Open Cloud, you can access Roblox resources through standard [REST](https://en.wikipedia.org/wiki/REST) APIs, which lets you build everything from command line automation tools to complex web apps. You can update experiences, restart servers, work with your data stores and memory stores, manage user restrictions, list inventory items, and much, much more.

This reference is broken into two sections:

- A [section that separates endpoints by feature](/cloud/reference/features/accounts) (Avatars, Game Passes, Users, etc.)
- A [section that separates endpoints by domain](/cloud/reference/domains/apis) (base URL)

**Both sections** contain the full list of available API endpoints. We recommend the [features section](/cloud/reference/features/accounts) since it helps consolidate endpoints by use case, but experienced Open Cloud developers might prefer to browse by domain.

- Whenever possible, use endpoints that support [API keys](./auth/api-keys.md) or [OAuth 2.0](./auth/oauth2-overview.md) for authentication. They have strong stability guarantees and receive regular updates.

- Legacy APIs use cookie-based authentication, can incorporate breaking changes without notice, and have minimal stability guarantees. We don't recommend them for production applications.

<Alert severity="info">
Roblox also offers [webhooks](./webhooks/webhook-notifications.md), which can notify your applications when certain events occur, such as refunds or changes to subscriptions.
</Alert>

## Get started with Open Cloud

1. Set up authentication for your application.

   See the documentation for how to use [API keys](./auth/api-keys.md) or [OAuth 2.0](./auth/oauth2-overview.md). API keys are the easiest way to get started.

1. Test API calls using tools like [Postman](https://www.postman.com) with [OpenAPI descriptions](./reference/openapi.md) or the [OAuth 2.0 sample app](./auth/oauth2-sample.md).
1. Review the [resource guides](./guides/index.md) for end-to-end walkthroughs of using certain APIs.
1. Explore the left navigation for the full list of features, [common API patterns](./reference/patterns.md), [types](./reference/types.md), and [error codes](./reference/errors.md).

## Make requests within experiences

`Class.HttpService` lets you make HTTP requests to a subset of the Open Cloud endpoints. For more information, see [In-experience HTTP requests](../cloud-services/http-service.md).

## Source

- Original documentation: https://create.roblox.com/docs/cloud
- GitHub source: https://github.com/Roblox/creator-docs/blob/main/content/en-us/cloud/index.md
- Captured: 2026-04-16
