# Inventaire (100 slots, filtres, tri) — GDD système

**Version :** 1.0  
**Dernière mise à jour :** 2026-09-02  
**Auteur :** game-designer / luau-systems-programmer  
**Statut :** Prêt pour implémentation  
**Parent :** `design/gdd/master-gdd.md`  
**Références :** `design/gdd/core-gameplay-gdd.md`, `design/gdd/economy-gdd.md`, 
`design/reponses-consolidees.md` (Q47–Q51, Q90)

---

## 1. Overview & Purpose

L'inventaire est le système central de gestion des objets du joueur. Il stocke tous les équipements
(armes et armures) obtenus en combat, permet leur tri, leur fusion, leur forge, et gère les cas
limites (sac plein, drop d'un boss, suppression d'objets).

**Rôle clé :** C'est le système fondation pour l'équipement, la Forge infinie, la fusion et l'économie.
Sans inventaire fonctionnel et robuste, aucun autre système d'items ne fonctionne.

---

## 2. Core Mechanics

### 2.1 Capacité

- **Capacité de base :** 100 slots
- **Bonus Pack de Départ :** +25 slots (à acheter une seule fois pour 99 R$)
- **Capacité maximale :** 125 slots (100 + 25)
- **Slot = 1 item unique** (pas d'empilage ; les équipements ne stackent jamais)

Chaque slot contient **exactement 1 instance d'équipement** avec ses propres stats, niveau de Forge,
attributs de rareté et identifiant unique.

### 2.2 Catégories et tri

L'inventaire organise les items en **catégories** (ordre d'affichage fixe) :

| Catégorie | Type d'objet | Slots typiques | Notes |
|-----------|-------------|---|---|
| Armes | Armes équipées | 1 | L'arme active du héros |
| Casques | Armures tête | ~20 | Tous les casques du sac |
| Armures corps | Armures torse | ~20 | |
| Gants | Armures mains | ~20 | |
| Jambières | Armures jambes | ~20 | |
| Bottes | Armures pieds | ~20 | |

**Tri par défaut dans chaque catégorie :**
1. **Rareté** (décroissant : Mythique → Légendaire → Épique → Rare → Commun)
2. **Niveau de Forge** (décroissant : +999 → +0)
3. **Niveau d'objet** (ordre naturel du drop)

**Tri secondaire :** le joueur peut trier par :
- Rareté seule
- Niveau (statistique principale)
- Récence (plus récent en premier)
- Puissance estimée (stats totales)

Le serveur impose l'ordre ; le client l'affiche.

### 2.3 Affichage du niveau d'objet

**Règle visuelle :** le niveau de l'équipement est affiché **en gros** sur chaque ligne pour faciliter
la comparaison rapide.

Format : `Nom Rareté +N` (ex. `Épée Rare +15`)

### 2.4 Gestion du sac plein

Situation : le joueur tue un boss, reçoit un drop, mais le sac est plein (100/100 ou 125/125).

**Flux :**
1. Le serveur détecte `count(items) == capacity`.
2. Une fenêtre de dialogue s'affiche au client : *« Sac plein. Voulez-vous garder le nouvel objet ? »*
3. **Option A :** Garder le nouvel objet → le serveur en enlève un ancien (au choix du joueur, ou le plus faible par défaut).
4. **Option B :** Jeter le nouvel objet → le drop disparaît, aucune mutation d'inventaire.
5. **Timeout :** si pas de réponse en 30 secondes, le drop est jeté automatiquement.

Le joueur n'est **jamais forcé** à jeter un objet ; il peut voir tous ses équipements avant de choisir.

### 2.5 Restriction de changement d'arme

- **Changement d'arme autorisé :** uniquement au feu de camp (hors combat)
- **Raison :** éviter le spam de changement d'arme en combat et maintenir une stratégie cohérente par encounter
- **Implémentation :** le client envoie une requête au serveur ; le serveur refuse si `inCombat == true`

Changement de type d'équipement (casque, armure, etc.) fonctionne normalement en inventaire sans restriction.

### 2.6 Identifiants uniques

Chaque instance d'équipement a un **ID unique dans l'inventaire** :
- Format : `itemKey_<epoch>_<sequence>` (exemple : `sword_1725235123_0042`)
- Persistant : survit au Rebirth, à la sauvegarde/charger
- Utilisé par : Forge (pour tracker les niveaux +N), fusion, tri persistant

### 2.7 Fusion

**Règle :** la fusion **combine des matériaux** avec un objet cible pour en augmenter la rareté ou ajouter des propriétés.
- Coût en or croissant avec la rareté visée
- Les matériaux sont **consommés**
- L'objet cible reçoit la nouvelle rareté

**Détail complet :** voir `design/gdd/economy-gdd.md` §2.5.

---

## 3. Data Schema

Profil persistant, autorité serveur :

```lua
inventory: {
    capacity: number,              -- 100 ou 125
    items: {[itemKey]: {
        id: string,                -- itemKey_<epoch>_<seq>
        name: string,              -- "Épée", "Casque de fer"…
        itemType: "weapon" | "head" | "chest" | "hands" | "legs" | "feet",
        rarity: "common" | "rare" | "epic" | "legendary" | "mythic",
        baseStats: {
            attack?: number,
            defense?: number,
            hp?: number,
            …
        },
        forgeLevel: number,        -- 0, 1, 2, … 999+
        droppedAtKm: number,       -- zone d'origine
        droppedAtTime: number,     -- timestamp unix
        tags?: {string},           -- sets, cosmetics flags
        setId?: string,            -- "set_warrior_tier3"…
    }},
}
```

**Contraintes :**
- `count(items) <= capacity` (validé server-side)
- Chaque `itemKey` est unique dans l'inventaire
- `forgeLevel` existe toujours (par défaut 0)
- Les valeurs numériques sont entières, >= 0

---

## 4. Client-Server Split

**Serveur :** tout ce qui touche l'autorité des données
- Ajout/suppression d'items au sac
- Tri et filtrage de la liste maître
- Validation des slots disponibles
- Validation des propriétés d'item
- Fusion, suppression, Forge (interaction avec l'économie)
- Sauvegarde au DataStore

**Client :** affichage et input
- Rendu de la grille d'inventaire
- Tri local (optionnel, pré-calculé par le serveur)
- Sélection d'items pour fusion/suppression
- Affichage des stats de comparaison
- Animations et feedback

Le client affiche toujours ce que le serveur envoie. Aucune prédiction d'ajout/suppression.

---

## 5. RemoteEvents / Functions

Canal C→S centralisé (tous au niveau `PlayerService` ou dédié `InventoryService`) :

- `selectItem {itemKey}` — sélectionner un item pour voir ses stats détaillées (optionnel, pour l'UI)
- `removeItem {itemKey}` — supprimer un item du sac (désactiver dans le sac plein)
- `changeWeapon {itemKey}` — équiper une arme (refusé si en combat)
- `confirmFullBagAction {choice: "keep" | "discard", targetRemove?: itemKey}` — répondre au sac plein

Réponses S→C :
- `inventoryUpdate` — envoyée après toute mutation (ajout, suppression, tri)
- `bagFullPrompt {newItemData}` — sac plein, fenêtre de choix
- `weaponChangeRefused` — impossible en combat
- `itemForged {itemKey, newForgeLevel}` — confirmation Forge (propriété d'économie-gdd)

**Rate-limiting :**
- `selectItem` : 10/s
- `removeItem` : 2/s
- `changeWeapon` : 2/s
- `confirmFullBagAction` : 1/s (une seule réponse par fenêtre)

---

## 6. Player-Facing UI

### 6.1 Grille d'inventaire

- **Layout :** grille responsive en paysage (voir `ui-ux-gdd.md` pour détails)
- **Affichage par slot :**
  - Miniature/icône de l'item (couleur de rareté)
  - Nom + Rareté + Niveau de Forge (`Épée Rare +15`)
  - Niveau principal d'objet (visible, grande police)
  - Indicateur `(équipé)` pour l'arme active
  - Hover : stats complètes, zone d'origine, timestamp de drop

### 6.2 Tri et filtres

- Bouton **« Trier par »** : Rareté | Niveau | Récence | Puissance
- Bouton **« Catégorie »** : Armes | Casques | Armures | Gants | Jambières | Bottes | Tous
- Les choix sont persistants (sauvegardés côté client via `LocalStorage` ou côté serveur)

### 6.3 Fusion et suppression

- Sélection d'un item → popup : « Fusionner » | « Supprimer » | « Équiper (si arme) »
- Fusion : choix des matériaux, confirmation du coût, animation
- Suppression : confirmation simple, puis disparition

### 6.4 Sac plein

- Grande fenêtre modale au-dessus du jeu
- Affiche l'item qui arrive et propose :
  - Liste des items actuels (triée, sélectionnable pour supprimer)
  - Boutons : « Garder le nouvel objet et supprimer [sélectionné] » | « Jeter le nouvel objet »
- Timeout visuel (compte à rebours 30 s)

### 6.5 Capacité visible

- HUD : `Inventaire : 87/100` (ou `102/125` si bonus)
- Barre de progression visuelle (rouge si plein, orange si > 90 %)

---

## 7. Edge Cases & Error States

1. **Sac plein sans sélection après 30 s :** le drop est jeté, notification légère (« Objet jeté »).

2. **Item supprimé entre l'affichage et la fusion :** le serveur refuse la fusion, message « L'objet n'existe plus »,
   rafraîchissement UI.

3. **Objet forgé entre l'affichage et la fusion :** la fusion utilise les stats actuelles de l'objet forgé.

4. **Changement d'arme en combat :** le serveur refuse, message « Impossible en combat ».

5. **Capacité réduite (équipement bonus supprimé) :** 
   - Si `count(items) > new_capacity`, le serveur **marque l'inventaire en surcharge**.
   - Le joueur ne peut plus récupérer de drops ; doit supprimer des items pour revenir sous la limite.
   - Notification : « Inventaire surchargé. Supprimez un item pour continuer. »

6. **Deux suppressions simultanées (spam):** le rate-limit (`2/s`) en empêche une. Refus serveur silencieux + log.

7. **Items de fusion verrouillés :** si un item est marqué « équipé » ou « dans une fusion en cours »,
   la fusion est refusée jusqu'au déblocage.

8. **DataStore indisponible :** les mutations se font en mémoire ; inventaire jouable mais sans persistance.
   Au retour du DataStore, flush du dirty flag.

9. **Inventaire corrompu au load :** le serveur valide `count(items) <= capacity` ;
   s'il y a surcharge, les items en surplus (les plus anciens) sont supprimés.

10. **Fusion avec matériaux insuffisants :** refus avec message clair : « Matériaux insuffisants pour cette fusion. »

11. **Rebirth avec inventaire plein :** l'inventaire est préservé ; aucune mutation automatique.

12. **Objet en plusieurs exemplaires (crash du profil) :** le serveur recréé les `itemKey` uniques ;
    aucun doublon n'existe dans la structure réelle.

---

## 8. Balancing Parameters

Tous les paramètres sont centralisés dans `GameConfig.Inventory` :

```lua
baseCapacity = 100
bonusCapacityPackId = "capacity_pack"
bonusCapacity = 25
maxCapacity = 125
bagFullTimeoutSeconds = 30
weaponChangeRateLimitPerSec = 2
removeItemRateLimitPerSec = 2
```

**Cibles de validation :**

- Le sac plein doit arriver autour du **km 30–50** pour un joueur dans son 1er run (environ après 20–30 kills).
- La capacité est rarement un goulot d'étranglement ; les joueurs **comprennent qu'ils doivent fondre/supprimer**.
- Les objets anciens deviennent « déchet » passé une certaine zone (pas utiles, prennent du place).
- Le bonus +25 slots change la progression tard (autour du Cauchemar ou R2+), donnant un petit avantage pay-to-convenience.

---

## 9. Integration Points

**Dépend de :**
- Équipement (`EquipmentService` — qui crée les items au drop)
- Combat (`CombatServer` — génère les drops au kill)
- Économie (`EconomyService` — fusion, Forge, suppression avec coûts)
- Persistance (`PlayerDataService` — sauvegarde/charge l'inventaire)
- UI (`InventoryScreenGui` — affichage)

**Alimente :**
- Équipement actif (l'arme equippée affecte les stats du héros)
- Stats (les armures équipées affectent DEF/HP)
- Codex (les objets trouvés complètent les familles du Codex)
- Classements (la rareté max et le Forge max sont des stats de prestige)
- Analytics (quelle rareté est farmée, où)

**Implémentation attendue :**

1. `EquipmentService` — crée des instances d'item avec `itemKey` unique
2. `InventoryService` — gère la liste, le tri, le rate-limiting, la suppression
3. `EconomyService.fuseItem()` — consomme des matériaux, appelle l'inventaire
4. `PlayerDataService` — persiste `inventory` au profil
5. UI `InventoryScreenGui` — affichage de la grille + dialogs
6. Tests : overflow, fusion, suppression, Rebirth, edge cases

### Critères d'acceptation

- ✅ Capacité configurée, testée jusqu'à 125 slots
- ✅ Tri fonctionne dans tous les ordres proposés
- ✅ Sac plein génère une fenêtre, pas une perte d'objet
- ✅ Changement d'arme refusé en combat
- ✅ Fusion et suppression décrémenter correctement le comptage
- ✅ Rebirth préserve l'inventaire complet
- ✅ Aucun item dupliqué
- ✅ Rate-limiting empêche les abus
- ✅ Edge cases testés (surcharge, objet manquant, DataStore down, etc.)
- ✅ Persistance robuste (Rebirth, rechargement, crash simulé)

---

**Suite :** Codex (collection, bonus) et Familiers (rôles, stats) complètent le système d'items.
