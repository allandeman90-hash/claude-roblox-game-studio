---
title: MessagingService
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/MessagingService
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/MessagingService.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: networking
tags: [roblox-class, messaging, cross-server, service]
---

# MessagingService

Allows servers of the same experience to communicate with each other.

## Description

**MessagingService** allows servers of the same experience to communicate with
each other in real time (less than 1 second) using topics. Topics are
developer‑defined strings (1–80 characters) that servers use to send and
receive messages.

Delivery is best effort and not guaranteed. Make sure to architect your
experience so delivery failures are not critical.

[Cross-Server Messaging](../../../cloud-services/cross-server-messaging.md)
explores how to communicate between servers in greater detail.

If you want to publish ad-hoc messages to live game servers, or publish across
experiences, you can use the
[Open Cloud APIs](../../../cloud/guides/usage-messaging.md).

#### Limitations

Note that these limits are subject to change.

<table>
	<thead>
		<tr>
			<th>Limit</th>
			<th>Maximum</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>
				<b>Size of message</b>
			</td>
			<td>
				1kB
			</td>
		</tr>
		<tr>
			<td>
				<b>Messages sent per game server</b>
			</td>
			<td>
				 600 + 240 * (number of players in this game server) per minute
			</td>
		</tr>
		<tr>
			<td>
				<b>Messages received per topic</b>
			</td>
			<td>
				(40 + 80 * number of servers) per minute
			</td>
		</tr>
		<tr>
			<td>
				<b>Messages received for entire game</b>
			</td>
			<td>
				 (400 + 200 * number of servers) per minute
			</td>
		</tr>
    <tr>
			<td>
				<b>Subscriptions allowed per game server</b>
			</td>
			<td>
				 20 + 8 * (number of players in this game server)
			</td>
		</tr>
    <tr>
			<td>
				<b>Subscribe requests per game server</b>
			</td>
			<td>
				 240 requests per minute
			</td>
		</tr>
	</tbody>
</table>

## Inheritance

Inherits from: `Instance`

Class tags: `NotCreatable`, `Service`, `NotReplicated`

Memory category: `Instances`

## Properties

_No public properties documented._

## Methods

### `MessagingService:PublishAsync`

```
PublishAsync(topic: string, message: Variant) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`ServerCommunication`

Invokes the supplied callback whenever a message is pushed to the topic.

This function sends the provided message to all subscribers to the topic,
triggering their registered callbacks to be invoked.

Yields until the message is received by the backend.

**Parameters:**

- `topic` : `string` — Determines where the message is sent.
- `message` : `Variant` — The data to include in the message.

**Returns:**

- `()` — 

### `MessagingService:SubscribeAsync`

```
SubscribeAsync(topic: string, callback: Function) -> RBXScriptConnection
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`ServerCommunication`

Begins listening to the given topic.

This function registers a callback to begin listening to the given topic.
The callback is invoked when a topic receives a message. It can be called
multiple times for the same topic.

#### Callback

The callback is invoked with a single argument, a table with the following
entries:

<table>
	<thead>
		<tr>
			<th>Field</th>
			<th>Summary</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>
				<b>Data</b>
			</td>
			<td>
				Developer supplied payload
			</td>
		</tr>
		<tr>
			<td>
				<b>Sent</b>
			</td>
			<td>
				Unix time in seconds at which the message was sent
			</td>
		</tr>
	</tbody>
</table>

It yields until the subscription is properly registered and returns a
connection object.

To unsubscribe, call `Datatype.RBXScriptConnection|Disconnect()` on the
returned object. Once called, the callback should never be invoked.
Killing the script containing the connections also causes the underlying
connect to be unsubscribed.

See also `Class.MessagingService:PublishAsync()` which sends the provided
message to all subscribers to the topic, triggering their registered
callbacks to be invoked.

**Parameters:**

- `topic` : `string` — Determines where to listen for messages.
- `callback` : `Function` — Function to be invoked whenever a message is received.

**Returns:**

- `RBXScriptConnection` — Connection that can be used to unsubscribe from the topic.

## Events

_No public events documented._

## Notes / Deprecations

- Method `MessagingService:PublishAsync` yields (tag `Yields`).
- Method `MessagingService:SubscribeAsync` yields (tag `Yields`).

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- MessagingService:SubscribeAsync: subscribing-to-cross-server-messages

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/MessagingService
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/MessagingService.yaml
- Captured: 2026-04-16
