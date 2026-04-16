---
title: Roblox-Ts Tutorial - Roblox-Ts and Flamework Introduction
type: raw-source
source_url: https://devforum.roblox.com/t/roblox-ts-tutorial-roblox-ts-and-flamework-introduction/1937537
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
category: devforum-tutorial
author: Zerxiase
post_date: 2022-08-24
tags: [flamework, roblox-ts, typescript, framework, singletons, components]
---

# Roblox-Ts Tutorial: Roblox-Ts and Flamework Introduction

**Author:** Zerxiase (Boomy)
**Posted:** August 24, 2022

## Overview

This tutorial guides developers through setting up Roblox-Ts with Flamework, a framework that provides extensive features for TypeScript development in Roblox. The guide covers project initialization, Rojo installation, and foundational Flamework concepts including Singletons and Components.

## Key Setup Steps

**Project Creation:** Developers create an empty folder and use PowerShell to install the Flamework template via `npx degit rbxts-flamework/template`, followed by `npm i` and `npm run build`.

**Rojo Installation:** The tutorial requires installing Rojo as an extension in Visual Studio Code and as a plugin in Roblox Studio (version 7 recommended). Connection between VSC and Studio enables live code synchronization via `npm run watch`.

## Core Concepts

**Singletons** function similarly to ServerScripts or LocalScripts. They include:
- **Services:** Handle server-side logic
- **Controllers:** Manage client-side logic

**LifecycleEvents** allow classes to hook into Flamework's event system. The tutorial demonstrates `onInit()` and `onStart()` implementations using TypeScript syntax.

**Components** represent objects within the game world (doors, vehicles, weapons). They attach to Roblox instances via tags and utilize constructor dependency injection. Components require defining:
- An Attributes interface for typed properties
- An Instance interface for the target object type

## TypeScript Fundamentals

The guide emphasizes TypeScript's type-oriented nature versus Lua's untyped approach. Key differences include function syntax (`myFunction() {}` vs Lua's `function myName() end`) and event connection patterns using arrow functions.

## Community Response

The post generated sustained interest with requests for a Part 2, which the author committed to in October 2024, noting prior military service obligations.

## Source

Original URL: https://devforum.roblox.com/t/roblox-ts-tutorial-roblox-ts-and-flamework-introduction/1937537
Captured: 2026-04-16
