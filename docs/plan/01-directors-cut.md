# Quête Minute — Director's Cut

> La vision retenue. Proposition de redesign : garder le système d'équipement, retravailler
> et ajouter tout le reste pour faire un jeu social, profond, et dans lequel on dépense.
> Artifact : `claude.ai/code/artifact/dbf3e8d6-6cb0-4035-ae98-a89875e4792a`

---

## A — Le pari

Le GAME_SPEC est un portage fidèle de MinuteQuest : une ligne, auto-combat, mort, équipement,
rebirth. Comme jeu Android payant de 2014, complet. Comme jeu Roblox gratuit de 2026, trois
problèmes structurels :

1. **Il est solo, et le dit.** Le spec coupe explicitement multijoueur, échange, guildes,
   classements. La rétention Roblox *est* une rétention sociale. Pas de co-op = pas de
   « viens jouer avec moi » — le seul message qui diffuse vraiment un jeu.
2. **Le combat ne demande rien au joueur.** 100 % passif — même le tap-to-speed a été retiré.
   Le moment-à-moment, c'est regarder des chiffres changer. Aucune décision, aucune réaction,
   aucune expression de skill.
3. **Rien n'est mémorable.** 12 zones numérotées, des boss qui sont `hp × multiplicateur` avec
   un ratio ATK/INT, pas de monde, pas de personnages, pas d'identité. Un joueur ne peut pas
   le décrire à un ami en une phrase qui donne envie.

**Le pari :** garder l'identité 100 %-GUI, instant, faible-input (paysage verrouillé) — quasi
tous les jeux Roblox sont des mondes 3D lourds, donc un bon jeu GUI est un différenciateur, pas
une limite. Puis rendre la GUI **profonde et sociale** au lieu de **minimale et solo**. Pitch
en une phrase : *« l'auto-battler que tu joues vraiment avec tes amis, en sessions courtes, qui
respecte ton temps. »*

---

## B — Ce qu'on garde : le système d'équipement, inchangé

La seule partie du spec que je livrerais telle quelle, parce que le design est juste :

- 6 slots · 5 raretés en pur multiplicateur de stats · **niveaux d'objet indicatifs qui ne
  bloquent jamais** — parfait pour le rebirth, où l'on est niveau 1 en stuff Lv.400.
- Sets Guerrier / Mage symétriques avec bonus paliers 2 / 3 / 4 ; DEF et RES viennent seulement
  du stuff, donc un guerrier pur veut quand même des pièces Mage contre un boss magique.
- Fusion stricte du même objet exact comme *filet* de pitié, pas comme raccourci — 1 Mythique
  coûte 360 Communs exprès.
- On l'**étend** seulement — il supporte déjà l'échange (objets auto-contenus) et le transmog
  cosmétique (skiner un objet, garder ses stats) sans redesign.

---

## Les upgrades

Taggés : **Keep** (inchangé) · **Reshape** (retravailler la version du spec) · **Add** (nouveau).
Effort : **S** ≤½j · **M** 1–2j · **L** 3–5j · **XL** 1sem+.

### Profondeur de combat

| # | Titre | Tag | Effort | Quand | Détail | Pourquoi c'est mieux |
|---|-------|-----|--------|-------|--------|----------------------|
| 1 | Compétences actives | Add | M | Lancement | 3 slots à cooldown, déclenchées par le joueur. Voie-flavored — Guerrier : Exécution / Rempart / Cri ; Mage : Météore / Barrière / Surcharge. Débloquées via l'arbre de talents (#13). | Un changement et le jeu devient un jeu : placer son burst avant la frappe lourde du boss, popper le bouclier quand les adds spawnent. Faible plancher, vrai plafond de skill. |
| 2 | Mécaniques de boss | Reshape | M | Lancement | Chaque boss reçoit UNE signature : frappe lourde télégraphée (fenêtre d'interruption), phase de bouclier (course contre un timer), adds invoqués (AoE), DoT qui stacke (nettoyé par pet Heal). | Les boss du spec ne diffèrent que par un ratio ATK/INT et un mur de stats. Ce sont des combats qu'on *apprend* — et la raison d'amener une compo de pets précise. |
| 3 | Équipe de 3 pets | Reshape | M | Lancement | 3 slots de pets au lieu d'1 — on monte une compo DPS / Tank / Heal ; chaque pet a un passif + une compétence déclenchée. | Les pets passent de « petit % de buff qu'on remarque à peine » à la moitié du build et un vrai objectif de collection. |
| 4 | Positionnement sur la ligne | Add | S | v1.1 | Tenir un modificateur pour avancer agressivement (devant — on tank, +dégâts) ou rester en retrait (le boss vise les pets). Un petit bouton risk/reward. | Le seul input du spec est une direction de marche. Ceci ajoute un choix tactique en direct pour un coût quasi nul. |

### Social

| # | Titre | Tag | Effort | Quand | Détail | Pourquoi c'est mieux |
|---|-------|-----|--------|-------|--------|----------------------|
| 5 | Feux de camp partagés | Add | L | v1.1 | Les feux de camp des 50 km deviennent des salles hub GUI : on voit les héros + le stuff des autres joueurs, un chat global, la boutique, un « spar » (duel amical de builds), et la file de raid. **Reste 100 % GUI** — une liste de lobby, pas un monde 3D. | Le feu de camp du spec est un menu boutique solo. C'est ici que le jeu devient social sans abandonner l'identité GUI. |
| 6 | Boss de raid co-op | Add | XL | v1.2 | 2–4 joueurs, une arène GUI séparée, un boss de raid avec de vraies mécaniques, les rôles comptent (quelqu'un spec tank, quelqu'un amène le cleanse), un timer d'enrage, une table de butin de sets raid-only. | C'est l'endgame ET le hook viral — « viens faire le raid avec moi » est le type de message le plus partagé sur Roblox. |
| 7 | Échange | Add | M | v1.1 | Le système d'équipement le supporte déjà. Une fenêtre d'échange GUI, une confirmation, une petite taxe (Robux ou or). | Une raison de farmer des doublons, une économie, une interaction joueur-à-joueur. |
| 8 | Crews / guildes | Add | L | v1.2 | Un crew de ~20, un objectif hebdo partagé (km collectif / kills de boss), un boss de crew, une boutique de crew avec des cosmétiques uniques. | Le mécanisme de rétention D30 le plus fort qui existe — l'obligation sociale. |
| 9 | Classements saisonniers | Add | S | Lancement | Reset hebdo : meilleur temps de clear du donjon du jour, plus de km cette saison, plus de clears de raid. Récompenses cosmétiques + titres. | Le spec exclut explicitement les classements. C'est de la rétention gratuite. |

### Identité

| # | Titre | Tag | Effort | Quand | Détail | Pourquoi c'est mieux |
|---|-------|-----|--------|-------|--------|----------------------|
| 10 | Cadre « La Descente » | Reshape | M | Lancement | La ligne n'est pas 12 zones génériques, c'est une descente dans la Faille. Chaque zone est une couche avec une courte histoire environnementale et un boss qui est un *personnage* : un nom, une rancune, 2–3 répliques de taunt. Les 12 boss reviennent — on affronte un Roi Gobelin affaibli à la couche 1, il revient à la couche 7 « ayant level up aussi ». | Le monde du spec est une droite numérotée. Ceci coûte une page d'écriture et rend le jeu mémorable. |
| 11 | Codex / bestiaire | Add | S | Lancement | Chaque ennemi et boss tué débloque une carte : art, une ligne de lore, un petit bonus permanent de compte (+0,5 % dégâts vs cette famille). | Transforme les kills en collection, donne un foyer au lore, récompense l'exploration. |
| 12 | Un vrai style guide art & son | Reshape | M | Lancement | S'engager sur un style pixel fort + une bande-son composée par couche, plutôt que « fantasy générique, swap de palette ». La leçon de modération intégrée : un style guide défini, sûr, cohérent en amont. | Le spec dit « fond noir, monospace, pas de couleurs vives » et s'arrête. Une identité définie, c'est ce qui sépare un screenshot qui reçoit un clic d'un qu'on scrolle. |

### Méta-progression

| # | Titre | Tag | Effort | Quand | Détail | Pourquoi c'est mieux |
|---|-------|-----|--------|-------|--------|----------------------|
| 13 | Arbre de talents | Add | M | Lancement | Par voie, un point tous les 5 niveaux, respec libre au feu de camp. Vraies fourches : crit/burst vs sustain/bruiser vs caster de compétences. Gate les compétences actives de #1. | Le spec a un axe (allouer 5 stats). Ceci ajoute une *identité de build* qui survit au rebirth. |
| 14 | Ascension | Add | M | v1.1 | Au-dessus du rebirth. Tous les 10 rebirths on ascend : on choisit un modificateur de monde permanent (mobs +50 % PV mais drops +100 %, ou les boss gagnent une mécanique mais donnent un point de talent). | Le rebirth seul flat-line vers R15 (le spec l'admet et hand-wave « un déblocage qualitatif tous les 5, à définir »). L'Ascension est ce système, designé. |
| 15 | Bonus de collection | Add | S | Lancement | « Posséder les 4 pièces d'un set (toute rareté) » → un passif permanent de compte. « Posséder les 12 sets » → un titre + un cosmétique. Pareil pour les 40 pets. | Rend le farm de doublons et le stuff de voie opposée intéressant à garder ; étend le plafond de grind de plusieurs mois. |

### Forme de session & endgame

| # | Titre | Tag | Effort | Quand | Détail | Pourquoi c'est mieux |
|---|-------|-----|--------|-------|--------|----------------------|
| 16 | Donjon du jour | Add | M | Lancement | Une graine fixe par jour, 5 salles + un boss, ~4 minutes, un classement de temps de clear mondial, butin garanti Rare+. | La session du spec, c'est « cours jusqu'à la mort ». Ceci est un rituel quotidien bite-sized, compétitif, où tout le monde joue la même chose — la meilleure primitive de rétention. |
| 17 | Modificateurs de défi | Add | S | v1.1 | Rejouer une couche déjà battue avec des modificateurs empilés (½ PV, ×2 dégâts boss, pas de soin) pour des matériaux cosmétiques premium. | Valeur de rejeu pour du contenu déjà battu ; le spec fait d'une couche battue un poids mort. |
| 18 | Pass de saison | Add | M | Lancement | Saisons de 8 semaines, piste gratuite + piste premium (Robux), ~50 paliers, XP en jouant à n'importe quoi. La piste premium est ~80 % cosmétique + un peu de confort. | Le système à plus haut ROI de rétention *et* de monétisation du Roblox moderne. Non optionnel si l'objectif est « les clients dépensent des Robux ». |

### Monétisation

| # | Titre | Tag | Effort | Quand | Détail | Pourquoi c'est mieux |
|---|-------|-----|--------|-------|--------|----------------------|
| 19 | Boutique cosmétique d'abord | Add | M | Lancement | Skins de héros, auras de pet, polices/couleurs de nombres de dégâts, mobilier de feu de camp, effets de kill, plaques de nom. Le gacha (avec probas affichées) existe *uniquement* ici, jamais pour la puissance. | Revenu cosmétique illimité et éthique ; nourrit aussi l'identité de #10 — des joueurs qui portent ton monde. |
| 20 | Passes de confort | Add | S | Lancement | ×2 or, ×2 XP, avance auto, +inventaire, VIP — le set de la ship roadmap. Composent de la valeur plus on joue longtemps. | Récompensent les retenus, pas les impulsifs — et aucun ne touche une stat, la DEF, la RES ou un taux de drop. |
| 21 | Offres pilotées par les analytics | Add | M | v1.1 | Un pack de départ pour les nouveaux joueurs accrochés, un bundle « welcome back » pour les lapsed, un revive/boost ciblé pour quelqu'un bloqué sur un boss — piloté par la couche d'events de la ship roadmap. | Vend dans un moment ressenti au lieu d'un menu statique ; chaque offre est une réponse à un comportement réel. |

### Présentation

| # | Titre | Tag | Effort | Quand | Détail | Pourquoi c'est mieux |
|---|-------|-----|--------|-------|--------|----------------------|
| 22 | Passe de game-feel GUI | Reshape | M | Lancement | Barres de vie de boss avec pastilles de phase, flashs de crit plein écran, faisceaux de butin par rareté, célébration de « power spike » sur une grosse amélioration, hit-stop sur les coups lourds. Tout GUI, tout pas cher. | La liste §12 de juice du spec (nombres flottants, fond qui défile) est un plancher. C'est la différence entre « tableur » et « jeu ». |

---

## Ce que je couperais de ma propre liste pour le lancement

Être honnête sur un planning solo. Le lancement ne livre que les items taggés **Lancement**.

**Dans pour le lancement :** compétences · mécaniques de boss · équipe de 3 pets · La Descente ·
codex · style guide art/son · arbre de talents · bonus de collection · donjon du jour · pass de
saison · boutique cosmétique · passes de confort · passe de game-feel · classements saisonniers.

**Différé v1.1 :** feux de camp partagés · échange (+ taxe) · Ascension · modificateurs de défi ·
offres pilotées analytics · positionnement sur la ligne.

**Différé v1.2 :** boss de raid co-op · crews. *(Les gros systèmes sociaux viennent en dernier —
on les construit une fois qu'il y a des joueurs pour les remplir.)*

---

## Comment ça se fond dans la ship roadmap

| Phase ship roadmap | Upgrades qui s'y intègrent |
|--------------------|----------------------------|
| P1 · Remplir le monde | cadre La Descente · codex · style guide art/son · data de mécanique de boss |
| P2 · Première session | arbre de talents (construit avec la création) · équipe de 3 pets · compétences débloquées via le tutoriel |
| P3 · Raisons de revenir | donjon du jour · pass de saison (piste gratuite) · classements saisonniers · bonus de collection |
| P4 · Monétisation | boutique cosmétique · piste premium du pass · passes de confort |
| P5 · Feel & polish | passe de game-feel GUI · VFX des compétences et des mécaniques de boss |
| Post-lancement | tout le bloc social, l'Ascension, l'échange, les modificateurs de défi, les offres ciblées |

Effet net sur le planning : environ **+10–14 jours de travail focalisé** par-dessus les 28 de la
ship roadmap (le sous-ensemble de lancement).

---

## North star

La ship roadmap donne un jeu *complet*. Celle-ci donne un jeu *retenu*.

| | Complet seulement | Avec le Director's Cut |
|---|---|---|
| | D1 ~10 % · D7 ~3 % · ARPU faible · plateau à faible CCU. Un jeu fini que personne ne joue plus à D14. | Donjon du jour + pass de saison + builds de talents poussent le **D7 vers 8–12 %**. Classements et (plus tard) co-op créent la boucle de partage. Cosmétiques + pass montent l'**ARPPU ×3–5**. |
