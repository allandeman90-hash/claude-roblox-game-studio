# Donjon-raid solo — GDD système

**Version :** 1.0  
**Dernière mise à jour :** 2026-09-02  
**Auteur :** game-designer / systems-designer  
**Statut :** Prêt pour implémentation  
**Parent :** `design/gdd/master-gdd.md`  
**Références :** `design/gdd/core-gameplay-gdd.md`, `design/gdd/daily-dungeon-gdd.md`, `design/gdd/progression-gdd.md`,
`design/reponses-consolidees.md` (Q37)

---

## 1. Overview & Purpose

Le **Donjon-raid** (mentionné en Q37 comme R20 : « Donjon dimensionnel ») est un **mode de jeu** distinct,
accessible au Rebirth 20+. C'est un **donjon long et difficile** avec **paliers de difficulté** progressifs
et des **boss exclusifs**, offrant des récompenses élevées.

**Rôle clé :** Progression long-terme post-Cauchemar. C'est le système pour les joueurs très actifs
qui ont besoin de contenu plus dur et de récompenses d'end-game.

---

## 2. Core Mechanics

### 2.1 Accès et prérequis

- **Déverrouillage :** Rebirth 20+
- **Accès :** bouton « Raid » au Feu de camp
- **Prérequis :** avoir atteint au moins Cauchemar niveau 1 (premier palier)

### 2.2 Structure des paliers

Le Raid est divisé en **paliers de difficulté croissante** :

| Palier | Difficulté | Bosses | Récompenses |
|--------|-----------|--------|-------------|
| 1 | Difficile | 3 boss exclusifs | Légendaires + or élevé |
| 2 | Très difficile | 3 boss + ennemis ×1.5 | Légendaires renforcés |
| 3 | Cauchemardesque | 3 boss + ennemis ×2 | Mythiques + or massif |
| ∞ | Infini | Bosses répétés, difficulté ↑ | Paliers de complétion |

**Progression :** le joueur choisit un palier au départ (peut faire 1, puis 2, puis 3, puis ∞).

### 2.3 Bosses exclusifs

Chaque palier contient 3 **bosses exclusifs** du Raid (design différent des boss normaux) :
- Mécaniques spéciales (plusieurs phases, adds importants, enrage)
- Visuels distincts (assets Raid-only)
- Drops exclusifs (items « Raid-tier »)

### 2.4 Accès libre (pas de clé unique)

Contrairement au Donjon du Jour :
- **Pas de clé requise** (accès illimité, tant qu'on est au Rebirth 20+)
- **Pas de cooldown** (on peut faire plusieurs tentatives/jour)
- **Progression permanente** : une fois un palier complété, on peut revenir pour l'affronter à nouveau

### 2.5 Palier infini

Après le palier 3, un **palier infini** s'ouvre :
- Les 3 boss du palier 3 se répètent indéfiniment (pattern)
- Difficulté augmente à chaque cycle (+5 % ennemis tous les cycles)
- Récompenses croissantes (or bonus, taux de loot ↑)
- Pas de limite functionnelle

**Raison :** permet aux joueurs de « farmer » du contenu infinite (progression sans plafond).

### 2.6 Récapitulation vs Recommencer

- **Accumulatif :** les récompenses s'accumulent au fur et à mesure
- **Sauvegardes :** progression dans le Raid peut être gardée (le joueur peut revenir plus tard)
- **Sortie libre :** le joueur peut quitter le Raid à tout moment et revenir plus tard (dans la même tentative)

### 2.7 Récompenses

Récompenses par palier :

| Palier | Or | Items | Autre |
|--------|---|-------|-------|
| 1 | 5 000 | 2 Légendaires | — |
| 2 | 12 000 | 2 Légendaires renforcés | — |
| 3 | 30 000 | 2 Mythiques | +2 points de compétence |
| ∞/cycle | 3 000 + progressif | 1 Légendaire/Mythique | — |

**Multiplicateur fin-game :** si en Cauchemar niveau 5+, récompenses ×1.5.

---

## 3. Data Schema

Profil persistant, autorité serveur :

```lua
raid: {
    highestPalierCompleted: number,    -- 0, 1, 2, 3, ou ∞
    currentAttempt: {
        palier: number,
        bossesDefeated: {[bossId]: true},
        rewardsAccumulated: {or: number, items: {}},
        inProgress: boolean,
    }?,
    infiniteCycles: number,            -- nombre de cycles du palier infini complétés
}
```

---

## 4. Client-Server Split

**Serveur :**
- Validation du prérequis (R20+, Cauchemar 1+)
- Génération des bosses par palier
- Suivi de la progression (boss à boss)
- Sauvegarde partielle (sauvegarder à chaque boss)
- Calcul et distribution des récompenses
- Tracking du palier infini

**Client :**
- Affichage du Raid (visuel)
- Sélection du palier
- Affichage de la progression (boss X/3)
- Affichage des récompenses accumulées
- Bouton « Continuer » / « Quitter »

---

## 5. RemoteEvents / Functions

Canal C→S centralisé :

- `startRaidAttempt {palier: 1 | 2 | 3 | "infinite"}` — démarrer une tentative
- `proceedToNextBoss {}` — avancer au boss suivant
- `exitRaidAndClaimRewards {}` — quitter et réclamer les récompenses
- `continueInfinitePalier {}` — continuer un nouveau cycle du palier infini

Réponses S→C :
- `raidStarted {palierData, bosses}` — palier généré
- `bossProceedure {nextBoss}` — prochain boss affiché
- `bossDefeated {reward}` — boss vaincu + récompense
- `raidEnded {totalRewards}` — fin du Raid, récompenses finales
- `infiniteCycleCompleted {reward}` — cycle du palier infini terminé

**Rate-limiting :** `startRaidAttempt` 1/s.

---

## 6. Player-Facing UI

### 6.1 Écran principal Raid

- Titre : « Donjon-raid (Rebirth 20+ requis) »
- Sélection du palier : boutons « Palier 1 » « Palier 2 » « Palier 3 » « Infini »
- Descriptions : difficulté, boss, récompenses attendues
- Prérequis affichés : « Rebirth 20+ » « Cauchemar 1+ »

### 6.2 Progression dans le Raid

- Affichage : « Boss 2 / 3 »
- Visuel : nom du boss, portrait
- Récompenses accumulées : « Or : 8 000 / Items : 2 »

### 6.3 Fin de Raid

- Pop-up : « Raid complété! »
- Affichage des récompenses finales
- Bouton : « Réclamer » (items vont en inventaire, or en bank)
- Bouton : « Recommencer ce palier »

### 6.4 Palier infini

- Affichage : « Cycle 5 / ∞ »
- Affichage du multiplicateur de difficulté : « Ennemis ×1.25 »
- Bouton : « Continuer cycle » / « S'arrêter »

---

## 7. Edge Cases & Error States

1. **Startup du Raid sans R20 :** refus avec message clair « Rebirth 20 requis ».

2. **Startup du Raid sans Cauchemar 1 :** refus avec message « Complétez Cauchemar niveau 1 d'abord ».

3. **Mort au dernier boss (3/3) :** tentative échouée, récompenses perdues (pas de checkpoint).

4. **Rebirth pendant un Raid :** tentative abandonnée, récompenses perdues (pas remboursées).

5. **Sortie du jeu sans « Quitter » :** la tentative est conservée en mémoire, rechargée au retour.

6. **Palier infini avec difficulté qui overflow :** les multiplicateurs sont clamés à une valeur max (1000% ou autre).

7. **Boss corrompu / manquant :** refus de démarrer, tentative annulée, joueur informé.

8. **Récompenses non appliquées :** vérification au login, recompte si manquantes.

9. **Deux tentatives simultanées :** serveur refuse, message « Raid en cours ».

10. **Palier infini après 1000 cycles :** comportement unchanged (infini = vraiment infini).

---

## 8. Balancing Parameters

Tous les paramètres sont centralisés dans `GameConfig.Raid` :

```lua
minRebirth = 20
minNightmareLevel = 1
palierCount = 3
bossesPerPalier = 3
palierRewards = {
    {or = 5000, items = 2},
    {or = 12000, items = 2},
    {or = 30000, items = 2},
}
nightmarePowerMultiplierBonus = 1.5  -- si Cauchemar 5+
infiniteDifficultyGrowth = 1.05  -- +5% par cycle
infiniteOrPerCycle = 3000
```

**Cibles de validation :**

- Palier 1 doit être complètement faisable au R20 avec Cauchemar 1 (entrée douce).
- Palier 3 doit être **très difficile** (boss exclusifs réellement challenging).
- Palier infini doit permettre des sessions ultra-longues (pour les speed-runners).
- Récompenses de Raid > récompenses normales mais pas hyperromptantes (éviter trivialisation).

---

## 9. Integration Points

**Dépend de :**
- Progression (`ProgressionService` — vérification R20+, Cauchemar 1+)
- Combat (`CombatServer` — logique des bosses)
- Inventaire (`InventoryService` — réception des items)
- Économie (`EconomyService` — or des récompenses)
- Rebirth (`RebirthService` — vérification du palier)
- UI (`RaidGui` — interface)

**Alimente :**
- Progression long-terme (R20+ objectif)
- Compétition (speed-running du palier infini)
- Engagement ultra-long-terme (pas de plafond)

**Implémentation attendue :**

1. Créer `RaidService` : génération, validation, progression
2. Ajouter `raid` au profil
3. Bosses exclusifs (3 pour chaque palier)
4. Gestion du palier infini (cycles, scaling)
5. UI `RaidGui` : sélection, progression, récompenses
6. Tests : accès, paliers, infini, edge cases

### Critères d'acceptation

- ✅ Prérequis vérifiés (R20+, Cauchemar 1+)
- ✅ 3 paliers générés avec bosses corrects
- ✅ Palier infini fonctionne (cycles illimités)
- ✅ Récompenses appliquées correctement
- ✅ Progression sauvegarée par boss (checkpoint)
- ✅ Tentatives peuvent être quittées / reprises
- ✅ Rebirth interrompt tentative (récompenses perdues)
- ✅ Edge cases testés

---

**Rôle stratégique :** Le Raid est le contenu d'end-game pour R20+, offrant une progressioninfinie
et des récompenses d'élite. C'est l'objectif lointain pour les joueurs très engagés.
