---
title: HttpService
type: service
category: services
subcategory: networking
owner: luau-systems-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/HttpService.md
related:
  - "[[open-cloud-api]]"
  - "[[RemoteEvent]]"
tags: [roblox-class, networking, server-only]
---

# HttpService

> Server-only service for outbound HTTP requests, JSON encoding/decoding, and GUID generation. [[RemoteEvent]]

## Summary

HttpService allows experience servers to send HTTP requests to external web services using `RequestAsync`, `GetAsync`, and `PostAsync`. This enables integration with third-party analytics, data storage, remote configuration, error reporting, or real-time communication. It can also call a subset of the Open Cloud APIs.

Beyond HTTP requests, HttpService provides `JSONEncode` and `JSONDecode` for JSON serialization (usable even with HTTP disabled), `GenerateGUID` for random UUID v4 strings, `UrlEncode` for percent-encoding, and `GetSecret` for accessing the experience secrets store. The JSON and GUID methods work on both client and server without enabling HTTP.

HTTP must be explicitly enabled per experience via Game Settings > Security > Allow HTTP Requests. Only send requests to trusted third-party platforms. The service also supports `CreateWebStreamClient` for SSE/WebSocket streaming, but this is Studio-only and must be removed before publishing.

## API Surface

### Properties

- `HttpEnabled: boolean` -- Whether HTTP requests can be sent. Must be enabled in Experience Settings (not scriptable in published places).

### Methods

- `:RequestAsync(requestOptions: Dictionary) -> Dictionary` -- Sends an HTTP request with full control (method, headers, body, compression, timeout). Returns a response dictionary with `Success`, `StatusCode`, `Headers`, `Body`. Yields.
- `:GetAsync(url: string, nocache: boolean?, headers: any?) -> string` -- Shorthand for GET requests. Returns the response body only. Yields.
- `:PostAsync(url: string, data: string, contentType: Enum.HttpContentType?, compress: boolean?, headers: any?) -> string` -- Shorthand for POST requests. Returns the response body only. Yields.
- `:JSONEncode(input: any) -> string` -- Converts a Luau table to a JSON string. Works without HTTP enabled. Accepts buffers up to 50 MiB.
- `:JSONDecode(input: string) -> any` -- Converts a JSON string to a Luau table. Works without HTTP enabled.
- `:GenerateGUID(wrapInCurlyBraces: boolean?) -> string` -- Generates a random UUID v4 string. Default wraps in curly braces.
- `:UrlEncode(input: string) -> string` -- Percent-encodes a string for URL safety.
- `:GetSecret(key: string) -> Secret` -- Returns a Secret from the experience secrets store. Not printable, not available locally.
- `:CreateWebStreamClient(streamClientType, requestOptions) -> WebStreamClient` -- Studio-only. Creates a streaming connection (SSE, WebSocket). Limit of 6 simultaneous clients.

### Events

_No public events._

## Budgets and Limits

- **External HTTP requests**: 500 requests per minute per server
- **Open Cloud requests**: 2,500 requests per minute per server (separate limit)
- **WebStreamClient**: Maximum 6 simultaneous streaming clients (Studio only)
- **JSONEncode buffer limit**: 50 MiB for buffer inputs
- **Response timeout**: Configurable via the `Timeout` field in RequestAsync

## Common Patterns

### Sending a GET request with error handling

```lua
local HttpService = game:GetService("HttpService")

local success, result = pcall(function()
    return HttpService:RequestAsync({
        Url = "https://api.example.com/data",
        Method = "GET",
        Headers = {
            ["Authorization"] = "Bearer token123",
        },
    })
end)

if success and result.Success then
    local data = HttpService:JSONDecode(result.Body)
    print("Received:", data)
else
    warn("HTTP request failed:", result)
end
```

### JSON round-trip (no HTTP needed)

```lua
local HttpService = game:GetService("HttpService")

local data = { name = "Sword", damage = 50, enchanted = true }
local json = HttpService:JSONEncode(data)
print(json) -- {"name":"Sword","damage":50,"enchanted":true}

local decoded = HttpService:JSONDecode(json)
print(decoded.name) -- Sword
```

## Pitfalls

- **Must be enabled**: HTTP requests fail silently if `HttpEnabled` is not toggled on in Experience Settings.
- **Server-only**: HTTP requests can only be made from server scripts. Never expose HttpService access through remotes to the client.
- **Always pcall**: External services can timeout or reject requests. Wrap in pcall and handle failure gracefully.
- **Content-Type header**: `RequestAsync` does not auto-detect body format. Set `Content-Type` header manually when sending JSON (`application/json`).
- **inf/nan in JSONEncode**: The encoder allows `inf` and `nan` which are not valid JSON. This can cause issues with external services.
- **Empty table ambiguity**: An empty Luau table `{}` encodes as an empty JSON array `[]`, not an empty object `{}`.

## Related

- [[open-cloud-api]] -- using HttpService with Roblox Open Cloud
- [[RemoteEvent]] -- for client-server communication within the experience

## Sources

- [wiki/raw/roblox-creator-docs/services/HttpService.md](../raw/roblox-creator-docs/services/HttpService.md)
