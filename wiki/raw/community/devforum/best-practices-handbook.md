---
title: Best Practices Handbook
type: raw-source
source_url: https://devforum.roblox.com/t/best-practices-handbook/2593598
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
category: devforum-tutorial
author: CodedJack
post_date: 2023-09-14
tags: [best-practices, clean-code, naming, guard-clauses, dry, memory-management]
---

# Best Practices Handbook

**Author:** CodedJack
**Posted:** September 14, 2023

## Overview

Jack, who has collaborated with prominent Roblox groups, compiled this handbook covering best practices for general programming and Lua-specific challenges.

## Key Best Practices

### Naming Conventions
Use camelCase for variables and functions. The guide recommends meaningful names like `ragDollService` instead of cryptic abbreviations like `rds`.

### Guard Clauses
"Guard clauses are conditionals that exit a function/loop with a return/break/continue statement." This reduces nested conditionals and improves readability.

### Module Scripts
"Module scripts allow you to create clean and reusable code." They prevent code duplication across projects.

### Functional Programming
Functions should avoid manipulating data and instead return outputs without side effects.

### Type Checking
Implement type annotations for variables, parameters, and returns to catch errors early.

### DRY Principle
"Don't Repeat Yourself" - avoid duplicating code across multiple locations.

### Memory Management
- Clean up event connections using `:Disconnect()` or `:Once()` to prevent memory leaks
- Use `task.wait()` instead of deprecated `wait()`

### Instance Creation Performance
Set the Parent property last: create instance → assign properties → set Parent → connect signals.

### Service Access
Prefer `game:GetService("ServiceName")` over direct references like `game.ServiceName`.

## Source

Original URL: https://devforum.roblox.com/t/best-practices-handbook/2593598
Captured: 2026-04-16
