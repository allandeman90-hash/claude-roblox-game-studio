# Récompense quotidienne (7 jours) — GDD système

**Version :** 1.0  
**Dernière mise à jour :** 2026-09-02  
**Auteur :** game-designer / luau-systems-programmer  
**Statut :** Prêt pour implémentation  
**Parent :** `design/gdd/master-gdd.md`  
**Références :** `design/gdd/core-gameplay-gdd.md`, `design/gdd/pets-gdd.md`, `design/gdd/campfire-gdd.md`,
`design/reponses-consolidees.md` (Q77–Q79)

---

## 1. Overview & Purpose

La **Récompense quotidienne** est un système simple mais crucial : chaque jour, le joueur qui se connecte reçoit
une récompense. La valeur **augmente** chaque jour sur 7 jours, puis **réinitialise au jour 1**.

**Rôle clé :** Moteur de rétention majeur. Pousse les joueurs à revenir chaque jour, avec une montée progressive
de la dopamine (petit cadeau → jackpot le jour 7).

---

## 2. Core Mechanics

### 2.1 Chaîne de 7 jours

La récompense suit une chaîne consécutive :

| Jour | Récompense | Durée/Détail |
|------|-----------|---|
| **J1** | Boost Or + XP ×2 | 4 heures in-game |
| **J2** | Boost ×2 + 1 clé Donjon | 6 heures in-game |
| **J3** | Familier aléatoire +20 % puissance | De la zone actuelle + boost 6 h |
| **J4** | Boost ×2 + 2 clés Donjon | 6 heures in-game |
| **J5** | Toutes récompenses J1–J4 ×2 | (sauf familier) + boost |
| **J6** | Set d'équipement Épique complet | Niveau adapté, zone juste avant record |
| **J7** | Arme exceptionnelle +30 % stats | Gain massif (« jackpot ») |

### 2.2 Réclamation

- **Timing :** chaque login, le joueur voit un pop-up « Récompense du jour ! »
- **Bouton :** « Réclamer »
- **Réception :** récompense envoyée immédiatement à l'inventaire/stats
- **Persistance :** la récompense est concrète (or, item, boost actif)

### 2.3 Continuité

**Définition de « jour »:**
- Un jour = 24 heures réelles
- Chaque login se marque d'un timestamp

**Règles :**
- Si login 1 à J1 10:00 → login 2 avant J2 10:00 = J2 continué
- Si login manqué (dépasse 24h) → réinitialisation à J1
- **Marge de 48h :** si le joueur revient dans les 48h, il peut reprendre où il s'est arrêté
  (ex. : s'arrête J3 mercredi, revient vendredi = J4, pas J1)

### 2.4 Boosts actifs

Les boosts (Or ×2, XP ×2) sont **des multiplicateurs appliqués à la session actuelle** :
- ×2 or sur tous les butins
- ×2 XP sur tous les kills
- Durée : 4 à 6 heures in-game (temps de jeu, pas temps réel)

**Implémentation :** un flag `boostActive` et `boostEndTime` dans le profil.

### 2.5 Familiers aléatoires (J3)

Le familier reçu au **J3** est aléatoire parmi les monstres de la zone actuelle du joueur :
- Si au km 0–20 → familier de zone 1 (Rat, Chauve-Souris, etc.)
- Si au km 50–100 → familier de zone 2, etc.
- Rareté : variable, mais garantie **+20 % de puissance** vs le même trouvé en loot normal

**Cas limite :** si le joueur est au Feu de camp quand il réclame J3, on utilise la dernière zone parcourue.

### 2.6 Set d'équipement (J6)

Le set reçu au **J6** est un ensemble complet d'équipements Épiques (arme + 5 armures) :
- **Rareté :** Épique (locked)
- **Niveau :** adapté au niveau du héros
- **Zone d'origine :** la zone **juste en dessous du record du joueur**
  (ex. : record à km 75 → set de zone km 50–60)
- **Visuel :** avant déblocage, affichage d'une **silhouette noire**

Cela incite le joueur à revenir, et donne un coup de pouce sans dépasser son progression.

### 2.7 Arme exceptionnelle (J7)

L'arme du **J7** est une **arme exclusive** :
- **Bonus :** +30 % de stats vs une arme normale de la zone
- **Rareté :** Rare ou Épique (selon la progression du joueur)
- **Présentation :** « Arme du Destin » ou cosmétique spéciale

C'est l'apothéose de la chaîne, le « jackpot » émotionnel.

---

## 3. Data Schema

Profil persistant, autorité serveur :

```lua
dailyReward: {
    currentDay: number,         -- 1 à 7
    lastClaimTime: number,      -- timestamp unix
    claimedDays: {[day: 1..7]: boolean},  -- tracking de la chaîne
    chainBroken: boolean,       -- true si dépassement 48h
}
```

**Remarques :**
- `currentDay` est recalculé au join (basé sur `lastClaimTime` + logique 24h/48h)
- `claimedDays` sert à vérifier si déjà réclamé aujourd'hui (protection anti-double-claim)

---

## 4. Client-Server Split

**Serveur :**
- Calcul du jour actuel (basé sur timestamps)
- Génération de la récompense
- Validation du timing (pas de double-claim)
- Application des boosts
- Persistance

**Client :**
- Affichage du pop-up de récompense
- Affichage de la chaîne actuelle (J3/7, par exemple)
- Animation d'ouverture de cadeau
- Affichage de la prochaine récompense (teaser)

---

## 5. RemoteEvents / Functions

Canal C→S centralisé :

- `claimDailyReward {}` — réclamer la récompense du jour

Réponses S→C :
- `dailyRewardClaimed {day, reward, nextDay}` — confirmation + préview du jour suivant
- `boostApplied {type, multiplier, durationSeconds}` — notification de boost actif
- `inventoryUpdated` — items reçus

**Rate-limiting :** `claimDailyReward` 1/min (protection anti-spam).

---

## 6. Player-Facing UI

### 6.1 Pop-up de récompense

Au login, affichage immédiat :
- Titre : « Récompense du Jour 3 / 7 »
- Image animée : coffre s'ouvre, récompense s'affiche
- Descriptions claires : « Boost Or ×2 · 4 heures »
- Bouton : « Réclamer »
- Prochaine récompense (teaser) : « Demain : Familier aléatoire »

### 6.2 Chaîne visuelle

- Grille de 7 cases (jour 1–7)
- Case actuelle : surlignée, numéro en gros
- Cases passées (réclamées) : ✓ checkmark
- Cases futures : silhouette / point d'interrogation
- Indication de la marge de 48h : « Reviens avant [date] pour continuer »

### 6.3 Durée des boosts

- HUD : affichage du temps restant du boost (ex. « Boost ×2 : 2h 15m »)
- Barre de progression (visuelle)
- Notification légère quand il expire

### 6.4 Récompense J6 (silhouette)

- Avant déblocage : silhouette noire du set
- Au déblocage : révélation progressive (animation)
- Stats : niveau, rareté, zone d'origine

---

## 7. Edge Cases & Error States

1. **Double clic sur « Réclamer »:** serveur refuse, message « Déjà réclamé aujourd'hui ».

2. **Connexion à minuit (changement de jour):** le serveur calcule le jour basé sur son timestamp.

3. **Dépassement de 48h :** réinitialisation à J1, notification « Chaîne brisée ».

4. **Boost expirant pendant un combat :** multiplicateur retiré en temps réel (fin du combat : or compté normalement).

5. **J3 avec familier dupliqué :** un familier distinct est créé (pas de fusion).

6. **J6 avec inventaire plein :** les items du set ne sont pas reçus ; le joueur doit libérer de l'espace,
   puis peut réclamer manuellement (ou au prochain login).

7. **J7 avec arme équipée :** la nouvelle arme entre en inventaire, peut être équipée au Feu de camp.

8. **Changement de classe/zone avant J3 :** familier basé sur la zone au moment de la réclamation.

9. **Boost non appliqué au login :** vérification du flag `boostActive` et réapplication si corruption.

10. **DataStore indisponible :** J se calcule localement, récompense envoyée en mémoire, flush au retour.

11. **Rebirth pendant une chaîne active :** la chaîne est **préservée** (continue au jour suivant).

---

## 8. Balancing Parameters

Tous les paramètres sont centralisés dans `GameConfig.DailyReward` :

```lua
chainLength = 7
cooldownHours = 24
gracePeriodHours = 48
boostMultiplier = 2.0
boostDurationHours = {4, 6, 0, 6, 6, 0, 0}  -- par jour
familiarBonusMultiplier = 1.2  -- +20 %
setRarityJ6 = "epic"
weaponBonusJ7 = 1.30  -- +30 %
```

**Cibles de validation :**

- **Rétention :** la chaîne 7 jours doit être **le motif principal d'une première semaine** (J7 = raison de revenir).
- **Boosts :** ×2 or/XP encourage l'activité (non-oppressive).
- **Familier J3 :** familier gratuit +20 % aide la progression.
- **Set J6 :** arrive à un moment où c'est utile (non trop tard, non trop tôt).
- **Arme J7 :** +30 % est un vrai coup de pouce (pas négligeable).

---

## 9. Integration Points

**Dépend de :**
- Connexion/Session (`SessionService` — timing de login)
- Inventaire (`InventoryService` — réception des items)
- Progression (`ProgressionService` — application des boosts)
- Familiers (`PetService` — génération d'un familier aléatoire)
- Économie (`EconomyService` — application du boost or)
- UI (`CampfireGui` — pop-up de récompense)

**Alimente :**
- Rétention (chaîne de 7 jours)
- Progression (boosts, items)
- Économie (or bonus)
- Engagement (jackpot du J7)

**Implémentation attendue :**

1. Ajouter `dailyReward` au profil
2. Implémenter la logique de calcul du jour (24h / 48h)
3. Créer `DailyRewardService` : génération, validation, réclamation
4. Ajouter le pop-up au login
5. Implémenter l'application des boosts
6. Générateurs de familier/set/arme
7. Tests : chaîne, boosts, edge cases, Rebirth

### Critères d'acceptation

- ✅ Chaîne de 7 jours fonctionne
- ✅ Cooldown 24h / grâce 48h corrects
- ✅ Boosts appliqués et affichés
- ✅ Familier/Set/Arme générés correctement
- ✅ Pop-up au login
- ✅ Chaîne préservée au Rebirth
- ✅ Edge cases testés (dépasse 48h, plein inventaire, changement zone, etc.)

---

**Intégration :** S'affiche au login via le Feu de camp. Complément parfait pour la rétention.
