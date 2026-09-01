# Decision Log

Major decisions with rationale. Append new entries at the bottom.

<!-- Template:
## YYYY-MM-DD — Decision Title

**Decision**: What was decided.

**Context**: Why this decision came up.

**Options Considered**:
1. Option A: rejected — reason
2. Option B: accepted — reason

**Deciders**: user, agent(s)

**Impact**: What changed as a result.
-->

## 2026-08-31 — GDD maître v1.0 + 119 décisions de design

**Decision**: Écriture du GDD maître (`design/gdd/master-gdd.md`) à partir du questionnaire de
119 questions (`design/questions-jeu.md` / `design/reponses-consolidees.md`) + de l'analyse de
monétisation (`design/economy/monetization.md`).

**Context**: Les décisions de design étaient éparpillées entre GAME_SPEC, docs/plan, mémoire et
conversations. Le proprio a répondu à un questionnaire QCM de 119 questions + 6 questions
supplémentaires (N1-N6) sur toute la surface du jeu.

**Décisions structurantes actées**:
- Stats montent automatiquement par classe × sous-classe (fini l'allocation manuelle au niveau) ;
  points de compétence gagnés uniquement par du jeu actif, permanents (survivent au Rebirth).
- Sous-classe au Rebirth 5 (Berserker/Gardien, Destructeur/Sage). Jalons /5 : R10 4e familier,
  R15 branche avancée, R20 donjon dimensionnel, R25 double spé, R30 maîtrise.
- Niveau max = 100 + 20×rebirths ; le mur EST la raison du Rebirth ; 1er mur vers km 25-35.
- Mode Cauchemar = ladder de difficulté par couche, infini (remplace l'idée "Ascension").
- Boss nommé tous les 10 km + big boss de raid tous les 100 km.
- Mort : garde tout, re-marche depuis le dernier feu de camp (auto-checkpoint /50 km),
  monstres réapparus. Château = feu de camp du km 0.
- "Raid" au lancement = donjon solo plus dur ; co-op en v1.1.
- Monétisation incluse au lancement, plafonds ×3, `max()` jamais empilé, un joueur gratuit
  finit tout. Classement "Robux dépensés" → paliers de Soutien non chiffrés.
- Donjon du Jour par étages, 1 clé/jour, mort = clé perdue, 7 thèmes fixes de la semaine.

**Deciders**: proprio (réponses au questionnaire), game-designer, monetization-lead,
analytics-retention-specialist, exploit-security-specialist.

**Impact**: `design/gdd/master-gdd.md` + `systems-index.md` créés. Débloque la Phase 1 (contenu).
23 GDD par système à écrire. Valeurs chiffrées `[À CALER — P1.9]` via /balance-check.

## 2026-09-01 — Le Guerrier n'a PAS de RES (pas de résistance croisée)

**Decision**: L'armure Guerrier donne **uniquement de la DEF**, l'armure Mage **uniquement de la
RES**. Aucune stat croisée. Pas de constante `crossResistPct`.

**Context**: 5 des 12 boss de La Descente sont magiques (Sorcière, Liche, Archimage, Spectre,
Œil du Vide) et frappent la RES. Un Guerrier a 0 RES → il encaisse ces boss à plein régime.
L'economy-designer avait proposé une résistance croisée optionnelle (~25 %) comme filet.

**Options Considered**:
1. `crossResistPct = 0.25` inerte, à activer si D6 le montre : rejeté — dilue l'identité des voies,
   ajoute un bouton de tuning de plus.
2. **0 % croisé, assumé** : accepté — le Guerrier franchit les boss magiques par le **kit**
   (pouvoirs, familier soigneur/tank, interruption de la grosse attaque, timing de recul), pas
   par une stat. Cohérent avec le pilier 4 (« une couche de décisions actives »).

**Deciders**: proprio, economy-designer.

**Impact**: `EquipmentConfig` : commentaire figé, pas de constante ajoutée. **Consigne pour C1/C3
(combat-gdd / boss-mechanics-gdd)** : chaque boss magique DOIT être franchissable par un Guerrier
nu-de-RES via le kit — à valider dans les 12 signatures de boss et le playtest K3.

## 2026-09-01 — Track D : modèle chiffré verrouillé (D1-D6)

**Decision**: Paramètres finaux du modèle de balance, validés en bloc par le proprio via
l'economy-designer (D1-D5) + playthrough D6.

**Paramètres actés** (tous dans `GameConfig` / `EquipmentConfig` / `ZoneConfig`) :
- **Stats** : 4 points auto/niveau (`Level.autoPointsPerLevel`) répartis par `GameConfig.ClassGrowth`
  (6 tables — Guerrier 45 POW / 40 VIT / 10 SPD / 5 LUK ; Mage 31 INT / 49 VIT / 10 SPD / 10 LUK,
  −30 % dégâts +22 % PV ; 4 sous-classes) + 1 point libre / 5 niveaux.
- **Ennemi** : `Enemy.refPointsPerLevel = 4.7` (découplé du joueur — le mob de même niveau sur-cote
  un joueur nu de ~18 %) ; `enemyAttackInterval 2.0` (early brutal assumé).
- **Crit** : `min(1, LUK/2500)` ; Destructeur `LUK/1800 + 0.0012·niveau`.
- **XP** : `xpForNextLevel(n) = round(6 + 0.5·n^1.10)`, Σ→L100 = 4331 (courbe A « douce », cycle
  rebirth rapide ; le coeff `0.5` est le bouton de calage D6/K3).
- **Or** : `Enemy.base.gold 8`, `goldPerLevel 1.026` ; coût rebirth inchangé `10000·2.2^(n-1)`.
- **Rebirth** : `skillMult(n) = 1 + 0.10n + 0.01n(n-1)` (croissant, Q38 — R1 ×1.10, R5 ×1.70,
  R10 ×2.90) sur les points gagnés ; `xpMult(n) = 1 + 0.25n`.
- **Cauchemar** : ennemis `hp ×1.55^k` / `atk ×1.35^k`, récompenses `×1.80^k`, enrage
  `max(30, 95−5k)` s, déblocage 100 kills + 25/palier, porte globale boss Couche 6.
- **Pass S1** : 50 paliers × 1000 XP ; mission 40, bonus complétion 150 (journée quêtes = 550 =
  55 % d'un palier → quêtes seules ~palier 33, il faut de la Descente/donjon pour finir),
  segment 100 km = 3000 (one-shot Q85).
- **Armes** : `weaponBase 100` (arme boutique = +100 % ATK) ; raretés bande LARGE
  `1.0 / 1.5 / 2.2 / 3.5 / 6.0` (revert « Étape 4.0 » ; Mythique tient ~6 zones) ; arme boss = ×2.5
  boutique de même zone ; 50 armes (2 starter ×0.5 + 24 boutique + 24 boss).
- **Armures** : 96 pièces (12 sets × 4 × 2 voies) auto-générées, stats dérivées (zone, rareté),
  Guerrier → DEF / Mage → RES (0 croisé) ; 12 identités de set distinctes (dégâts/survie/vitesse) ;
  table de butin boss déplacée en config (GAME_SPEC §6.3 inchangée).
- **Rosters** : multiplicateurs de rôle retunés (produit moyen HP×ATK = 1.01 → « mob niv L ≈
  joueur niv L ») ; 72 monstres taggés `famille` (codex) + `petRole`.

**Deciders**: proprio, economy-designer, systems-designer (coordination game-designer).

**Impact**: `GameConfig.luau` / `EquipmentConfig.luau` / `ZoneConfig.luau` / `LootService.luau`
édités (commits `0611dfb`, `4c0dd97`, `24456d7`, + D5). Tableurs de référence :
`design/economy/D1-stat-growth.md` · `D6-playthrough-balance.md`.

**⚠️ 2 items ouverts (D6) — bloquent le GATE Phase 1 côté balance** :
1. **PRÉREQUIS** : `mob niv = round(km × 3.5)` pas encore dans `EnemyService.levelForKm` /
   `rollBoss` — à écrire (décision de session, hors périmètre édits D1-D5).
2. **BLOCANT cible « mur km 25-35 »** : les mobs grandissent linéairement (level-driven), le gear
   géométriquement (×1.30/zone) → un Guerrier équipé dépasse le level cap et pousse à ~km 95.
   `100 + 20·rebirths` ne barre rien tel quel. **Fix recommandé** : `GameConfig.Combat.levelGap*`
   (pénalité de dégâts quand `mobNiv − joueurNiv > 5`) → mur ressenti km 33-42, à resserrer à
   30-37 via `levelGapDmgStep ≈ 0.035`. Décision proprio + C1 (combat-gdd) + implémentation
   G-track. Détail : `design/economy/D6-playthrough-balance.md` §3.
