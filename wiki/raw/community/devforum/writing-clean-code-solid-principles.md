---
title: "Writing Clean Code Part 2: What is SOLID? How do I use it? Why do I care?"
type: raw-source
source_url: https://devforum.roblox.com/t/writing-clean-code-part-2-what-is-solid-how-do-i-use-it-why-do-i-care/2186450
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
category: devforum-resource
author: samjay22
post_date: 2023-02-17
tags: [solid, oop, clean-code, principles, luau, maintainability]
---

# Writing Clean Code Part 2: What is SOLID?

**Author:** samjay22 (Dev)
**Posted:** February 17, 2023

## Overview

The post presents SOLID as "a set of 5 principles used in developing highly flexible, extendable, and maintainable Object Oriented code." This tutorial serves as Part 2 of a clean code series.

## The Five SOLID Principles Applied to Luau

### 1. Single Responsibility Principle (SRP)

**Definition:** A class or module should have "only one responsibility per actor."

**Problem Example:** The initial Crop class violated SRP by managing both crop growth logic and reward distribution. The author demonstrates this creates unnecessary coupling.

**Solution:** Separate concerns into distinct classes—one managing crop lifecycle, another handling rewards through composition rather than inheritance.

Key insight:
> "This de-couples our code which means that we have functionality that is connected without having to directly associate."

### 2. Open/Closed Principle (OCP)

**Core Concept:** Systems should be "open for extension but closed for modification."

**Application:** Rather than altering existing Player class code, developers extend functionality through inheritance. A PowerUp class inherits from Player and modifies speed without changing the original implementation.

> "This implementation not only prevents us from possibly breaking the player object but also allows us to separate the logic in different places."

### 3. Liskov Substitution Principle (LSP)

**Principle:** Derived types must be "substitutable for each other without affecting the correctness of the program."

**Example:** A Car inheriting from Vehicle can be passed to any function expecting a Vehicle parameter without breaking functionality.

### 4. Interface Segregation Principle (ISP)

**Goal:** Create "small, focused interfaces specific to current needs" rather than monolithic ones.

**Luau Implementation:** Using Luau's type system, separate interfaces like `IRegularPlayer` and `IAdminPlayer` prevent forcing unrelated methods onto classes that don't need them.

### 5. Dependency Inversion Principle (DIP)

**Focus:** Decouple high-level modules from low-level implementations through facades and factories.

**Pattern:** Model-View-Controller (MVC) separates database logic, business controllers, and user interfaces across distinct layers.

**Example Code Pattern:** An OrderFacade abstracts Inventory and PaymentProcessor interactions, simplifying client code and centralizing change management.

## Practical Luau Examples

The post includes complete code implementations:

- **Crop System:** Demonstrates SRP separation between growth management and reward systems
- **Vehicle/Car Hierarchy:** Shows LSP in action with substitutable objects
- **Interactables Factory:** Uses dependency inversion with Door, Switch, and Lever classes implementing a common interface
- **Order Processing Facade:** Real-world MVC pattern with types and organized responsibilities

## Why SOLID Matters

> "They help write highly scalable, sustainable, and highly productive code."

Key benefits include:
- Reduced tight coupling between components
- Improved code maintainability over time
- Enhanced extensibility without modifying existing implementations
- Better team collaboration through consistent standards

## Source

Original URL: https://devforum.roblox.com/t/writing-clean-code-part-2-what-is-solid-how-do-i-use-it-why-do-i-care/2186450
Captured: 2026-04-16
