# Brief — Refonte UI de `RpgGui` (Quête Minute)

**Créé :** 2026-09-03 · **Pour :** session Claude Code après `/clear`

---

## Objectif

Refonte complète du HUD `RpgGui`, **écran par écran**. Le joueur (Allan, solo dev,
pas très technique, francophone) trouve l'UI actuelle mauvaise — « codex a fait
n'importe quoi ». Cible visuelle : propre, lisible, pas de doré qui « bave »,
moins de bordures blanches, mise en page qui utilise l'espace.

## État du repo au départ

- `master` = `2d58538`, **tout poussé, working tree propre**.
- Rojo tourne (`~/.rojo/bin/rojo.exe serve serve.project.json`, port 34872).
  Vérifier avec `netstat | grep 34872` ; relancer en tâche de fond si absent.
  Studio est connecté (le `studio_id` change à chaque redémarrage de Studio →
  toujours `mcp__Roblox_Studio__list_roblox_studios` d'abord).
- DataStore KO en Studio (`StudioAccessToApisNotAllowed`) = normal, mode
  « degraded / UNSAVED ». Chaque Play = profil neuf.

## Contrainte structurelle CLÉ

`RpgGui` **vit dans le fichier `.rbxl`** (place file), **PAS synchronisé par
Rojo** (`serve.project.json` exclut `StarterGui`). Donc :

1. On édite les **instances live dans Studio** via MCP
   (`mcp__Roblox_Studio__multi_edit`, `execute_luau` en datamodel `Edit`).
2. `src/StarterGui/RpgGui.gui.json` est un **snapshot versionné** (305 nœuds).
   `src/ReplicatedStorage/GuiBuilder.luau` sait le reconstruire
   (`GuiBuilder.build(HttpService:JSONDecode(...))`).
3. **Après chaque écran modifié : re-dumper le JSON** (écrire un petit
   sérialiseur Luau qui walk `RpgGui` et sort le format `{class, props, children}`
   — voir la forme dans `GuiBuilder.luau` `de()`), puis commit le `.gui.json`.
4. `CombatClient.client.luau` (~1900 lignes) référence **chaque nœud du HUD**.
   Supprimer un nœud ⇒ trouver et retirer/adapter le code CombatClient qui le
   touche (`FindFirstChild`, `WaitForChild`, accès direct), sinon crash runtime.
   Vérifier chaque suppression : `grep -n '"<NodeName>"' CombatClient.client.luau`.

## Ce que Codex a laissé (le vrai problème)

**Deux systèmes d'UI empilés, l'ancien jamais retiré. ~40 % des nœuds sont morts
(`Visible=false`, jamais rallumés).**

| Visible / actif (garder) | Mort — à purger (nœud + code CombatClient) |
|---|---|
| `Background.BottomPanel.DescenteLeft` (colonne stats gauche) | `Background.BottomPanel.HeroPanel` (+ `HeroInfoBox`, `HeroStatsBox`, `HeroTimeBox`) |
| `Background.BottomPanel.DescenteRight` (colonne droite — mais 6 cartes `vis=false` mortes dedans : `HpText`,`HpBar`,`HpValue`,`EnemyCard`,`EnemyPvCard`,`GoldCard`,`AtkCard`) | `Background.BottomPanel.CenterPanel` (+ `GoldBox`, `EnemyInfoBox`) |
| `Background.BottomPanel.CombatZone` (la scène) | `Background.BottomPanel.MenuPanel` (+ `MenuButton`, `RebirthButton`) |
| `Background.TopSection.ArtifactDeaths/ArtifactCenter/ArtifactEnemy` | `Background.TopSection.DeathBox`, `Background.TopSection.RightBox` |
| `ZoneTrack.DescenteText` + `ZoneTrack.DescenteRail` + `ZoneTrack.Boss` | `ZoneTrack.Label` + `ZoneTrack.Rail` + `ZoneTrack.Tick1..10` + `ZoneTrack.Dot` + `ZoneTrack.BossMark` |
| `InventoryScreen` (inventaire — Inventory Sprint) | `EquipOverlay` (ancien inventaire complet : `Tabs`, `ItemList`, `RowTemplate`, `FilterBar`, `Summary`) |
| `ShopOverlay`, `ChateauOverlay` (rebirth/checkpoints), `GameOverWindow`, `AccessibilityScreen`, `BagFullPrompt`, `LowHpVignette` | `CombatZone.ZoneLabel`, `CombatZone.DistanceLabel`, `CombatZone.PlayerHpBar`, `CombatZone.EnemyHpPanel`, `CombatZone.EnemyName`, `CombatZone.StatusText` (anciens overlays scène, remplacés par DescenteLeft/Right) |

Noms génériques à renommer au passage : `InventoryScreen.SlotTabs.TextButton` ×7,
`InventoryScreen.FilterRow.TextButton` ×2, tout `AccessibilityScreen` (`Frame`,
`TextLabel`, `TextButton` non nommés).

## Le « glow »

**Aucun effet technique** (pas de Bloom, pas de `TextStroke` sur le HUD, pas de
post-process). C'est le doré **`Color3.fromRGB(255, 220, 70)`** ultra-saturé sur
fond quasi-noir qui bave optiquement. Hardcodé dans `RpgGui` (valeur
`1, 0.862745, 0.27451`), **pas** lu depuis `StyleConstants`.
→ Le retinter en ambre doux (p.ex. `RGB(224, 196, 128)` ou `RGB(210, 180, 120)`).
Idem : ~70 `UIStroke` blanc pur 2px → gris `RGB(150,150,155)` 1px semi-transparent.
`StyleConstants.BaseColors.Accent` porte la même valeur criarde — le corriger
aussi (ReplicatedStorage, lui EST synchronisé Rojo, sert `FtueClient` etc.).

## Problèmes de layout observés (capture HUD de départ)

- Colonne gauche : ~40 % de hauteur utilisée, **gros vide** avant le bouton
  `TALENTS` en bas. Barre PV en haut à gauche déborde du panneau, « 30/30 » collé
  au bord. Traitement des lignes incohérent (certaines soulignées, d'autres non).
- Barre du haut : « ☠ 0 · COUCHE 1 · 0.0 KM » centré, immenses vides gauche/droite.
- Côté droit : `INVENTAIRE` + `MENU` avec énormément de vide autour.
- Police `Enum.Font.Code` (monospace) partout → look « placeholder de dev ».
- Cadre de la scène de combat = simple rectangle bordé, un peu brut.

## Méthode imposée

1. `list_roblox_studios` → `get_studio_state` (Edit mode pour éditer, Play pour tester).
2. **Un écran à la fois.** Ordre suggéré : HUD principal (DescenteLeft/Right +
   TopSection + ZoneTrack + CombatZone) → InventoryScreen → ShopOverlay →
   ChateauOverlay → GameOverWindow → AccessibilityScreen → BagFullPrompt.
3. Par écran : screenshot AVANT → purge nœuds morts + code CombatClient →
   re-layout + retint → screenshot APRÈS → **montrer à Allan, attendre son OK** →
   re-dump `RpgGui.gui.json` → commit `refactor(ui): <écran>` (fr, finir par
   `Co-Authored-By: Claude Sonnet 5` + `Claude-Session:`).
4. Après CHAQUE modif de `src/` : tester en Studio Play (console 0 erreur).
5. Protocole projet : proposer avant d'écrire, pas de commit sans accord d'Allan.

## Pour tester le HUD sans se taper le tuto FTUE

Le FTUE (nouveau, commit `5661180`) affiche des coach-marks au spawn. Pour un
profil « déjà joué » qui saute le tuto : en `execute_luau` datamodel `Server`,
après spawn, `PlayerDataService` — ou plus simple, jouer 2 s et acquitter :
`CombatEvent:FireServer({type="ftueAck", stepId="move"})` puis avancer. Ou
ignorer les bulles (elles ne bloquent rien).

## Références

- `docs/plan/08-handoff-2026-09-03.md` — état global du projet
- `design/gdd/ui-ux-gdd.md` — langage visuel cible (ZIndex, typo, accessibilité)
- `src/ReplicatedStorage/Shared/StyleConstants.luau` — thème (couleurs, helpers)
- `src/README.md` — explication du workflow RpgGui / GuiBuilder
- Mémoire : `minutrpg-build-progress`, `minutrpg-directors-cut-direction`

## Écarts hors-scope de cette refonte (ne pas s'y perdre)

Équilibrage « WoW Classic » validé OK par Allan. Track C (5 GDD restants).
README/agent-roster (50→44 skills, 36→35 agents). `upload.py` ne connaît pas les
sprites pets uploadés via MCP — **ne pas lancer `upload.py`** (il écrase AssetMap).
