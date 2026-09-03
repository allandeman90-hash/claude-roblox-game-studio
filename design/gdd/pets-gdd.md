# Familiers (mini-monstres, rôles par famille) — GDD système

**Version :** 1.0  
**Dernière mise à jour :** 2026-09-02  
**Auteur :** game-designer / luau-gameplay-programmer  
**Statut :** Prêt pour implémentation  
**Parent :** `design/gdd/master-gdd.md`  
**Références :** `design/gdd/core-gameplay-gdd.md`, `design/gdd/inventory-gdd.md`, `design/gdd/codex-gdd.md`,
`design/reponses-consolidees.md` (Q52–Q56, Q66)

---

## 1. Overview & Purpose

Un **familier** est un mini-monstre permanent qui accompagne le héros et fournit un **effet statique continu**
(soins, dégâts bonus, armure, etc.). Les familiers sont des objets de collection et de progression,
obtenus comme butins rares, gérés en inventaire et activés au feu de camp.

**Rôle clé :** Système de progression secondaire qui récompense la collection et donne une couche
de stratégie (choix du rôle du familier). Les familiers soigneurs sont *critiques* pour survivre aux boss.

---

## 2. Core Mechanics

### 2.1 Obtention

**Sources :**
- **Récompense du tuto :** à la fin du tutoriel (`onboarding-gdd.md` §2.1), le joueur reçoit
  **la « Fée »** — un familier générique **identique pour tous les nouveaux joueurs**, rôle DPS,
  rareté Commune. Sa puissance est **50 % de celle d'un familier lâché par un monstre** de même
  zone/rareté (`EquipmentConfig.StarterPetPowerMult = 0.5`, appliqué dans
  `EquipmentService.getPetEffect` via le flag `isStarter`) — comme les armes de départ. Le joueur
  peut re-choisir son rôle au feu de camp.
- **Drops en combat :** chaque monstre normal a une chance de drop familier (rareté variable)
- **Boss golden :** chaque boss nommé donne une version **"dorée"** unique du familier (aspect visuel différent, stats meilleures)
- **Récompenses quotidiennes :** J3 et J5 du système quotidien donnent un familier aléatoire de la zone actuelle (+20 % de puissance vs le même trouvé en loot)

Tous les familiers s'obtiennent dans l'inventaire comme des objets équipables.

### 2.2 Familiers disponibles

**Catalogue :** un familier pour chaque monstre normal + 1 version dorée par boss nommé.

Exemple pour la Couche 1 (Cavernes Superficielles) :
- Rat (normal, rare, épique, légendaire, mythique)
- Rat Doré (1 version, obtenue en battant le boss Couche 1)
- Chauve-Souris (normal, rare, épique…)
- Chauve-Souris Dorée (boss drop)
- Gobelin (…)
- Gobelin Doré (boss drop)
- Ogre (…)

La rareté d'un familier affecte ses stats : un Rat Épique > un Rat Rare.

### 2.3 Rôles et familles

Chaque monstre appartient à une **famille** (Bêtes, Morts-vivants, Élémentaires, Démons, Draciens, etc.).

Chaque familier peut être équipé dans l'un des **3 rôles** :
- **DPS** : augmente l'attaque du héros (+% attaque)
- **Tank** : augmente la défense/HP du héros (+% défense ou +% HP)
- **Heal** : soigne le héros régulièrement pendant les combats (+HP/s)

**Règle familiale :** la **famille du monstre détermine le rôle le PLUS FORT** :
- Bêtes : **DPS > Tank > Heal** (les Bêtes sont plus agressives)
- Morts-vivants : **Heal > DPS > Tank** (les non-vivants guérissent mieux)
- Draciens : **Tank > DPS > Heal** (les dragons sont des tankers)
- etc.

En chiffres : si un bonus de base est `+10 %`, alors :
- Rôle PLUS FORT (famille) : `+10 %`
- Rôle MOYEN : `+7 %`
- Rôle FAIBLE : `+4 %`

**Choix du rôle :** le joueur choisit le rôle du familier au feu de camp. Changer le rôle coûte **200 or** (ou est gratuit après le Rebirth, voir section Edge Cases).

### 2.4 Équipement

- **Limite :** 4 familiers peuvent être actifs **en même temps**
- **Jalons de déblocage :**
  - Départ : 1 familier
  - R10 (Rebirth 10) : déblocage du 2ᵉ familier
  - R20 : déblocage du 3ᵉ familier
  - R30 : déblocage du 4ᵉ familier
- **Interface :** au feu de camp, une grille « Familiers Actifs » montre les 4 slots. Le joueur glisse un familier de l'inventaire dans un slot.

### 2.5 Soins du familier Heal

Un familier en rôle **Heal** soigne le héros **pendant les combats** :
- Fréquence : 1 soin / 3 secondes de combat (configurable)
- Montant : basé sur les stats du familier + son rôle Heal
- Effet visuel : petits cœurs flottants au-dessus du héros
- Mécanique clé : **sans familier Heal, les boss sont beaucoup plus difficiles**

### 2.6 Stats et progression

Les stats du familier dépendent de :
- **Monstre base** (Rat vs Ogre) : valeurs de référence
- **Rareté** (Commun → Mythique) : multiplicateur croissant
- **Niveau du héros** : les familiers scallent dynamiquement avec le héros (voir section Data Schema)
- **Rôle** : modifie le bonus appliqué au héros

Les stats du familier **ne prennent pas de niveaux Forge** (contrairement aux armes).

### 2.7 Pas de pouvoirs actifs

Les familiers ne donnent **aucun pouvoir déclenché** (pas de bouton spécial en combat).
C'est un système d'effets passifs, plus simple et prévisible.

---

## 3. Data Schema

Profil persistant, autorité serveur :

```lua
pets: {
    inventory: {[petKey]: {
        id: string,                -- petKey_<epoch>_<seq>
        monsterId: string,         -- "rat", "ogre", "golem"…
        isGolden: boolean,         -- true si boss drop
        rarity: "common" | "rare" | "epic" | "legendary" | "mythic",
        role: "dps" | "tank" | "heal",  -- rôle choisi
        level: number,             -- suit le niveau du héros (recalculé au join)
    }},
    active: {[slot: 1..4]: petKey | nil},  -- les 4 slots actifs (nil si vide)
    unlockedSlots: number,        -- 1, 2, 3 ou 4 (deblocked par rebirths)
}
```

**Remarques :**
- `level` du familier = niveau du héros (toujours synchronisé)
- `role` peut être changé au feu de camp pour un coût
- Tous les familiers survivent au Rebirth
- Les familiers de l'inventaire inactif ne consomment aucune ressource

---

## 4. Client-Server Split

**Serveur :**
- Calcul des stats du familier (rareté, niveau, rôle, famille)
- Application des bonus au héros (attaque, défense, HP, soins)
- Gestion des soins en combat (ticks de Heal)
- Validation du choix de rôle et du changement
- Déblocage des slots (R10, R20, R30)
- Persistance au profil

**Client :**
- Affichage de la grille Familiers Actifs
- Affichage de l'inventaire de familiers
- Sélection et changement de rôle
- Animation des soins (cœurs flottants)
- Prévision des stats (« +8 % attaque si DPS, +5 % si Tank »)

Le serveur valide tous les changements ; le client ne fait qu'afficher.

---

## 5. RemoteEvents / Functions

Canal C→S centralisé :

- `setPetRole {petKey, newRole: "dps" | "tank" | "heal"}` — changer le rôle d'un familier
- `setPetInSlot {slot: 1..4, petKey}` — équiper un familier dans un slot
- `removePetFromSlot {slot: 1..4}` — retirer un familier d'un slot
- `getPetStats {petKey}` — récupérer les stats détaillées (optionnel, pour l'UI)

Réponses S→C :
- `petsUpdated` — envoyée après toute mutation (changement de rôle, équipement)
- `heroStatsUpdated` — bonus appliqués au héros
- `petRoleChangeRefused` — refus (solde insuffisant, etc.)
- `healTick {amount, petId}` — notification de soin en combat

**Rate-limiting :**
- `setPetRole` : 2/s
- `setPetInSlot` : 2/s
- `removePetFromSlot` : 2/s

---

## 6. Player-Facing UI

### 6.1 Grille Familiers Actifs (au feu de camp)

- **Layout :** 4 slots visibles, style « carte »
- Chaque slot affiche :
  - Icône du familier (couleur de rareté)
  - Nom du monstre + (Doré) si applicable
  - Rôle actuellement équipé (DPS | Tank | Heal)
  - Stats appliquées : `+8 % Attaque`
  - Clic pour changer le rôle ou retirer

### 6.2 Changement de rôle

- Clic sur un familier équipé → popup : « Changer de rôle »
- Radio buttons : DPS | Tank | Heal
- Affichage des bonus pour chaque rôle (avec la famille surlignée)
- Coût affiché : « 200 or » ou « Gratuit après Rebirth »
- Bouton « Confirmer »

### 6.3 Équipement depuis l'inventaire

- Menu Inventaire → onglet Familiers
- Grille des familiers détenus (triés par rareté, puis par monstre)
- Clic sur un familier → popup : « Équiper dans quel slot ? »
- Sélection d'un slot libre → équipement immédiat

### 6.4 Déblocage de slots

- Au R10, R20, R30 : notification « Nouvel emplacement familier débloqué »
- Les nouveaux slots apparaissent vides dans la grille
- Aucune action requise du joueur

### 6.5 Soins en combat

- Familier Heal actif → petits cœurs animés flottent au-dessus du héros
- Chaque soin affiche un nombre flottant (+40 HP, etc.)
- Discret, ne cache pas le combat

---

## 7. Edge Cases & Error States

1. **Changement de rôle sans or :** refus avec message « Or insuffisant pour changer de rôle ».

2. **Déverrouillage de slot avant R10 :** le slot reste verrouillé. Affichage : « Disponible au Rebirth 10 ».

3. **Retrait d'un familier en combat :** pas autorisé ; le joueur ne peut modifier que hors combat (au feu de camp).

4. **Familier dupliqué dans deux slots :** impossible ; le serveur refuse l'équipement si déjà actif.

5. **Familier supprimé pendant qu'il est équipé :** le slot devient vide, les bonus sont retirés, notification légère.

6. **Rebirth avec familier équipé :** tous les familiers sont préservés, les slots restent équipés.

7. **Changement de classe avec familier équipé :** le familier reste actif (pas lié à la classe).

8. **Familier Heal avec 0 mana/ressource :** les soins continuent (pas de système de mana).

9. **Overhealing (HP > max) :** l'HP est clamé à la valeur maximale, aucun overflow.

10. **Deux changements de rôle simultanés :** le rate-limit (2/s) en empêche un. Refus silencieux + log.

11. **Familier hors de l'inventaire :** si un familier actif est supprimé de l'inventaire manuellement (corruption), le serveur le retire du slot.

12. **Familier trouvé à la même rareté qu'un possédé :** aucune fusion ; c'est un objet distinct (les deux peuvent coexister).

---

## 8. Balancing Parameters

Tous les paramètres sont centralisés dans `GameConfig.Pets` :

```lua
petRoleChangeCost = 200  -- or
petSlotUnlockRebirth = {10, 20, 30}  -- R10, R20, R30
petHealFrequencySeconds = 3.0
petHealAmountMultiplier = 1.0
petStatsBonusScale = {  -- multiplicateurs par rôle vs rôle de famille
    strong = 1.0,       -- 10 % → 10 %
    medium = 0.7,       -- 10 % → 7 %
    weak = 0.4          -- 10 % → 4 %
}
```

**Cibles de validation :**

- Un familier Heal doit être **presque indispensable** pour battre les boss (première mort sans Heal vers km 30–50).
- Changer de rôle doit coûter assez pour que ce soit une décision, mais pas au point qu'on ne change jamais (200 or ~= 2–3 kills).
- Les 4 slots débloqués graduellement donnent un objectif long terme (R30 = très loin, reward satisfaisante).
- Un joueur sans familier Heal peut survivre mais c'est beaucoup plus difficile (crée une boucle « je dois farm un Heal »).

---

## 9. Integration Points

**Dépend de :**
- Inventaire (`InventoryService` — les familiers sont stockés comme objets)
- Combat (`CombatServer` — application des bonus, ticks de Heal)
- Progression (`ProgressionService` — les familiers scallent avec le niveau du héros)
- Rebirths (`RebirthService` — préservation des familiers)
- UI (`CampfireGui` — interface de gestion)
- Codex (`CodexService` — les familiers complètent les familles)

**Alimente :**
- Stats du héros (attaque, défense, HP, soins)
- Difficulté des boss (Heal change la viabilité)
- Collection (le Codex suit les familiers trouvés)
- Progression à long terme (déblocages R10/R20/R30)

**Implémentation attendue :**

1. Étendre le profil joueur avec `pets` (inventaire, slots actifs)
2. Ajouter la logique de déblocage de slots au Rebirth
3. Implémenter `PetService` : statiques, application de bonus, gestion de rôles
4. Ajouter les ticks de Heal en combat (CombatServer)
5. UI Campfire : grille de 4 slots, gestion de rôles
6. Inventaire : onglet Familiers, équipement rapide
7. Drops : ajouter les familiers aux butins (via EnemyService)
8. Tests : déblocage, rôles, bonus, Rebirth, edge cases

### Critères d'acceptation

- ✅ Départ : 1 familier du tuto
- ✅ Slots débloqués aux bons Rebirths (R10, R20, R30)
- ✅ 4 rôles possibles, multiplicateurs applicables correctement
- ✅ Changement de rôle + coût d'or validé
- ✅ Ticks de Heal visibles, montants corrects
- ✅ Familiers préservés au Rebirth
- ✅ Stats du héros reflètent les bonus des familiers actifs
- ✅ Drops incluent les familiers (rares)
- ✅ Aucun familier dupliqué dans deux slots
- ✅ Edge cases testés (retrait en combat, suppression, overflow HP, etc.)

---

**Suite :** Codex complète l'identification des monstres + leurs familiers.
