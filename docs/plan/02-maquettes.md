# Quête Minute — Les Écrans (maquettes)

> Wireframes de chaque écran, orientation **paysage forcée** (16:9 de référence, plus large sur
> téléphone). Style réel : fond noir, monospace, bordures blanches épaisses, couleurs réservées
> aux dégâts et à la rareté. Tout est 100 % GUI, autoritaire serveur.
> Rendu visuel : `claude.ai/code/artifact/eb8ecc96-7a55-49d8-9717-e379d7d737e7`

**Raretés (bordure de case) :** Commun gris · Rare bleu · Épique violet · Légendaire orange ·
Mythique rouge. **Jaune** = actif / prêt. **Rouge** = danger / boss.

---

## 00 — Contrainte : le HUD imposé par Roblox

Roblox superpose son propre HUD, non déplaçable : le bouton **☰ menu** et le **💬 chat** en
**haut à gauche**. Chaque maquette laisse ce coin libre.

| | |
|---|---|
| **Ce qui est imposé** | Bouton ☰ (menu Roblox, obligatoire) + bouton 💬 chat, coin haut-gauche. Occupe ~ les 15 % de largeur × haut de l'écran. |
| **Ce qu'on désactive** | `SetCoreGuiEnabled(PlayerList, false)` et `(Backpack, false)` (pas de personnage) → le coin haut-droit est libre pour le jeu. |
| **Ce qu'on lit dans le code** | `GuiService.TopbarInset` (un `Rect`) donne la zone exacte réservée ; on cale les éléments après. |
| **La règle** | Aucun bouton, texte lisible ou barre importante dans le coin haut-gauche. Infos de jeu **centrées** ou à droite ; barre de PV démarre après le retrait. |

---

## 01 — Chargement + Menu titre

La porte d'entrée. Un joueur qui revient atterrit ici. Récompense quotidienne et pass de saison
visibles immédiatement.

**Layout paysage :** moitié gauche = gros logo `QUÊTE MINUTE` + sous-titre `— La Descente —` +
[héros animé sur la ligne]. Moitié droite = ligne stats (`COUCHE 4 · KM 42.0 · REBIRTH 2`), gros
bouton `▶ JOUER`, bandeau `◆ RÉCOMPENSE DU JOUR · À RÉCLAMER`, barre `Pass de saison — palier 12`,
puis 6 accès (Talents · Sac · Boutique · Codex · Rang · ⚙).

1. Logo à gauche + héros animé qui marche sur la ligne. Le chargement (ReplicatedFirst) montre le même bloc avec une barre de progression.
2. Un seul gros bouton, à droite dans la zone d'appui naturelle. Reprend au dernier checkpoint.
3. Badge quotidien qui pulse tant qu'il est réclamable → calendrier 7 jours.
4. Progression du pass toujours visible sans ouvrir de menu.
5. Six accès directs : Talents · Inventaire · Boutique · Codex · Classement · Réglages.

---

## 02 — Création du héros

Un seul choix qui compte : la voie de départ. Elle donne l'arme de tier 1 et cadre le tutoriel.
La classe reste pilotée par l'arme équipée (GAME_SPEC 3.3).

**Layout :** barre de titre `CRÉE TON HÉROS`. Milieu = 3 colonnes : carte GUERRIER (sélectionnée,
bordure jaune épaisse, `POW · dégâts stables · cadence rapide · DEF`) | aperçu héros central avec
la teinte | carte MAGE (`INT · dégâts lourds · cadence lente · RES`). Barre du bas = swatches de
teinte + champ nom + bouton `COMMENCER`.

1. Deux cartes de voie, la sélectionnée en bordure jaune épaisse + « Voie choisie ». Un tap bascule.
2. Aperçu du héros au centre avec la teinte appliquée en direct.
3. 4 teintes gratuites, d'autres en boutique plus tard. Purement cosmétique.
4. Nom filtré chat-safe, réutilisé sur les classements et au feu de camp.
5. « Commencer » accorde l'épée / la baguette de tier 1 et lance les 5 coach-marks.

---

## 03 — Écran de combat

Le cœur du jeu, en 3 colonnes paysage : panneau héros à gauche, scène large au centre, panneau
ennemi + or à droite. Équipe de 3 pets, 3 compétences, position, prochain objectif.

**Barre du haut :** `[☰ 💬 Roblox]` (zone réservée, gauche) · `💀 3 · Couche 4 · 42.4 km`
(centré) · `Loup Sauvage Niv.9` (droite). Puis barre de PV joueur (démarre après le retrait) +
barre de PV ennemi.

**Colonne gauche :** `LV 10 · R2 / Épée courte / Set Toile 3/4 / Wisp T/D/H` · `ATK 245 / DEF 120
· RES 80 / CRIT 4%` · bouton `TALENTS`.

**Centre :** scène — héros + 3 pets (Tank devant bleu, DPS derrière rouge, Heal en retrait vert),
ennemi à droite, dégâts flottants (`-247` jaune, `-891!` rouge critique), ligne `→ Boss Roi
Gobelin · 0.4 km`. Dessous : bascule `◀ AVANT / arrière ▶`. Puis barre de 3 compétences centrée :
`[Exécution ▶] [Rempart 4s] [Cri de guerre ▮▮▯]`.

**Colonne droite :** `Loup Sauvage N9 / PV 47 / 77` · `OR 2 017` · `ATK 62% · INT 38% · phys.` ·
bouton `MENU`.

**Bas :** piste de couche pleine largeur `Couche 4 — Champs de Cendres · Étape 4/10 · prochain :
BOSS ▸` + barre de progression.

Annotations :
1. Panneau héros à gauche : niveau, équipement, stats dérivées, accès aux talents.
2. Scène centrale large : héros + **3 pets**, ennemi à droite. Dégâts flottants recyclés (jaune / rouge critique), ancrés sur l'ennemi actif.
3. Bascule **Avant / Arrière** : devant = tu encaisses, +dégâts ; derrière = le boss vise tes pets.
4. Trois compétences centrées. Prête = bordure jaune + « ▶ ». Recharge = compte à rebours. Charge = jauge de ressource.
5. Panneau ennemi à droite : PV, or, répartition ATK/INT, type de dégâts, bouton Menu.
6. Piste de couche pleine largeur en bas + ligne « → prochain objectif » dans la scène.
7. **Zone réservée Roblox** (coin haut-gauche) : bouton ☰ menu + 💬 chat, imposés, non déplaçables. Aucun élément de jeu ici — les infos (morts / couche / km) sont centrées, le nom de l'ennemi à droite, la barre de PV démarre après le coin.

---

## 04 — Combat de boss (mécanique)

Chaque boss a une signature. Ici : frappe lourde télégraphée (tape pour interrompre), phases à
pastilles, adds à nettoyer en AoE, minuteur d'enrage.

**Différences vs 03 :** barre de vie de boss rouge + 3 pastilles de phase (2/3 franchies) ; scène
bordée de rouge + flash de bord d'écran ; boss sprite grand + 2 adds ; télégraphe en bas de la
scène `⚠ FRAPPE LOURDE — TAPE POUR INTERROMPRE` + jauge rouge qui se remplit ; colonne gauche =
`Enrage dans 0:22` / `Pet Heal : soin +2%/s` / `Butin : Set Roi Gobelin` ; barre de compétences
recontextualisée (`Rempart` → `TAP · interrompt` en rouge, `Cri` → `efface adds`).

1. Barre de vie de boss + **pastilles de phase** (2/3 franchies). Chaque phase ajoute ou retire une mécanique.
2. Télégraphe : jauge rouge qui se remplit + libellé + bordure de scène rouge + flash de bord d'écran. Fenêtre d'interruption ~1,5 s.
3. Adds invoqués. Ils tapent en plus ; une compétence AoE (« Cri ») les efface.
4. Les compétences se recontextualisent : « Rempart » devient l'interruption, sa tuile passe rouge et clignote.
5. Minuteur d'enrage : boss non mort à temps → gros bonus de dégâts. Force un stuff / des niveaux suffisants.

---

## 05 — Arbre de talents

Par voie, 1 point tous les 5 niveaux, réinitialisation gratuite au feu de camp. Trois branches
côte à côte. Débloque les compétences actives.

**Layout :** barre du haut = onglets `GUERRIER` / `MAGE` + `Points : 3` + bouton `Réinitialiser
(gratuit au feu)`. Milieu = 3 colonnes `FUREUR` / `GARDIEN` / `TACTIQUE`, chacune une chaîne
verticale de nœuds (`Maîtrise crit.`, `Rage`, `Exécution ▶`, … / `Peau dure`, `Rempart ▶`, … /
`Lien du pet`, `Cri de guerre ▶`, …). Bas = carte de détail :
`MAÎTRISE CRITIQUE — +8% chance de critique. Débloque Exécution (achève un ennemi sous 20% PV).`

1. Onglets GUERRIER / MAGE — deux arbres, on peut investir dans les deux si on multi-classe.
2. Trois branches côte à côte : **Fureur** (burst/crit) · **Gardien** (survie/DEF) · **Tactique** (compétences & pets).
3. Nœuds : plein jaune = acquis · contour clair = disponible · terne = verrouillé. « ▶ » = débloque une compétence active.
4. Carte de détail en bas au tap d'un nœud : effet chiffré + compétence éventuelle.
5. Réinitialisation gratuite au feu de camp → on encourage l'expérimentation, surtout avant un boss.

---

## 06 — Inventaire

Plein écran, GAME_SPEC §1.2, adapté paysage : slots équipés à gauche, grille de 100 au centre,
ramassage auto à droite, totaux en bas.

**Layout :** barre du haut = `ÉQUIPEMENT` + `Tri: Rareté ▼` `Filtre: Tout ▼` `✕`. Colonne gauche
(~22 %) = 6 slots équipés (CASQUE Épique / PLASTRON Rare / JAMBIÈRES vide / BOTTES Commun / ARME
Rare / PET ×3 Rare), bordure = rareté portée. Centre = `INVENTAIRE 74 / 100` + grille ~14 cases
de large, bordure de rareté. Colonne droite (~24 %) = `RAMASSAGE AUTO / Rareté min : Rare ▼ / [✓]
Guerrier / [ ] Mage` + bouton `Vendre < Rare` + carte de comparaison `+120 ATK / −15 DEF`. Bas =
panneau de set `SET ROI GOBELIN — 3/4 (Guerrier) · ✓ 2p +15% dgts · ✓ 3p +30% dgts, +20% vie · ✗
4p …` + totaux `ATK 2 450 · DEF 890 · RES 340 · PV 12 400`.

1. Six emplacements équipés (dont PET ×3). Bordure = rareté portée. Tap → sélecteur du slot.
2. Grille 100 cases, bordure de rareté (gris/bleu/violet/orange/rouge). Tri : rareté · puissance · set · récent.
3. Filtres de ramassage auto **sur la page même** : rareté minimale + deux cases indépendantes Guerrier / Mage.
4. Vente rapide « sous [rareté], ni équipé ni verrouillé », avec confirmation. Fusion sur chaque pile éligible.
5. Panneau de set + totaux de stats en bas. Au tap d'un objet : comparaison, deltas vert / rouge.

---

## 07 — Feu de camp (hub partagé)

Tous les 50 km. 100 % GUI : liste de joueurs et fenêtres, pas de monde 3D. Boutique, spar, file
de raid, échanges.

**Layout :** titre `FEU DE CAMP — KM 50`. 3 colonnes : `En ligne (6)` avec héros + couche |
[feu de camp animé] + chat | boutons `Boutique` / `Spar (duel de builds)` / `Échange` + widget
`FILE DE RAID · Golem des Profondeurs · 2/4 ▸`. Bas = `REPRENDRE LA DESCENTE`.

1. Rendu léger d'un feu de camp (Frames animés) — le seul « décor » riche du jeu.
2. Liste des joueurs présents + leur couche. Tap un nom → voir son héros / stuff, inviter, échanger.
3. Chat global du feu de camp, filtré, persistant tant qu'on est au camp.
4. File de raid : rejoindre une équipe pour un boss de raid (mécaniques, rôles, butin dédié) — v1.2.
5. Boutique · Spar (duel amical sans enjeu) · Échange (fenêtre + confirmation + petite taxe), puis reprise.

---

## 08 — Donjon du jour

Une graine fixe par jour, 5 salles + boss, ~4 minutes, classement de temps de clear mondial,
butin Rare+ garanti.

**Layout :** titre `DONJON DU JOUR · 2026-08-31 · même graine pour tous`. Chemin `▣ — ▣ — ▣ — ▢ —
◆` + `salle 3/5`. 2 colonnes : `Ton temps 02:14` / `Ton record du jour 03:41` | classement du
jour (`1. xX_Pro — 01:52` …) + `Garanti : Rare+ · top 100 : mat. cosmétiques`. Bas = `ENTRER`.

1. Même donjon pour tout le monde ce jour-là — c'est ce qui rend le classement comparable.
2. Chemin de 5 salles + un boss, salle courante en surbrillance. Reset chaque jour à minuit UTC.
3. Chrono en direct vs ton meilleur temps du jour.
4. Classement journalier (OrderedDataStore) + un classement saisonnier cumulé.
5. Butin Rare+ garanti pour tous ; les récompenses compétitives ne donnent aucune puissance.

---

## 09 — Pass de saison

Saisons de 8 semaines, piste gratuite + piste premium (Robux), ~50 paliers, XP gagnée en jouant à
n'importe quoi. La piste de paliers est naturellement horizontale.

**Layout :** titre `PASS DE SAISON — S1 · 47 jours restants · palier 12`. `XP vers palier 13` +
barre. Piste horizontale des paliers 9→16, 2 rangées `GRATUIT ▲` / `PREMIUM ▼` (premium
verrouillé = 🔒), palier courant encadré (bord jaune). Bas = `DÉBLOQUER LE PREMIUM — 799 R$` +
note « rétroactif ».

1. XP de pass toujours visible ; on la gagne en combattant, au donjon, aux missions, au raid.
2. Deux rangées : piste gratuite en haut (or, œufs, gemmes), premium en bas (verrouillée sans achat).
3. Palier courant encadré, bord supérieur jaune. Le premium est ~80 % cosmétique + un peu de confort.
4. Achat rétroactif : débloquer au palier 12 rend d'un coup les 12 récompenses premium.
5. Fin de saison : les cosmétiques restent, un nouveau pass démarre. Jamais de puissance exclusive.

---

## 10 — Boutique (cosmétiques d'abord)

Skins, auras de pet, effets de dégâts, mobilier de camp, plaques. Gacha (probabilités affichées)
uniquement ici, jamais pour la puissance.

**Layout :** titre `BOUTIQUE` + onglets `Skins / Auras / Effets / Mobilier / Plaques /
Améliorations` + solde Robux. Bannière `PACK DE DÉPART — 199 R$ (une fois) · 5 000 or · pet Rare
· set cosmétique complet`. Grille de cartes cosmétiques (aperçu, nom, prix ; une carte `Coffre
skin · GACHA`). Lien `Voir les probabilités du coffre`.

1. Onglets par type + un onglet séparé « Améliorations » (×2 or, ×2 XP, avance auto, +sac, VIP).
2. Tout est purement cosmétique — rien ne touche une stat, la DEF, la RES ou un taux de drop.
3. Bannière « Pack de départ » : offre unique très rentable, poussée aux nouveaux joueurs accrochés (analytics).
4. Cartes avec aperçu, nom, prix en Robux ; une seule catégorie « coffre » aléatoire.
5. Lien « Voir les probabilités » obligatoire dès qu'il y a de l'aléatoire — exigence Roblox.

---

## 11 — Codex / bestiaire

Chaque monstre et boss tué débloque une carte : art, une ligne de lore, un petit bonus permanent
de compte.

**Layout :** titre `CODEX` + onglets `Monstres / Boss / Objets` + `34 / 96`. Grille de cartes
(découverte = art + nom · non découverte = silhouette). Carte de détail à droite : art, `LOUP
SAUVAGE — Couche 1 · Bête`, « Rien de ce qui descend ne remonte entier. », `Bonus : +0,5% dégâts
contre les Bêtes`.

1. Compteur global de complétion — objectif visible à long terme.
2. Grille de cartes : découverte = art + nom · non découverte = silhouette « ??? ».
3. Carte de détail à droite : art, famille (Bête / Mort-vivant / Élémentaire…), une ligne de lore.
4. Bonus permanent minuscule par famille — récompense le fait de tout tuer plutôt que de courir.
5. Onglet Objets : chaque pièce vue au moins une fois, avec sa provenance et son set.

---

## 12 — Château (Rebirth & Ascension)

Checkpoints sélectionnables, rebirth infini (garde stuff/pets), et au-dessus l'Ascension tous les
10 rebirths — un modificateur de monde permanent.

**Layout :** titre `CHÂTEAU · max atteint : couche 4 · km 40`. 3 colonnes : `Point de départ`
(`[ km 0 ] [ 10 ] [ 20 ] [ 30 ] [ 40 ]`) | `REBIRTH 3 · Coût 48 000 or · Tu as 51 200 · Bonus
actuel : +40% dégâts · +50% XP · [REBIRTH]` | `Ascension — verrouillée · Progression 3 / 10
rebirths · Choix à venir : +50% PV mobs / +100% drop · ou · boss +1 mécanique / +1 pt talent`.

1. Checkpoints de 10 km débloqués — on repart d'où on veut pour farmer une pièce précise.
2. Rebirth : coût `10 000 × 2.2^(n-1)`, garde équipement / pets / checkpoints, remet niveau / stats / or / distance.
3. Bonus additifs affichés (+dégâts, +XP). Tous les 5 rebirths : un déblocage qualitatif.
4. **Ascension** à R10 : tu choisis un modificateur de monde permanent — l'endgame quand le rebirth s'essouffle.
5. Chaque palier d'ascension ré-ouvre un peu de l'arbre de talents et débloque des sets de raid supérieurs.

---

## 13 — Écran de mort

Roguelike : la mort est une progression, pas une punition. L'XP est conservée. La revive payante
est une option, jamais un mur.

**Layout :** bloc centré `TU ES TOMBÉ` (rouge, gros) · `Distance : 4.2 KM · Couche 4 · meilleur :
4.8 KM` · `XP conservée : 45 000 — tu recommences plus fort.` · boutons côte à côte `RECOMMENCER
(couche 3)` et `RÉAPPARAÎTRE ICI — 50 R$`.

1. Message franc, gros, rouge, centré. Pas d'écran de game-over déprimant — c'est une boucle.
2. Distance + couche atteinte, et le record personnel à côté pour cadrer la prochaine tentative.
3. Rappel explicite que l'XP est gardée — le joueur voit qu'il a gagné quelque chose.
4. « Recommencer » repart au checkpoint sélectionné (par défaut le dernier). Bouton principal.
5. Revive payante = produit consommable via `ProcessReceipt` idempotent. Optionnelle, jamais requise.

---

## 14 — La Descente (les 12 couches)

La ligne n'est pas 12 zones numérotées, c'est une descente dans la Faille. Chaque couche a une
identité et un boss qui est un personnage — il revient, plus fort, plus loin.

| Couche | Nom | Identité | Boss (km) |
|--------|-----|----------|-----------|
| C1 | Plaine de l'Aube | la surface qui s'effrite | Roi Gobelin (10) |
| C2 | Carrière des Runes | la pierre se souvient | Golem de Pierre (20) |
| C3 | Bois des Murmures | rien n'y pousse droit | Sorcière des Bois (30) |
| C4 | Champs de Cendres | le feu ne s'est jamais éteint | Colosse des Cendres (40) |
| C5 | Toundra des Âmes | le froid qui retient | Liche Glaciale (50) |
| C6 | Côte des Naufrages | sous la ligne de flottaison | Tyran des Abysses (60) |
| C7 | Ruines d'Aethel | la cité qui a trop su | Archimage Déchu (70) |
| C8 | Terres Brisées | la géométrie lâche | Béhémoth (80) |
| C9 | Landes du Deuil | l'écho de tout ce qui est tombé | Spectre Hurlant (90) |
| C10 | Forge de Fer | la machine qui creuse | Dragon de Fer (100) |
| C11 | Faille du Vide | là où la lumière s'arrête | Œil du Vide (110) |
| C12 | Fin de Toute Chose | le fond | Avatar de la Fin (120) |

Chaque boss apparaît d'abord affaibli, puis revient ~6 couches plus bas avec sa mécanique
complète et 2–3 lignes de dialogue rappelant votre dernier échange. Après la couche 12 : boucle
infinie + Ascension. Contenu post-lancement : couches 13–15.
