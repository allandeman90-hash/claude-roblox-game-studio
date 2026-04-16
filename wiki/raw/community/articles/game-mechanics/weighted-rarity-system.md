---
title: "How to Make a Weighted Rarity System"
type: raw-source
source_url: https://devforum.roblox.com/t/how-to-make-a-weighted-rarity-system/1570487
source_type: devforum
captured_at: 2026-04-15
captured_by: mechanics-rpg
category: devforum-tutorial
author: DevForum Community
post_date: 2022-01-15
tags: [rarity, weighted-random, loot, tiers, probability]
---

# How to Make a Weighted Rarity System

**Source:** DevForum Community Tutorial

## Rarity Tiers

Example probabilities:
- Common: 45%
- Rare: 35%
- Epic: 18%
- Legendary: 2%

## Implementation

### Step 1: Define Rarities

Table containing rarity names paired with probability weights: `Common = 45`, etc.

### Step 2: Calculate Total Weight

Loop that sums all probability values (e.g., total = 100).

### Step 3: Roll and Determine Rarity

Generate a random number between 1 and total weight. Iterate through the rarity table accumulating weights until the cumulative total exceeds the random number.

## Three Components

1. A rarity definition table with name-value pairs
2. A loop calculating cumulative weight
3. A comparison function matching random results to rarity tiers

## Applications

Crates, eggs, loot drops, equipment drops. Accommodates modifications and user improvements.
