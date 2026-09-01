# Follow-ups — dette & câblage à traiter dans les tracks suivantes

Liste vivante des TODO laissés en suspens par les tracks terminés. Chaque entrée
indique le track qui doit la traiter.

**Dernière mise à jour : 2026-09-01** (après Track B complet).

---

## Issus de Track B (sécurité & stabilité)

### Sécurité / exploit → `/exploit-check`, Track K1

1. **A5 — validation profonde équipement.** Les handlers `CombatEvent`
   (`equipItem` / `unequipItem` / `fuseItem` / `toggleLock`) passent
   `data.id / rarete / zone / slot` bruts à `EquipmentService`. Confirmer que
   l'ownership + les bornes (rareté valide, `zone ≤ maxZoneReached`, slot
   cohérent) sont **vérifiés dans** `EquipmentService.equip/fuse/addItem/grantOwnership`,
   pas supposés.
2. **`notifyClient {type="purchaseGranted"}`** (ReceiptService) — aucun handler
   client pour ce type ; toast à ajouter (Track F / I3).
3. **`Remotes.luau`** — registre central jamais utilisé (CombatEvent/ShopEvent
   créés ad hoc). Centralisation + envisager `UnreliableRemoteEvent` pour les
   nombres de dégâts.

### Combat / progression → Track G

4. **`st.nightmareTier`** — `RewardService.multiplier(player, cat, st)` le lit
   déjà (→ 0 aujourd'hui). G9 doit le poser sur l'état de combat + câbler
   `GameConfig.Nightmare.hpMult/atkMult/enrageSeconds` dans les boucles +
   `earnedPointsPerNewTier`.
5. **`st.exp`** — accumulateur XP dans l'état de combat, vestigial, jamais
   persisté (`captureProfile` ne le lit pas), remis à 0 au rebirth. À
   clarifier / supprimer en G1.
6. **Bump `PROFILE_VERSION` → 2.** B3/B4/B5 ont ajouté des champs profil en
   **additif** sans bump (`migrate()` backfill) :
   `gemmes / boosts / fusionTokens / renameCredits / passTierCredits /
   unclaimedProducts / processedReceipts / premiumSeason`. G1 (stats dérivées,
   `earnedPoints{pool,allocation}`, subclass) = le vrai bump → ajouter
   `if profile.version < 2 then …` dans `migrate()`.

### Contenu / data → Tracks C / D

7. **EnemyService ne propage ni `famille` ni `petRole` ni `magic`.** `ZoneConfig`
   les porte maintenant (D3) mais `EnemyService.rollEnemy` ne les met pas dans
   le descripteur ennemi. Nécessaire pour : codex (C5), drop de familier dérivé
   de la famille du monstre tué (C5 / G6 — aujourd'hui `LootService.rollPetDrop`
   tire au hasard dans `EquipmentConfig.Pets`), mitigation magique des casters
   (G3).
8. **`GameConfig.Rewards.rebirthBonus`** n'a que `xp`. Si le design veut un bonus
   rebirth sur or/loot/petLoot (`monetization.md` §2), Track D ajoute les courbes.
9. **Loot mult sur drops de boss** (B5, capé 0.95, étendu aux boss de couche par
   B6d) — `/economy-audit` D5 / K3 : ne pas casser « un Mythique est un
   événement » ni les taux de set (test : boss couche 1 ×15).

### Monétisation → Tracks I / H

10. **`ProductConfig.ids` + `Rewards.permanentPasses[].id` = 0.** Track I remplit
    les vrais Developer Product IDs + Game Pass IDs depuis le Creator Dashboard.
    Tant que 0 : `ProcessReceipt` → `NotProcessedYet` sur tout produit, resolver
    ignore les pass.
11. **Champs profil écrits mais consommés par personne** : `premiumSeason` /
    `passTierCredits` / `unclaimedProducts` / `renameCredits` / `fusionTokens`.
    - H6 : pass saison set/reset `premiumSeason` + applique `passTierCredits`
    - I3 : draine `unclaimedProducts` (coffres cosmétiques + supporter pack)
    - I2 : UI renommage (`renameCredits`)
    - `EquipmentService.fuse` : `fusionTokens` paient le coût d'or (Q49)
12. **Boost temporaire** (`profile.boosts`, écrit par B4 `boostWeekend`) — aucun
    timer HUD, aucune source hors achat (récompense J1, pass premium H1 / H6).

### Infra → Track K2

13. **`/datastore-review` complet** : tempête BindToClose 8 joueurs, test de
    migration, chemin « DataStore indispo » jouable avec bandeau (Q109) —
    `PlayerDataService.isPersisting()` existe mais aucun bandeau UI ne le lit.
    Trancher ProfileStore vs custom durci.

---

## Issus de Track A (assets → jeu)

- **Sprites `pet_*`** — pas générés (les familiers = mini-versions des 72
  monstres). CombatClient a un fallback propre (pet masqué). À traiter quand
  le lot familiers arrive.
- **Carte de transition de couche** (A4) — reportée, attend les phrases
  d'ambiance (E3).
- **3 monstres couche 12** (`ombre_portee`, `gardien_seuil`, `temoin_silencieux`)
  = silhouettes quasi sans détail. Voulu (Vide) ou re-découpe — à trancher.
- **Modération asynchrone** — 208 assets uploadés sans rejet à l'upload, mais la
  modération peut encore signaler. À surveiller.

---

## Issus de Track E (narratif — E1-E4 terminé)

1. **Namespaces de localisation** (Track F) : `boss_dialogue.*`,
   `layer_card.<slug>.ambiance`, `codex.<slug>.lore`. Chaînes serveur, hors
   filtre runtime (seul le nom de héros saisi passe `TextService`).
2. **Composant « bandeau narrateur »** pour Béhémoth (ui-programmer) : style
   distinct de la bulle, italique, sans portrait.
3. **Flag `firstKill[gardienId]` / `[gardienId .. "_r2"]`**
   (luau-gameplay-programmer) : conditionne les répliques héros `[chute]` à la
   1ʳᵉ victoire (rencontres 1 et 2 séparées) ; persiste à travers Rebirth.
4. **Capstone « les 12 Gardiens révélés »** (economy-designer) : récompense à
   définir + chiffrer. Les Gardiens ne comptent pas dans les 5 familles.
5. **Bonus codex** (economy-designer) : valeur du bonus par carte révélée +
   les 5 bonus de complétion de famille (Élém→RES, Construct→réduc dégâts,
   Bête→vitesse atk, Mort-vivant→régén, Humanoïde→or).
6. **Gueules (big boss, 100 km)** : dialogue = lignes d'arrivée R1 du Gardien —
   à reconfirmer selon le scope combat (C3). Signature raid par Gueule idem.
7. **Bible §11** : réserver 3 identités de couche pour 13-15 (post-lancement) ;
   Aethel = seul nom propre de lieu.

## Issus de Track D (modèle chiffré)

- **`D1-stat-growth.md` tables B/C** calculées à `refPointsPerLevel 5.0` (avant
  décision). Valeur retenue = 4.7 → ratios ~10-12 % plus favorables. Rafraîchir
  le doc en D6.
- **Risque D6** : `skillMult` ×1.70 à R5 sur toutes les stats gagnées peut
  rendre triviaux les 50 premiers niveaux post-rebirth. Correctif prêt : scinder
  `mult earned/free` (courbe croissante) + `mult auto` plus doux (`1 + 0.06n`).
