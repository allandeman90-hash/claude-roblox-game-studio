---
title: "Roblox Shop GUI Part 2: Scripting Currency, Items, and Purchases"
type: raw-source
source_url: https://devforum.roblox.com/t/tutorial-roblox-shop-gui-part-2-scripting-currency-items-purchases/4162394
source_type: devforum
captured_at: 2026-04-15
captured_by: mechanics-rpg
category: devforum-tutorial
author: DevForum Community
post_date: 2025-03-15
tags: [shop, gui, currency, purchases, remote-events, server-validation]
---

# Roblox Shop GUI Part 2: Scripting Currency, Items, and Purchases

**Source:** DevForum Community Tutorial

## Currency Management (Leaderstats)

Foundation uses Roblox's standard leaderstats system. When players join, a server script creates a folder and currency value. Players start with an initial amount (e.g., 100 Cash) that displays on the leaderboard.

## Item Purchase Logic

### Client-Side (LocalScript on Button)

Local script detects button clicks and fires a RemoteEvent to the server requesting a purchase for a specific item by name.

### Server-Side Validation

The ShopServerHandler script performs:
1. Verifies the item exists and has a defined price
2. Confirms the player possesses sufficient currency
3. Deducts the cost from the player's Cash value
4. Clones the item from ReplicatedStorage and places it in the player's Backpack

**Critical:** "If you handled the money deduction on the Client, an exploiter could simply delete the line that subtracts money, getting everything for free."

## Robux Integration

For real-money transactions, MarketplaceService replaces manual currency handling. ProcessReceipt ensures items are awarded even if players disconnect mid-purchase.

## DataStore Persistence

Part 3 covers data persistence for purchased items and currency to survive between sessions.
