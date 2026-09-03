# Codex (familles, bonus de complétion) — GDD système

**Version :** 1.0  
**Dernière mise à jour :** 2026-09-02  
**Auteur :** game-designer / luau-systems-programmer  
**Statut :** Prêt pour implémentation  
**Parent :** `design/gdd/master-gdd.md`  
**Références :** `design/gdd/core-gameplay-gdd.md`, `design/gdd/pets-gdd.md`,
`design/reponses-consolidees.md` (Q57–Q60)

---

## 1. Overview & Purpose

Le **Codex** est un système de collection et de progression qui récompense l'exploration et l'accumulation.
Le joueur remplit progressivement des **familles** (Bêtes, Morts-vivants, etc.) en tuant des monstres et
obtenant des familiers. Quand une **famille complète** est possédée, un **bonus permanent croissant**
est débloqué.

**Rôle clé :** Système de progression secondaire qui encourage la diversité (variété de monstres/familiers)
et donne un objectif de collection à long terme. Les bonus de complétion aident tard-game (Cauchemar).

---

## 2. Core Mechanics

### 2.1 Familles

Le jeu regroupe **tous les monstres** en familles thématiques :

| Famille | Monstres | Exemples |
|---------|----------|----------|
| Bêtes | Créatures naturelles | Rat, Chauve-Souris, Loup, Araignée… |
| Morts-vivants | Non-vivants | Squelette, Zombie, Spectre, Fantôme… |
| Élémentaires | Éléments incarnés | Golem, Salamandre, Élémentaire d'eau… |
| Démons | Créatures infernales | Imp, Démon, Succube, Seigneur démoniaque… |
| Draciens | Créatures serpentines | Dragon, Drake, Wyrm… |
| Humanoides | Créatures intelligentes | Gobelin, Ogre, Cyclope, Géant… |

Chaque famille contient **10 à 15 monstres** (selon la zone et la profondeur).

### 2.2 Entrées du Codex

Une **entrée du Codex** est créée pour :
- **Chaque monstre normal** (ex. Rat, Chauve-Souris…) + **version dorée du boss** de ce monstre
- **Chaque boss nommé** (ex. Boss Couche 1 : "Roi Gobelin")

Exemple pour la Couche 1 (Cavernes Superficielles) :
- Rat (monstre normal)
- Rat Doré (version du boss du Rat)
- Chauve-Souris (monstre normal)
- Chauve-Souris Dorée
- Gobelin (monstre normal)
- **Roi Gobelin** (boss nommé de la couche) — entrée distincte

**Silhouette :** tant que l'entrée n'est pas déverrouillée, l'UI affiche une **silhouette noire** ou un point d'interrogation.

### 2.3 Déverrouillage d'une entrée

Une entrée se déverrouille quand le joueur **tue le monstre 10 fois** :
- Chaque kill incremente un compteur (visible au clic : « 7/10 »)
- Après le 10ᵉ kill, l'entrée se remplit : image, nom, stats visibles

**Cas spécial :** les **boss nommés** se déverrouillent au **1er kill** (pas besoin de tuer 10 fois).

### 2.4 Complétude d'une famille

Une **famille est complète** quand **tous les monstres et boss de cette famille** ont leurs entrées
déverrouillées.

Exemple : Famille Bêtes = Rat, Chauve-Souris, Loup, Araignée (+ versions dorées) = 8 entrées.
Une fois les 8 déverrouillées → **Famille Bêtes : COMPLÈTE** → Bonus débloqué.

### 2.5 Bonus de famille

Quand une famille est complète, le joueur reçoit un **bonus permanent croissant** :

```
bonusParFamille = baseBonus × multiplicateurRareté × (1 + 0,15 × familiesCompletées)
```

**Bonus proposé (à calibrer) :** +5 % à une stat (Attaque, Défense, HP, ou XP/Or).

Exemple :
- 1ᵉ famille : +5 % Attaque
- 2ᵉ famille : +5 % Défense
- 3ᵉ famille : +5 % HP
- 4ᵉ famille : +5 % Or (pour les puits d'or)
- 5ᵉ famille : +5 % XP
- 6ᵉ famille : +5 % Vitesse de Heal (familiers)
- etc. (boucle sur les stats ou bilan global +X % puissance)

**Important :** aucune limite au nombre de familles complètes (pas de plafond, progression infinie).

### 2.6 Onglet Objets

En plus des monstres/familiers, le Codex inclut un **onglet « Objets »** qui liste **tous les équipements du jeu**
(armes, armures).

Les objets non trouvés apparaissent en **silhouette noire**.
Les objets trouvés (au moins 1 dans l'inventaire, historique, ou drop) s'affichent normalement.

**Pas de bonus d'objets :** c'est purement cosmétique / achievement / collection.

---

## 3. Data Schema

Profil persistant, autorité serveur :

```lua
codex: {
    monsters: {[monsterId]: {
        kills: number,            -- 0–∞ (nombre de kills)
        unlocked: boolean,        -- true si kills >= 10 (ou 1 pour boss)
        firstKillTime: number?,   -- timestamp unix
    }},
    bosses: {[bossId]: {
        defeated: boolean,        -- true si au moins 1 kill
        firstKillTime: number?,
    }},
    items: {[itemId]: {
        seen: boolean,            -- true si au moins 1 trouvé/drop
    }},
    families: {[familyId]: {
        name: string,
        monstersInFamily: {[monsterId]: true},  -- tous les monstres de la famille
        isComplete: boolean,      -- true si tous déverrouillés
        completionTime: number?,  -- timestamp
        bonusApplied: boolean,    -- bonus appliqué au profil
    }},
}
```

**Remarques :**
- Les kills continuent d'incrémenter après 10 (utile pour les stats, les achievements)
- `isComplete` est calculé serveur-side : `all(monsters) unlocked AND all(bosses) defeated`
- Les bonuses persistent au Rebirth (Codex n'est jamais réinitialisé)

---

## 4. Client-Server Split

**Serveur :**
- Tracking des kills par monstre
- Déverrouillage automatique au 10ᵉ kill / 1er boss
- Calcul de complétude familiale
- Application des bonus au profil du héros
- Persistance au DataStore

**Client :**
- Affichage du Codex (grille de silhouettes / images)
- Affichage du compteur de kills (« 7/10 »)
- Animations de déverrouillage (transition silhouette → image)
- Affichage de la complétion familiale (barre, éclat, bonus appliqué)
- Recherche/filtrage dans l'onglet Objets

Le serveur envoie l'état complet du Codex au client au join ; les mutations sont envoyées en temps réel.

---

## 5. RemoteEvents / Functions

Canal C→S centralisé :

- `getCodexData {}` — charger l'état du Codex (optionnel, pour la première ouverture)

Réponses S→C (push-based) :
- `codexInitialized {state}` — au join, envoi complet du Codex
- `monsterKillTracked {monsterId, newKills}` — après chaque kill
- `monsterUnlocked {monsterId}` — au 10ᵉ kill
- `bossDefeated {bossId}` — au 1er kill d'un boss
- `familyCompleted {familyId, bonusApplied}` — une famille devient complète + bonus appliqué
- `heroStatsUpdated` — bonus de Codex ajoutés aux stats

**Rate-limiting :** aucun, c'est du push serveur (non user-initiated).

---

## 6. Player-Facing UI

### 6.1 Onglet Codex (interface principal)

- **Accès :** menu principal (Feu de camp) ou raccourci en HUD
- **Sélection de famille :** dropdown ou tabs horizontaux
- **Grille de monstres :** 4–6 colonnes selon l'écran (responsive)
- Chaque case : silhouette ou image + nom + compteur kills

### 6.2 Silhouettes

- **Avant 10 kills :** silhouette noire, texte « ??? »
- **Avant 1er kill (boss) :** silhouette noire, texte « ??? »
- **Après déverrouillage :** image complète, nom, stats, description courte

### 6.3 Compteur de kills

- Au survol ou clic sur une entrée : affichage du compteur : « Tués : 7/10 »
- Si complété : « ✓ Déverrouillé »
- Timestamp optionnel : « Première récompense le 2026-09-02 »

### 6.4 Statut de famille

- **Avant complétion :** affichage de la progression : « Bêtes : 5/8 entrées »
- **À la complétion :** éclair / animation, titre brillant « COMPLÈTE »
- **Bonus affiché :** « +5 % Attaque appliqué »

### 6.5 Onglet Objets

- Grille de tous les équipements du jeu (100+ items)
- Silhouettes pour les non-trouvés
- Images pour les trouvés
- Clic : stats de l'objet, zone de drop
- Filtrage : par type (arme, armure), rareté, zone

### 6.6 Statistiques globales

- Total kills : « 1 247 monstres tués »
- Familles complètes : « 3 / 6 »
- Bonus accumulé : « +15 % Puissance globale »
- Progrès vers la prochaine famille : « Morts-vivants : 6/7 »

---

## 7. Edge Cases & Error States

1. **Kill du 10ᵉ monstre en combat :** déverrouillage immédiat, notification légère au sortir du combat.

2. **Rebirth avec familles complètes :** toutes les familles et leurs bonus sont conservés.

3. **Suppression d'un équipement unique :** l'entrée reste déverrouillée dans l'onglet Objets (pas de révocation).

4. **Boss possédant plusieurs formes :** chaque forme compte comme 1 entrée distincte.

5. **Monstre réapparu dans une zone ultérieure :** 1 entrée par monstre (pas de duplication).

6. **Kills futurs après déverrouillage :** le compteur continue d'incrémenter (cosmétique, utile pour stats).

7. **Codex affiché pendant un Rebirth :** l'état sauvegardé se charge, pas de perte de progès.

8. **Deux joueurs sur le même account (impossible):** N/A.

9. **Complétion de famille mais équipement manquant :** les bonus de Codex s'appliquent indépendamment du Codex Objets.

10. **Mutation d'une famille entre deux ouvertures du Codex :** rechargement complet de l'état au join.

11. **DataStore indisponible :** kills/déverrouillages en mémoire, bonus appliqués ; flush au retour du DataStore.

12. **Rareté ou stats d'un item changent (patch):** l'entrée Objets reste visible ; aucune invalidation.

---

## 8. Balancing Parameters

Tous les paramètres sont centralisés dans `GameConfig.Codex` :

```lua
killsToUnlockMonster = 10
killsToUnlockBoss = 1  -- boss: au 1er kill
bonusPerFamilyBase = 0.05  -- +5 % stat
bonusGrowthPerFamily = 0.0  -- +0 % par famille supplémentaire (linéaire)
-- Variant: exponentiel 1.05× par famille pour scaling end-game
```

**Cibles de validation :**

- **Complétude d'une famille :** doit prendre 1–2 sessions de progression normale (pas d'obligation ; réward optionnelle).
- **Bonus au Cauchemar :** les bonus de Codex (15–20 % au 4ᵉ famille) aident mais ne remplacent pas l'équipement/Forge.
- **Progression infinie :** pas de plafond ; les joueurs les plus actifs acumulent 50+ familles (impossible à cause du contenu limité, mais mécaniquement possible).
- **Onglet Objets :** jamais un goulot critique ; c'est purement cosmétique.

---

## 9. Integration Points

**Dépend de :**
- Combat (`CombatServer` — tracking des kills)
- Monstres/Familles (`EnemyService` — liste complète des monstres, leurs familles)
- Familiers (`PetService` — les familiers sont aussi des entrées du Codex)
- Équipement (`EquipmentService` — onglet Objets, drops)
- Progression (`ProgressionService` — les bonus du Codex modifient les stats du héros)
- Persistance (`PlayerDataService` — sauvegarde du Codex)
- UI (`CodexGui` — interface d'affichage)

**Alimente :**
- Stats du héros (bonus de familles complètes)
- Récompense et motivation (objectif de collection)
- Analytics (taux de complétion, profil du joueur)
- Achievements (familles complètes, tous les objets, etc.)

**Implémentation attendue :**

1. Mapper tous les monstres à des familles (config centralisée)
2. Créer `CodexService` : tracking des kills, déverrouillages, bonus
3. Ajouter `codex` au profil joueur (init au nouvel account)
4. UI `CodexGui` : grille de monstres, onglet Objets, stats
5. Push d'événements Codex lors des kills (au serveur)
6. Application des bonus aux stats du héros (multiplicateur)
7. Tests : déverrouillage, complétion, Rebirth, bonus, Objets, edge cases

### Critères d'acceptation

- ✅ Chaque monstre trackable et assignable à 1 famille
- ✅ 10 kills pour déverrouiller un monstre normal
- ✅ 1 kill pour déverrouiller un boss
- ✅ Familles complètes calculent correctement
- ✅ Bonus appliqués aux stats du héros
- ✅ Onglet Objets affiche tous les équipements
- ✅ Silhouettes cachent les non-trouvés
- ✅ Codex préservé au Rebirth
- ✅ Stats et compteurs correctes après rechargement
- ✅ Edge cases testés (kills futurs, suppression d'objets, DataStore down, etc.)

---

**Résumé :** Le Codex crée une progression de collection à long terme, avec des bonus croissants qui aident
au end-game (Cauchemar). C'est un système optionnel mais satisfaisant pour les Achievers.
