---
title: Team Create
type: studio
category: studio
subcategory: collaboration
owner: roblox-studio-specialist
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/studio-features/packages-official-docs.md
related:
  - "[[packages]]"
  - "[[rojo-mapping]]"
  - "[[play-solo-team-test]]"
tags: [studio, collaboration, team-create, drafts, commits]
---

# Team Create

> Real-time collaborative editing in Roblox Studio, allowing multiple developers to work on the same place simultaneously.

## Summary

Team Create is Roblox's built-in collaboration system. When enabled on a place, multiple developers can open and edit the same place at the same time, seeing each other's changes in near-real-time. The system includes script drafts and commits to prevent simultaneous script edit conflicts, plus in-Studio commenting for threaded discussions anchored to 3D objects.

## Enabling Team Create

1. Open a place in Roblox Studio.
2. Navigate to **View > Team Create** panel.
3. Click **Turn On** to enable collaboration.
4. The place is now cloud-hosted; all collaborators connect to the same session.

Team Create requires the place to be published to Roblox. Local `.rbxl` files cannot use Team Create.

## How It Works

### Instance Editing

When a collaborator selects and modifies an instance (Part, Model, etc.), that change replicates to all other connected editors in real time. A colored outline shows which instances are being edited by which collaborator.

### Script Drafts and Commits

Scripts use a draft/commit model rather than live co-editing:

1. **Drafts:** When a collaborator opens a script, they work on a local draft. Other collaborators see the last committed version.
2. **Committing:** The collaborator commits their draft to make it visible to others. Commits can be batched (multiple scripts at once).
3. **Conflict resolution:** If two collaborators edit the same script, the second to commit sees a merge prompt.

Access drafts via **View > Drafts** panel. Batch commits available for committing multiple script changes at once.

### Comments (2025)

Collaborators can pinpoint objects in the 3D view to start threaded discussions, leave to-dos and notes, and communicate about changes directly where they create.

## Permissions

Team Create uses the experience's collaborator list:

- **Owner:** Full control, can add/remove collaborators.
- **Collaborators (Edit):** Can modify instances, commit scripts, and use all editing tools.
- **Collaborators (Play):** Can playtest but cannot edit.

Manage collaborators via Creator Dashboard > experience > Permissions.

## Workflow

### Recommended Team Create Workflow

1. Enable Team Create on the place.
2. Add collaborators via Creator Dashboard.
3. Each developer opens the place in Studio.
4. Work on non-overlapping areas when possible (different parts of the map, different UI screens).
5. Use Drafts for all script work; commit frequently.
6. Use Comments for review discussions and TODOs.
7. Playtest via Team Test (multiple Studio instances simulating server + clients).

### Combining with External Version Control

Team Create and Rojo/Argon can coexist but require discipline:

- Use Team Create for non-code assets (terrain, models, lighting, UI layout).
- Use Rojo for code (scripts synced from Git).
- Avoid editing the same scripts in both systems simultaneously.

## Pitfalls

- Team Create sessions are cloud-hosted; network latency affects edit propagation.
- Large places with many parts can cause slow synchronization.
- Script drafts can diverge significantly if collaborators work on the same file for extended periods without committing.
- No built-in merge tool for conflicting script edits; manual resolution required.
- Team Create auto-saves periodically; there is no manual "save" in the traditional sense.
- Undo/redo history is local to each collaborator and does not span others' changes.

## Related

- [[packages]] -- Packages complement Team Create by providing version-controlled reusable assets.
- [[rojo-mapping]] -- External sync tools for code-focused workflows alongside Team Create.
- [[play-solo-team-test]] -- Team Test mode for multi-client playtesting in Team Create sessions.

## Sources

- [Roblox Creator Docs: Collaboration](https://create.roblox.com/docs/studio/collaboration)
- [DevForum: Collaborative Editing has arrived!](https://devforum.roblox.com/t/collaborative-editing-has-arrived/401676)
- [DevForum: Batch Commits for Collaborative Editing](https://devforum.roblox.com/t/batch-commits-for-collaborative-editing-are-now-available/450692)
- [DevForum: Collaborate with Comments in Studio](https://devforum.roblox.com/t/collaborate-with-comments-in-studio/3634356)
