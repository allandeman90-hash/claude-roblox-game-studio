# Social System GDD

**Version**: 1.0
**Last Updated**: YYYY-MM-DD
**Author**: game-designer
**Parent**: `design/gdd/master-gdd.md`

---

## 1. Overview & Purpose

Social features are the strongest retention driver on Roblox. This system enables players to connect, play together, and build ongoing relationships.

---

## 2. Feature List

- **Friends**: Add / remove / view friends list
- **Party**: Form a group to play together
- **Chat**: Text chat with filter
- **Emotes**: Non-verbal communication
- **Trading**: Exchange items (if applicable)
- **Guilds / Clans**: Persistent social groups (if applicable)
- **Social Spaces**: Lobby, hub area, housing

---

## 3. Friends

- **Add friend**: Send friend request. Target accepts.
- **Maximum friends**: Roblox limit (~200)
- **Friend status**: Online / offline / in-game
- **Invite to party**: If friend is in a compatible game state
- **Friend leaderboard**: Ranked by level or score

---

## 4. Party System

- **Max party size**: 4 (or game-specific)
- **Party leader**: Can invite, kick, disband
- **Party chat**: Separate channel from global
- **Party bonuses**: XP bonus for grouped play
- **Teleport to party**: Join party leader's server (via TeleportService)
- **Party queue**: For matchmaking

---

## 5. Chat

- Uses `TextChatService`
- All messages pass through Roblox chat filter
- **Global chat**: Server-wide
- **Party chat**: Party-only
- **Guild chat**: Guild-only (if applicable)
- **Private messages**: Between friends
- **Moderation**: Report button for inappropriate chat; server-side rate limits

---

## 6. Emotes

- Unlockable via quests, purchases, or achievements
- Trigger via menu or hotkey
- Shown as animation on character + icon above head
- Rate limited (max 1 per 2 seconds) to prevent spam

---

## 7. Data Schema

| Key | Type | Default |
|-----|------|---------|
| `friends_pending` | table (set of UserIds) | `{}` |
| `unlocked_emotes` | table (set of IDs) | `{}` |
| `guild_id` | number? | nil |
| `social_blocked` | table (set) | `{}` |

Note: Roblox's `Players.IsFriendsWith` handles the friends list natively (doesn't need DataStore).

---

## 8. Remotes

| Name | Type | Direction | Args |
|------|------|-----------|------|
| SendFriendRequest | RemoteEvent | C→S | (targetUserId: number) |
| CreateParty | RemoteEvent | C→S | () |
| InviteToParty | RemoteEvent | C→S | (targetUserId) |
| PlayEmote | RemoteEvent | C→S | (emoteId: string) |
| ChatMessage | RemoteEvent | S→C | (channel, sender, message) |

All validate: rate limits, valid targets, permission checks.

---

## 9. Edge Cases

1. **Friend invite while offline**: Stored pending, delivered on login
2. **Party leader leaves**: Leadership transfers to next member
3. **Party size exceeds limit mid-play**: New joins rejected
4. **Chat filter blocks benign text**: Show filter result; don't expose to others
5. **Emote spam**: Rate limited
6. **Player blocks another**: No chat visible between them

---

## 10. Integration Points

### Depends On
- Player Data (unlocked emotes, guild ID, blocked list)
- TextChatService (chat infrastructure)

### Depended On By
- Party quests (quest progression shared in party)
- Trading system (needs friend/party context)
- Analytics (social engagement metrics)

---

## Acceptance Criteria

- [ ] Friends list displays correctly
- [ ] Party creation/invite/disband works
- [ ] Chat respects filter
- [ ] Emotes play for self and visible to others
- [ ] No social exploits (spam, harassment loops)
- [ ] Rate limits functional
