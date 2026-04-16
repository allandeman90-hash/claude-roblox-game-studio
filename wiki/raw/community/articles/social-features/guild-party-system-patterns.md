---
title: "Guild/Clan and Party System Implementation Patterns"
type: raw-source
source_url: https://devforum.roblox.com/t/guild-clan-system/3365185
source_type: devforum
captured_at: 2026-04-15
captured_by: research-agent-phase3
category: social-features
tags: [guild, clan, party, social, DataStore, MessagingService, cross-server]
secondary_sources:
  - https://devforum.roblox.com/t/party-system-oop-party-system-v1/2042243
  - https://devforum.roblox.com/t/how-to-code-a-guild-system/2071255
  - https://devforum.roblox.com/t/creating-a-guildclan-system/486665
---

# Guild/Clan and Party System Implementation Patterns

## Guild/Clan System Architecture

### Data Structure (Server-Side)

```lua
-- Per-guild DataStore entry
type GuildData = {
    guildId: string,
    name: string,
    leader: number,        -- UserId
    currency: number,
    members: {[number]: {  -- keyed by UserId
        role: string,      -- "Leader" | "Officer" | "Member"
        joinedAt: number,
    }},
    settings: {
        isOpen: boolean,
        maxMembers: number,
    },
}
```

### Storage Strategy
- One DataStore key per guild (e.g., "guild_<guildId>")
- Player data stores guild membership ID for quick lookup
- MemoryStoreService for cross-server invite cache
- MessagingService for real-time updates across servers

### Core Challenges
1. Two players in different servers changing guild data simultaneously
2. Rank permission conflicts from concurrent operations
3. Large member lists exceeding DataStore value limits
4. Cross-server invite delivery and acceptance

### Recommended Architecture
- Server-authoritative guild operations via RemoteEvent
- UpdateAsync with check-and-set for all guild mutations
- MessagingService to broadcast changes to all servers
- Per-server cache invalidation on MessagingService receipt

---

## OOP Party System (Transient, In-Memory)

### Architecture
Uses OOP with metatables. Central Party module manages all instances. Physical representations in ReplicatedStorage under PhysicalParties folder.

### Data Structure

```lua
-- Party object properties
type Party = {
    Leader: Player,
    MaxMembers: number,        -- default 4
    CurrentMemberCount: number,
    InviteOnly: boolean,
    Members: {Player},
    Invites: {[Player]: Party},
    Blacklist: {Player},
}

-- Physical Instance hierarchy (ReplicatedStorage)
-- PhysicalParty (Folder)
--   Members (Folder)
--     [PlayerName] (ObjectValue)
--       Attribute: Leader (bool)
--       Attribute: CanKick (bool)
--       Attribute: CanInvite (bool)
--   Invites (Folder)
--   Blacklist (Folder)
```

### API

| Method | Description |
|--------|-------------|
| Party.new(Player) | Create new party |
| party:disband() | Remove party |
| party:addMember(Player) | Add member (checks space, blacklist) |
| party:removeMember(Player) | Remove non-leader member |
| party:invitePlayer(Player) | Create invite (20s cooldown) |
| party:setPermission(Member, Perm, Toggle) | Set Leader/CanKick/CanInvite |
| party:blacklistPlayer(Player) | Block player |
| party:transferOwnership(Player) | Change leader |
| party:teleportMembers(PlaceId, Data) | Teleport all members together |
| PartyModule:getParty(Player) | Get player's party or "NoParty" |

### Teleport Support
teleportMembers accepts: ReservedServerCode, JobId, ShouldReserveServer.
Uses TeleportService:TeleportAsync().

### Design Patterns Used
- Metatable OOP for party instances
- Singleton registry: Parties table maps leaders to party objects
- Physical manifestation: Instance hierarchy mirrors logical structure for replication
- Attribute-based permissions on Instance objects
- RemoteEvent for client-server communication

### Known Limitations
- Minimal error checking (must add validation)
- InviteOnly not enforced in addMember
- Requires external GUI for invite feedback
- No persistence (parties are transient, in-memory only)
