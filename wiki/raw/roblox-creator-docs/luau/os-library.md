---
title: os Library
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/libraries/os
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-2
category: luau-language
tags: [luau, os, library, time, date, clock]
---

# os Library

This library provides functions related to time and date. It currently serves the purpose of providing information about the system time under the UTC format. It has been heavily sandboxed from the standard Lua `os` library and does not allow you to perform any system-altering operations.

## Functions

### os.clock

```
os.clock(): double
```

Returns elapsed time in seconds since an arbitrary baseline with sub-microsecond precision. This function is useful for comparing durations between two events that occur on the same computer, and is the best option for benchmarking.

Unlike with functions such as `os.time()` or `DateTime.now()`, adjustments to the system clock (such as by the user or NTP) do not cause time to jump forwards or backwards.

```lua
-- Record the initial time:
local startTime = os.clock()
-- Do something you want to measure the performance of:
local a, b = 0, 1
for _ = 1, 5000000 do
	a, b = b, a
end
-- Measure amount of time this took:
local deltaTime = os.clock() - startTime
print("Elapsed time: " .. deltaTime)
-->  Elapsed time: 0.044425600033719 (actual number may vary)
```

### os.date

```
os.date(formatString: string, time: int): Dictionary
```

Formats the given `formatString` with date/time information based on the given time, or if not provided, the value returned by `os.time()`.

> **Note:** This function should be avoided in new work. Instead, use the `DateTime` API, which supports localized formatting.

The following specifiers (based on the C function strftime) are supported:

| Specifier | Meaning | Example |
|---|---|---|
| `%a` | Abbreviated weekday name | Mon |
| `%A` | Full weekday name | Monday |
| `%b` | Abbreviated month name | Feb |
| `%B` | Full month name | February |
| `%c` | Date and time | Mon Feb 12 14:14:35 2024 |
| `%d` | Day of the month | 12 |
| `%H` | Hour, using 24-hour clock | 14 |
| `%I` | Hour, using 12-hour clock | 02 |
| `%j` | Day of year | 043 |
| `%m` | Month | 02 |
| `%M` | Minute | 14 |
| `%p` | Either "AM" or "PM" | PM |
| `%S` | Second | 35 |
| `%U` | Week number (first Sunday as the first day of week one) | 06 |
| `%w` | Weekday | 1 |
| `%W` | Week number (first Monday as the first day of week one) | 07 |
| `%x` | Date | 02/12/24 |
| `%X` | Time | 14:14:35 |
| `%y` | Two-digit year | 24 |
| `%Y` | Full year | 2024 |
| `%z` | ISO 8601 offset from UTC in timezone | -0800 |
| `%Z` | Timezone name or abbreviation | PST |
| `%%` | The % character | % |

If the provided `formatString` is exactly `"*t"` (local time) or `"!*t"` (UTC time), this function instead returns a dictionary containing the following components:

| Field | Type | Description |
|---|---|---|
| year | int | An integer that describes the current year (e.g. 2017) |
| month | int | An integer between 1 and 12 (starting from January) |
| wday | int | An integer between 1 and 7 (starting from Sunday) |
| yday | int | An integer between 1 and 366 (day into the year) |
| day | int | An integer between 1 and 31 |
| hour | int | An integer between 1 and 24 |
| min | int | An integer between 0 and 59 |
| sec | int | An integer between 0 and 60 |
| isdst | bool | Whether daylight savings time is currently active |

### os.difftime

```
os.difftime(t2: int, t1: int): int
```

Returns the number of seconds from `t1` to `t2`. The difference is computed assuming that `t1` and `t2` are correctly casted to the `time_t` format.

### os.time

```
os.time(time: table = UTC time): int
```

Returns how many seconds have passed since the Unix epoch (1 January 1970, 00:00:00), under current UTC time. If provided a table formatted similarly to that returned by `os.date()`, it returns the number of seconds from the Unix epoch to that time instead.

Note that the returned time uses the device's local clock. Most operating systems automatically sync their local time against online time servers, so this should be within a few hundred milliseconds. However, users can easily disable sync behavior and set the system time to anything they want; for synchronized time between client and server, use `Workspace:GetServerTimeNow()` instead.

> **Note:** This function should be avoided in new work. Instead, use the `DateTime` API, which supports localized formatting.

When you need to precisely measure the time elapsed between two points in time, like when testing performance, use `os.clock()` instead.

## Source

Original URL: https://create.roblox.com/docs/reference/engine/libraries/os
GitHub source: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/libraries/os.yaml
Captured: 2026-04-16
