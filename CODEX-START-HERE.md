# Codex — reprise du projet "Quête Minute"

Auto-battler RPG Roblox, 100% GUI, paysage-only. Tu reprends après une session Claude.

## Lis d'abord (dans l'ordre)
1. `docs/plan/07-handoff-2026-09-01.md` — état exact, ce qui reste, décisions déjà prises
2. `docs/plan/06-followups.md` — la dette technique à traiter
3. `docs/plan/00-plan-complet.md` §D — les tracks A→L et leurs prompts
4. `design/gdd/master-gdd.md` + `design/gdd/systems-index.md` — la conception
5. `CLAUDE.md` — règles du projet (protocole : proposer avant d'écrire, pas de commit sans accord)

## Setup
- **Rojo** (sync fichiers → Studio) : `C:\Users\Allan\.rojo\bin\rojo.exe serve serve.project.json` dans un terminal, puis dans Studio : panneau Rojo → Connect (port 34872). Toute modif de `src/` se synchronise en direct.
- **Ne touche jamais** `src/StarterGui/` (RpgGui construit à la main, hors Rojo).
- **Clé Roblox Open Cloud** : `C:\Users\Allan\.roblox\open-cloud.env` (hors repo). Sert seulement si tu ré-uploades des assets via `tools/assetgen/upload.py`.
- Toolchain (selene/stylua) pas installée. Vérifie la syntaxe en chargeant les modules dans Studio (Play mode = require frais ; Edit mode a un cache périmé).

## État
- **Tracks A (assets), B (sécurité code), D (modèle chiffré), E (narratif) : TERMINÉS.**
- **Track C (23 GDD système) : 6/23 écrits.** Fait : core-gameplay, combat, progression, talents, subclass, rebirth, abilities, boss-mechanics, nightmare.
- **30 commits sur master, NON pushés.**

## Ce que tu dois faire

### 1. Finir Track C (les GDD manquants)
Modèle : `.claude/docs/templates/gdd-system.md` (9 sections, formules explicites, ≥8 edge cases). Ne recontredis PAS le modèle chiffré (`design/economy/D1-stat-growth.md`, `D6-playthrough-balance.md`, `GameConfig.luau`).

- **C4 reste : `design/gdd/economy-gdd.md`** — décisions dans le handoff §"En cours" (or=jeu, sink=Rebirth, Q61b abandonné, Reforge, boutique 5 objets, respec 250/point, gemmes f2p 300-500/saison).
- **C5** : `pets-gdd.md`, `codex-gdd.md`, `inventory-gdd.md`
- **C6** : `campfire-gdd.md`, `daily-reward-gdd.md`, `missions-gdd.md`, `daily-dungeon-gdd.md`, `raid-gdd.md`
- **C7-C8** : le reste de `systems-index.md` (weapons, armor-sets, trading, social, leaderboards, ftue, settings, accessibility, live-ops…) + `/design-review` mental sur chaque.
- Mets à jour `design/gdd/systems-index.md` au fur et à mesure.

### 2. Track G — implémentation gameplay (le gros du travail)
`docs/plan/00-plan-complet.md` §D Track G. Priorités issues de la dette (`06-followups.md`) :
- **G1** : `PROFILE_VERSION → 2` + migration ; stats dérivées (retirer `stats` du save) ; `earnedPoints{pool,alloc}` / `freePoints` ; stats auto via `GameConfig.ClassGrowth.statsAtLevel` dans `StatsService`.
- **G3** : `EnemyService.rollEnemy` doit propager `famille` / `petRole` / `magic` (déjà dans `ZoneConfig`) dans le descripteur ennemi. Puis mitigation magique des casters dans `DamageService`.
- **G4** : talents (arbre, effets dans `StatsService.recalc` + hooks combat).
- **G6** : pets — `LootService.rollPetDrop` doit dériver le rôle de la famille du monstre tué.
- **G7** : mécaniques de boss (phases, télégraphe, interruption via `castAbility`, adds, enrage).
- **G9** : Cauchemar — poser `st.nightmareTier`, câbler `GameConfig.Nightmare.*` dans les boucles de combat.

### 3. Tracks F, H, I, J, K, L
- **F** : UI/UX — maquettes manquantes (Talents, encart feu de camp), écrans des systèmes.
- **H** : Season Pass — consommer `premiumSeason` / `passTierCredits`.
- **I** : monétisation — créer les Developer Products + Game Passes dans le Creator Dashboard, remplir `ProductConfig.ids` et `GameConfig.Rewards.permanentPasses[].id` (tous à 0 actuellement) ; drainer `unclaimedProducts`.
- **J** : audio. **K** : QA / perf / `/exploit-check` (dont le follow-up A5 : validation profonde des handlers équipement). **L** : release.

## Règles
- Propose (diff/plan) avant d'écrire. Commit seulement sur demande, messages `type(scope): description` en français, finis par `Co-Authored-By:` + `Claude-Session:` (ou l'équivalent Codex).
- Après chaque changement `src/`, vérifie en Studio (Play mode).
- Ne casse pas les 5 protections de `design/economy/monetization.md` §2.
