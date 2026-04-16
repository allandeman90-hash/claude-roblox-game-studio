---
title: "Fusion: possiblyOutlives, scopes and you"
type: raw-source
source_url: https://devforum.roblox.com/t/fusion-possiblyoutlives-scopes-and-you-video-slides/3032067
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
category: devforum-tutorial
author: Elttob (dphfox)
post_date: 2024-06-20
tags: [fusion, ui, scopes, destruction-order, useafterdestroy]
---

# Fusion: `possiblyOutlives`, Scopes and You

**Author:** Elttob (dphfox)
**Posted:** June 20, 2024

## Overview

This tutorial explains Fusion's scope-based object management system and the `possiblyOutlives` warning that appears when objects may depend on newer objects that could be destroyed first.

## Key Concepts

### Object-Oriented Programming in Fusion

Unlike traditional Luau libraries that use `:destroy()` methods, Fusion uses **scopes** to manage object lifecycles. Instead of destroying objects individually, developers append objects to a scope and call `doCleanup()` to destroy all objects at once.

### Destruction Order Problem

The core issue:

> "When one thing depends on another thing in Fusion, the library will look at the scopes to figure out the ordering of the objects."

Objects should be destroyed from newest to oldest. If an older object depends on a newer object, it can raise a `useAfterDestroy` error when the dependency no longer exists.

### The `possiblyOutlives` Warning

This warning triggers when the system detects an older object depending on a newer one—a dangerous ordering problem that could cause runtime errors.

## Solutions

**Simple Fix:** Reorder code so dependencies are created before dependent objects.

**Advanced Fix:** Use inner scopes via `innerScope()` to create temporary scopes that mark specific destruction points, allowing dynamic object replacement while maintaining correct destruction order.

## Code Pattern Example

Inner scopes can be created, destroyed independently, and removed from outer scopes, enabling temporary object management without manual cleanup of individual items.

## Source

Original URL: https://devforum.roblox.com/t/fusion-possiblyoutlives-scopes-and-you-video-slides/3032067
Captured: 2026-04-16
