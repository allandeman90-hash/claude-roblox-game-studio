# Feu de camp (hub, coffre horaire) — GDD système

**Version :** 1.0  
**Dernière mise à jour :** 2026-09-02  
**Auteur :** game-designer / luau-gameplay-programmer  
**Statut :** Prêt pour implémentation  
**Parent :** `design/gdd/master-gdd.md`  
**Références :** `design/gdd/core-gameplay-gdd.md`, `design/gdd/inventory-gdd.md`, `design/gdd/pets-gdd.md`,
`design/gdd/progression-gdd.md`, `design/reponses-consolidees.md` (Q10, Q66–Q68)

---

## 1. Overview & Purpose

Le **Feu de camp** est le hub central du jeu — le lieu de repos et de gestion. C'est où le joueur :
- Se soigne avant de continuer
- Change de classe/sous-classe
- Gère ses familiers et cosmétiques
- Accède aux donjons et raids
- Voit ses missions du jour
- Réclame les récompenses quotidiennes
- Considère un Rebirth
- Accède à la boutique

Le Feu de camp est **présenté comme un château/structure pixelisée 2D** au km 0 (début de chaque run).

---

## 2. Core Mechanics

### 2.1 Localisation et accès

- **Fréquence :** le joueur atteint un Feu de camp **tous les 50 km** (`GameConfig.World.campfireEveryKm`),
  progression infinie. Le premier est donc à **km 50**. *(Note : il n'y a PAS de feu de camp
  spécial « fin de zone 1 » — une version antérieure de ce GDD le mentionnait, c'était une
  erreur ; le cadeau de familier du tutoriel est découplé du feu de camp, voir `onboarding-gdd.md`.)*
- **Déclenchement :** quand le joueur entre dans la zone du château (`campfireRangeKm` d'un
  multiple de 50) → transition écran (5 secondes) et menu principal du Feu de camp
- **Retour :** bouton « Quitter le Feu de camp » → retour à la marche

### 2.2 Soins (récupération)

**Mécanique :**
- Le joueur reçoit une **barre de récupération** (0–100 %)
- Le soin est **lent intentionnellement** (~10 % HP/s sur 10 secondes pour full heal)
- Pendant qu'on se soigne, le joueur peut faire autre chose (gérer inventaire, familiers, consulter missions)
- Un **petit bonus temporaire** de +10 % vitesse de marche est appliqué pour les prochains km (5 km de durée)

**Raison :** encourage le joueur à explorer les autres fonctions du Feu de camp plutôt que d'attendre passivement.

### 2.3 Changement de classe / sous-classe

- **Classe (arme) :** on peut la changer **seulement au Feu de camp**, pas en marche/combat
- **Sous-classe :** changeable au Feu de camp (coûte 0 or après R5, avant c'est impossible)
- Interface simple : liste des classes, descriptions, bouton « Choisir »

### 2.4 Gestion des familiers

- **Interface :** grille des 4 slots de familiers actifs
- **Actions :** équiper / retirer / changer de rôle (Heal/DPS/Tank)
- **Coût de rôle :** 200 or pour changer de rôle (voir pets-gdd.md)
- Accès à l'inventaire complet de familiers

### 2.5 Gestion des cosmétiques

- **Types :** skins de héros, auras, cadres d'interface, couleurs
- **Achat :** via or (cosmétiques permanents) ou gemmes (premium)
- **Application :** le joueur sélectionne et applique immédiatement
- **Persistance :** les choix survivent au Rebirth

### 2.6 Coffre horaire (cadeau gratuit)

**Mécanique :**
- Un **gros coffre** se remplit en arrière-plan et s'ouvre une fois par heure (réel, pas in-game)
- Contenu : or (variable par progression), petits items, clés de donjon
- Bouton pulsant « Ouvrir le coffre » quand il est prêt
- Cooldown de 1h strict (heure réelle)

**Raison :** encourage les logins répétés, donne du free-to-play un peu d'or passif.

### 2.7 Donjons et raids

- **Accès :** bouton « Donjon du Jour » et « Raid » au Feu de camp
- Voir les GDDs spécifiques (daily-dungeon-gdd.md, raid-gdd.md)

### 2.8 Missions du jour

- **Affichage :** onglet « Missions » montrant les 10 missions de la journée
- Voir missions-gdd.md

### 2.9 Récompense quotidienne (7 jours)

- **Affichage :** onglet « Récompense du jour », bouton pulsant « Réclamer »
- Voir daily-reward-gdd.md

### 2.10 Rebirth

- **Accès :** onglet « Rebirth »
- **Affichage :** coût en or (configuré), bonus du prochain Rebirth
- Voir rebirth-gdd.md

### 2.11 Classements

- **Affichage optionnel :** un petit onglet montrant le top 3 distance (podium)
- Voir leaderboards-gdd.md

---

## 3. Data Schema

Le Feu de camp n'a **pas de données persistantes** propres. Il lit :
- Stats du héros (`ProgressionService`)
- Inventaire (`InventoryService`)
- Familiers (`PetService`)
- Cosmétiques appliqués (`PlayerDataService.cosmetics`)
- Timestamp du dernier coffre ouvert (`lastChestOpenTime`)

Une seule donnée à tracker :

```lua
campfire: {
    lastChestOpenTime: number,  -- timestamp unix du dernier coffre
    nextChestReadyTime: number, -- timestamp unix du prochain coffre
}
```

---

## 4. Client-Server Split

**Serveur :**
- Gestion du cooldown du coffre (1h réelle)
- Génération du contenu du coffre
- Validation du changement de classe/sous-classe
- Changement de cosmétiques (persistance)
- Soins du joueur (stat mutation)

**Client :**
- Affichage du hub (grille de boutons/onglets)
- Affichage de la barre de récupération
- Animation de récupération
- Sélection de classe/cosmétique
- Affichage du coffre (déverrouillé ou en attente)

---

## 5. RemoteEvents / Functions

Canal C→S centralisé :

- `changeClass {classId}` — changer d'arme/classe
- `changeSubclass {subclassId}` — changer de sous-classe
- `openChest {}` — ouvrir le coffre (serveur valide le cooldown)
- `applyCosmeticItem {cosmeticId, slot}` — appliquer un cosmétique
- `beginHealing {}` — débuter la récupération
- `stopHealing {}` — arrêter la récupération

Réponses S→C :
- `classChanged {newClassId}`
- `subclassChanged {newSubclassId}`
- `chestOpened {items, rewards}` — contenu du coffre
- `healingProgress {currentHp, maxHp}`
- `cosmeticApplied {cosmetic, slot}`

**Rate-limiting :**
- `changeClass` : 1/s
- `changeSubclass` : 1/s
- `openChest` : 1/s (mais cooldown réel 1h)
- `applyCosmeticItem` : 2/s

---

## 6. Player-Facing UI

### 6.1 Structure générale

**Écran principal du Feu de camp :**
- Haut-gauche : image du château (pixel art 2D)
- Centre-droit : grille d'onglets/boutons
  - 🎮 Jouer (retourner à la marche)
  - ⚔️ Classe
  - 🛡️ Sous-classe
  - 👹 Familiers
  - 🎨 Cosmétiques
  - 📦 Coffre horaire
  - 🏆 Récompense du jour
  - ⚡ Missions
  - 📜 Donjon du Jour
  - 📍 Raid
  - ♻️ Rebirth
  - 🏅 Classements (petit)

### 6.2 Onglet Classe

- Liste des classes disponibles (armes)
- Sélection → affichage des stats (ATQ, DEF, HP par niveau)
- Bouton « Choisir »

### 6.3 Onglet Familiers

- Grille des 4 slots, drag-and-drop ou clic pour assigner
- Bouton « Gérer l'inventaire »

### 6.4 Onglet Cosmétiques

- Grille des cosmétiques achetés
- Application rapide
- Magasin intégré (voir boutique)

### 6.5 Coffre horaire

- Grande image du coffre (fermé ou ouvert selon le statut)
- Si prêt : bouton pulsant « Ouvrir le coffre »
- Si en attente : affichage du temps restant (HH:MM)
- Animation d'ouverture, affichage du contenu

### 6.6 Soins

- Barre de progression (0–100 %)
- Affichage HP : `123 / 500`
- Bouton « S'arrêter »
- Texte : « Soin en cours... Vous pouvez faire autre chose. »

---

## 7. Edge Cases & Error States

1. **Changement de classe avec inventaire incomplet :** refus si pas de classe valide.

2. **Ouverture du coffre avant la fin du cooldown :** serveur refuse, affichage du temps restant.

3. **Rebirth depuis le Feu de camp :** le joueur est ramené au km 0, réapparaît au Feu de camp immédiatement.

4. **Quitter le Feu de camp pendant la récupération :** soins interrompus, HP conservé.

5. **Changement de cosmétique pendant la marche (hors Feu de camp) :** impossible (UI désactivée).

6. **Coffre jamais ouvert (nouveau joueur) :** l'heure réelle du premier login marque le départ du cooldown.

7. **Rejouer rapidement après fermeture :** le cooldown continue en arrière-plan (basé sur l'heure serveur).

8. **Familier supprimé pendant qu'on le sélectionne :** erreur de validation, suggestion de le remplacer.

9. **Cosmétique supprimé (jamais arrive, mais…) :** le cosmétique est retiré, héros revient à l'apparence de base.

10. **Rebirth en attente de coffre :** le Rebirth procède, coffre non ouvert (pas de perte).

11. **DataStore indisponible :** changements en mémoire, flush au retour du DataStore.

---

## 8. Balancing Parameters

Tous les paramètres sont centralisés dans `GameConfig.Campfire` :

```lua
chestCooldownSeconds = 3600  -- 1 heure
healingRatePerSecond = 0.10  -- 10 % par seconde
healingBonusMovementSpeed = 1.10  -- +10 %
healingBonusDurationKm = 5  -- 5 km
```

**Cibles de validation :**

- Le coffre doit être une **raison de revenir** (or passif sans effort = motivation).
- Les soins doivent être **lents assez pour que le joueur explore le menu** (pas juste attendre).
- Le bonus de soins donne un **petit coup de pouce** (pas un avantage injuste).

---

## 9. Integration Points

**Dépend de :**
- Progression (`ProgressionService` — stats du héros)
- Inventaire (`InventoryService` — changement de classe)
- Familiers (`PetService` — gestion)
- Cosmétiques (`PlayerDataService` — application)
- Missions/Donjons (`MissionsService`, `DungeonService` — accès)
- Rebirth (`RebirthService` — interface)
- UI (`CampfireGui` — interface principale)

**Alimente :**
- Progression (changement de classe, soins)
- Économie (coffre gratuit, cosmétiques)
- Retention (raison de revenir)

**Implémentation attendue :**

1. Créer `CampfireGui` avec structure d'onglets
2. Implémenter les transitions (marche → Feu de camp → marche)
3. Ajouter la logique du coffre (cooldown 1h, génération de contenu)
4. Gérer les changements de classe/cosmétiques
5. Intégrer les panneaux des autres systèmes (Missions, Rebirth, etc.)
6. Tests : changeclass, soins, coffre, cooldown, edge cases

### Critères d'acceptation

- ✅ Feu de camp accessible et ergonomique
- ✅ Coffre avec cooldown 1h fonctionnel
- ✅ Changement de classe/sous-classe fonctionnel
- ✅ Soins lents, bonus temporaire appliqué
- ✅ Tous les onglets accédés depuis le hub
- ✅ Transitions fluides
- ✅ Persistance des changements (classe, cosmétiques)
- ✅ Edge cases testés

---

**Suite :** Les donjons, missions et récompenses se gèrent depuis le Feu de camp.
