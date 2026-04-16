---
title: Round-Based Team Game Framework
type: raw-source
source_url: https://devforum.roblox.com/t/how-to-create-a-round-based-team-game/1640544
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-p2-game-patterns
category: game-pattern
tags: [game-pattern, round-system, teams, lobby, spawn-management]
---

# Round-Based Team Game Tutorial

## Game Lifecycle Overview

Players are put into an intermission and spawned at a lobby spawn point. After the intermission, players are divided into two teams and spawned at their respective spawn points.

## Core Architecture

**Project Structure:**
- Three spawn points (lobby + two team spawns) with neutral teams and AutoAssignable disabled
- Two teams with matching spawn colors and AutoAssignable set to false
- GameScript containing two module scripts: GameManager and TeamManager

## Round Flow

The main loop follows this sequence:
1. `StartIntermission()` - waits for minimum player count
2. `StopIntermission()` - checks if enough players exist
3. `StartRound()` - initiates gameplay
4. `StopRound()` - handles round completion

## Team Assignment System

The TeamManager distributes players by creating a table of the two teams and sorting them from smallest to largest, then assigning the player the smallest team to maintain balance.

## Key Functions

**GameManager operations:**
- StartIntermission / StopIntermission
- StartRound / StopRound
- RoundEnded (placeholder for winner logic)

**TeamManager operations:**
- AssignTeams() - distributes players to balanced teams
- RemoveTeams() - resets player teams to lobby (neutral)
- PlayerJoined() - handles mid-round arrivals

## Design Notes

This represents a framework requiring additional custom implementations like GUIs and leaderstats. Spawn points use TeamColor matching with Neutral=false and AutoAssignable=false for controlled spawn assignment.

## Source
Original URL: https://devforum.roblox.com/t/how-to-create-a-round-based-team-game/1640544
