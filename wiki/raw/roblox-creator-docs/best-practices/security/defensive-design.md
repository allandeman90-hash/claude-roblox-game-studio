---
title: Defensive design tactics
type: raw-source
source_url: https://create.roblox.com/docs/scripting/security/defensive-design
github_source: https://github.com/Roblox/creator-docs/blob/main/content/en-us/scripting/security/defensive-design.md
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-4
category: best-practice
subcategory: security
tags: [security, defensive-design, threat-modeling]
---

# Defensive design tactics

<Alert severity = 'warning'>
The following content covers various concepts and tactics to improve security and mitigate cheating in your Roblox experiences. It's highly recommended that all developers read through these to ensure that your experiences are secure and fair for all users. Check the sidebar for additional security topics.
</Alert>

Basic design decisions can serve as "first step" security measures to discourage exploits. The core principle is to design systems where cheating is either impossible or provides no meaningful advantage, rather than trying to detect and prevent cheating after the fact.

Consider a shooter game where players earn points for kills. An exploiter might create bots that teleport to the same location to be repeatedly killed for easy points. This scenario illustrates the difference between reactive and defensive approaches:

<table><thead>
  <tr>
    <th>Approach</th>
    <th>Predictable outcome</th>
  </tr></thead>
<tbody>
  <tr>
    <td>Chase down bots by writing code that attempts to detect them (reactive approach).</td>
    <td>
		<Alert severity = 'error'>Exploiters seeking quick points will find a way around your complex detection code and use their bots in a different way.</Alert>
		</td>
  </tr>
  <tr>
    <td>Reduce or outright remove point gains for kills on newly spawned players (defensive approach).</td>
    <td>
		<Alert severity = 'success'>Extra time and friction is now required for exploiters because they get no points for instantly killing their bots. Additionally, "spawn campers" are discouraged because they no longer get points for killing newly spawned players.</Alert>
		</td>
  </tr>
</tbody>
</table>

Additional defensive design scenarios:

<table><thead>
  <tr>
    <th>Potential exploit scenario</th>
    <th>Reactive Approach (less effective)</th>
    <th>Defensive approach (more effective)</th>
  </tr></thead>
<tbody>
  <tr>
    <td>(Obby) Exploiter teleports to the end to claim rewards</td>
    <td>Only check the player's final position and try to detect impossible completion times</td>
    <td>Design with mandatory, sequential checkpoints. Server validates each checkpoint was activated in order before granting rewardsYou can add another layer by flagging players who complete stages faster than humanly possible. The design of the experience (requiring checkpoints) is what enables the effective server-side validation.</td>
  </tr>
  <tr>
    <td>(Combat) Client reports dealing impossible damage amounts</td>
    <td>Try to detect and filter out impossible damage values</td>
    <td>Server calculates all damage from server-sided weapon stats and validates hits through server-side raycasting</td>
  </tr>
  <tr>
    <td>(Economy) Exploiter duplicates items through rapid requests</td>
    <td>Try to detect duplicate requests or unusual patterns</td>
    <td>Implement server-side cooldowns and validate all transactions against current player inventory state</td>
  </tr>
</tbody></table>

<Alert severity = 'info'> <AlertTitle>Key principle</AlertTitle> <br /> When designing a new feature, ask yourself: "How would an exploiter abuse this, and can I change the design to make that abuse impossible or worthless?" Instead of trying to detect cheating after it happens, design your experience so that cheating either cannot occur or provides no meaningful advantage.</Alert>

## Source

- Original documentation: https://create.roblox.com/docs/scripting/security/defensive-design
- GitHub source: https://github.com/Roblox/creator-docs/blob/main/content/en-us/scripting/security/defensive-design.md
- Captured: 2026-04-16
