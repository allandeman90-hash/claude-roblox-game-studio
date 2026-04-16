# Melee Combat, Combo Systems, and Parry/Block

**Sources:**
- https://devforum.roblox.com/t/open-source-simple-combat-system-with-blocking-and-stun/2484521
- https://devforum.roblox.com/t/methods-for-creating-advanced-combat-systems/3578546
- https://devforum.roblox.com/t/parry-based-combat-system/2978893
- https://devforum.roblox.com/t/parryblocking-system-for-combat/2288364
**Captured:** 2026-04-15

## Hit Detection Methods (Community Consensus)

1. Raycasts: Precise but difficult to tweak, embedded in movement
2. Region3/Spatial Queries: Balance of precision and performance
3. Magnitude-based: Cheap but only ball-shape
4. .Touched() events: "Never use .touched for a competitive combat system" — unreliable

## State Machines for Combat

Described as "the most practical way" to structure combat:
- Multiple stun types: true stun, regular stun, endlag stun
- States: idle, windup, active, recovery, cooldown, blocking, parrying, staggered

## Timing and Animation

- Use code-based timing, not animation events for balance
- Animation events take longer to adjust than code-based wait timers
- Animation markers useful for VFX sync but not balance-critical timing

## Parry System Architecture

### Common Pattern (from multiple threads)

1. Server tracks a "Parrying" attribute on the character (boolean)
2. When attacking, check if target has Parrying = true
3. Parry window is short (typically 200-300ms)
4. Successful parry: attacker gets stunned, defender gets counter-attack window

### Block System

1. Hold-to-block: reduces damage by percentage while active
2. Server validates block state before applying damage reduction
3. Block stamina/durability prevents infinite blocking
4. Directional blocking: only blocks hits from the front

## Combo Chains

- Track current combo index per player on server
- Each combo hit has: animation, damage multiplier, hitbox timing
- Combo resets after timeout (typically 0.8-1.5s between inputs)
- Final combo hit usually has larger hitbox and higher damage

## I-Frames (Invincibility Frames)

- Short window of invulnerability during certain actions (dodge, parry success)
- Server-managed: set an "Invulnerable" flag, check before applying damage
- Typical duration: 0.2-0.5 seconds
- Prevent chain-stun/chain-damage exploits

## Anti-Exploits

- All combat state managed on server
- Client sends intent (attack, block, parry), server validates timing and position
- Rate-limit attack attempts (prevent macro spam)
- Validate target distance before applying damage
