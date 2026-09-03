# Donjon du Jour (par étages) — GDD système

**Version :** 1.0  
**Dernière mise à jour :** 2026-09-02  
**Auteur :** game-designer / level-designer  
**Statut :** Prêt pour implémentation  
**Parent :** `design/gdd/master-gdd.md`  
**Références :** `design/gdd/core-gameplay-gdd.md`, `design/gdd/campfire-gdd.md`, `design/gdd/progression-gdd.md`,
`design/reponses-consolidees.md` (Q73–Q76)

---

## 1. Overview & Purpose

Le **Donjon du Jour** est un **mini-donjon thématique quotidien** structuré en **étages avec difficulté croissante**.
Le joueur commence à un étage adapté à sa progression et décide à chaque étage de **continuer** (récompenses ↑, risque ↑)
ou de **s'arrêter** (garder ses récompenses). Mourir = perte des récompenses non sécurisées.

**Rôle clé :** Système d'engagement quotidien avec une boucle **Risk vs Reward**. Encourage les logins,
donne des récompenses concentrées (or, items rares) et crée de la tension (« dois-je continuer ? »).

---

## 2. Core Mechanics

### 2.1 Structure par étages

Le Donjon du Jour a **5 étages** :

| Étage | Ennemis | Défi | Sécurité | Récompenses |
|-------|---------|------|----------|------------|
| 1 | Zone 1 (facile) | Mobs normaux | ✓ Sécurisé | 20 or + 1 item commun |
| 2 | Zone 2 (moyen) | Mobs + 1 mini-boss | Moyen | 50 or + 2 items |
| 3 | Zone 3 (difficile) | Mobs durs + boss | Difficile | 150 or + Rare |
| 4 | Zone 4 (très difficile) | Mobs très durs + gros boss | Très difficile | 400 or + Épique |
| 5 | Boss exclusif Donjon | Mécaniques spéciales | Boss | 1000 or + Légendaire |

**Sécurité :** les étages 1–3 sont « sécurisés » (les récompenses sont garanties même si on meurt après).
À partir de l'étage 4, les récompenses peuvent être perdues en cas de mort.

### 2.2 Progression initiale

Au **premier du jour**, le joueur reçoit **1 clé de Donjon** :
- Il peut faire **1 tentative par jour**
- Réussite = progression à l'étage suivant
- Mort = fin de la tentative (clé consommée)

**Point de départ :** le joueur reprend chaque jour à l'**étage maximal atteint précédemment**, impossible d'aller plus haut
la même semaine (anti-farm, encouragement de revenir chaque jour pour progresser).

### 2.3 Salles et défis

Chaque étage contient **5 salles + 1 boss final** :

| Salle | Type | Défi |
|-------|------|------|
| 1–4 | Normal | Mobs aléatoires du thème, coffres optionnels |
| 5 | Défi | Variation (pas de soin, dégâts ×2, ennemis ×2, etc.) |
| Boss | Combat | Boss exclusif du Donjon (assets à déterminer) |

Certaines salles ont des **coffres optionnels risqués** : ouvrir = récompense bonus mais ennemis se renforcent.

### 2.4 Thème quotidien

Chaque jour a un **thème** fixe sur une semaine :
- Lundi = Bêtes
- Mardi = Morts-vivants
- Mercredi = Élémentaires
- Jeudi = Démons
- Vendredi = Draciens
- Samedi = Humanoides
- Dimanche = Mixte (tous)

Le thème détermine : mobs, décor, musique, boss visuel.

### 2.5 Risk vs Reward

À chaque fin d'étage :
- **Récompenses sécurisées :** or + items (normalement)
- **Récompenses à risque** (étages 4–5) : si on meurt avant la fin, les récompenses de cet étage sont perdues
- **Bouton :** « Continuer » ou « S'arrêter et garder »

**Psychologie :** encourage la prise de risque progressive (« juste un étage de plus »).

### 2.6 Clés de Donjon bonus

Autres sources de clés :
- Missions (J2, J4, J5 de la récompense quotidienne)
- Missions quotidiennes (complétion donne des clés)
- Pass de saison (paliers premium)

Permet de faire plusieurs tentatives certains jours.

### 2.7 Classement par étage

Un **classement des meilleurs temps** est tenu :
- Trié par étage (meilleur temps de l'étage 1, meilleur de l'étage 2, etc.)
- **Top 100 globaux** : gagnent or + XP + 1 point de compétence permanent
- **Top 10 par étage** : gagnent un **titre** (ex. « Champion du Donjon Étage 3 »)

Classement **réinitialisé chaque semaine** (dimanche 23:59) pour égalité des chances.

### 2.8 Progression personnelle

Le joueur reprend toujours à son **étage max** pour la semaine en cours :
- Record : étage 4 → lundi = peut entrer à étage 4
- Nouvelle semaine (lundi) : réinitialisation au étage 1
- Impossible de dépasser son record pendant la semaine

**Raison :** empêche un joueur très fort de "écraser" un nouveau joueur au classement en farmant éternellement.

---

## 3. Data Schema

Profil persistant, autorité serveur :

```lua
dungeon: {
    dailyClue: number,                  -- 0 ou 1 (consommée ou non)
    attemptInProgress: boolean,         -- true si dans le donjon
    currentFloor: number,               -- étage actuel (1–5)
    maxFloorThisWeek: number,          -- record de la semaine
    weekStartTime: number,              -- timestamp du lundi 00:00 UTC
    rewardsSecured: {or: number, items: {}},  -- récompenses "verrouillées"
    currentRewards: {or: number, items: {}},  -- récompenses si on continue
}
```

---

## 4. Client-Server Split

**Serveur :**
- Génération des étages et mobs
- Génération du boss
- Validation du combat (mouvements, dégâts)
- Tracking des récompenses (sécurisé vs à risque)
- Gestion des choix (continuer / s'arrêter)
- Calcul du classement
- Persistance

**Client :**
- Rendu du donjon (visuel)
- Affichage des récompenses possibles
- Boutons « Continuer » / « S'arrêter »
- Affichage du temps d'étage
- Affichage du classement

---

## 5. RemoteEvents / Functions

Canal C→S centralisé :

- `startDungeonAttempt {floor: 1..5}` — démarrer une tentative
- `proceedToNextFloor {}` — passer à l'étage suivant
- `stopAndClaimRewards {}` — arrêter et garder les récompenses
- `openRiskyChest {}` — ouvrir un coffre bonus (renforce les ennemis)

Réponses S→C :
- `dungeonStarted {floorData}` — étage généré
- `floorCompleted {rewards}` — étage complété, récompenses affichées
- `bossDefeated {reward}` — boss vaincu
- `dungeonEnded {finalRewards, lostRewards}` — fin du donjon
- `leaderboardUpdated {ranking}` — classement mis à jour

**Rate-limiting :** `startDungeonAttempt` 1/s (une seule tentative à la fois).

---

## 6. Player-Facing UI

### 6.1 Écran principal Donjon

- Haut : « Donjon du Jour — Thème : Bêtes (lundi) »
- Centre : étage actuel (1–5), visuel du décor
- Bas : 2 boutons « Continuer » / « S'arrêter et Garder »
- Côté : affichage des récompenses actuelles vs sécurisées

### 6.2 Combat dans le Donjon

- Combat identique au jeu normal (auto-battler)
- HUD allégé, focus sur l'étage en cours
- Petite notification : « Étage 3 / 5 »

### 6.3 Choix au bout d'étage

- Pop-up : « Étage 3 complété! »
- Affichage des récompenses sécurisées en vert
- Affichage des récompenses à risque (si étage 4+) en orange
- Boutons : « S'arrêter » (vert, sûr) / « Continuer » (orange, risqué)

### 6.4 Classement

- Onglet dédié : top 10 du jour (meilleurs temps par étage)
- Affichage du rang du joueur : « Vous êtes #27 »
- Titre: « Top 10 des plus rapides »

### 6.5 Progression visuelle

- Barre d'étages : 1 ▯ 2 ▯ 3 ✓ 4 ✓ 5 ⊘ (✓ = complété, ⊘ = actuel)

---

## 7. Edge Cases & Error States

1. **Mort au dernier étage (5) :** récompenses du 5 perdues si réputées à risque ; 1–4 gardées.

2. **Clé consommée à la première salle:** impossible d'avancer, choix de S'arrêter (ou attendre clé bonus).

3. **Réinitialisation de semaine pendant une tentative :** on termine l'étage actuel, les récompenses sont données,
   mais le record est réinitialisé à 1 pour le lundi suivant.

4. **Deux tentatives simultanées (bug):** serveur refuse, message « Tentative en cours ».

5. **Changement de classe au Donjon :** impossible en combat. À la fin d'étage, on peut changer
   (va en arrière-plan).

6. **Rebirth pendant une tentative :** tentative abandonnée, clé remboursée.

7. **Clé bonus jamais reçue:** vérification serveur au claim de missions / récompenses.

8. **Récompenses perdues (mort étage 5):** notification claire « Récompenses de l'étage 5 perdues ».

9. **Classement incomplet (moins de 10 participantsjour):** affichage normal (top 5 si 5 participants).

10. **Défaite au boss finale (étage 5):** fin du donjon, récompenses de 1–4 gardées, 5 perdue.

11. **Score identique (temps):** départage par ordre de complétion (qui a fini en premier).

12. **DataStore indisponible :** tentative en mémoire, classement récompensé au retour.

---

## 8. Balancing Parameters

Tous les paramètres sont centralisés dans `GameConfig.Dungeon` :

```lua
floorsCount = 5
keyPerDay = 1
floorRewards = {
    {or = 20, items = 1},   -- floor 1
    {or = 50, items = 2},   -- floor 2
    {or = 150, items = 1},  -- floor 3 (rare)
    {or = 400, items = 1},  -- floor 4 (épique)
    {or = 1000, items = 1}, -- floor 5 (légendaire)
}
securedFloors = {1, 2, 3}  -- étages où les récompenses sont garanties
leaderboardTopSize = 100
leaderboardRewardSkillPoints = 1
weekResetDay = 0  -- dimanche
```

**Cibles de validation :**

- Un joueur actif doit **atteindre étage 3–4** en quelques jours (progression satisfaisante).
- Clés bonus doivent permettre 1–2 tentatives extra/semaine (encourage missions complètes).
- Récompenses équivalent à ~10 min d'équipement normal (valeur attractive mais pas game-breaking).
- Classement top 100 récompense ~5–10 joueurs actifs/jour (competitive mais accessible).

---

## 9. Integration Points

**Dépend de :**
- Combat (`CombatServer` — logique de combat identique)
- Progression (`ProgressionService` — génération d'étages adapt au niveau)
- Inventaire (`InventoryService` — réception des items)
- Économie (`EconomyService` — or des récompenses)
- Monstres (`EnemyService` — génération thématique)
- UI (`DungeonGui` — interface complète)
- Classement (`LeaderboardService` — tracking temps)

**Alimente :**
- Rétention (raison de revenir chaque jour)
- Progression (items rares)
- Engagement (risk vs reward)
- Compétition (classement)

**Implémentation attendue :**

1. Créer `DungeonService` : génération, validation, récompenses
2. Ajouter `dungeon` au profil
3. Thèmes quotidiens (mapping jour → monstres/boss)
4. Générateur d'étages (mobs + boss)
5. Gestion Risk vs Reward (état sécurisé vs à risque)
6. Classement hebdomadaire (réinitialisation dimanche)
7. UI `DungeonGui` : écran principal, choix étage, classement
8. Tests : progression, risk/reward, classement, réinitialisation, edge cases

### Critères d'acceptation

- ✅ 5 étages générés correctement
- ✅ Thème quotidien appliqué
- ✅ Clé = 1 tentative/jour
- ✅ Progression / S'arrêter fonctionne
- ✅ Récompenses sécurisées et à risque distinctes
- ✅ Mort = perte de récompenses à risque
- ✅ Classement top 100 mis à jour
- ✅ Réinitialisation hebdomadaire
- ✅ Rebirth et changement classe gérés
- ✅ Edge cases testés

---

**Succès :** Le Donjon du Jour crée une boucle captivante (risk vs reward) qui motive les logins quotidiens
et offre des récompenses concentrées (or + items rares) à une population compétitive.
