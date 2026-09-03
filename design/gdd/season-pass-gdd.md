# Pass de saison (8 semaines) — GDD système

**Version :** 1.0  
**Dernière mise à jour :** 2026-09-02  
**Auteur :** game-designer / monetization-lead  
**Statut :** Prêt pour implémentation  
**Parent :** `design/gdd/master-gdd.md`  
**Références :** `design/gdd/core-gameplay-gdd.md`, `design/gdd/campfire-gdd.md`, `design/gdd/missions-gdd.md`,
`design/gdd/daily-dungeon-gdd.md`, `design/economy/monetization.md`,
`design/reponses-consolidees.md` (Q85–Q88)

---

## 1. Overview & Purpose

Le **Pass de saison** est un **système de progression cosmétique et de confort** sur **8 semaines**. 
Le joueur gagne de l'**XP de pass** en jouant (tuant des mobs, boss, missions) et déverrouille des **paliers**
(tiers) qui donnent des récompenses.

Le pass a deux **pistes** :
- **Piste gratuite** : récompenses cosmétiques et petits boosts
- **Piste premium** (payante en Robux) : récompenses premium (cosmétiques exclusifs, boosts puissants)

**Rôle clé :** Principal moteur monétaire du jeu (RPG F2P typique). Offre confort et cosmétiques,
jamais de puissance directe.

---

## 2. Core Mechanics

### 2.1 Durée et réinitialisation

- **Saison :** 8 semaines (56 jours)
- **Timing :** lundi 00:00 UTC = début de semaine, dimanche 23:59 = fin
- **Nombre de saisons/an :** ~6–7 saisons (recouvrement possible)
- **Réinitialisation :** à la fin des 8 semaines, nouveau pass démarre (anciennes récompenses perdues si non complétées)

### 2.2 Piste gratuite

**Contenu :**
- Cosmétiques simples (skins neutres, auras discrètes, cadres)
- Petits boosts (×1.2 or, ×1.2 XP)
- Gemmes (300–500 total par saison)
- Clés de Donjon du Jour
- Points de compétence (petit nombre)

**Estimation :** ~30–40 paliers complètement gratuites.

**Coût :** 0 Robux.

### 2.3 Piste premium

**Contenu :**
- Cosmétiques exclusifs (skins épiques, auras brillantes, cadres spéciaux)
- Boosts forts (×3 or, ×3 XP, ×3 chance loot, ×3 chance familier)
- Bonus de compétence (points de compétence extra)
- Tickets de fusion (économie)
- Potions de revive instantanée (QoL, jamais pay-to-win)
- Gemmes (150 gemmes supplémentaires)

**Estimation :** ~40–50 paliers premium au-delà des gratuits.

**Coût :** 499 Robux (configuration depuis monetization.md).

### 2.4 XP de pass

Le joueur gagne de l'**XP de pass** en jouant, graduellement :

| Action | XP de pass |
|--------|-----------|
| Tuer un monstre normal | 1 |
| Tuer un boss nommé | 10 |
| Boss de couche (tous les 10 km) | 30 |
| Big boss (tous les 100 km) | 100 |
| Compléter une mission | 5–10 (selon difficulté) |
| Étage du Donjon du Jour | 15 |
| Cycle du palier infini (Raid) | 20 |
| Fin de saison complète (100 km) → bonus | 200 (une fois par saison) |

**Timing :** les petites contributions s'accumulent tout naturellement. Un joueur passif à ~50–60 XP/jour.
Un joueur actif atteint ~100–150 XP/jour.

### 2.5 Paliers (Tiers)

Le pass a **~80–90 paliers** au total :
- Paliers 1–40 : accessibles gratuitement et premium
- Paliers 41–80+ : premium exclusif

Chaque palier demande **100 XP de pass** (progression lente mais constante).

**Paliers clés :**
- Palier 10 : cosmétique visuel (première peau)
- Palier 40 : set complet gratuit (bottes + casque + 2 armures) + gemmes
- Palier 50 (premium) : cosmétique épique + boost ×2 week-long
- Palier 80 (premium) : cosmétique légendaire + 100 gemmes

### 2.6 Rien après le dernier palier

Une fois le palier max complété :
- Plus aucune récompense nouvelle
- L'XP continue à s'accumuler (cosmétique, pour tracker progress)
- Le joueur doit attendre la saison suivante pour continuer

### 2.7 Perte de récompenses

Si le joueur n'a pas acheté le premium jusqu'à la fin de saison :
- Paliers gratuits complétés → récompenses gardées
- Paliers premium déverrouillés mais non achetés → récompenses **perdues** (pour inciter à acheter avant fin)

**Cas limite :** si acheté après le palier 50, on obtient les récompenses rétroactives des paliers 1–50 immédiatement.

---

## 3. Data Schema

Profil persistant, autorité serveur :

```lua
seasonPass: {
    seasonId: string,                  -- "2026-09-s1" (année-s#)
    currentTier: number,               -- 1–90
    xpInCurrentTier: number,           -- 0–99 (progress vers palier suivant)
    totalXpThisSeason: number,         -- cumul complet
    premiumUnlocked: boolean,          -- true si Pass acheté
    purchaseTime: number?,             -- timestamp de l'achat premium
    claimedRewards: {[tier: 1..90]: boolean},  -- ce qui a été réclamé
}
```

---

## 4. Client-Server Split

**Serveur :**
- Calcul de l'XP gagné (par action)
- Déverrouillage automatique des paliers
- Validation du purchase premium
- Gestion des récompenses (réclamation)
- Persistance

**Client :**
- Affichage de la barre de progression XP
- Affichage du palier actuel
- Affichage des récompenses futures (preview)
- Bouton « Acheter Pass Premium » (si applicable)
- Affichage des récompenses déverrouillées

---

## 5. RemoteEvents / Functions

Canal C→S centralisé :

- `claimSeasonPassReward {tier: 1..90}` — réclamer une récompense déverrouillée
- `purchaseSeasonPass {}` — acheter le pass premium (s'il existe MarketplaceService)

Réponses S→C (push) :
- `seasonPassXpGained {xp, source}` — XP gagné (notification)
- `seasonPassTierUnlocked {tier, rewards}` — nouveau palier déverrouillé
- `seasonPassRewardClaimed {tier, reward}` — récompense réclamée
- `seasonPassPurchased {}` — premium acheté, piste premium débloquée
- `seasonPassEnded {seasonId, seasonOver: boolean}` — fin de saison (si actif)

**Rate-limiting :** `claimSeasonPassReward` 2/s, `purchaseSeasonPass` 1/min.

---

## 6. Player-Facing UI

### 6.1 Onglet Pass de saison

- Titre : « Pass de saison — Saison 1 (8 sem) »
- Indicateur de temps : « 5 semaines restantes »
- Barre de progression XP : `XP : 6450 / 9000`
- Sélection piste : boutons « Gratuit » / « Premium »

### 6.2 Affichage des paliers

- Grille scrollable de 80–90 paliers
- Chaque palier :
  - Numéro (1–90)
  - Icône de la récompense
  - Titre (« Skin Guerrier v1 », « +5 gemmes », etc.)
  - Verrouillé / Déverrouillé
  - Badge « PREMIUM » si palier premium non acheté

### 6.3 Paliers premium vs gratuit

- Paliers 1–40 : **border neutre** (gratuit ET premium)
- Paliers 41–80 : **border dorée/premium** (premium exclusive)

Avant achat premium : paliers dorés affichent un **cadenas** et « À débloquer ».

### 6.4 Bouton d'achat

- Si passe non acheté : **grand bouton rouge** « ACHETER LE PASS PREMIUM (499 R$) »
- Sous-texte : « Débloquez 40 paliers exclusifs et boosts premium »
- Si acheté : bouton grisé « PREMIUM DÉBLOQUÉ ✓ »

### 6.5 Récompenses à réclamer

- Les paliers déverrouillés affichent un **point lumineux** ou badge « RÉCLAMER »
- Clic = pop-up de récompense, bouton « Réclamer »
- Animation d'ouverture (cadeau s'ouvre, récompense affichée)

### 6.6 Statut de fin de saison

- 1 semaine avant fin : notification « Plus qu'une semaine pour compléter le pass! »
- Jour dernier : notification urgente « Dernier jour du pass! »
- Après fin : « Pass expiré. Nouvelle saison le [date] »

---

## 7. Edge Cases & Error States

1. **Purchase premium après palier 50 :** récompenses rétroactives (paliers 1–50) envoyées immédiatement.

2. **Fin de saison avec paliers non réclamés :** récompenses perdues si en piste gratuite,
   perdues aussi en piste premium (incitation à réclamer à temps).

3. **XP gagné après réinitialisation :** action survient après minuit → XP compté pour nouvelle saison.

4. **Pass premium acheté après réinitialisation :** seul l'XP de la nouvelle saison compte.

5. **Changement de classe pendant une mission de pass :** mission continue normalement.

6. **Rebirth pendant une saison :** pass preserved (XP continues à s'accumuler).

7. **Double achat de premium :** serveur refuse avec message « Premium déjà acheté ».

8. **Récompense non appliquée :** vérification au login, recount si manquante.

9. **XP overflow (joueur très actif):** palier 90 est le max, XP continue d'accumuler (cosmétique).

10. **Saison qui se termine en jeu (transition):** vérification serveur à chaque action, passage automatique.

11. **Purchase MarketplaceService fail :** refus, notification « L'achat a échoué. Réessayez ».

12. **DataStore indisponible :** XP en mémoire, rewards en mémoire, flush au retour.

---

## 8. Balancing Parameters

Tous les paramètres sont centralisés dans `GameConfig.SeasonPass` :

```lua
seasonDurationDays = 56
totalTiers = 80  -- gratuit: 1-40, premium: 41-80
xpPerTier = 100
xpFreeGain = {  -- XP par action, piste gratuite
    mobKill = 1,
    bossKill = 10,
    layerBoss = 30,
    bigBoss = 100,
}
premiumPrice = 499  -- Robux
premiumExclusiveStartTier = 41
```

**Cibles de validation :**

- **Taux de complétion gratuit :** un joueur casual complète 50–60 % du pass gratuit (engagement, pas obligation).
- **Taux de complétion premium :** acheteur doit pouvoir complèter 80–90 % du pass (~1–2 heures/jour en moyenne).
- **Aucune puissance :** boosts sont confort (×3), cosmétiques purs, jamais d'avantage mécanique.
- **Retention :** pass de 8 semaines = motif de revenir 2 mois.

---

## 9. Integration Points

**Dépend de :**
- Combat (`CombatServer` — XP de bosses, kills)
- Progression (`ProgressionService` — XP de missions)
- Donjons (`DungeonService` — XP de récompenses)
- Inventaire (`InventoryService` — cosmétiques appliqués)
- Économie (`EconomyService` — boosts appliqués)
- MarketplaceService (Roblox native) — achat premium
- UI (`SeasonPassGui` — interface principal)

**Alimente :**
- Rétention (8 semaines = réason de revenir)
- Monétisation (499 R$ premium)
- Engagement (progression quotidienne)
- Cosmétiques (skins, auras exclusives)

**Implémentation attendue :**

1. Créer `SeasonPassService` : gestion XP, paliers, récompenses
2. Ajouter `seasonPass` au profil
3. Récompenses par palier (cosmétiques, boosts, gemmes)
4. Intégration MarketplaceService (achat premium)
5. UI `SeasonPassGui` : grille de paliers, bouton d'achat
6. XP hooks (tous les serveurs de jeu)
7. Gestion de fin de saison (réinitialisation lundi 00:00)
8. Tests : XP, paliers, premium purchase, fin de saison, edge cases

### Critères d'acceptation

- ✅ XP gagné correctement par toutes les actions
- ✅ Paliers déverrouillés automatiquement à 100 XP
- ✅ Premium achetable et déverrouille paliers 41+
- ✅ Récompenses appliquées (cosmétiques, boosts, gemmes)
- ✅ Réinitialisation à lundi 00:00 UTC
- ✅ Notification de fin de saison
- ✅ Récompenses perdues si non réclamées après expiration
- ✅ Rétroactivité si premium acheté en cours de saison
- ✅ Rebirth ne réinitialise pas le pass
- ✅ Edge cases testés

---

**Impact monétaire :** Moteur principal de F2P. À calibrer pour revenue optimal (499 R$ = sweet spot pour accessible + premium).
