---
title: "GroupService API Reference — Roblox Creator Documentation"
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/GroupService
source_type: official-docs
captured_at: 2026-04-15
captured_by: research-agent-phase3
category: social-features
tags: [groups, GroupService, ranks, membership, social]
---

# GroupService API Reference

Non-creatable service enabling developers to fetch information about Roblox groups from within a game.

## Methods

### GetGroupInfoAsync(groupId: int64) -> Variant
Yields. Retrieves a table containing group details:
- Name (string)
- Id (int64)
- Owner (table: Name, Id)
- EmblemUrl (string)
- Description (string)
- Roles (array of {Name, Rank})

### GetGroupsAsync(userId: int64) -> Array
Yields. Returns a list of tables for all groups a player is a member of:
- Name (string)
- Id (int64)
- EmblemUrl (string)
- Rank (number, 0-255)
- Role (string, role name)
- IsPrimary (boolean)

### GetAlliesAsync(groupId: int64) -> StandardPages
Yields. Returns StandardPages with information on all group allies.

### GetEnemiesAsync(groupId: int64) -> StandardPages
Yields. Returns StandardPages with information on all group enemies.

### PromptJoinAsync(groupId: int64) -> GroupMembershipStatus
Yields. Displays a prompt to the local player to join the specified group.

## Player Methods (on Player object)

### Player:IsInGroup(groupId: number) -> boolean
Returns whether the player is in the specified group.

### Player:GetRankInGroup(groupId: number) -> number
Returns the player's rank (0-255) in the specified group. Returns 0 if not a member.

### Player:GetRoleInGroup(groupId: number) -> string
Returns the player's role name in the specified group. Returns "Guest" if not a member.

## Security
- All methods: Security: None
- Capabilities required: Groups

## Groups Cloud API (OpenCloud)

### Endpoints
- GET /cloud/v2/groups/{GROUP_ID}/memberships — Retrieve user membership IDs
- GET /cloud/v2/groups/{GROUP_ID}/roles — List all group roles with rank IDs
- PATCH /cloud/v2/groups/{GROUP_ID}/memberships/{membershipId} — Update player rank

### Authentication
Requires x-api-key header with OpenCloud API key.
Enable permissions: group:read, group:write.

### Ranking Workflow
1. Get Membership ID: filter memberships for target player
2. Retrieve Group Roles: cache all roles mapping rank numbers to role IDs
3. Match Rank Number: search cached roles for desired rank
4. Update Membership: PATCH request to assign role

### Limitations
- Beta status: breaking changes possible
- Rate limiting on rapid requests
- API stability varies; consider fallback systems
