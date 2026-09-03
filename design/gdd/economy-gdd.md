# Économie (or, gemmes, boutiques et Forge infinie) — GDD système

**Version :** 1.0  
**Dernière mise à jour :** 2026-09-01  
**Auteur :** game-designer / economy-designer  
**Statut :** Prêt pour implémentation, équilibrage final en jeu requis  
**Parent :** `design/gdd/master-gdd.md`  
**Références :** `design/economy/monetization.md`, `design/economy/D6-playthrough-balance.md`,
`design/gdd/rebirth-gdd.md`, `design/gdd/nightmare-gdd.md`

---

## 1. Overview & Purpose

L'économie repose sur deux monnaies strictement séparées :

- **Or** : monnaie de jeu gagnée en jouant. Elle finance le Rebirth, la Forge infinie,
  la fusion, les boutiques, leurs renouvellements et le respec des statistiques.
- **Gemmes** : monnaie premium obtenue en petite quantité gratuitement. Elle achète uniquement
  des cosmétiques et du confort latéral, jamais de puissance directe.

Le Rebirth reste le grand objectif économique de progression. La **Forge infinie** est le puits
d'or sans plafond : elle permet, à un coût volontairement déraisonnable, de transformer un objet
ancien ou amusant en objet de prestige viable. L'option existe pour la collection et la frime ;
elle ne doit jamais être la manière rentable de progresser.

---

## 2. Core Mechanics

### 2.1 Gains d'or

L'or provient des monstres, boss, missions, donjons, récompenses quotidiennes et événements.
Le serveur calcule toujours le montant final :

```text
orEnnemi = 8 × 1,026^(min(niveauEnnemi − 1, 90))
orFinal = orEnnemi × multiplicateurType × multiplicateurConfort × multiplicateurCauchemar
```

- Boss de couche : multiplicateur de référence `×5`.
- Big boss : multiplicateur de référence `×30`.
- Les bonus de confort cumulés restent plafonnés à `×3`.
- Le Rebirth n'ajoute aucun multiplicateur d'or direct.
- Toute valeur est arrondie côté serveur et bornée à `≥ 0`.

### 2.2 Puits d'or

Ordre d'importance attendu :

1. **Rebirth** : `10 000 × 2,2^(n−1)` pour acheter le Rebirth `n`.
2. **Forge infinie** : puits sans plafond destiné au long terme et au prestige.
3. **Fusion** : coût croissant avec la rareté visée ; les matériaux restent obligatoires.
4. **Boutiques et renouvellements**.
5. **Respec des statistiques** : `250 × points libres et gagnés actuellement alloués`.
6. **Petite sélection de cosmétiques permanents vendus contre de l'or**.

L'or ne permet jamais d'acheter un palier Cauchemar, une meilleure cote de rareté ou un succès.

### 2.3 Forge infinie

Tout équipement peut être forgé sans limite de niveau : `+0`, `+1`, … `+999`, puis au-delà.
L'objet conserve définitivement son identifiant, sa zone d'origine, sa rareté, son set et son
apparence. La Forge augmente uniquement ses statistiques numériques.

```text
multForge(f) = 1,003^f
statFinale = statBaseObjet × multForge(f)

coûtSuivant(f) = arrondi(coûtForgeBaseObjet × 1,035^f)
```

Repères de puissance :

| Niveau | Multiplicateur approximatif |
|---:|---:|
| +10 | ×1,03 |
| +100 | ×1,35 |
| +250 | ×2,11 |
| +500 | ×4,47 |
| +999 | ×20,0 |

Règles :

- Aucun plafond fonctionnel ; les grands nombres utilisent les protections numériques communes.
- Chaque clic achète exactement un niveau, après validation et débit atomique côté serveur.
- Une vieille arme peut rejoindre l'end-game, mais son coût total devient astronomique.
- Une arme récente reste nettement plus rentable à puissance égale.
- Le niveau `+N` est visible dans le nom, la fiche, le chat de drop et les classements futurs.
- La Forge n'augmente ni la rareté ni les probabilités de butin.
- Les coefficients `1,003` et `1,035` vivent dans `GameConfig.Economy`, jamais en dur dans l'UI.

Le coût de base dépend de la valeur native de l'objet. Proposition d'ancrage :

```text
coûtForgeBaseObjet = max(100, prixBoutiqueThéoriqueObjet × 0,10)
```

Le calibrage final doit vérifier qu'une arme de départ vers `+999` représente des milliards ou
davantage, sans rendre les premiers niveaux frustrants.

### 2.4 Boutiques

**Feu de camp :** stock de cinq objets adaptés à la voie active : une arme et quatre armures.
Raretés normales : Commun ou Rare. Une sixième ligne de luxe peut apparaître avec une rareté
supérieure et un prix fortement majoré.

**Renouvellement :** le joueur dépense de l'or pour re-tirer le stock. Le coût dépend de la zone
et empêche le spam gratuit.

**Marchand ambulant :** chance d'apparition d'environ 15 % par cluster de pas avant chaque km 50.
Il propose trois objets de la zone courante, dont une ligne rare garantie, puis disparaît lorsqu'il
est dépassé.

Le serveur possède le stock, la zone, les raretés et les prix. Le client ne transmet qu'un choix.

### 2.5 Respec et fusion

- Respec des statistiques uniquement au feu de camp et hors combat.
- Coût : `250 × nombre de points libres et gagnés alloués` ; aucun surcoût selon le nombre de
  respecs antérieurs.
- Les statistiques automatiques de classe ne sont pas redistribuables.
- Le respec des talents reste gratuit, conformément au GDD Talents.
- Les jetons de fusion peuvent payer le coût d'or, mais ne remplacent jamais les exemplaires requis.

### 2.6 Gemmes

Les gemmes servent aux skins, auras, cadres, effets, renommage et confort latéral autorisé.
Elles n'achètent jamais : statistiques, équipement de combat, Forge, points de compétence,
Rebirth, paliers Cauchemar ou meilleures probabilités de loot.

Sources gratuites visées : environ **300 à 500 gemmes par saison**, principalement via la piste
gratuite du pass. Le chiffre final appartient au GDD Pass de saison. VIP donne 10 gemmes par jour ;
le Pack de départ en donne 150 une seule fois.

---

## 3. Data Schema

Profil persistant, autorité serveur :

```lua
or_: number,
gemmes: number,
forgeLevels: {[string]: number}, -- itemKey unique -> niveau entier >= 0
lastMerchantKm: number?,
shopState: {
    zone: number,
    seed: number,
    restockCount: number,
}?,
```

Le niveau de Forge appartient à l'instance d'objet, pas seulement à son modèle. Une fusion,
suppression ou consommation d'objet doit traiter explicitement cette valeur. Les écritures passent
par le système dirty/flush et les achats Robux par le registre idempotent des reçus.

---

## 4. Client-Server Split

**Serveur :** gains, soldes, prix, stocks, validation de propriété, débits atomiques, Forge,
fusion, respec et sauvegarde.

**Client :** affichage, prévisualisation, formatage des grands nombres, animations et confirmation.
Une prévisualisation n'est jamais une preuve de prix ou de propriété.

Toute opération suit : valider → vérifier le solde → débiter → appliquer → marquer dirty → répondre.
Les jalons critiques utilisent un flush forcé lorsque requis par la politique de persistance.

---

## 5. RemoteEvents / Functions

Canal C→S existant ou centralisé :

- `buyEquipment {itemId}`
- `restockShop {}`
- `forgeItem {itemKey, count?}` — `count` borné ; valeur par défaut 1
- `respecStats {}`
- `fuseItem {...}`

Réponses S→C : `shopOpen`, `purchaseResult`, `forgeResult`, `economyUpdate`.

Caps proposés : achat 4/s, restock 2/s, Forge 4/s, respec 1/s, fusion 4/s. Chaque handler valide
types, bornes, propriété, contexte de feu de camp et solde côté serveur.

---

## 6. Player-Facing UI

- HUD : solde d'or et gemmes avec suffixes lisibles.
- Boutique : prix, comparaison avec l'équipement porté et origine de l'objet.
- Forge : objet sélectionné, niveau actuel, multiplicateur actuel, prochain gain, coût suivant,
  solde après achat et confirmation pour les dépenses élevées.
- Le nom affiche systématiquement `Nom Rareté +N`.
- Une arme ancienne très forgée reçoit une présentation de prestige, sans fausse indication de rareté.
- Les achats Robux affichent le prix réel fourni par Roblox, jamais un prix codé en dur.

---

## 7. Edge Cases & Error States

1. Solde insuffisant : refus sans débit ni modification.
2. Double clic ou paquet dupliqué : une seule opération valide par transaction.
3. Objet supprimé entre ouverture et Forge : refus et rafraîchissement UI.
4. Objet verrouillé : Forge autorisée, fusion/vente refusées selon la règle d'inventaire.
5. Valeur `count` forgée, négative ou énorme : rejet ou clamp serveur.
6. Déconnexion après débit : mutation et sauvegarde sont traitées comme une opération cohérente.
7. DataStore indisponible : Forge, fusion payante et Rebirth bloqués ; combat jouable en mémoire.
8. Coût dépassant la précision sûre : passage aux grands nombres configurés ou blocage explicite,
   jamais `inf`, `nan` ou solde négatif.
9. Objet `+999` fusionné : la règle de transfert doit être affichée avant confirmation ; par défaut,
   la fusion conserve le plus haut niveau parmi les matériaux sans additionner les niveaux.
10. Changement de classe avec boutique ouverte : le stock serveur reste celui de la session ouverte.
11. Marchand dépassé pendant l'achat : session fermée, achat refusé.
12. Restock spammé : rate-limit et coût serveur empêchent tout tirage gratuit.
13. Cosmétique déjà possédé : refus ou compensation explicitement définie, jamais double débit.
14. Rebirth avec or juste suffisant : débit atomique, aucun solde négatif.

---

## 8. Balancing Parameters

Tous les paramètres sont centralisés dans `GameConfig.Economy` :

```lua
forgePowerPerLevel = 1.003
forgeCostGrowth = 1.035
forgeMinBaseCost = 100
forgeBasePriceRatio = 0.10
statRespecCostPerPoint = 250
merchantChancePerCluster = 0.15
```

Cibles de validation :

- Une arme de départ très forgée peut atteindre la puissance end-game, mais coûte des milliards+
  et reste moins rentable qu'un drop récent.
- Le coût du prochain Rebirth reste visible avant que le joueur puisse en acheter plusieurs.
- Les puits hors Rebirth absorbent environ 35 % du revenu brut d'un joueur actif.
- Les gemmes ne procurent aucun avantage de combat mesurable.
- Aucun multiplicateur de confort ne dépasse le plafond global ×3.

---

## 9. Integration Points

**Dépend de :** équipement/inventaire, loot, progression, Rebirth, Cauchemar, persistance,
monétisation et pass de saison.

**Alimente :** boutiques, Forge, fusion, UI d'inventaire, classements de prestige et analytics.

Implémentation attendue : `GameConfig.Economy`, extension des données d'instances dans
`EquipmentService`, service de Forge serveur, UI Forge au feu de camp, migration profil et tests
d'économie/overflow.

### Critères d'acceptation

- Toutes les mutations sont serveur-autoritaires et rate-limitées.
- La Forge fonctionne au-delà de +999 sans plafond artificiel.
- Les coûts et puissances suivent exactement les fonctions de configuration.
- Une arme ancienne peut rattraper l'end-game uniquement à un coût manifestement non optimal.
- Les sauvegardes conservent le niveau de Forge sans duplication ni perte.
- Aucun achat en or, gemmes ou Robux ne vend directement un palier Cauchemar.

