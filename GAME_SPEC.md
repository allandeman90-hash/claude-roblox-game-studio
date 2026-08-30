# SPÉCIFICATION — RPG automatique 2D sur Roblox

RPG minimaliste inspiré de MinuteQuest (Android, 2014). Le joueur avance sur une
ligne horizontale, combat automatiquement, meurt, recommence plus fort.
Toute la profondeur vient de l'équipement et du rebirth.

**Contrainte fondatrice : le jeu est 100% GUI. Il n'y a AUCUN monde 3D, aucun
personnage Roblox, aucune caméra. Tout se passe dans un ScreenGui.**

---

## 1. INTERFACE

### 1.1 Écran principal

Une maquette HTML fonctionnelle est fournie avec ce document
(`maquette-gui.html`). **Elle fait autorité sur la disposition, les proportions
et le style.** L'ouvrir dans un navigateur avant de commencer.

Structure verticale, du haut vers le bas :

```
┌──────────────────────────────────────────────┐
│ 40/55  [████████░░░░]                        │  ← barre HP joueur
│                          ┌─────────────────┐ │
│                          │ NOM ENNEMI Lv.4 │ │  ← encart HP ennemi
│                          │ [██████░░░]     │ │     (coin haut droit)
│                          │ 54/77 HP        │ │
│                          └─────────────────┘ │
│                                              │
│      [HÉROS]  ⚔  -247   [ENNEMI]             │  ← zone de combat
│   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   │     (dégâts flottants)
│   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓   │     sol + décor défilant
│                              24 EXP/min      │
├────────────┬──────────────────┬──────────────┤
│ ┌────────┐ │ ┌──────────────┐ │ ┌──────────┐ │
│ │ HÉROS  │ │ │  G  2017     │ │ │  MENU    │ │
│ │ LV:10  │ │ └──────────────┘ │ │  TAP     │ │
│ │ E ÉPÉE │ │ ┌──────────────┐ │ └──────────┘ │
│ │ E ARMR │ │ │ NOM ENNEMI   │ │              │
│ │ E PET  │ │ │ Lv4  [███░░] │ │              │
│ └────────┘ │ │ MAX HP:   77 │ │              │
│ ┌────────┐ │ │ ATK:     40% │ │              │
│ │ ATK 245│ │ │ INT:     60% │ │              │
│ │ DEF 120│ │ │ SPD:      12 │ │              │
│ │ RES  80│ │ │ EXP:       4 │ │              │
│ └────────┘ │ │ TYPE: MAGIQUE│ │              │
│ ┌────────┐ │ └──────────────┘ │              │
│ │ TEMPS  │ │                  │              │
│ │    12M │ │                  │              │
│ │ DIST   │ │                  │              │
│ │ 4.2KM  │ │                  │              │
│ └────────┘ │                  │              │
└────────────┴──────────────────┴──────────────┘
```

Règles de style, reprises de la maquette :
- fond noir, texte blanc, police monospace
- chaque bloc d'information est un rectangle à **bordure blanche épaisse**
  (4px pour les panneaux, 2px pour les boîtes internes)
- panneau inférieur en 3 colonnes : gauche (héros), centre (or + ennemi),
  droite (menu)
- la colonne gauche contient 3 boîtes empilées, séparées visuellement
- aucune couleur vive ; seuls les dégâts flottants sont colorés
  (jaune = normal, rouge = critique)

Les 3 lignes `E ÉPÉE / E ARMR / E PET` sont cliquables :
- **E ÉPÉE** → ouvre le sélecteur d'armes
- **E ARMR** → ouvre l'inventaire complet (§1.2)
- **E PET** → ouvre le sélecteur de pets

La ligne ARMR affiche un résumé : nom du set dominant, ou « Mixte ».

### 1.2 Écran d'inventaire

Plein écran, par-dessus l'écran principal, même style graphique.

```
┌──────────────────────────────────────────────┐
│  ÉQUIPEMENT                              [X] │
├─────────────────┬────────────────────────────┤
│  CASQUE         │  INVENTAIRE      74 / 100  │
│  [Roi Gobelin]  │  ┌──┬──┬──┬──┬──┬──┬──┐    │
│   Épique · Guer │  │  │  │  │  │  │  │  │    │
│                 │  ├──┼──┼──┼──┼──┼──┼──┤    │
│  PLASTRON       │  │  │  │  │  │  │  │  │    │
│  [Roi Gobelin]  │  ├──┼──┼──┼──┼──┼──┼──┤    │
│   Rare · Guer   │  │  │  │  │  │  │  │  │    │
│                 │  └──┴──┴──┴──┴──┴──┴──┘    │
│  JAMBIÈRES      │                            │
│  [ vide ]       │  Tri : Rareté ▼            │
│                 │  Filtre : Tout ▼           │
│  BOTTES         │                            │
│  [Roi Gobelin]  │  RAMASSAGE AUTO            │
│   Commun · Guer │   Rareté min : Rare ▼      │
│                 │   [✓] Guerrier  [ ] Mage   │
├─────────────────┴────────────────────────────┤
│  SET ROI GOBELIN — 3/4 (Guerrier)            │
│  ✓ 2 pièces : +15% dégâts                    │
│  ✓ 3 pièces : +30% dégâts, +20% vie          │
│  ✗ 4 pièces : +50% dgts, +40% vie, +25% vit. │
├──────────────────────────────────────────────┤
│  ATK 2450   DEF 890   RES 340   HP 12400     │
└──────────────────────────────────────────────┘
```

Fonctionnalités requises :
- grille de 100 cases, bordure colorée selon la rareté
  (gris / bleu / violet / orange / rouge)
- tri : rareté, puissance, set, récent
- filtre : par emplacement, par set, par voie
- au clic sur un objet : comparaison avec l'objet équipé, différences en
  vert/rouge
- verrouillage d'un objet (empêche la vente)
- vente rapide : « vendre tout ce qui n'est ni équipé ni verrouillé, en dessous
  de [rareté] »
- fusion (§5) accessible depuis cet écran
- **les cases de ramassage auto doivent être ici, visibles sans sous-menu** —
  le joueur les manipule souvent

### 1.3 Écran de sélection de départ (château)

Liste des checkpoints débloqués (§8). Bouton de rebirth avec son coût affiché.

---

## 2. BOUCLE DE JEU

Le joueur maintient une zone gauche ou droite pour se déplacer. Entrer en
contact avec un monstre déclenche l'attaque automatique. Tapoter accélère la
cadence.

Boucle serveur, à chaque tick :
1. calculer les dégâts du héros et du pet DPS
2. les appliquer au monstre courant
3. le monstre attaque en retour selon sa cadence
4. si HP monstre ≤ 0 → tirage de butin, apparition du suivant
5. si HP joueur ≤ 0 → retour au dernier checkpoint choisi
6. mettre à jour l'interface

**Sécurité : la cadence d'attaque doit être validée côté serveur.** Un client
qui envoie 1000 clics/seconde doit être plafonné. Aucune stat, aucun or, aucun
drop ne doit jamais être calculé côté client.

---

## 3. STATS

### 3.1 Stats du joueur

Cinq stats, points alloués librement à chaque niveau :

| Stat | Effet |
|---|---|
| POW | dégâts physiques (voie Guerrier) |
| INT | dégâts magiques (voie Mage) |
| VIT | HP max = VIT × 5 |
| SPD | cadence d'attaque |
| LUK | taux de critique |

Critique : ×2 dégâts, taux ≈ LUK/10000.

### 3.2 Stats défensives

**DEF** (réduit les dégâts physiques) et **RES** (réduit les dégâts magiques)
**proviennent uniquement de l'équipement**, jamais des points de niveau.

- l'équipement Guerrier donne majoritairement de la DEF
- l'équipement Mage donne majoritairement de la RES

Conséquence voulue : un guerrier pur (0 point en INT) a quand même intérêt à
porter du stuff Mage contre un boss magique, pour la RES.

### 3.3 Les deux voies

| | Guerrier | Mage |
|---|---|---|
| Stat offensive | POW | INT |
| Dégâts | stables, cadence rapide | élevés, cadence lente |
| Stat secondaire | SPD | LUK |
| Défense dominante | DEF | RES |

---

## 4. ÉQUIPEMENT

### 4.1 Structure d'un objet

Un objet a exactement quatre propriétés :

```
Casque du Roi Gobelin [Lv.100] · Guerrier · Épique
```

- **nom** : dépend du boss/zone d'origine
- **Lv.** : purement indicatif, celui du boss d'origine. **N'entre dans aucun
  calcul.** Sert uniquement au tri et à la lisibilité. Ne doit jamais bloquer
  l'équipement (important après un rebirth, où le joueur est niveau 1 avec du
  stuff Lv.400).
- **voie** : Guerrier ou Mage
- **rareté** : multiplie les stats de base

Il n'y a **pas d'éléments** (feu, glace…), **pas de tags**, **pas de niveau
d'objet réel**.

### 4.2 Emplacements

6 au total : Arme, Casque, Plastron, Jambières, Bottes, Pet.
Les 4 pièces d'armure sont dans l'écran d'inventaire, pas sur l'écran
principal.

### 4.3 Rareté

| Rareté | Chance | Multiplicateur |
|---|---|---|
| Commun | 60% | ×1.0 |
| Rare | 25% | ×1.5 |
| Épique | 10% | ×2.2 |
| Légendaire | 4% | ×3.5 |
| Mythique | 1% | ×6.0 |

Une sixième rareté « Divin » (0,05%, ×10.0) est prévue pour une future mise à
jour — **ne pas l'implémenter maintenant**, mais laisser la structure de
données extensible.

La rareté est tirée **indépendamment** du type d'objet, après avoir déterminé
quel objet tombe. Elle doit être annoncée visuellement au drop (texte flottant),
pas seulement découverte dans l'inventaire.

### 4.4 Contenu de lancement

- 50 armes
- 40 pets
- 12 boss × 4 pièces × 2 voies = 96 armures

---

## 5. SETS ET FUSION

### 5.1 Bonus de set

Chaque boss définit un set de 4 pièces. Les bonus s'appliquent par paliers,
**uniquement si les pièces sont de la même voie** :

| Pièces portées | Bonus (exemple) |
|---|---|
| 2 | +15% dégâts |
| 3 | +30% dégâts, +20% vie |
| 4 | +50% dégâts, +40% vie, +25% vitesse d'attaque |

Les versions Guerrier et Mage d'un set ont des bonus **symétriques** : là où la
version Guerrier donne « +50% dégâts POW », la version Mage donne « +50% dégâts
INT ». Même structure, même valeur.

Un mélange 2 Guerrier + 2 Mage ne déclenche aucun palier.

Chaque set doit avoir une identité propre : certains orientés dégâts, d'autres
survie, d'autres vitesse.

### 5.2 Fusion

Fusion **stricte** : uniquement des exemplaires du **même objet exact** (même
nom, même emplacement, même voie).

| Recette | Résultat |
|---|---|
| 3 Communs | 1 Rare |
| 4 Rares | 1 Épique |
| 5 Épiques | 1 Légendaire |
| 6 Légendaires | 1 Mythique |

Coût cumulé : 1 Mythique = 360 Communs. C'est volontairement plus cher que le
farm direct — la fusion est un filet de sécurité, pas un raccourci.

**Aucune pitié, aucune conversion croisée.** Si le joueur n'a jamais vu les
jambières, aucune fusion ne les lui donnera. Il doit farmer.

---

## 6. MONSTRES ET BOSS

### 6.1 Monstres normaux

Niveau du monstre = distance en km × 10.

### 6.2 Boss

Un boss tous les 10 km (12 boss au lancement). Chaque boss a une **répartition
ATK / INT** affichée dans le panneau d'information :

```
Roi Gobelin [Lv.100]   70% ATK / 30% INT   → frappe physique
Sorcière    [Lv.500]   40% ATK / 60% INT   → frappe magique
```

Cette répartition détermine le **type de dégâts que le boss inflige**, donc
quelle défense du joueur compte (DEF ou RES). Un boss magique fait mal à un
guerrier peu équipé en RES — mais ne le bloque jamais : il peut compenser avec
plus de VIT, un pet Tank ou Heal, ou des niveaux supplémentaires.

**Le boss ne résiste pas au type de dégâts du joueur.** Un guerrier tape aussi
fort qu'un mage sur un boss magique ; il encaisse simplement moins bien.

### 6.3 Table de butin des boss

**Un seul tirage par kill.** Jamais deux pièces d'un coup.

| Résultat | Chance |
|---|---|
| Or / bonus XP | 50% |
| Bottes Guerrier | 7% |
| Bottes Mage | 7% |
| Jambières Guerrier | 6% |
| Jambières Mage | 6% |
| Plastron Guerrier | 5% |
| Plastron Mage | 5% |
| Casque Guerrier | 4,5% |
| Casque Mage | 4,5% |
| Arme Guerrier | 2,5% |
| Arme Mage | 2,5% |

Ces pourcentages sont **constants à toutes les zones**. La difficulté croissante
suffit à ralentir la progression : un boss du km 10 se tue en 20 s, un boss du
km 200 en 4 min, donc 50 kills passent de 17 min à 3 h.

Ordre de tirage : d'abord le type d'objet (table ci-dessus), puis la rareté
(§4.3), indépendamment.

---

## 7. ÉCONOMIE ET COURBES

### 7.1 Courbe de puissance

**×1.35 par zone de 10 km**, appliqué uniformément à :
- HP et stats des monstres
- puissance des armes et armures de boutique
- or lâché par les monstres

Cette uniformité est **critique** : si les monstres montent plus vite que
l'équipement disponible, la progression devient mathématiquement impossible et
aucun rebirth ne peut le compenser.

### 7.2 Armes de boutique vs armes de boss

L'arme de boutique d'une zone doit permettre de battre le boss de cette zone si
les stats du joueur suivent. L'arme du boss est **2,5× plus puissante** que
l'arme de boutique de la même zone.

```
Zone 100 — arme de boutique : 100 de puissance
Zone 100 — arme de boss     : 250 de puissance (base, avant rareté)
```

Avec ×1.35 par zone, une arme de boss Mythique reste supérieure aux boutiques
pendant environ **6 zones**. C'est voulu : un Mythique doit être un événement.

### 7.3 Or

L'or lâché dépend du **niveau du monstre**, pas du temps passé. Farmer le km 1
doit rester possible mais dérisoirement peu rentable — le joueur doit le voir
immédiatement dans les chiffres, sans qu'aucune règle ne l'interdise.

### 7.4 Boutiques

Boutique d'armes et boutique d'armures apparaissent régulièrement le long du
parcours. Chacune vend 5 objets. Les boutiques déjà visitées mettent à jour leur
stock quand le joueur progresse.

---

## 8. REBIRTH ET CHECKPOINTS

### 8.1 Rebirth

- **infini**
- **conserve l'équipement, les pets et les checkpoints**
- **remet à zéro** : niveau, points de stats, or, distance
- **aucune condition de distance** — le joueur peut rebirth où il veut
- **coût en or** : `10 000 × 2.2^(n−1)`

| Rebirth | Coût |
|---|---|
| R1 | 10 000 |
| R2 | 22 000 |
| R3 | 48 000 |
| R5 | 234 000 |
| R10 | 6,1 M |
| R20 | 4,2 Md |

Bonus par rebirth : **+20% dégâts, +25% XP** (additif).

Tous les 5 rebirths, un déblocage qualitatif (à définir : emplacement
supplémentaire, famille d'objets, avantage de départ). Sans ça, le rebirth
devient monotone vers R15.

**Objectif de calibrage : après un rebirth, le joueur doit retraverser son
parcours précédent en environ 20% du temps initial.** L'équipement conservé
fournit déjà ~35% ; le bonus d'XP fait le reste. C'est bien le bonus d'XP, pas
celui de dégâts, qui compte ici — ce qui ralentit au rebirth c'est de remonter
les niveaux, pas de tuer les monstres.

### 8.2 Checkpoints

Chaque palier de 10 km atteint devient un **point de départ sélectionnable** au
château. Le joueur peut recommencer au km 10, 20, 30… pour farmer une pièce ou
un pet précis.

---

## 9. PETS

40 pets. Chaque pet a un **rôle fixe** (attaché au pet, pas choisi par le
joueur) :

| Rôle | Effet |
|---|---|
| DPS | attaque en plus du héros, à sa propre cadence |
| Tank | absorbe un **pourcentage** des dégâts reçus |
| Heal | régénère un **pourcentage** des HP max par seconde |

Les effets Tank et Heal doivent être en pourcentage, jamais en valeur fixe,
sinon ils décrochent complètement en fin de partie.

La rareté et la fusion fonctionnent exactement comme pour l'équipement :
3 Pingouins Communs → 1 Pingouin Rare.

---

## 10. INVENTAIRE

- **100 slots**
- inventaire plein → **le drop est refusé**, message « Inventaire plein »
- **filtre de ramassage automatique**, réglable en jeu :
  - rareté minimale à ramasser
  - `[ ] Ramasser Guerrier` et `[ ] Ramasser Mage`, **deux cases indépendantes**
    (les deux cochées par défaut ; le joueur peut tout ramasser, une seule voie,
    ou rien)

Le joueur bascule ces cases fréquemment : il ignore la voie opposée pour
économiser de la place, puis la réactive quand il bute sur un boss du type
opposé et a besoin de DEF/RES. Ces contrôles doivent être immédiatement
accessibles, pas enfouis dans un sous-menu.

---

## 11. PERSISTANCE

Sauvegarde par DataStore. Utiliser **ProfileStore** (module communautaire) —
il évite les pièges classiques de perte de données et de sessions concurrentes.

Structure à sauvegarder :

```lua
{
  niveau = 25,
  xp = 45000,
  or_ = 125000,
  distance = 4.2,
  checkpointMax = 4,          -- km 40 débloqué
  rebirths = 3,
  stats = { pow = 25, int = 5, vit = 30, spd = 20, luk = 18 },
  pointsNonAlloues = 0,
  equipe = {
    arme = { id = "epee_gobelin", voie = "guerrier", rarete = "epique" },
    casque = { ... }, plastron = { ... },
    jambieres = { ... }, bottes = { ... },
    pet = { id = "pingouin", role = "dps", rarete = "rare" },
  },
  inventaire = { ... },       -- max 100 entrées
  verrouilles = { ... },
  filtres = { rareteMin = "rare", guerrier = true, mage = false },
}
```

Sauvegarde automatique périodique + à la déconnexion.

**Roblox n'a pas de mode hors-ligne** : contrairement à MinuteQuest, le jeu
s'arrête quand le joueur quitte. Ne pas implémenter de gains hors-ligne au
lancement.

---

## 12. NOTES TECHNIQUES

- **Affichage des grands nombres** : suffixes K / M / Md / T. Les valeurs
  dépassent vite le million. Luau utilise des doubles, aucun problème de
  précision avant 2^53.
- **Décor** : fond défilant en boucle avec parallaxe, en ImageLabel.
- **Dégâts flottants** : texte animé qui monte et s'estompe, jaune pour les
  coups normaux, rouge pour les critiques.
- **Performance** : cible 30 FPS sur mobile. Éviter de créer/détruire des
  instances GUI à chaque frame — recycler un pool d'objets pour les dégâts
  flottants.
- Aucune donnée sensible côté client ; tous les calculs de combat, de butin et
  d'économie sur le serveur.

---

## 13. PÉRIMÈTRE DE LA V1

**Inclus** : tout ce qui précède.

**Exclus volontairement, pour de futures mises à jour** :
- rareté Divin
- multijoueur, échange, guildes, raids
- monétisation (game passes, produits développeur)
- gains hors-ligne
- classements

L'objectif de cette version est un jeu **jouable et complet en solo**. Les
extensions viendront si le jeu trouve son public.
