---
title: Service Reference Index
type: raw-source-index
captured_by: research-agent-1
captured_at: 2026-04-16
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
---

# Roblox Service Reference Index

Raw capture of the official Roblox Creator Documentation class reference pages. Each row links to the rendered doc; underlying text was pulled from the official `Roblox/creator-docs` GitHub repository (authoritative YAML source) on 2026-04-16.

## Tier 1 (captured)

| Class | Category | Source URL | Captured | Summary |
|-------|----------|------------|----------|---------|
| [DataStoreService](DataStoreService.md) | persistence | [DataStoreService docs](https://create.roblox.com/docs/reference/engine/classes/DataStoreService) | 2026-04-16 | A game service that gives access to persistent data storage across places in a game. |
| [GlobalDataStore](GlobalDataStore.md) | persistence | [GlobalDataStore docs](https://create.roblox.com/docs/reference/engine/classes/GlobalDataStore) | 2026-04-16 | An object that exposes methods to access a single data store. |
| [OrderedDataStore](OrderedDataStore.md) | persistence | [OrderedDataStore docs](https://create.roblox.com/docs/reference/engine/classes/OrderedDataStore) | 2026-04-16 | A GlobalDataStore that also allows for ordered data store entries. |
| [DataStoreKeyInfo](DataStoreKeyInfo.md) | persistence | [DataStoreKeyInfo docs](https://create.roblox.com/docs/reference/engine/classes/DataStoreKeyInfo) | 2026-04-16 | An object specifying information about a particular version of the key. |
| [MemoryStoreService](MemoryStoreService.md) | memory-store | [MemoryStoreService docs](https://create.roblox.com/docs/reference/engine/classes/MemoryStoreService) | 2026-04-16 | Exposes methods to access specific primitives within MemoryStore. |
| [MemoryStoreSortedMap](MemoryStoreSortedMap.md) | memory-store | [MemoryStoreSortedMap docs](https://create.roblox.com/docs/reference/engine/classes/MemoryStoreSortedMap) | 2026-04-16 | Provides access to a sorted map within `Class.MemoryStoreService`. |
| [MemoryStoreHashMap](MemoryStoreHashMap.md) | memory-store | [MemoryStoreHashMap docs](https://create.roblox.com/docs/reference/engine/classes/MemoryStoreHashMap) | 2026-04-16 | Provides access to a hash map within `Class.MemoryStoreService`. |
| [MemoryStoreQueue](MemoryStoreQueue.md) | memory-store | [MemoryStoreQueue docs](https://create.roblox.com/docs/reference/engine/classes/MemoryStoreQueue) | 2026-04-16 | Provides access to a queue within MemoryStore. |
| [RemoteEvent](RemoteEvent.md) | networking | [RemoteEvent docs](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent) | 2026-04-16 | An object which facilitates asynchronous, one-way communication across the client-server boundary. Scripts firing a `Class.RemoteEvent` do not yield. |
| [RemoteFunction](RemoteFunction.md) | networking | [RemoteFunction docs](https://create.roblox.com/docs/reference/engine/classes/RemoteFunction) | 2026-04-16 | An object which facilitates synchronous, two-way communication across the client-server boundary. Scripts invoking a `Class.RemoteFunction` yield until they receive a response from the recipient. |
| [UnreliableRemoteEvent](UnreliableRemoteEvent.md) | networking | [UnreliableRemoteEvent docs](https://create.roblox.com/docs/reference/engine/classes/UnreliableRemoteEvent) | 2026-04-16 | An object which facilitates asynchronous, unordered and unreliable, one-way communication across the client-server boundary. Scripts firing a `Class.UnreliableRemoteEvent` do not yield. |
| [BindableEvent](BindableEvent.md) | events | [BindableEvent docs](https://create.roblox.com/docs/reference/engine/classes/BindableEvent) | 2026-04-16 | An object which enables custom events through asynchronous one-way communication between scripts on the same side of the client-server boundary. Scripts firing a `Class.BindableEvent` do not yield. |
| [BindableFunction](BindableFunction.md) | events | [BindableFunction docs](https://create.roblox.com/docs/reference/engine/classes/BindableFunction) | 2026-04-16 | An object which allows for synchronous two-way communication between scripts on the same side of the client-server boundary. Scripts invoking a `Class.BindableFunction` yield until the correspondin... |
| [MarketplaceService](MarketplaceService.md) | economy | [MarketplaceService docs](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService) | 2026-04-16 | The service responsible for in-experience transactions. |
| [Players](Players.md) | players | [Players docs](https://create.roblox.com/docs/reference/engine/classes/Players) | 2026-04-16 | A service that contains presently connected `Class.Player` objects. |
| [Player](Player.md) | players | [Player docs](https://create.roblox.com/docs/reference/engine/classes/Player) | 2026-04-16 | An object that represents a presently connected client to the experience. |
| [PlayerGui](PlayerGui.md) | gui | [PlayerGui docs](https://create.roblox.com/docs/reference/engine/classes/PlayerGui) | 2026-04-16 | A container for a player's currently rendered `Class.ScreenGui\|ScreenGuis`. |
| [StarterGui](StarterGui.md) | gui | [StarterGui docs](https://create.roblox.com/docs/reference/engine/classes/StarterGui) | 2026-04-16 | A container for `Class.LayerCollector` objects to be copied into the `Class.PlayerGui` of `Class.Player\|Players`. Also provides a range of functions for interacting with the `Class.CoreGui`. |
| [StarterPlayer](StarterPlayer.md) | players | [StarterPlayer docs](https://create.roblox.com/docs/reference/engine/classes/StarterPlayer) | 2026-04-16 | A service which allows the defaults of properties in the `Class.Player` object to be set. |
| [StarterPlayerScripts](StarterPlayerScripts.md) | players | [StarterPlayerScripts docs](https://create.roblox.com/docs/reference/engine/classes/StarterPlayerScripts) | 2026-04-16 | A container for objects to be copied to a Player's PlayerScripts when they join a game. |
| [StarterCharacterScripts](StarterCharacterScripts.md) | players | [StarterCharacterScripts docs](https://create.roblox.com/docs/reference/engine/classes/StarterCharacterScripts) | 2026-04-16 | Stores instances to be parented to a player's character when it spawns. |
| [ReplicatedStorage](ReplicatedStorage.md) | containers | [ReplicatedStorage docs](https://create.roblox.com/docs/reference/engine/classes/ReplicatedStorage) | 2026-04-16 | A container service for objects that are replicated to all clients. |
| [ServerStorage](ServerStorage.md) | containers | [ServerStorage docs](https://create.roblox.com/docs/reference/engine/classes/ServerStorage) | 2026-04-16 | A container whose contents are only accessible on the server. Objects descending from ServerStorage will not replicate to the client and will not be accessible from `Class.LocalScript\|LocalScripts`. |
| [ServerScriptService](ServerScriptService.md) | containers | [ServerScriptService docs](https://create.roblox.com/docs/reference/engine/classes/ServerScriptService) | 2026-04-16 | A container service for server-only `Class.Script` objects. |
| [ReplicatedFirst](ReplicatedFirst.md) | containers | [ReplicatedFirst docs](https://create.roblox.com/docs/reference/engine/classes/ReplicatedFirst) | 2026-04-16 | A container whose contents are replicated to all clients (but not back to the server) first before anything else. |
| [Workspace](Workspace.md) | world | [Workspace docs](https://create.roblox.com/docs/reference/engine/classes/Workspace) | 2026-04-16 | **Workspace** houses 3D objects which are rendered to the 3D world. Objects not descending from it will not be rendered or physically interact with the world. |
| [RunService](RunService.md) | runtime | [RunService docs](https://create.roblox.com/docs/reference/engine/classes/RunService) | 2026-04-16 | Service responsible for all runtime activity and progression of time. |
| [Lighting](Lighting.md) | environment | [Lighting docs](https://create.roblox.com/docs/reference/engine/classes/Lighting) | 2026-04-16 | The `Lighting` service controls global lighting in an experience. It includes a range of adjustable properties that you can use to change how lighting appears and interacts with other objects. |
| [SoundService](SoundService.md) | audio | [SoundService docs](https://create.roblox.com/docs/reference/engine/classes/SoundService) | 2026-04-16 | A service that determines various aspects of how the audio engine works. Most of its properties affect how `Class.Sound\|Sounds` play in the experience. |
| [Sound](Sound.md) | audio | [Sound docs](https://create.roblox.com/docs/reference/engine/classes/Sound) | 2026-04-16 | An object that emits sound. This object can be placed within a `Class.BasePart` or `Class.Attachment` to emit a sound from a particular position within a place or world, or it can be attached elsew... |
| [SoundGroup](SoundGroup.md) | audio | [SoundGroup docs](https://create.roblox.com/docs/reference/engine/classes/SoundGroup) | 2026-04-16 | A `Class.SoundGroup` is used to manage the volume and sound effects on multiple `Class.Sound\|Sounds` at once. `Class.Sound\|Sounds` in the SoundGroup will have their volume and effects adjusted by t... |
| [TweenService](TweenService.md) | animation | [TweenService docs](https://create.roblox.com/docs/reference/engine/classes/TweenService) | 2026-04-16 | Used to create `Class.Tween\|Tweens` which interpolate, or tween, the properties of instances. |
| [Tween](Tween.md) | animation | [Tween docs](https://create.roblox.com/docs/reference/engine/classes/Tween) | 2026-04-16 | The `Class.Tween` object controls the playback of an interpolation. |
| [TeleportService](TeleportService.md) | networking | [TeleportService docs](https://create.roblox.com/docs/reference/engine/classes/TeleportService) | 2026-04-16 | Enables transporting `Class.Player\|Players` between places and servers. For more information on how to teleport players between servers, see [Teleport between places](../../../projects/teleport.md). |
| [HttpService](HttpService.md) | networking | [HttpService docs](https://create.roblox.com/docs/reference/engine/classes/HttpService) | 2026-04-16 | Allows sending HTTP requests and provides various web-related and JSON methods. |
| [TextChatService](TextChatService.md) | chat | [TextChatService docs](https://create.roblox.com/docs/reference/engine/classes/TextChatService) | 2026-04-16 | A service handling in-experience text chat. |
| [MessagingService](MessagingService.md) | networking | [MessagingService docs](https://create.roblox.com/docs/reference/engine/classes/MessagingService) | 2026-04-16 | Allows servers of the same experience to communicate with each other. |
| [CollectionService](CollectionService.md) | world | [CollectionService docs](https://create.roblox.com/docs/reference/engine/classes/CollectionService) | 2026-04-16 | A service which manages instance collections using assigned tags. |
| [ContextActionService](ContextActionService.md) | input | [ContextActionService docs](https://create.roblox.com/docs/reference/engine/classes/ContextActionService) | 2026-04-16 | A service used to bind user input to contextual actions. |
| [UserInputService](UserInputService.md) | input | [UserInputService docs](https://create.roblox.com/docs/reference/engine/classes/UserInputService) | 2026-04-16 | `UserInputService` is primarily used to detect the input types available on a user's device, as well as detect input events. |
| [GuiService](GuiService.md) | gui | [GuiService docs](https://create.roblox.com/docs/reference/engine/classes/GuiService) | 2026-04-16 | Offers numerous properties and methods for working with `Class.GuiObject\|GuiObjects`, player preferences, and other UI‑related tasks. |
| [ProximityPrompt](ProximityPrompt.md) | interaction | [ProximityPrompt docs](https://create.roblox.com/docs/reference/engine/classes/ProximityPrompt) | 2026-04-16 | An object that lets you prompt players to interact with an object in the 3D world. |
| [ClickDetector](ClickDetector.md) | interaction | [ClickDetector docs](https://create.roblox.com/docs/reference/engine/classes/ClickDetector) | 2026-04-16 | An object that provides user input on in-experience `Class.BasePart\|BaseParts` and `Class.Model\|Models`. |

## Tier 2 — Foundational Classes (captured)

| Class | Category | Source URL | Captured | Summary |
|-------|----------|------------|----------|---------|
| [Instance](Instance.md) | core | [Instance docs](https://create.roblox.com/docs/reference/engine/classes/Instance) | 2026-04-16 | The base class for all classes in the Roblox class hierarchy which can be part of the DataModel tree. |
| [BasePart](BasePart.md) | core | [BasePart docs](https://create.roblox.com/docs/reference/engine/classes/BasePart) | 2026-04-16 | The abstract base class for in-world objects that physically interact. |
| [Part](Part.md) | world | [Part docs](https://create.roblox.com/docs/reference/engine/classes/Part) | 2026-04-16 | A common type of BasePart that comes in different primitive shapes. |
| [MeshPart](MeshPart.md) | world | [MeshPart docs](https://create.roblox.com/docs/reference/engine/classes/MeshPart) | 2026-04-16 | A form of BasePart that includes a physically simulated custom mesh. |
| [Model](Model.md) | world | [Model docs](https://create.roblox.com/docs/reference/engine/classes/Model) | 2026-04-16 | Container objects that group BaseParts together. |
| [Camera](Camera.md) | rendering | [Camera docs](https://create.roblox.com/docs/reference/engine/classes/Camera) | 2026-04-16 | A class which defines a view of the 3D world. |
| [Terrain](Terrain.md) | world | [Terrain docs](https://create.roblox.com/docs/reference/engine/classes/Terrain) | 2026-04-16 | A voxel-based terrain system for building large-scale environments. |
| [Attachment](Attachment.md) | physics | [Attachment docs](https://create.roblox.com/docs/reference/engine/classes/Attachment) | 2026-04-16 | Defines a CFrame relative to a BasePart for use with constraints and other objects. |
| [Motor6D](Motor6D.md) | physics | [Motor6D docs](https://create.roblox.com/docs/reference/engine/classes/Motor6D) | 2026-04-16 | A joint that animates between two parts, used for character rigs. |
| [WeldConstraint](WeldConstraint.md) | physics | [WeldConstraint docs](https://create.roblox.com/docs/reference/engine/classes/WeldConstraint) | 2026-04-16 | Joins two BaseParts as a rigid body. |
| [Debris](Debris.md) | utility | [Debris docs](https://create.roblox.com/docs/reference/engine/classes/Debris) | 2026-04-16 | Service for scheduling cleanup of instances after a delay. |
| [Frame](Frame.md) | gui | [Frame docs](https://create.roblox.com/docs/reference/engine/classes/Frame) | 2026-04-16 | A GuiObject that renders as a plain rectangle, generally used as a container. |
| [TextLabel](TextLabel.md) | gui | [TextLabel docs](https://create.roblox.com/docs/reference/engine/classes/TextLabel) | 2026-04-16 | A 2D user interface element that displays non-interactive text. |
| [TextButton](TextButton.md) | gui | [TextButton docs](https://create.roblox.com/docs/reference/engine/classes/TextButton) | 2026-04-16 | A 2D user interface element that displays interactive text. |
| [ImageLabel](ImageLabel.md) | gui | [ImageLabel docs](https://create.roblox.com/docs/reference/engine/classes/ImageLabel) | 2026-04-16 | A 2D user interface element that displays a non-interactive image. |
| [ImageButton](ImageButton.md) | gui | [ImageButton docs](https://create.roblox.com/docs/reference/engine/classes/ImageButton) | 2026-04-16 | A 2D user interface element that displays an interactive image. |
| [ScrollingFrame](ScrollingFrame.md) | gui | [ScrollingFrame docs](https://create.roblox.com/docs/reference/engine/classes/ScrollingFrame) | 2026-04-16 | A Frame with scrollable content area. |
| [UIListLayout](UIListLayout.md) | gui-layout | [UIListLayout docs](https://create.roblox.com/docs/reference/engine/classes/UIListLayout) | 2026-04-16 | Lays out sibling GuiObjects in a list. |
| [UIGridLayout](UIGridLayout.md) | gui-layout | [UIGridLayout docs](https://create.roblox.com/docs/reference/engine/classes/UIGridLayout) | 2026-04-16 | Lays out sibling GuiObjects in a grid. |
| [UIAspectRatioConstraint](UIAspectRatioConstraint.md) | gui-layout | [UIAspectRatioConstraint docs](https://create.roblox.com/docs/reference/engine/classes/UIAspectRatioConstraint) | 2026-04-16 | Constrains the aspect ratio of a GuiObject. |
| [UIScale](UIScale.md) | gui-layout | [UIScale docs](https://create.roblox.com/docs/reference/engine/classes/UIScale) | 2026-04-16 | Scales a GuiObject and its descendants. |
| [UICorner](UICorner.md) | gui-layout | [UICorner docs](https://create.roblox.com/docs/reference/engine/classes/UICorner) | 2026-04-16 | Applies rounded corners to a GuiObject. |
| [UIStroke](UIStroke.md) | gui-layout | [UIStroke docs](https://create.roblox.com/docs/reference/engine/classes/UIStroke) | 2026-04-16 | Applies an outline to a GuiObject or text. |
| [UIPadding](UIPadding.md) | gui-layout | [UIPadding docs](https://create.roblox.com/docs/reference/engine/classes/UIPadding) | 2026-04-16 | Applies padding to a GuiObject. |
| [Animator](Animator.md) | animation | [Animator docs](https://create.roblox.com/docs/reference/engine/classes/Animator) | 2026-04-16 | The main class responsible for the playback and replication of animations. |
| [AnimationTrack](AnimationTrack.md) | animation | [AnimationTrack docs](https://create.roblox.com/docs/reference/engine/classes/AnimationTrack) | 2026-04-16 | Controls the playback of an animation on an Animator. |
| [Animation](Animation.md) | animation | [Animation docs](https://create.roblox.com/docs/reference/engine/classes/Animation) | 2026-04-16 | References an animation asset for use with an Animator. |

## Capture methodology

- The public pages at `create.roblox.com/docs/reference/engine/classes/<Class>` are JavaScript-rendered and return empty bodies to standard `WebFetch`. To preserve fidelity, raw YAML sources were pulled from `https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/<Class>.yaml` — this is the exact same content the live docs site generates from.
- Each `.md` file in this directory is a direct, lossless rendering of the YAML frontmatter into Markdown with preserved `Class.*`/`Datatype.*`/`Global.*` cross-reference markers from the source. No editorializing or paraphrasing.
- Code samples in the source YAML are referenced by ID (e.g. `DataStore-Budget`); the verbatim Luau snippets live in sibling `.md` files in the Roblox repo and can be fetched on-demand by a follow-up pass if needed.

## Related pages not captured in this pass

The Tier 1 YAMLs cross-reference many supporting classes and guide pages that were out of scope for this agent. Follow-up agents may want to capture:

- `DataStore`, `DataStoreOptions`, `DataStoreInfo`, `DataStoreVersionPages`, `DataStoreKeyPages` — raw DataStore surface types
- `MemoryStoreSortedMap`, `MemoryStoreHashMap`, and `MemoryStoreQueue` item/key helper types
- `ProcessReceipt` / developer product receipt callback contract (lives in `MarketplaceService`)
- `TextChannel`, `TextSource`, `ChatWindowConfiguration`, `TextChatCommand`, `BubbleChatConfiguration` — TextChatService ecosystem
- `InputObject`, `TouchObject`, `GamepadState` — UserInputService / ContextActionService companion types
- `TweenInfo` (Datatype), `Enum.EasingStyle`, `Enum.EasingDirection`, `Enum.PlaybackState` — TweenService companions
- `TeleportOptions`, `TeleportAsyncResult`, `TeleportData` — TeleportService payload types
- `Lighting` child atmospheric effects: `Atmosphere`, `Sky`, `Clouds`, `BloomEffect`, `ColorCorrectionEffect`, `DepthOfFieldEffect`, `SunRaysEffect`, `BlurEffect`
- Sound descendants: `EqualizerSoundEffect`, `ReverbSoundEffect`, `CompressorSoundEffect`, `DistortionSoundEffect`, `EchoSoundEffect`, `ChorusSoundEffect`, `FlangeSoundEffect`, `PitchShiftSoundEffect`, `TremoloSoundEffect`
- Data store / memory store / HTTP / teleport guide pages referenced inline (links to `../../../cloud-services/*.md`)

These URLs should be fed to agent-5 (or a follow-up raw-source pass) if a deeper capture is needed.
