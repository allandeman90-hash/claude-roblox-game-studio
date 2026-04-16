---
title: Luau Standard Library Reference
type: raw-source
source_url: https://luau.org/library
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: library
tags: [luau, stdlib, math, string, table, buffer, vector, bit32, utf8, coroutine, os, debug]
---

# Luau Standard Library Reference

## Global Functions

- **`assert(value, message?)`** — Returns value if truthy; raises error with optional message if falsy.
- **`error(obj, level?)`** — Raises error with specified object; `level` adds call frame information.
- **`gcinfo()`** — Returns total heap size in kilobytes.
- **`getfenv(target?)`** — Retrieves environment table for function or call stack level.
- **`getmetatable(obj)`** — Returns metatable for object; protected metatables return their `__metatable` value.
- **`next(t, i?)`** — Returns next key-value pair in table traversal.
- **`newproxy(mt?)`** — Creates untyped userdata; optionally with empty modifiable metatable.
- **`print(args)`** — Outputs arguments to standard output using tabs as separators.
- **`rawequal(a, b)`** — Compares type and object identity without metatables.
- **`rawget(t, k)`** — Table lookup bypassing metatables and `__index`.
- **`rawlen(t)`** — Returns raw length of table or string, bypassing `__len`.
- **`rawset(t, k, v)`** — Assigns table field, bypassing metatables and `__newindex`.
- **`select(i, args)`** — With `'#'` returns argument count; with number returns arguments from that index forward/backward.
- **`setfenv(target, env)`** — Changes environment table for function or stack level.
- **`setmetatable(t, mt?)`** — Modifies table metatable; errors if protected.
- **`tonumber(s, base?)`** — Converts string to number in specified base (default 10); returns `nil` on failure.
- **`tostring(obj)`** — Converts object to string; calls `__tostring` if available.
- **`type(obj)`** — Returns type name: `"nil"`, `"boolean"`, `"number"`, `"vector"`, `"string"`, `"table"`, `"function"`, `"userdata"`, `"thread"`, `"buffer"`.
- **`typeof(obj)`** — Returns type; for host-defined userdata with `__type`, returns that value.
- **`ipairs(t)`** — Iterator for numeric keys `[1..#t]` in order.
- **`pairs(t)`** — Iterator for all table keys in unspecified order.
- **`pcall(f, args)`** — Calls function; returns `(true, results)` on success or `(false, error)` on failure.
- **`xpcall(f, e, args)`** — Like `pcall` but calls error handler function `e` on failure.
- **`unpack(a, f?, t?)`** — Returns values from table indices `[f..t]`; `f` defaults to 1, `t` to length.

---

## `math` Library

- **`math.abs(n)`** — Absolute value; returns NaN for NaN input.
- **`math.acos(n)`** — Arc cosine in radians; range `[0, π]`; NaN if outside `[-1, 1]`.
- **`math.asin(n)`** — Arc sine in radians; range `[-π/2, π/2]`; NaN if outside `[-1, 1]`.
- **`math.atan(n)`** — Arc tangent in radians; range `[-π/2, π/2]`.
- **`math.atan2(y, x)`** — Arc tangent of y/x considering quadrant; range `[-π, π]`.
- **`math.ceil(n)`** — Rounds upward to integer.
- **`math.cos(n)`** — Cosine of radians.
- **`math.cosh(n)`** — Hyperbolic cosine.
- **`math.deg(n)`** — Converts radians to degrees.
- **`math.exp(n)`** — Base-e exponent (`e^n`).
- **`math.floor(n)`** — Rounds downward to integer.
- **`math.fmod(x, y)`** — Remainder of x mod y, rounded toward zero; NaN if y is zero.
- **`math.frexp(n)`** — Returns `(significand, exponent)` where n = s × 2^e.
- **`math.ldexp(s, e)`** — Returns `s × 2^e`.
- **`math.lerp(a, b, t)`** — Linear interpolation: `a + (b - a) × t`; guaranteed to stay in `[a, b]` when `t ∈ [0, 1]`.
- **`math.log(n, base?)`** — Logarithm in specified base (default `e`); NaN for negative input.
- **`math.log10(n)`** — Base-10 logarithm.
- **`math.max(list)`** — Maximum of arguments; requires at least one input.
- **`math.min(list)`** — Minimum of arguments; requires at least one input.
- **`math.modf(n)`** — Returns `(integer part, fractional part)` with matching sign.
- **`math.pow(x, y)`** — Returns `x^y`.
- **`math.rad(n)`** — Converts degrees to radians.
- **`math.random()`** — Returns random number in `[0, 1]`.
- **`math.random(n)`** — Returns random integer in `[1, n]`.
- **`math.random(min, max)`** — Returns random integer in `[min, max]`.
- **`math.randomseed(seed)`** — Reseeds generator for deterministic sequences.
- **`math.sin(n)`** — Sine of radians.
- **`math.sinh(n)`** — Hyperbolic sine.
- **`math.sqrt(n)`** — Square root; NaN for negative input.
- **`math.tan(n)`** — Tangent of radians.
- **`math.tanh(n)`** — Hyperbolic tangent.
- **`math.noise(x, y?, z?)`** — 3D Perlin noise value at `(x, y, z)`; y and z default to 0; range `[-1, 1]`. **(Luau-specific)**
- **`math.clamp(n, min, max)`** — Returns `n` if in `[min, max]`; otherwise min or max; errors if `min > max`. **(Luau-specific)**
- **`math.sign(n)`** — Returns `-1` (negative), `1` (positive), or `0` (zero/NaN). **(Luau-specific)**
- **`math.round(n)`** — Rounds to nearest integer; ties away from zero. **(Luau-specific)**
- **`math.map(x, inmin, inmax, outmin, outmax)`** — Maps `x` from `[inmin, inmax]` to `[outmin, outmax]`. **(Luau-specific)**

Constants: `math.pi`, `math.huge`. (RFC math-constants proposes `math.nan`, `math.e`, `math.phi`, `math.sqrt2`, `math.tau`.)

---

## `table` Library

- **`table.concat(a, sep?, f?, t?)`** — Joins elements at indices `[f..t]` with separator.
- **`table.foreach(t, f)`** — Iterates all elements calling `f`; **deprecated**, use `for` loops instead.
- **`table.foreachi(t, f)`** — Iterates numeric keys `[1..#t]` in order; **deprecated**.
- **`table.getn(t)`** — Returns length; **deprecated**, use `#t`.
- **`table.maxn(t)`** — Returns maximum numeric key; returns 0 if none.
- **`table.insert(t, v)`** — Appends value to array portion.
- **`table.insert(t, i, v)`** — Inserts value at index `i`; shifts subsequent elements.
- **`table.remove(t, i?)`** — Removes element at index `i` (default: last); shifts subsequent.
- **`table.sort(t, f?)`** — Sorts array portion; `f` is comparison predicate.
- **`table.pack(args)`** — Returns table with array portion plus `n` field indicating count.
- **`table.unpack(a, f?, t?)`** — Returns values from indices `[f..t]`.
- **`table.move(a, f, t, d, tt?)`** — Copies elements `[f..t]` from `a` to `tt` (default `a`) starting at index `d`.
- **`table.create(n, v?)`** — Creates table with `n` elements set to `v`. **(Luau-specific)**
- **`table.find(t, v, init?)`** — Returns index of first element equal to `v`. **(Luau-specific)**
- **`table.clear(t)`** — Removes all elements while preserving capacity. **(Luau-specific)**
- **`table.freeze(t)`** — Freezes table preventing modifications; errors if already frozen or protected. **(Luau-specific)**
- **`table.isfrozen(t)`** — Returns `true` if table is frozen. **(Luau-specific)**
- **`table.clone(t)`** — Returns shallow copy with same metatable; not frozen even if source was. **(Luau-specific)**

---

## `string` Library

- **`string.byte(s, f?, t?)`** — Returns numeric codes for bytes at indices `[f..t]`.
- **`string.char(args)`** — Returns string from byte codes (0-255).
- **`string.find(s, p, init?, plain?)`** — Searches for pattern `p` in `s`. Returns match position, length, and captures.
- **`string.format(s, args)`** — Printf-style formatting.
- **`string.gmatch(s, p)`** — Returns iterator producing pattern matches and captures.
- **`string.gsub(s, p, f, maxs?)`** — Replaces pattern matches.
- **`string.len(s)`** — Returns byte count (equivalent to `#s`).
- **`string.lower(s)`** — Returns lowercase ASCII version.
- **`string.match(s, p, init?)`** — Returns pattern captures or full match.
- **`string.rep(s, n)`** — Returns string repeated `n` times.
- **`string.reverse(s)`** — Returns bytes in reversed order.
- **`string.sub(s, f, t?)`** — Returns substring at byte range `[f..t]`.
- **`string.upper(s)`** — Returns uppercase ASCII version.
- **`string.split(s, sep?)`** — Splits by separator (default `,`); empty separator splits into single-byte strings. **(Luau-specific)**
- **`string.pack(f, args)`** — Encodes values per pack format (fixed sizes: short=16, long=64, int=32, size_t=32).
- **`string.packsize(f)`** — Returns size of packed representation.
- **`string.unpack(f, s)`** — Decodes string per pack format.

---

## `coroutine` Library

- **`coroutine.create(f)`** — Creates new coroutine running function `f`.
- **`coroutine.running()`** — Returns currently running coroutine or nil in main.
- **`coroutine.status(co)`** — Returns `"running"`, `"suspended"`, `"normal"`, or `"dead"`.
- **`coroutine.wrap(f)`** — Creates coroutine; returns function that resumes it with arguments.
- **`coroutine.yield(args)`** — Suspends current coroutine.
- **`coroutine.isyieldable()`** — Returns `true` if current coroutine can yield.
- **`coroutine.resume(co, args)`** — Resumes coroutine; returns `(true, results)` or `(false, error)`.
- **`coroutine.close(co)`** — Closes coroutine (must be dead or suspended).

---

## `bit32` Library

All functions treat inputs as 32-bit unsigned integers `[0..4294967295]`; bit 0 is least significant.

- **`bit32.arshift(n, i)`** — Arithmetic right shift (sign-bit propagates).
- **`bit32.band(args)`** — Bitwise AND; no arguments returns all bits set.
- **`bit32.bnot(n)`** — Bitwise NOT.
- **`bit32.bor(args)`** — Bitwise OR; no arguments returns 0.
- **`bit32.bxor(args)`** — Bitwise XOR; no arguments returns 0.
- **`bit32.btest(args)`** — Returns `true` if AND result is nonzero.
- **`bit32.extract(n, f, w?)`** — Extracts `w` bits (default 1) from position `f`.
- **`bit32.lrotate(n, i)`** — Left rotate by `i` bits; negative `i` rotates right.
- **`bit32.lshift(n, i)`** — Left shift by `i` bits.
- **`bit32.replace(n, r, f, w?)`** — Replaces `w` bits at position `f` with `r`.
- **`bit32.rrotate(n, i)`** — Right rotate by `i` bits.
- **`bit32.rshift(n, i)`** — Right shift by `i` bits.
- **`bit32.countlz(n)`** — Consecutive leading zeros; returns 32 if `n` is 0. **(Luau-specific)**
- **`bit32.countrz(n)`** — Consecutive trailing zeros. **(Luau-specific)**
- **`bit32.byteswap(n)`** — Swaps byte order. **(Luau-specific)**

---

## `utf8` Library

- **`utf8.offset(s, n, i?)`** — Returns byte offset of codepoint number `n` from byte position `i`.
- **`utf8.codepoint(s, i?, j?)`** — Returns Unicode codepoints with starting byte offsets.
- **`utf8.char(args)`** — Creates string from Unicode codepoint numbers.
- **`utf8.len(s, i?, j?)`** — Returns codepoint count; returns `nil` plus invalid byte position if malformed.
- **`utf8.codes(s)`** — Iterator producing `(byte offset, codepoint)` pairs.

---

## `os` Library (restricted under sandbox)

- **`os.clock()`** — High-precision timestamp in seconds for duration measurement.
- **`os.date(s?, t?)`** — Returns table or string representation of time `t`. Format `"*t"` returns table with sec/min/hour/day/month/year/wday/yday/isdst.
- **`os.difftime(a, b)`** — Returns difference `a - b` in seconds.
- **`os.time(t?)`** — Returns current Unix timestamp (or timestamp from table).

Note: `os.execute`, `os.exit`, `os.getenv`, `os.remove`, `os.rename`, `os.tmpname`, `os.setlocale` are all removed under the sandbox.

---

## `debug` Library (restricted)

- **`debug.info(co, level, s)` / `debug.info(level, s)` / `debug.info(f, s)`** — Returns information per format string `s`:
  - `s` = source path
  - `l` = line number
  - `n` = function name (empty if unknown)
  - `f` = function object
  - `a` = argument count + variadic boolean
- **`debug.traceback(co?, msg?, level?)`** — Returns stringified callstack with optional message prefix.

---

## `buffer` Library (Luau-specific)

Represents fixed-size mutable memory block; 1GB maximum size.

- **`buffer.create(size)`** — Creates zero-initialized buffer.
- **`buffer.fromstring(str)`** — Creates buffer from string contents.
- **`buffer.tostring(b)`** — Returns buffer data as string.
- **`buffer.len(b)`** — Returns buffer size in bytes.
- **`buffer.readi8/u8/i16/u16/i32/u32/f32/f64(b, offset)`** — Reads bytes as specified type; little-endian, IEEE 754 for floats.
- **`buffer.writei8/u8/i16/u16/i32/u32/f32/f64(b, offset, value)`** — Writes value as specified type.
- **`buffer.readstring(b, offset, count)`** — Reads `count` bytes as string.
- **`buffer.writestring(b, offset, value, count?)`** — Writes string bytes.
- **`buffer.readbits(b, bitOffset, bitCount)`** — Reads `bitCount` bits (0-32 range) into unsigned integer.
- **`buffer.writebits(b, bitOffset, bitCount, value)`** — Writes `bitCount` bits (0-32 range) from value.
- **`buffer.copy(target, targetOffset, source, sourceOffset?, count?)`** — Copies bytes; overlapping regions behave as if copied to temporary first.
- **`buffer.fill(b, offset, value, count?)`** — Sets count bytes to value; omitting count fills to end.

---

## `vector` Library (Luau-specific)

3-component vectors (x, y, z) by default; 4-component with w if `LUA_VECTOR_SIZE=4`. Components accessed via x/X, y/Y, z/Z, w/W fields; immutable.

**Constants:**
- **`vector.zero`** / **`vector.one`** — All components 0 or 1.

**Construction:**
- **`vector.create(x, y, z)`** / **`vector.create(x, y, z, w)`** — Creates vector.

**Math:**
- **`vector.magnitude(vec)`** — Magnitude (includes w in 4-wide mode).
- **`vector.normalize(vec)`** — Unit vector.
- **`vector.cross(vec1, vec2)`** — Cross product; ignores w in 4-wide, returns 3D result.
- **`vector.dot(vec1, vec2)`** — Dot product.
- **`vector.angle(vec1, vec2, axis?)`** — Angle in radians between vectors.

**Component-wise:**
- **`vector.floor(vec)`** / **`vector.ceil(vec)`** / **`vector.abs(vec)`** / **`vector.sign(vec)`**
- **`vector.clamp(vec, min, max)`**
- **`vector.max(vecs)`** / **`vector.min(vecs)`** — Per-component max/min across inputs.

## Source

- Original URL: https://luau.org/library
- Captured: 2026-04-16
