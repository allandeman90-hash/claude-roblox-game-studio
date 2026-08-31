# Quête Minute — Stratégie de Monétisation

**Version :** 1.0
**Date :** 2026-08-31
**Auteur :** monetization-lead (synthèse : economy-designer, systems-designer, analytics-retention-specialist, exploit-security-specialist, game-designer)
**Statut :** Validé par le proprio (2026-08-31) — à implémenter en P4

Basé sur `design/reponses-consolidees.md` (décisions Q1–Q94) et l'analyse des 3 agents FoG.
Ne remplace pas le GDD ; l'alimente (section 6 du GDD maître).

---

## 1. La règle d'or

> On vend **la vitesse à laquelle le joueur parcourt le tapis roulant** (XP, or, vitesse du monde,
> taux de drop, capacité du sac, auto-marche) — parce que le tapis est infini et se rééquilibre
> seul via le Cauchemar.
>
> On ne vend **jamais la position du curseur sur le tapis** (points de compétence, rebirths,
> stats d'équipement, paliers de Cauchemar) — parce que c'est ça, la progression, et c'est ce
> que mesurent les 4 classements.

Dans Quête Minute, l'XP EST la progression et les stats montent automatiquement. Conséquences :

- **XP ×N est le booster le plus sûr** : auto-plafonné par le niveau max (`100 + 20 × rebirths`,
  Q26). Il amène le joueur à son plafond plus vite, puis ne fait plus rien jusqu'au rebirth
  suivant. Message d'achat honnête : « atteins ton plafond de niveau plus vite », jamais
  « deviens plus fort ».
- **Or ×N est le plus proche de la ligne P2W** : or → rebirth → multiplicateurs permanents
  croissants (Q38). D'où le plafond **×3 strict**, rendu acceptable par la courbe Q64 (le coût du
  rebirth garde toujours l'avance sur les gains d'or → même ×3, on ne fait que décaler la date du
  prochain rebirth, jamais en enchaîner).

---

## 2. Prérequis techniques — 5 protections non négociables AVANT de vendre

Auditées dans le code réel (`src/`). Bloquantes pour la publication payante (tâches P0.8 / P4.3).

| # | Protection | Sans elle |
|---|---|---|
| 1 | `ProcessReceipt` **idempotent** + registre des `PurchaseId` en DataStore (grant-puis-enregistre, `PurchaseGranted` seulement si l'écriture réussit) | Chaque Developer Product (coffre, gemmes, boost) crédité plusieurs fois |
| 2 | **Rate-limit** sur tous les handlers `CombatEvent` + **découplage des sauvegardes** (flag `dirty` + 1 seule écriture / 30–60 s, garanties uniquement sur PlayerRemoving / BindToClose / jalons) | Spam `equipItem`/`unequipItem` → budget DataStore de toute l'instance épuisé → **perte de progression des autres joueurs** = remboursements |
| 3 | Supprimer **`devReset` / `DEV_MODE` / `PlayerDataService.wipe`** (serveur + bouton client) | N'importe quel client envoie `{type="devReset"}` → efface un compte (`DEV_MODE = true` en prod) |
| 4 | **Session lock** rafraîchi toutes ~30 s (< `LOCK_STALE_S = 90`) + **`BindToClose` 25 s** (au lieu de 3 s) | Rollback / duplication cross-serveur + perte massive au shutdown Roblox |
| 5 | **Resolver unique de multiplicateurs**, serveur, `max()` et non produit + fermeture de la session shop sur restart / rebirth / mort | Empilement de multiplicateurs incontrôlé (×2 × ×3 × Cauchemar…) + achat de gear sur-tier via shop périmé |

Formule du resolver :
```
multiplicateur_effectif(joueur, categorie) =
    max( valeur_pass_permanent(joueur, categorie),
         valeur_pass_premium_actif(joueur, categorie) )       -- confort : MAX, jamais produit

Puis, catégories qui se multiplient VOLONTAIREMENT (documenté, gagné en jeu uniquement) :
    gain_final = base
               × multiplicateur_effectif(joueur, categorie)   -- confort acheté, plafond ×3
               × cauchemar_reward_mult(couche, palier)          -- ×2,5 par palier, Q40, gagné
               × rebirth_bonus(rebirths)                        -- Q38, gagné

catégorie ∈ { xp, gold, loot, petLoot }
```
Les boosts temporaires stockent `{ expiresAt = os.time() + N }` côté serveur ; le resolver ignore
les entrées expirées à chaque lecture. La possession de Game Pass passe par
`MarketplaceService:UserOwnsGamePassAsync` en `pcall`, **mise en cache serveur**, rafraîchie sur
`PromptGamePassPurchaseFinished`. Jamais un booléen envoyé par le client.

---

## 3. Catalogue de lancement

### 3.1 Game Pass permanents

| Produit | Prix R$ | Plafond max | Avantage | Impact balance | Risque P2W |
|---|---:|---|---|---|---|
| **Pack de Départ** (1×/compte) | 99 | 1 achat | 150 gemmes + boost ×2 tout 24 h + 25 slots sac + 3 clés donjon + cadre/couleur exclusifs | Coup de pouce ponctuel, se dilue en ~2 jours | Faible |
| **×2 XP** | 249 | ×3 (avec Pass Saison, `max()`) | Double le gain d'XP | Auto-plafonné par le niveau max (Q26) | Faible |
| **×2 Or** | 349 | ×3 (`max()`) | Double l'or gagné | Q64 absorbe : décale la date du rebirth, pas le plafond de puissance | Faible-moyen |
| **Grand Sac** | 149 | 200 stacks (base 100) | +100 emplacements d'inventaire | Élargit, n'augmente rien | Nul |
| **Pass Vitesse** | 499 | ×3 monde (×2 gagnable) ; donjon verrouillé ×1 | Sélecteur en jeu ×1/×2/×3 + auto-marche pleine vitesse (retire le malus Q3) | Accélère uniformément ; donjon exclu (Q46) | Faible |
| **VIP** | 699 | cosmétique + confort | Cadre animé, aura, couleur de nom, style de dégâts, coffre quotidien supérieur, 2 slots de build, 1 reroll mission/j, 10 gemmes/j | +10 % or fondu dans le cap ×3 ; le reste = confort/cosmétique | Faible |
| **Collectionneur** | 999 | cosmétique only | Set « Prestige » évolutif (look indexé sur nb de rebirths + palier Cauchemar) + tout le futur cosmétique + mobilier feu de camp exclusif | **Zéro** | Nul |
| **Bundle Ultimate** | 1799 | = somme des 5 pass | XP + Or + Vitesse + Sac + VIP, ~20 % de remise (~2245 → 1799) | Aucun au-delà des composants ; ancre décote | Faible |

### 3.2 Saisonnier

| Produit | Prix R$ | Plafond | Avantage | Impact | Risque |
|---|---:|---|---|---|---|
| **Premium Saison** (8 sem., rétroactif) | 499 | ×3 XP/or/loot/loot-familier (`max()`, jamais empilé) | Piste premium Q87 : confort fort (boosts ×3, tickets de fusion, clés de donjon, potions de revive) + ~80 % cosmétiques saisonniers | Multiplicateurs plafonnés ×3 ; flag `premium` reset en fin de saison (cosmétiques obtenus restent) | Faible |

### 3.3 Developer Products (consommables)

| Produit | Prix R$ | Plafond | Avantage | Risque |
|---|---:|---|---|---|
| **Sacs de gemmes** S/M/L/XL | 80 / 400 / 800 / 1700 | gemmes = cosmétique + confort latéral **only** | ~90 / 520 / 1150 / 2650 gemmes (bonus croissant affiché) | Nul (firewall) |
| **Coffre Cosmétique** | 99 (×1) / 449 (5+1) | cosmétique **strict** + pitié + achat direct en gemmes | Skin/aura/effet aléatoire, **poids serveur affichés**, `PolicyService` vérifié | Nul si odds + pitié + achat direct |
| **Boost Week-end ×2 48 h** | 79 | ne franchit jamais ×3 | ×2 XP + or + loot pendant 48 h (pour non-détenteurs de pass) | Faible |
| **Jetons de Fusion ×5** | 49 | paient le **coût en or** de la fusion (Q49), **jamais** les matériaux (§5.2 strict) | Sautent le coût d'or croissant d'une fusion | Faible |
| **Renommage / Titre custom** | 99 | — | Change le nom/titre affiché | Nul |
| **Palier de Pass** ×1 / ×5 | 39 / 149 | jusqu'au dernier palier de la saison | +1 / +5 paliers de pass de saison | Faible |
| **Supporter Pack saisonnier** | 400 | 1×/saison, revient en variante | Bundle cosmétique thématique + gemmes | Nul |

**Pas de Potion de Revive au lancement** (Q91) — la revive existe seulement comme objet gagné
(récompense 7 jours, missions, pass premium). Réouverture possible : 49 R$, **1 revive/run
absolu**, sur l'écran de résumé de mort comme choix calme (sans minuteur, sans clignotement),
uniquement si les données post-lancement montrent un point de rage-quit net.

### 3.4 Roblox Premium (détection `MembershipType`)

+10 % or (fondu dans le cap ×3, ne le dépasse jamais) + coffre quotidien de feu de camp exclusif
+ cadre « Premium » (Q94).

---

## 4. Plafonds durs par avantage

| Avantage | Plafond | Règle |
|---|---|---|
| Multiplicateur XP | **×3** | `max(pass, premium)`, jamais empilé ; auto-limité par le niveau max |
| Multiplicateur Or | **×3** | idem ; le +10 % VIP/Premium se fond dedans (pas ×3,1) |
| Taux de drop équipement | **×3** | poids de rareté (60/25/10/4/1) **jamais** modifiés |
| Taux de drop familier | **×3** | idem |
| Vitesse du monde | **×3** payant / **×2** gagnable (boss Couche 12) | Donjon du Jour verrouillé ×1 pour tous |
| Auto-marche | vitesse « bouton tenu » | on n'achète pas plus vite que jouer à la main |
| Sac | **200 stacks** (base 100) | un cran, pas d'échelle infinie |
| Revive | **1 / run** absolu | quel que soit le nombre possédé |
| Clés de donjon achetées | **+1 classée / jour** *ou* practice-only | le donjon donne un point de compétence permanent au top 100 |
| Slots de build | **5 total** | confort latéral |
| Boosts temporaires | ne franchissent jamais ×3 | un boost 48 h + un pass ne donnent pas ×5 |
| Points de compétence / rebirths / stats / DEF / RES / rareté / armes de boss / effet de familier | **jamais vendus, aucun multiplicateur** | — |
| Paliers de Cauchemar | **or uniquement** (Q61), jamais Robux | — |
| Dépense cosmétique | illimitée, **valeur décroissante** | une fois tout le catalogue courant acquis, plus rien d'utile jusqu'à la saison suivante |

---

## 5. Les 5 (+1) choses à ne SURTOUT PAS vendre

1. **Points de compétence** (ou un multiplicateur). Permanents, sans plafond (Q30), survivent au
   rebirth ; « le Cauchemar rééquilibre » suppose que tous les joueurs les gagnent au même
   rythme. En vendre dé-calibre le Cauchemar et pollue les 4 classements.
2. **Rebirths / jetons de rebirth / réductions de coût.** Q64 (« jamais tout à fait assez d'or »)
   est le moteur central. Un jeton effondre le sink d'or et l'échelle Q37 (R15/R20/R25/R30).
3. **Multiplicateurs de stats / DEF / RES / dégâts, armes de boss, équipement, poids de rareté.**
   Casse la courbe uniforme (GAME_SPEC §7.1 : « progression mathématiquement impossible ») et
   « un Mythique doit être un événement » (§7.2).
4. **Paliers de Cauchemar pour Robux.** Acheter un palier = acheter le ×2,5 récompenses (Q40) =
   acheter or/XP/loot. Rester **or uniquement** (Q61).
5. **La récompense de fidélité J6/J7 (ou « acheter la récompense du jour »), et tout coffre
   touchant une stat.** Pas de gacha de puissance, pas de pitié inter-objets (§5.2 : « il doit
   farmer »), pas de « débloque le set instantanément ».
6. **(Bonus)** Pas de minuteur FOMO « dernière chance », pas de prompt chronométré après une
   mort, pas d'objet en quantité limitée absolue.

---

## 6. Grille de prix Robux

Prix « charme » (finissant par 9), calés **sous** un palier d'achat Robux (laisse un reliquat qui
pousse au rachat). Prix scriptés via `GetProductInfo`, jamais codés en dur → compatible price
optimization + regional pricing (`GetUsersPriceLevelsAsync` pour l'anti-arbitrage).

| R$ | Produit |
|---:|---|
| 39 / 49 | Palier de pass ×1 · Jetons de fusion · clé de donjon +1 · (revive future) |
| 79 | Boost Week-end ×2 48 h |
| 99 | **Pack de Départ** · Coffre cosmétique ×1 · Renommage |
| 149 | **Grand Sac** · Palier de pass ×5 |
| 249 | **×2 XP** |
| 349 | **×2 Or** |
| 400 | Supporter Pack saisonnier |
| 449 | Coffre cosmétique 5+1 |
| 499 | **Pass Vitesse** · **Premium Saison** |
| 699 | **VIP** |
| 999 | **Collectionneur** (ancre premium) |
| 1799 | **Bundle Ultimate** (superfan) |

Sacs de gemmes : **80 / 400 / 800 / 1700** (pile sur les paliers d'achat Robux).

---

## 7. Stratégie gros dépensier (R50 → R100)

Une fois les 5 pass confort possédés, **aucun produit n'ajoute plus de puissance**. C'est voulu.
Le whale continue de dépenser sur :

| Levier | Pourquoi ça tient jusqu'à R100 |
|---|---|
| **Premium Saison** (toutes les 8 sem.) | Cosmétiques neufs + confort, indéfiniment. KPI cœur = le **resub saison-sur-saison** (cible 60 %+) |
| **Set « Prestige » évolutif** (Collectionneur) | Apparence indexée sur le nb de rebirths et le palier Cauchemar. Un look « 100 rebirths » impossible à falsifier — flex de temps de jeu rendu visible |
| **Coffre Cosmétique** (nouvelles séries chaque saison) | Catalogue procédural qui s'étend : cadres, auras, effets de kill, mobilier, plaques, styles de dégâts, halos de familier |
| **Trophées cosmétiques** de premier-kill Cauchemar + codex complété | « Champion de la Couche X, Cauchemar N » : titre + bordure par exploit |
| **Mobilier de feu de camp / plaques / podium** (Q66, Q83) | Surfaces de personnalisation infinies |
| **Slots de build** (jusqu'à 5) | Utile dès R25 (double spé Q37) — latéral |

**Plafond du whale :** après tout le catalogue *courant*, il attend la saison suivante. Aucune
dépense ne produit plus de bénéfice mécanique.

**⚠️ Risque long terme :** jeu idle solo. Une fois la progression « résolue » (~R15-R20,
mois 2-3), il ne reste que classements + cosmétiques + nouveau contenu. Le bloc social (crews,
raids, échange) est différé v1.1+. **Si le social glisse de 6 mois → mur de churn D30→D60 chez
les joueurs les plus engagés, ceux qui dépensent.** La cadence de contenu (couches 13-15,
sets de raid, ~1 couche + 1 set / 2 semaines) EST le moteur de dépense end-game.

---

## 8. Stratégie free-to-play

**Un joueur gratuit finit tout le jeu.** 100 % gratuit et complet :

- Les 12 couches, tous les boss, « La Descente », le **Cauchemar infini**.
- Tout l'équipement, tous les pets, tous les sets, tous les Mythiques (farm, taux constants §6.3).
- Tous les points de compétence, l'arbre de talents complet, respec talents **gratuit** au feu de
  camp, le codex + bonus.
- Rebirth infini + tous les déblocages Q37.
- Récompense 7 jours entière, y compris le set Épique J6 et l'arme J7.
- 10 missions/jour + leurs points de compétence permanents.
- Donjon du Jour : 1 clé/jour gratuite, classement, **top 100 = point de compétence permanent**,
  top 10 = titre.
- Pass de saison piste gratuite : or, gemmes (« un peu gratuite », Q86).
- Vitesse ×2 gagnée au boss Couche 12.
- Boutique cosmétique en or, coffre gratuit toutes les heures, marchand ambulant.
- Tous les classements (sauf « Robux dépensés » → remplacé par paliers de Soutien, voir §9).
- Tri, filtres, ramassage auto, comparaison, auto-vente — **jamais paywall**.

**Progression de dépense sans obligation :** le F2P ressent la friction (farm lent, sac qui se
remplit, auto-marche à mi-vitesse) mais **rien ne le bloque**. Chaque achat = « je vais 2× plus
vite » ou « c'est plus joli », jamais « je peux enfin passer ». Le F2P est un **actif de
revenu** : base large → meilleur algo de découverte Roblox → plus d'Active Spenders
(Creator Rewards) → écosystème où la dépense du whale a du sens.

**Garde-fous à documenter/tester dans `/economy-audit` (P1.9) :**
- Chaque mur (boss, porte Cauchemar, étage de donjon) battable **en ×2** avec du gear f2p dans un
  budget-temps écrit.
- Aucun achat n'accorde stat / DEF / RES / accès à une table de drop.
- Puits Q61 « or → meilleures cotes de loot » : **gemmes uniquement + cap hebdo**, ou supprimé.
  C'est le seul endroit où la règle « aucun avantage de drop » risque de fuir.

---

## 9. Décisions arrêtées (2026-08-31)

| Réf | Décision |
|---|---|
| Q89 | Grille de prix mixte (petits pas chers, gros chers) — voir §6 |
| Q90 | Pack de Départ 99 R$, 1×/compte, apparaît après tuto + (km 30 OU login J2), jamais au join |
| Q91 | **Pas de revive payante au lancement** — revive = objet gagné uniquement |
| Q92 | Coffre 100 % cosmétique, odds affichés, pitié ~20 / ~80, achat direct en gemmes possible |
| Q93 | ×2 XP assumé comme accélérateur de temps (auto-plafonné) — message d'achat honnête |
| Q94 | Roblox Premium : +10 % or (fondu dans le cap) + coffre quotidien exclusif + cadre Premium |
| Tension 1 (Q24) | **Résolue** : boss nommé tous les 10 km (12 personnages de La Descente, cyclent au-delà de 120 km) + **big boss façon boss de raid tous les 100 km** (mécaniques renforcées, butin dédié) |
| Tension 2 (Q26) | **Résolue** : les ennemis continuent de scaler, le mur EST la raison du rebirth. Le **1er mur tombe vers km 25-35 / jour 2-3**, après l'accroche. Pitch de rebirth bruyant à ce moment |
| Tension 3 (Q77) | Garder J6/J7 forts (rétention) mais en **rattrapage** : J6 set Épique **non fusionnable** (zone juste sous le record) ; J7 arme +30 % **sur le gear de boutique** (pas boss/Mythique), non fusionnable. Cible `/economy-audit` : « arme J7 ≤ 60 % d'une arme de boss de même zone » |
| Tension 4 (vitesse) | **Un seul Pass Vitesse** ×1/×2/×3 (fusionne les 3 SKU). ×2 gagné au **boss Couche 12** (pas km 400). Auto-marche incluse dedans. Donjon forcé ×1 |
| Tension 5 (multiplicateurs) | **`max(permanent, premium)`, jamais le produit.** Affiché sur les 2 écrans d'achat |
| Tension 6 (Q81) | Classement « Robux dépensés » → remplacé par **paliers de Soutien** (Bronze/Argent/Or), non chiffrés, non classés |
| Podium (Q83) | **Par serveur** (top 3 du serveur courant), pas global |

---

## 10. Cibles (idle RPG 2D GUI Roblox — ne pas lire avant 500 payeurs / 14 jours de données)

| Métrique | Cible |
|---|---|
| D1 / D7 / D30 | 27 % / 10 % / 4 % |
| Session length | ~16 min |
| Sessions/jour (par DAU) | ~1,9 |
| Conversion payeur | ~3,5 % |
| ARPDAU | ~$0,045 |
| ARPPU | 500–700 R$ |
| Prise du Pack de Départ (des retenus J7) | ~30 % |
| Attache Pass de saison (du MAU) | ~7 %, resub 60 %+ |
| Part whale (top 1 % des payeurs) | 30–40 % du revenu ; top 10 % = 60–75 % |
| Ratio de temps de jeu Premium | ~10 % |

Modèle illustratif à 1 000 DAU : ~37 600 R$/mois d'achats + ~18 000 R$/mois de Creator Rewards
≈ **38 900 R$ earned/mois ≈ 136 $/mois**. À 10 000 DAU avec D7 > 12 % : ~1 500–2 500 $/mois.
**Presque tout dépend de la rétention D1/D7** → priorité absolue aux hooks quotidiens
(récompense, missions, donjon), qui servent aussi les Creator Rewards (« dans les 3 premiers
jeux de la journée » d'un joueur).

---

## 11. Cadre éthique (public jeune)

Le vrai risque de CE jeu n'est pas le P2W-contre-autrui (pas de PvP) — c'est le pattern
prédateur envers un public jeune. Règles :

- Aucun prompt d'achat pendant un combat actif, ni en 1ʳᵉ session (FTUE).
- Max 1 prompt contextuel par type et par session, cooldown dur, jamais plein écran
  non-skippable. Prompts **calmes, sans minuteur** : Grand Sac à 100/100 · ×2 Or après farm
  prolongé en zone basse · Pass Vitesse pendant une longue auto-marche.
- Gacha : cosmétique **strict**, poids serveur affichés, pitié, achat direct en gemmes,
  `PolicyService:GetPolicyInfoForPlayerAsync` → `ArePaidRandomItemsRestricted` vérifié.
  Jamais vendu en ventes externes / page Buy Robux.
- Pass complétable f2p en ~5-6 semaines de jeu normal (pas 8+ sous pression).
- Jamais de « restauration de streak » payante.
- Double monnaie : les gemmes n'achètent QUE du cosmétique et du confort latéral. Jamais un pass
  tarifé en gemmes. Prix Robux direct et lisible sur les pass.

---

## 12. Instrumentation minimale (P3.11, avant soft launch)

`AnalyticsService` doit émettre :
- `purchase_prompt_shown` / `purchase_started` / `purchase_completed` / `purchase_failed`
  (`productId`, `trigger`, `robuxValue`, `playerDay`, `rebirthCount`).
- `daily_reward_claimed` (`streakDay`, `rewardTier`).
- `session_start` / `session_end` (`speedTier` 1/2/3, `hasAutoAdvance`, `duration`, `sessionsToday`).
- `funnel_step` : join → FTUE fini → 1er boss → km 30 → 1er rebirth → 1er achat → 1er Premium Saison.
- `dungeon_attempt` (classée oui/non), `dungeon_floor_reached`, `dungeon_key_source`.
- `wall_hit` : joueur bloqué > N min sur le même km/boss (détecte les falaises de la tension 2).

Cohorte prioritaire post-lancement : **session length + sessions/jour du segment
« Pass Vitesse ×3 + auto » vs f2p**. Si le segment ×3 fait des sessions 3× plus courtes et ne
claime plus la récompense quotidienne → re-gater l'auto-marche à ×2 pendant les combats de boss.

---

## 13. Sources

- `design/reponses-consolidees.md` — décisions Q1–Q94
- `docs/plan/00-plan-complet.md` — section A (vision), P4 (catalogue prévu), P3.11 (analytics)
- `GAME_SPEC.md` — §4-§7 (équipement, butin boss, courbes), §13 (périmètre)
- `src/ReplicatedStorage/GameConfig.luau`, `src/ServerScriptService/{ShopService,LootService,EquipmentService,EnemyService,PlayerDataService,CombatServer}` — économie & sécurité réelles
- `wiki/monetization/` — `ethical-monetization.md`, `robux-price-tiers.md`, `game-pass.md`, `dev-product.md`, `process-receipt-idempotency.md`, `premium-benefits.md`, `engagement-based-payouts.md`
