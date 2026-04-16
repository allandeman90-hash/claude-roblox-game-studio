---
title: Luau Buffer Type - Compact Binary Data
type: raw-source
source_url: https://devforum.roblox.com/t/introducing-luau-buffer-type-beta/2724894
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: network
tags: [buffer, binary-encoding, serialization, network, bandwidth]
---

# Luau Buffer Type

## What is the Buffer Type

The Luau buffer type is "a fixed-size block of memory" introduced as a Beta feature in Roblox Studio (November 2023). Unlike strings, buffers support mutable binary data and direct byte interpretation as numeric types.

## Core Functions

### Creation
- `buffer.create(size)` - Creates zero-initialized buffer
- `buffer.fromstring(str)` - Converts string to buffer

### Reading/Writing
- `buffer.readi8`, `buffer.readi16`, `buffer.readu32`, `buffer.readf32`, `buffer.readf64` - Read operations
- `buffer.writei8`, `buffer.writei16`, `buffer.writeu32`, `buffer.writef32` - Write operations
- `buffer.tostring(buf)` - Convert to string
- `buffer.copy(src, srcOffset, dst, dstOffset, size)` - Buffer copying

## Network Serialization Example

```lua
local buf = buffer.create(#objects * (12 + 6))

for i, obj: Part in objects do
    local offset = (i - 1) * (12 + 6)
    local pos, ori = obj.Position, obj.Orientation
    
    buffer.writef32(buf, offset + 0, pos.X)
    buffer.writef32(buf, offset + 4, pos.Y)
    buffer.writef32(buf, offset + 8, pos.Z)
    
    buffer.writei16(buf, offset + 12, math.round(ori.X * 100))
    buffer.writei16(buf, offset + 14, math.round(ori.Y * 100))
    buffer.writei16(buf, offset + 16, math.round(ori.Z * 100))
end
```

This packs position (12 bytes) and orientation (6 bytes) into 18 bytes per part.

## Performance & Compression Benefits

### Advantages over alternatives
- **vs. Strings**: "Faster to extract data from" and support direct generation
- **vs. Number Arrays**: More compact memory footprint, reduced storage/transmission size, minimal garbage collection overhead
- **Compression**: Implements "transparent on-the-wire compression" using **Zstd algorithm** for network transmission

### Network Guidelines
- **Maximum: 50 MB per remote event transmission**
- Larger buffers benefit more from compression
- Grouping smaller buffers increases compression efficiency

## Use Cases

- Terrain serialization
- Audio/image processing
- Custom replication systems
- Voxel game chunk storage
- Physics data replication
- Inventory systems using ID-based encoding

## Platform Support (as of Feb 2024)

- Bindable/Remote events: Yes
- Network replication: Yes
- DataStore, MemoryStore: Yes
- MessagingService: Yes
- TeleportService: Yes
- HttpService (JSON encode/decode): Yes
- Attributes: Not yet supported

## Important Limitations

- **No cursors**: Manual offset tracking required
- **Fixed size**: Pre-allocation necessary; adaptive resizing via `buffer.create`/`buffer.copy`
- **Byte-based**: Bit-level manipulation not natively supported
- **UTF-8 incompatible**: Cannot directly store non-UTF8 data in DataStores without encoding

## Measurements / Numbers

| Metric | Value |
|--------|-------|
| Max per remote transmission | 50 MB |
| Compression algorithm | Zstd |
| Position bytes (f32 x3) | 12 bytes |
| Orientation bytes (i16 x3) | 6 bytes |
| MessagingService overhead | 35 + ceil(bytes/3) * 4 |

## Source

Original URL: https://devforum.roblox.com/t/introducing-luau-buffer-type-beta/2724894
Captured: 2026-04-16
