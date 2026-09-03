# Missions (10/jour, chaîne) — GDD système

**Version :** 1.0  
**Dernière mise à jour :** 2026-09-02  
**Auteur :** game-designer / systems-designer  
**Statut :** Prêt pour implémentation  
**Parent :** `design/gdd/master-gdd.md`  
**Références :** `design/gdd/core-gameplay-gdd.md`, `design/gdd/campfire-gdd.md`, `design/gdd/progression-gdd.md`,
`design/reponses-consolidees.md` (Q69–Q72)

---

## 1. Overview & Purpose

Les **Missions** sont des micro-objectifs quotidiens qui structurent la session et récompensent l'activité.
Chaque jour, le joueur reçoit **10 missions** (7 faciles, 2 dures, 1 très dure). Les compléter donne
des points de compétence permanents et des récompenses.

**Rôle clé :** Système de progression parallèle et de focalisation. Les missions donnent au joueur des buts
clairs et des récompenses tangibles (points de compétence = stats). La boucle quotidienne encourage l'engagement.

---

## 2. Core Mechanics

### 2.1 Chaîne de 10 missions

Chaque jour (réinitialisation à minuit serveur), le joueur reçoit 10 missions :

| Type | Quantité | Difficulté | Exemples |
|------|----------|-----------|----------|
| Faciles | 7 | Facile | Tuer 5 mobs · Avancer 10 km · Utiliser un pouvoir 3 fois |
| Dures | 2 | Difficile | Battre 2 boss · Atteindre km 75 · Forger 5 items |
| Très dure | 1 | Très difficile | Atteindre km 100 · Compléter Donjon du Jour |

Les missions sont générées aléatoirement selon la progression du joueur (niveau, record).

### 2.2 Objectifs des missions

Les missions couvrent diverse actions :

- **Kills :** tuer X monstres, tuer X boss nommés
- **Progression :** atteindre km X, atteindre niveau Y
- **Pouvoirs :** utiliser le pouvoir 1 / 2 / 3 un total de X fois
- **Équipement :** trouver une arme Rare, forger Y items
- **Familiers :** équiper 2 familiers, activer Heal 1 fois
- **Donjons :** compléter Donjon du Jour, atteindre étage X
- **Codex :** déverrouiller 3 entrées de Codex
- **Économie :** dépenser X or, gagner X or

Variance selon la classe du joueur, son Rebirth, son Cauchemar.

### 2.3 Durée et réinitialisation

- **Disponibilité :** 24 heures à compter de minuit serveur
- **Réinitialisation :** à minuit (22h–2h selon zone horaire locale, utiliser UTC)
- **Statut :** les missions en cours s'affichent, celles incomplètes sont perdues après minuit

### 2.4 Changement de mission (1/jour gratuit)

Le joueur peut **changer une mission une fois par jour gratuitement** :
- Bouton « Changer » sur une mission
- La mission est remplacée par une nouvelle du même type de difficulté
- Cooldown : 1 utilisation / 24h

Cela permet d'éviter les missions impossibles (ex. « atteindre km 200 » quand on est bloqué à km 50).

### 2.5 Récompenses

**Récompense par mission :**
- Facile : 1 point de compétence
- Dure : 2 points de compétence
- Très dure : 3 points de compétence

**Total journalier :** 7×1 + 2×2 + 1×3 = **14 points de compétence permanents** si toutes complétées.

**Bonus de complétion :** si le joueur complète **toutes les 10 missions**, il reçoit un **bonus de 2 points**
supplémentaires (total 16).

**Or bonus :** chaque mission complétée donne aussi un petit or (variable par difficulté : 50–200 or).

### 2.6 Suivi en temps réel

Le serveur suit la progression de chaque mission en temps réel :
- Tuer un mob → progressbar « 3/5 » se met à jour
- Atteindre un km → progression mise à jour
- Utiliser un pouvoir → compteur incrémenté

Le client affiche la progression **live** (pas de délai).

### 2.7 Missions impossibles

Certaines missions peuvent devenir **impossibles** si la progression change :
- Ex. : mission « Tuer le boss Couche 2 » mais le joueur fait un Rebirth et retourne au km 0
- Implémentation : mission est **marquée en gris** (non complétable), pas de pénalité
- Le joueur peut utiliser son changement gratuit pour la remplacer

---

## 3. Data Schema

Profil persistant, autorité serveur :

```lua
missions: {
    dayStartTime: number,              -- timestamp du dernier reset
    missions: {[missionId: 1..10]: {
        type: string,                  -- "kill_mobs", "reach_km", "use_ability"…
        difficulty: "easy" | "hard" | "very_hard",
        target: number,                -- objectif (ex. 5 pour "tuer 5 mobs")
        current: number,               -- progression actuelle
        completed: boolean,
        changedToday: boolean,         -- true si déjà utilisé le changement gratuit
    }},
}
```

---

## 4. Client-Server Split

**Serveur :**
- Génération des missions (minuit)
- Suivi de la progression
- Validation des complétions
- Détection de réinitialisation (minuit)
- Recompte des bonus
- Persistance

**Client :**
- Affichage de la liste de missions
- Affichage des progressbars en temps réel
- Bouton « Changer »
- Notification de complétion (animation, son)
- Statut global « X/10 complètes »

---

## 5. RemoteEvents / Functions

Canal C→S centralisé :

- `changeMission {missionId}` — changer une mission (gratuit 1/jour)
- `getMissionProgress {}` — récupérer l'état actuel (optionnel, pour refresh)

Réponses S→C (push) :
- `missionsGenerated {missions}` — 10 missions reçues (au login ou minuit)
- `missionProgressUpdated {missionId, currentProgress}` — progression live
- `missionCompleted {missionId, reward}` — mission complétée
- `allMissionsCompleted {bonusReward}` — bonus de 2 points si toutes faites
- `missionChangedToToday {newMission}` — changement effectué

**Rate-limiting :**
- `changeMission` : 1/s

---

## 6. Player-Facing UI

### 6.1 Onglet Missions (au Feu de camp)

- Liste de 10 missions
- Tri : faciles en haut, puis dures, puis très dure
- Affichage par mission :
  - Icône (type : épée = kill, km = marche, etc.)
  - Titre : « Tuer 5 mobs »
  - Progression : `3 / 5` ou barre
  - Récompense : « +1 compétence »
  - Bouton « Changer » (grisé si déjà utilisé aujourd'hui)

### 6.2 Statut global

- En haut : « 7 / 10 missions complètes »
- Barre de progression (0–100 %)
- Indication du bonus : « Complète les 10 pour +2 points bonus »

### 6.3 Notifications

- Complétion d'une mission : pop-up léger « Mission complètée! +2 compétences »
- Complétion de toutes : animation plus grande « BONUS DE COMPLÉTION! +2 points »

### 6.4 Minuit (réinitialisation)

- Notification : « Nouvelles missions disponibles »
- Anciennes missions disparaissent, 10 nouvelles s'affichent
- Animations de « nouveau jour »

---

## 7. Edge Cases & Error States

1. **Changement de mission après déjà changée :** refus, message « Changement gratuit déjà utilisé ».

2. **Complétion durant un combat :** validation après la fin du combat.

3. **Mission impossible (ex. « Tuer boss Couche 5 » mais niveau 20) :** affichée en gris, pas de pénalité.

4. **Rebirth pendant les missions :** compteurs réinitialisés (les missions continuent, adaptées à la nouvelle progression).

5. **Réinitialisation de minuit pendant un combat :** anciennes missions conservées jusqu'à la fin du combat,
   puis nouvelles s'affichent.

6. **Changement de classe :** certaines missions deviennent impossibles (ex. « Utiliser le pouvoir 1 »
   si on change de classe). Marquées en gris.

7. **Bonus jamais appliqué :** vérification serveur : si `count(completed) == 10` et `bonusApplied == false`,
   appliquer et marquer.

8. **Chaîne mission impossible et changement gratuit épuisé :** l'utilisateur ne peut pas compléter.
   Implémentation : on laisse l'utilisateur en attendre une nouvelle à minuit.

9. **DataStore indisponible :** missions en mémoire, complétion trackée, flush au retour.

10. **Spam de complétion :** rate-limit côté serveur, une seule complétion par requête.

11. **Missions générées mal (type invalide, cible 0):** validation serveur, régénération si corruption.

---

## 8. Balancing Parameters

Tous les paramètres sont centralisés dans `GameConfig.Missions` :

```lua
missionsPerDay = 10
easyCount = 7
hardCount = 2
veryHardCount = 1
skillPointRewards = {1, 2, 3}  -- easy, hard, very_hard
bonusForAllCompleted = 2
orRewards = {50, 100, 150}
changeFreePerDay = 1
```

**Cibles de validation :**

- **16 points de compétence/jour** (14 + 2 bonus) est un gain significatif mais pas game-breaking.
- Les missions impossibles ne pénalisent pas (marquage en gris, changement gratuit utile).
- La variété encourage des playstyles divers (tuer, forger, progresser, utiliser des pouvoirs).
- Le changement gratuit 1/jour permet d'éviter le frustration sans rendre gratuit.

---

## 9. Integration Points

**Dépend de :**
- Progression (`ProgressionService` — génération adaptée au niveau)
- Compétences (`ProgressionService` — application des points gagnés)
- Combat (`CombatServer` — tracking des kills)
- Équipement (`EquipmentService` — tracking forges)
- Familiers (`PetService` — tracking activations)
- Donjons (`DungeonService` — tracking complétion)
- Codex (`CodexService` — tracking déverrouillages)
- UI (`CampfireGui` — affichage des missions)

**Alimente :**
- Progression (points de compétence)
- Économie (or bonus)
- Engagement (objectifs quotidiens)
- Rétention (raison de revenir)

**Implémentation attendue :**

1. Créer `MissionsService` : génération, validation, suivi
2. Ajouter `missions` au profil
3. Générateurs de missions (répertoire par difficulté)
4. Suivi en temps réel (hooks dans CombatServer, EquipmentService, etc.)
5. UI `MissionsTab` dans CampfireGui
6. Gestion de minuit (réinitialisation)
7. Tests : génération, suivi, complétion, bonus, réinitialisation, edge cases

### Critères d'acceptation

- ✅ 10 missions générées chaque jour
- ✅ Chaîne de difficulté (7 faciles, 2 dures, 1 très dure)
- ✅ Progression trackée en temps réel
- ✅ Récompenses appliquées (points + or)
- ✅ Bonus de complétion (+2 points)
- ✅ Changement gratuit 1/jour
- ✅ Réinitialisation à minuit
- ✅ Missions impossibles marquées (pas de pénalité)
- ✅ Rebirth et changement de classe gérés
- ✅ Edge cases testés

---

**Rôle stratégique :** Les missions donnent au joueur des buts structurés et des récompenses permanentes (compétences),
complément parfait aux donjons et récompenses quotidiennes.
