---
title: buffer Type
type: luau-feature
category: luau
subcategory: stdlib
owner: luau-systems-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/luau/buffer-library.md
  - wiki/raw/luau-spec/library/standard-library.md
  - wiki/raw/luau-spec/rfcs/type-byte-buffer.md
  - wiki/raw/luau-spec/rfcs/function-buffer-bits.md
  - wiki/raw/community/performance/network/luau-buffer-type.md
related:
  - "[[table-library]]"
  - "[[string-library]]"
  - "[[math-library]]"
tags: [luau, stdlib, buffer, binary, performance, network]
---

# `buffer` Type

> A fixed-size mutable block of memory for efficient binary data storage and manipulation. Replaces `string.pack`/`string.unpack` for use cases requiring in-place mutation, compact serialization, and high-performance binary I/O.

## Syntax

All functions are accessed via the global `buffer` variable. Offsets are **zero-based** (offset 0 accesses the first byte). All multi-byte operations use **little-endian** byte order.

### Creation and conversion

```lua
buffer.create(size: number) -> buffer        -- zero-initialized; max 1 GiB
buffer.fromstring(str: string) -> buffer     -- size = #str
buffer.tostring(b: buffer) -> string
buffer.len(b: buffer) -> number              -- size in bytes
```

### Integer read/write

```lua
-- Signed
buffer.readi8(b, offset) -> number    -- [-128, 127]
buffer.readi16(b, offset) -> number   -- [-32768, 32767]
buffer.readi32(b, offset) -> number   -- [-2^31, 2^31-1]

-- Unsigned
buffer.readu8(b, offset) -> number    -- [0, 255]
buffer.readu16(b, offset) -> number   -- [0, 65535]
buffer.readu32(b, offset) -> number   -- [0, 2^32-1]

-- Matching write functions
buffer.writei8(b, offset, value)
buffer.writei16(b, offset, value)
buffer.writei32(b, offset, value)
buffer.writeu8(b, offset, value)
buffer.writeu16(b, offset, value)
buffer.writeu32(b, offset, value)
```

### Float read/write

```lua
buffer.readf32(b, offset) -> number   -- IEEE 754 single precision
buffer.readf64(b, offset) -> number   -- IEEE 754 double precision
buffer.writef32(b, offset, value)
buffer.writef64(b, offset, value)
```

### String read/write

```lua
buffer.readstring(b, offset, count) -> string
buffer.writestring(b, offset, value, count?)  -- count limits bytes written
```

### Bit-level access

```lua
buffer.readbits(b, bitOffset, bitCount) -> number   -- bitCount in [0, 32]
buffer.writebits(b, bitOffset, bitCount, value)     -- unsigned, least significant bits
```

### Bulk operations

```lua
buffer.copy(target, targetOffset, source, sourceOffset?, count?)
buffer.fill(b, offset, value, count?)  -- value in [0, 255]; omit count to fill to end
```

## Semantics

### Fixed size

Buffers are allocated once and cannot be resized. To grow a buffer, create a new larger buffer and use `buffer.copy` to transfer data.

### Zero-based offsets

Unlike Luau tables and strings (1-based), buffer offsets start at 0. This aligns with binary format specifications and avoids off-by-one overhead.

```lua
local b = buffer.create(4)
buffer.writeu8(b, 0, 0xFF)  -- first byte
buffer.writeu8(b, 3, 0xAA)  -- fourth byte
```

### Bounds checking

Every read/write operation validates that the accessed bytes are within the buffer. Out-of-bounds access throws a runtime error.

### Unaligned access

Read/write operations work at any byte offset. A `readi32` at offset 1 is valid (no alignment requirement). This differs from some native memory models.

### Identity not preserved across Roblox APIs

When a buffer passes through RemoteEvents, BindableEvents, or DataStores, the receiver gets a **copy**. The same buffer object cannot be shared across `Actor` scripts (Parallel Luau).

### NaN handling

If a stored float bit pattern represents NaN, the read function may return a different quiet NaN representation. This is a consequence of IEEE 754 NaN canonicalization.

### Deviation from Lua 5.1

The `buffer` type does not exist in Lua 5.1. It is entirely a Luau addition. Metatables cannot be set on buffers from Luau code.

## Examples

### Network serialization of part positions

```lua
--!strict
local BYTES_PER_PART = 18  -- 12 (position f32x3) + 6 (orientation i16x3)

local function packParts(parts: {BasePart}): buffer
    local buf = buffer.create(#parts * BYTES_PER_PART)
    for i, part in parts do
        local offset = (i - 1) * BYTES_PER_PART
        local pos = part.Position
        local ori = part.Orientation

        buffer.writef32(buf, offset + 0, pos.X)
        buffer.writef32(buf, offset + 4, pos.Y)
        buffer.writef32(buf, offset + 8, pos.Z)

        -- Store orientation as fixed-point (degrees * 100) in 16 bits
        buffer.writei16(buf, offset + 12, math.round(ori.X * 100))
        buffer.writei16(buf, offset + 14, math.round(ori.Y * 100))
        buffer.writei16(buf, offset + 16, math.round(ori.Z * 100))
    end
    return buf
end

local function unpackPosition(buf: buffer, index: number): (Vector3, Vector3)
    local offset = index * BYTES_PER_PART
    local pos = Vector3.new(
        buffer.readf32(buf, offset + 0),
        buffer.readf32(buf, offset + 4),
        buffer.readf32(buf, offset + 8)
    )
    local ori = Vector3.new(
        buffer.readi16(buf, offset + 12) / 100,
        buffer.readi16(buf, offset + 14) / 100,
        buffer.readi16(buf, offset + 16) / 100
    )
    return pos, ori
end
```

### Compact inventory encoding

```lua
-- Each item: 2 bytes (u16 item ID) + 2 bytes (u16 quantity)
local ITEM_SIZE = 4

local function packInventory(items: {{id: number, qty: number}}): buffer
    local buf = buffer.create(#items * ITEM_SIZE)
    for i, item in items do
        local offset = (i - 1) * ITEM_SIZE
        buffer.writeu16(buf, offset, item.id)
        buffer.writeu16(buf, offset + 2, item.qty)
    end
    return buf
end
```

### Bit-level flags

```lua
local buf = buffer.create(1)

-- Store 8 boolean flags in a single byte
buffer.writebits(buf, 0, 1, 1)  -- flag 0 = true
buffer.writebits(buf, 1, 1, 0)  -- flag 1 = false
buffer.writebits(buf, 2, 1, 1)  -- flag 2 = true

local flag0 = buffer.readbits(buf, 0, 1) == 1  --> true
local flag1 = buffer.readbits(buf, 1, 1) == 1  --> false
```

## Pitfalls

- **No automatic cursor.** You must manually track read/write offsets. Off-by-one errors are common; define constants for field sizes and compute offsets arithmetically.
- **Fixed size requires planning.** Pre-calculate the required size before creating. If the data size is dynamic, allocate for the maximum or resize via copy.
- **Zero-based indexing.** Unlike every other Luau data structure (tables, strings), buffers start at offset 0. Mixing 1-based and 0-based indexing in the same code is a common source of bugs.
- **Little-endian only.** If interoperating with big-endian systems, manual byte swapping is needed.
- **Compression is transparent on the wire.** When sent via RemoteEvents, Roblox applies Zstd compression automatically. Repetitive data compresses well; random data does not.
- **DataStore UTF-8 limitation.** Storing raw binary data in DataStores may fail if the buffer contains invalid UTF-8 sequences. Convert to base64 or hex if needed.
- **Max 50 MB per remote event transmission.**

### Platform support

| Feature | Supported |
|---|---|
| RemoteEvent / BindableEvent | Yes |
| DataStoreService | Yes |
| MemoryStoreService | Yes |
| MessagingService | Yes |
| TeleportService | Yes |
| HttpService (JSON) | Yes |
| Attributes | No |

## Related

- [[table-library]]
- [[string-library]]
- [[math-library]]

## Sources

- [Roblox Creator Docs: buffer Library](../raw/roblox-creator-docs/luau/buffer-library.md)
- [Luau Standard Library Reference](../raw/luau-spec/library/standard-library.md)
- [RFC: Buffer Type](../raw/luau-spec/rfcs/type-byte-buffer.md)
- [RFC: buffer.readbits / buffer.writebits](../raw/luau-spec/rfcs/function-buffer-bits.md)
- [DevForum: Luau Buffer Type](../raw/community/performance/network/luau-buffer-type.md)
