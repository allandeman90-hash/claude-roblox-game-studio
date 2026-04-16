---
title: buffer Library
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/libraries/buffer
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-2
category: luau-language
tags: [luau, buffer, binary, memory, little-endian]
---

# buffer Library

A buffer is an object that represents a fixed-size mutable block of memory. The buffer library provides functions for creation and manipulation of buffer objects, providing all its functions inside the global `buffer` variable.

Buffer is intended to be used a low-level binary data storage structure, replacing the uses of `string.pack()` and `string.unpack()`. Use cases include reading and writing existing binary formats, working with data in a more compact form, serialization to custom binary formats, and general work with native memory types like fixed-length integers and floats.

When passed through Roblox APIs, including sending a buffer through custom events, the identity of the buffer object is not preserved and the target will receive a copy. Similar to other limitations, the same buffer object cannot be used from multiple `Actor` scripts (Parallel Luau).

Many of the functions accept an offset in bytes from the start of the buffer. Offset of `0` from the start of the buffer memory block accesses the first byte. All offsets, counts and sizes should be non-negative integer numbers. If the bytes that are accessed by any read or write operation are outside the buffer memory, an error is thrown.

The `read` and `write` methods that work with integers and floats use [little-endian](https://en.wikipedia.org/wiki/Endianness) encoding.

## Functions

### buffer.create

```
buffer.create(size: number): buffer
```

Creates a buffer of the requested size with all bytes initialized to `0`. Size limit is 1 GiB, or 1,073,741,824 bytes.

### buffer.fromstring

```
buffer.fromstring(str: string): buffer
```

Creates a buffer initialized to the contents of the string. The size of the buffer equals the length of the string.

### buffer.tostring

```
buffer.tostring(b: buffer): string
```

Returns the buffer data as a string.

### buffer.len

```
buffer.len(b: buffer): number
```

Returns the size of the buffer in bytes.

### buffer.readbits

```
buffer.readbits(b: buffer, bitOffset: number, bitCount: number): number
```

Reads a range of bits into an unsigned integer from the buffer based on a specific `bitCount` integer from `0` to `32`, inclusive.

- `buffer.readbits(b, 0, 8)` is equivalent to `buffer.readu8(b, 0)`.
- `buffer.readbits(b, 0, 16)` is equivalent to `buffer.readu16(b, 0)`.
- `buffer.readbits(b, 0, 32)` is equivalent to `buffer.readu32(b, 0)`.
- `buffer.readbits(b, 0, 24)` reads 24 bits from the buffer.

### Integer read functions

```
buffer.readi8(b: buffer, offset: number): number    -- 8-bit signed
buffer.readu8(b: buffer, offset: number): number    -- 8-bit unsigned
buffer.readi16(b: buffer, offset: number): number   -- 16-bit signed
buffer.readu16(b: buffer, offset: number): number   -- 16-bit unsigned
buffer.readi32(b: buffer, offset: number): number   -- 32-bit signed
buffer.readu32(b: buffer, offset: number): number   -- 32-bit unsigned
```

Reads the data from the buffer by reinterpreting bytes at the offset as the corresponding integer type and converting it into a number.

### Float read functions

```
buffer.readf32(b: buffer, offset: number): number   -- 32-bit float
buffer.readf64(b: buffer, offset: number): number   -- 64-bit float
```

Reads the data from the buffer by reinterpreting bytes at the offset as a floating-point value. If the floating-point value matches any bit patterns that represent `NaN`, the returned value may be converted to a different quiet `NaN` representation.

### buffer.writebits

```
buffer.writebits(b: buffer, bitOffset: number, bitCount: number, value: number): ()
```

Writes data to the buffer based on a specific `bitCount` integer from `0` to `32`, inclusive. `value` is treated as an unsigned 32-bit number and only `bitCount` least significant bits are written.

### Integer write functions

```
buffer.writei8(b: buffer, offset: number, value: number): ()    -- value in [-128, 127]
buffer.writeu8(b: buffer, offset: number, value: number): ()    -- value in [0, 255]
buffer.writei16(b: buffer, offset: number, value: number): ()   -- [-32,768, 32,767]
buffer.writeu16(b: buffer, offset: number, value: number): ()   -- [0, 65,535]
buffer.writei32(b: buffer, offset: number, value: number): ()   -- [-2^31, 2^31-1]
buffer.writeu32(b: buffer, offset: number, value: number): ()   -- [0, 2^32-1]
```

### Float write functions

```
buffer.writef32(b: buffer, offset: number, value: number): ()
buffer.writef64(b: buffer, offset: number, value: number): ()
```

### buffer.readstring

```
buffer.readstring(b: buffer, offset: number, count: number): string
```

Reads a string of length `count` from the buffer at the specified `offset`.

### buffer.writestring

```
buffer.writestring(b: buffer, offset: number, value: string, count: number?): ()
```

Writes data from a string into the buffer at the specified `offset`. If an optional `count` is specified, only `count` bytes are taken from the string.

### buffer.copy

```
buffer.copy(target: buffer, targetOffset: number, source: buffer, sourceOffset: number? = 0, count: number?): ()
```

Copies `count` bytes from `source` starting at offset `sourceOffset` into the `target` at `targetOffset`. It's possible for `source` and `target` to be the same. Copying an overlapping region inside the same buffer acts as if the source region is copied into a temporary buffer and then that buffer is copied over to the target.

### buffer.fill

```
buffer.fill(b: buffer, offset: number, value: number, count: number?): ()
```

Sets `count` bytes in the buffer starting at the specified `offset` to `value` (in range [0, 255]). If `count` is omitted, all bytes after the specified offset are set.

## Source

Original URL: https://create.roblox.com/docs/reference/engine/libraries/buffer
GitHub source: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/libraries/buffer.yaml
Captured: 2026-04-16
