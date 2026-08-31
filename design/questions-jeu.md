# Quête Minute — Les questions à trancher avant d'écrire le GDD

**Date : 2026-08-31** · *(remplace `open-questions.md` — ne plus toucher à l'ancien fichier)*

Coche ta réponse à chaque question (mets un `x` entre les crochets : `[x]`), ou écris la tienne sur la ligne "Autre". On écrit le GDD quand tout est répondu.

**Avancement : Q1 à Q119 répondues + questions supplémentaires N1–N6 tranchées.**
Tout est consolidé dans `design/reponses-consolidees.md`. Prochaine étape : GDD maître.
(Q89–Q94 → `design/economy/monetization.md`. Q24 → (c). Q26 → décalage du 1er mur ~km 25-35 / jour 2-3. Q95/N1 : checkpoint auto à chaque feu de camp. N3 : le château = le feu de camp du km 0. N4 : raids = donjon-raid solo au lancement, co-op en v1.1.)

**Légende :**
- *[IMPORTANT - à décider avant le GDD]* : on ne peut pas écrire le GDD tant que ce n'est pas tranché.
- *[peut attendre plus tard]* : on peut écrire le GDD sans, on y reviendra.

---

## Sommaire des 29 sections

| # | Section | Questions |
|---|---------|-----------|
| 1 | Comment se passe une partie | Q1–Q4 |
| 2 | Les premières minutes et créer son héros | Q5–Q8 |
| 3 | Les menus et se déplacer dedans | Q9–Q11 |
| 4 | Le combat de tous les jours | Q12–Q15 |
| 5 | Les pouvoirs spéciaux | Q16–Q19 |
| 6 | Les combats de boss | Q20–Q24 |
| 7 | Devenir plus fort en montant de niveau | Q25–Q28 |
| 8 | Les points bonus, les talents et les sous-classes | Q29–Q34 |
| 9 | Le Rebirth (recommencer plus fort) | Q35–Q38 |
| 10 | Le mode difficile (Cauchemar) | Q39–Q43 |
| 11 | La vitesse du jeu | Q44–Q46 |
| 12 | Les objets et le sac | Q47–Q51 |
| 13 | Les familiers | Q52–Q56 |
| 14 | Le Codex (la collection de monstres) | Q57–Q60 |
| 15 | L'or et les boutiques | Q61–Q65 |
| 16 | Le feu de camp | Q66–Q68 |
| 17 | Les missions | Q69–Q72 |
| 18 | Le Donjon du Jour | Q73–Q76 |
| 19 | Les raisons de revenir jouer demain | Q77–Q80 |
| 20 | Les classements | Q81–Q84 |
| 21 | Le Pass de saison | Q85–Q88 |
| 22 | Ce qu'on achète avec des Robux | Q89–Q94 |
| 23 | Quand le héros meurt | Q95–Q98 |
| 24 | L'histoire de La Descente | Q99–Q101 |
| 25 | Les dessins, les sons, aider tout le monde à jouer | Q102–Q105 |
| 26 | Savoir ce que font les joueurs | Q106–Q107 |
| 27 | Les bugs et les situations bizarres | Q108–Q112 |
| 28 | Combien de choses au lancement | Q113–Q116 |
| 29 | Les nombres exacts à choisir | Q117–Q119 |

**Total : 119 questions.**

---

# 1. Comment se passe une partie

### Q1. Combien de temps vit le héros avant de mourir
*[IMPORTANT - à décider avant le GDD]*

Dans ton jeu, le héros avance sur une ligne, se bat tout seul contre des monstres, et un jour il meurt. Ensuite on recommence. Une "vie", c'est le temps entre le moment où il apparaît et le moment où il meurt.

- [ ] (a) Court : 3 à 6 minutes. Il meurt, on recommence vite. Plusieurs vies en 20 minutes.
- [ ] (b) Moyen : 8 à 12 minutes. Le but de chaque vie, c'est d'arriver au prochain boss.
- [ ] (c) Long : 15 à 20 minutes par vie.
- [x] (d) Pas de durée fixe : ça dure tant que le joueur survit.
- [ ] (e) Ça dépend : court au début du jeu, de plus en plus long quand on progresse.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** (d)

### Q2. Le moment "waouh" d'une vie
*[IMPORTANT - à décider avant le GDD]*

Chaque vie du héros doit avoir un moment fort qui donne envie de recommencer.

- [x] (a) Aller plus loin que son record de distance précédent.
- [ ] (b) Réussir à tuer le boss de la zone.
- [ ] (c) Trouver un objet rare qui brille.
- [ ] (d) Débloquer un nouveau point de départ (tous les 10 km).
- [ ] (e) Gagner assez d'or pour se payer le prochain Rebirth.
- [ ] (f) Gagner un point de talent et débloquer un nouveau pouvoir.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** (a)

### Q3. Le joueur qui ne touche à rien
*[IMPORTANT - à décider avant le GDD]*

On veut que le jeu soit reposant, sans appuyer sur plein de boutons. Mais pour avancer, le héros doit garder le doigt appuyé sur "gauche" ou "droite" pour marcher. Si le joueur ne touche à rien, le héros ne bouge pas et ne gagne rien.

- [ ] (a) Un bouton gratuit "rester ici" : le héros reste sur place, les monstres viennent à lui, il gagne des récompenses.
- [ ] (b) Le héros marche tout seul en aller-retour dans une zone déjà finie (gratuit). Avancer vers du nouveau reste payant.
- [ ] (c) Rien : sans tenir le bouton, aucun gain. On enlève l'idée de "jeu reposant".
- [ ] (d) Le héros continue d'avancer tout seul dans la direction en cours jusqu'à un mur ou la mort.
- [x] (e) Marche automatique gratuite partout, mais deux fois plus lente que si on tient le bouton.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** (e)

### Q4. Ce qu'on voit en premier en ouvrant le jeu
*[IMPORTANT - à décider avant le GDD]*

Quand quelqu'un lance ton jeu, il y a un petit écran de chargement, puis un premier écran.

- [ ] (a) Direct dans le combat, là où on s'était arrêté la dernière fois.
- [x] (b) Un menu d'accueil avec un gros bouton JOUER, la récompense du jour et le pass de saison bien visibles.
- [ ] (c) Le feu de camp (le lieu de repos).
- [ ] (d) Le château (choix du point de départ + Rebirth).
- [ ] (e) Un menu d'accueil très court, puis ça bascule tout seul dans le combat.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** (b)

---

# 2. Les premières minutes et créer son héros

### Q5. Le cadeau de fin de tutoriel
*[IMPORTANT - à décider avant le GDD]*

Quand un nouveau joueur arrive, on lui montre 5 petites bulles d'aide : tenir à droite, le combat se fait tout seul, regarder les nombres de dégâts, ouvrir le sac et équiper un objet, mettre un point de stat. À la fin de ces 5 étapes, on lui donne quelque chose pour l'accrocher.

- [ ] (a) Un beau tas d'or de départ.
- [x] (b) Un familier (petit compagnon) gratuit.
- [ ] (c) Un objet rare garanti.
- [ ] (d) Un pouvoir spécial débloqué tout de suite.
- [ ] (e) Une couleur ou une tenue exclusive pour son héros.
- [ ] (f) Plusieurs petits cadeaux à la fois (un peu d'or + un familier commun).
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** (b)

### Q6. Changer de Guerrier à Mage
*[IMPORTANT - à décider avant le GDD]*

Au tout début, le joueur choisit : Guerrier (tape vite, coups moyens) ou Mage (tape lentement, gros coups). En vrai, c'est l'arme équipée qui décide : une épée = Guerrier, une baguette = Mage.

- [ ] (a) On peut changer tout le temps : dès qu'on met une arme de l'autre type, on change de camp.
- [x] (b) On ne peut changer qu'au feu de camp.
- [ ] (c) Non : le choix du début est fixe jusqu'au prochain Rebirth.
- [ ] (d) On peut changer librement, mais ça vide l'arbre de talents (à re-remplir).
- [ ] (e) On peut changer, mais il y a un petit temps d'attente avant que ça prenne effet.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** (b)

### Q7. La couleur du héros
*[peut attendre plus tard]*

À la création, le joueur choisit une couleur pour son héros. On en donne 4 gratuites, les autres s'achètent plus tard.

- [x] (a) Rien, c'est juste joli, et c'est fixe pour la partie.
- [ ] (b) Juste joli, et on peut la changer quand on veut plus tard.
- [ ] (c) Joli, et ça apparaît aussi à côté de ton nom dans les classements.
- [ ] (d) Joli, et le style des nombres de dégâts s'accorde à la couleur.
- [ ] (e) Pas de couleur à la création : on ajoutera ça plus tard.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** (a)

### Q8. Sauter le tutoriel
*[peut attendre plus tard]*

Certains joueurs connaissent déjà ce genre de jeu et veulent commencer direct.

- [ ] (a) Non, tout le monde fait les 5 étapes une fois.
- [ ] (b) Oui, un bouton "passer" est visible.
- [ ] (c) Le tutoriel est si court (moins d'une minute) qu'on ne met pas de bouton "passer".
- [x] (d) On peut le passer, mais on perd alors le cadeau de fin (Q5).
- [ ] (e) On peut le passer seulement si le compte a déjà joué à un autre jeu du créateur.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** (d)

---

# 3. Les menus et se déplacer dedans

### Q9. Le combat continue-t-il quand on ouvre un menu ?
*[IMPORTANT - à décider avant le GDD]*

Pendant que le héros se bat, le joueur peut ouvrir son sac, ses talents, la boutique. Ces écrans prennent tout l'écran.

- [ ] (a) Le combat se met en pause. Le héros ne prend aucun dégât.
- [x] (b) Le combat continue normalement. Le héros peut mourir pendant que tu regardes ton sac.
- [ ] (c) Le combat continue, mais le héros arrête de taper et récupère juste de la vie.
- [ ] (d) Pause pour les monstres normaux, mais le combat continue si c'est un boss.
- [ ] (e) Le héros recule automatiquement hors de portée tant que le menu est ouvert.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** (b)

### Q10. Aller au château pour faire un Rebirth
*[IMPORTANT - à décider avant le GDD]*

Le "château" est l'écran où on choisit son point de départ et où on fait le Rebirth (recommencer sa partie en plus fort).

- [ ] (a) Par un bouton dans le menu, de n'importe où, à tout moment.
- [ ] (b) Il faut d'abord marcher jusqu'à un feu de camp.
- [ ] (c) Seulement quand le héros est mort.
- [ ] (d) On peut ouvrir le château partout, mais le bouton Rebirth ne marche qu'au feu de camp.
- [ ] (e) Seulement depuis le menu d'accueil (il faut quitter sa partie en cours).
- [x] Autre — j'écris précisément ce que je veux : une zone derrière l'étape 1 de la zone 1, avec un vrai château en pixel 2D où le héros peut entrer. Une fois entré, un menu s'affiche : Rebirth · changer de classe / sous-classe · raids & donjons · boutique du jeu · boutique Robux.

**Ma réponse :** Autre (château physique à visiter derrière la zone 1 ; menu à l'intérieur : Rebirth, classe/sous-classe, raids & donjons, boutique jeu, boutique Robux)

### Q11. Le bouton "retour"
*[peut attendre plus tard]*

Quand plusieurs écrans sont ouverts l'un par-dessus l'autre.

- [x] (a) Ferme juste le dernier écran ouvert, un par un.
- [ ] (b) Ferme tout d'un coup et revient direct au combat.
- [ ] (c) Ça dépend de l'écran où on est.
- [ ] (d) Un appui ferme l'écran courant ; deux appuis rapides ferment tout.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** (a)

---

# 4. Le combat de tous les jours

### Q12. Peut-on fuir un combat déjà commencé ?
*[IMPORTANT - à décider avant le GDD]*

Quand le héros touche un monstre, la bagarre démarre toute seule. Quand le héros n'est pas en train de se battre, il récupère de la vie petit à petit (2% par seconde). Donc reculer, se soigner, puis revenir pourrait être une bonne tactique.

- [ ] (a) Jamais. Une fois lancé, c'est jusqu'à ce que l'un meure. Pareil pour monstres et boss.
- [x] (b) On peut fuir les monstres normaux en s'éloignant, jamais les boss.
- [ ] (c) On peut toujours fuir, mais l'ennemi récupère toute sa vie pendant ce temps.
- [ ] (d) Fuir coûte quelque chose (un peu d'or, ou de la vie).
- [ ] (e) On peut fuir pendant les 3 premières secondes seulement, ensuite c'est verrouillé.
- [ ] (f) On ne "fuit" pas mais on peut reculer : le combat se met en pause tant qu'on tient "reculer", et reprend si on lâche.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** (b)

### Q13. Comment on sait qui va gagner le combat
*[IMPORTANT - à décider avant le GDD]*

Le héros et le monstre se tapent dessus chacun leur tour, tout seuls.

- [x] (a) Calculé coup par coup en direct : le joueur peut changer la fin avec ses pouvoirs.
- [ ] (b) Décidé à l'avance par un calcul (celui qui a le plus de "vie × dégâts" gagne). On regarde l'animation.
- [ ] (c) Coup par coup, mais le joueur ne peut rien faire d'autre que regarder.
- [ ] (d) Calcul d'avance pour les monstres normaux (rapide), coup par coup en direct pour les boss.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** (a)

### Q14. Comment le joueur fait marcher son héros
*[peut attendre plus tard]*

Le héros marche vers l'avant ou vers l'arrière, librement, entre les monstres et entre les zones. La direction est juste visuelle (le héros approche l'ennemi par la gauche ou par la droite) : ça ne change rien aux dégâts, ça ne change pas qui est visé. Il faut choisir les commandes.

- [ ] (a) Toucher le côté gauche ou le côté droit de l'écran.
- [ ] (b) Deux boutons fixes ◀ ▶ en bas de l'écran.
- [x] (c) Au clavier A/D et les flèches, au tactile deux boutons ◀ ▶, à la manette le stick — les trois marchent en même temps.
- [ ] (d) Un seul bouton "avancer" + un petit bouton "demi-tour".
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q15. Se soigner tout seul entre les monstres
*[IMPORTANT - à décider avant le GDD]*

Hors combat, le héros récupère 2% de sa vie chaque seconde. Contre les monstres normaux, le joueur peut donc reculer, attendre, et revenir en pleine forme à chaque fois.

- [x] (a) C'est voulu : les monstres normaux te ralentissent, seuls les boss sont de vrais murs.
- [ ] (b) Non : on baisse la vitesse de soin pour que les monstres normaux tuent les joueurs distraits.
- [ ] (c) Le soin ne marche pas si un monstre est juste à côté, même sans le toucher.
- [ ] (d) Le soin hors combat est lent ; un vrai gros soin ne se fait qu'au feu de camp.
- [ ] (e) Le soin tout seul s'arrête après quelques secondes : on ne remonte jamais à 100% sans feu de camp.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

---

# 5. Les pouvoirs spéciaux

### Q16. Comment on lance un pouvoir
*[IMPORTANT - à décider avant le GDD]*

Le héros a 3 pouvoirs spéciaux (par exemple : un gros coup, un bouclier, un cri de guerre). Après usage, chaque pouvoir doit "recharger" un moment.

- [ ] (a) Le joueur appuie lui-même sur la case du pouvoir (ou une touche Q, W, E au clavier).
- [ ] (b) Ils se lancent tout seuls dès qu'ils sont rechargés.
- [x] (c) Réglage au choix dans les options : tout seul / à la main.
- [ ] (d) À la main, mais un bouton "tout lancer" balance les 3 d'un coup.
- [ ] (e) Mélange : les pouvoirs d'attaque se lancent seuls, ceux de défense et d'interruption sont à la main.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q17. Les pouvoirs quand le joueur ne fait rien
*[IMPORTANT - à décider avant le GDD]*

On veut que le jeu soit jouable tranquillement, sans appuyer sur des boutons.

- [ ] (a) Ils se lancent tout seuls. Mais un joueur qui les place bien s'en sort mieux.
- [ ] (b) Ils ne se lancent jamais. Tant pis, le joueur se bat sans.
- [ ] (c) Ils se lancent tout seuls, sauf pendant les combats de boss (là, c'est à la main).
- [x] (d) Ils se lancent tout seuls dès qu'ils sont prêts ; le joueur peut reprendre la main quand il veut.
- [ ] (e) Un réglage "assistant" (ou un familier) lance les pouvoirs pour toi si tu l'actives.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q18. D'où viennent les 3 pouvoirs
*[IMPORTANT - à décider avant le GDD]*

Le Guerrier et le Mage n'ont pas les mêmes pouvoirs.

- [ ] (a) 3 pouvoirs fixes, toujours les mêmes pour un Guerrier, 3 autres fixes pour un Mage.
- [x] (b) Choisis dans une liste plus grande, débloqués dans l'arbre de talents.
- [ ] (c) 1 pouvoir au début, les 2 autres se débloquent en jouant.
- [ ] (d) Choisis dans une liste, débloqués en trouvant des objets ou des pages spéciales.
- [ ] (e) 3 pouvoirs fixes par sous-classe (donc ils changent au Rebirth 5).
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q19. La petite jauge à remplir avant un pouvoir
*[peut attendre plus tard]*

Dans les dessins, certains pouvoirs ont une jauge qui se remplit d'abord.

- [ ] (a) Elle se remplit avec le temps qui passe pendant le combat.
- [ ] (b) Elle se remplit en tapant et en encaissant des coups.
- [ ] (c) Elle se remplit en tuant des monstres.
- [ ] (d) Elle commence pleine, se vide à l'usage, se recharge hors combat.
- [x] (e) Pas de jauge du tout, juste un temps de recharge après usage.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

---

# 6. Les combats de boss

### Q20. Interrompre la grosse attaque d'un boss
*[IMPORTANT - à décider avant le GDD]*

Un boss prépare parfois une grosse attaque : une barre rouge se remplit. Si le joueur agit à temps, il annule l'attaque. On a retiré "taper l'écran" du combat, donc maintenant une de tes cases de pouvoir se transforme en "TAPE POUR INTERROMPRE" pendant ce moment.

- [x] (a) Pas le bon pouvoir équipé = pas d'interruption possible, on encaisse (et ça fait très mal).
- [ ] (b) Un bouton d'interruption de secours est toujours là, même sans le bon pouvoir.
- [ ] (c) N'importe quel pouvoir peut interrompre.
- [ ] (d) L'interruption se fait toute seule si un de tes pouvoirs est prêt (pas besoin de viser le bon moment).
- [ ] (e) Un des 3 slots de pouvoir est TOUJOURS un "parer/interrompre" imposé.
- [ ] (f) Tes familiers peuvent interrompre à ta place s'ils sont prêts.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q21. Les phases d'un boss
*[peut attendre plus tard]*

Dans les dessins, la barre de vie du boss a des petits ronds. Chaque rond franchi change quelque chose (le boss ajoute une attaque, invoque des monstres...).

- [ ] (a) 2 phases (chaque moitié de sa vie).
- [ ] (b) 3 phases.
- [x] (c) Entre 2 et 4 selon le boss.
- [ ] (d) 1 seule phase pour les boss de zone, 3 pour les gros boss (tous les 100 km).
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q22. Le boss qui s'énerve
*[IMPORTANT - à décider avant le GDD]*

Si le joueur met trop longtemps à tuer le boss, le boss "s'énerve" et tape beaucoup plus fort. Ça évite les combats qui durent une éternité.

- [ ] (a) Il s'énerve au bout de 1 minute 30.
- [ ] (b) Au bout de 3 minutes.
- [ ] (c) Ça dépend du boss.
- [ ] (d) Pas de minuteur : à la place, le boss tape de plus en plus fort petit à petit tout le combat.
- [x] (e) Le minuteur existe seulement en mode Cauchemar.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q23. Les petits monstres invoqués par le boss
*[peut attendre plus tard]*

Certains boss appellent des petits monstres en renfort. Un pouvoir qui touche tout le monde d'un coup permet de les balayer.

- [ ] (a) Ils restent et tapent en plus. C'est plus dur mais faisable.
- [x] (b) On les tue un par un, normalement.
- [ ] (c) Presque impossible sans un pouvoir de zone : c'est fait exprès pour forcer à changer ses pouvoirs.
- [ ] (d) Ils disparaissent tout seuls après quelques secondes.
- [ ] (e) Tes familiers s'en occupent pendant que tu tapes le boss.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q24. Un vrai boss unique tous les 10 km ?
*[IMPORTANT - à décider avant le GDD]*

Trois documents disent des choses différentes. Le vieux plan dit "un boss tous les 10 km". Le code d'aujourd'hui met un boss "passe-partout" tous les 10 km et un gros boss avec un nom seulement tous les 100 km. L'histoire de La Descente veut 12 boss avec un nom et une personnalité, un par couche (donc un tous les 10 km jusqu'à 120 km).

- [ ] (a) 12 boss uniques avec un nom, un par couche, dès le km 10. Après 120 km, ils reviennent en plus fort.
- [ ] (b) Boss "passe-partout" tous les 10 km + les 12 boss nommés seulement tous les 100 km (garder le code actuel).
- [x] (c) 12 boss nommés aux 12 couches + un "gros" boss (version costaud du même) tous les 100 km.
- [ ] (d) Un boss nommé toutes les 2 couches (tous les 20 km), 6 boss au lancement, moins de contenu à faire.
- [x] Autre — j'écris précisément ce que je veux : un boss NOMMÉ tous les 10 km (les 12 personnages de La Descente, qui cyclent au-delà du km 120) + tous les 100 km un BIG BOSS façon boss de raid (mécaniques renforcées, butin dédié).

**Ma réponse :** (c) + précision : le boss des 100 km est un "big boss / boss de raid", pas juste une version gonflée.

---

# 7. Devenir plus fort en montant de niveau

### Q25. Comment montent les stats du héros
*[IMPORTANT - à décider avant le GDD]*

Le héros a 5 stats : Force, Magie, Vie, Vitesse, Chance. Avant, le joueur plaçait 5 points où il voulait à chaque niveau. Maintenant on a décidé que les stats montent toutes seules à chaque niveau, selon un tableau qui dépend de la classe. Mais ce tableau n'existe pas encore.

- [ ] (a) 5 points par niveau, répartis selon des pourcentages (ex. Guerrier : 40% Force, 40% Vie, 15% Vitesse, 5% Chance).
- [ ] (b) De plus en plus de points par niveau, au fil du temps.
- [ ] (c) Un chiffre précis par stat et par niveau, écrit à la main.
- [ ] (d) Le joueur choisit un "style" à la création (bagarreur / costaud / rapide) qui fixe les pourcentages.
- [x] (e) Montée automatique de base, mais le joueur oriente quand même un peu (ex. 1 point libre sur 5).
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q26. Y a-t-il un niveau maximum ?
*[IMPORTANT - à décider avant le GDD]*

Le monde va très loin (jusqu'à 120 km, puis ça boucle). Plus on avance, plus les monstres sont forts. Le héros monte de niveau en les tuant.

- [ ] (a) L'infini : tant qu'il avance, il monte.
- [ ] (b) Pas de mur, mais après un certain niveau (genre 200) il faut énormément de monstres pour un seul niveau.
- [ ] (c) Un niveau maximum ferme (genre 500) qui pousse à faire un Rebirth.
- [ ] (d) Le niveau max = la distance atteinte (km × 10) : il monte avec l'exploration.
- [x] (e) Un mur qui monte avec le nombre de Rebirths (ex. 100 + 20 par Rebirth).
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q27. La quantité d'expérience pour changer de niveau
*[IMPORTANT - à décider avant le GDD]*

Dans le code : passer du niveau 1 au 2 demande 44 points d'expérience. Du 10 au 11 : 260. Du 50 au 51 : 5140. Un monstre donne environ 10 points d'expérience.

- [ ] (a) On garde cette formule telle quelle.
- [ ] (b) On la garde, mais je veux tester en jouant avant de valider.
- [ ] (c) Je veux une montée plus lente (chaque niveau plus long à atteindre).
- [ ] (d) Montée très rapide sur les 5 premiers niveaux, puis normale.
- [x] Autre — j'écris précisément ce que je veux :chaque niveau demande 35 % de l’XP du niveau précédent en plus

**Ma réponse :** _____

### Q28. Guerrier et Mage montent-ils pareil ?
*[peut attendre plus tard]*

Le tableau de montée dépend de la classe. Un Guerrier attaque avec la Force, un Mage avec la Magie.

- [ ] (a) Tout pareil, sauf Force pour l'un et Magie pour l'autre.
- [ ] (b) Le Guerrier gagne plus de Vie, le Mage gagne plus de Chance.
- [x] (c) Chaque classe a son propre tableau, à régler stat par stat.
- [ ] (d) Pareil au début ; les différences n'apparaissent qu'avec les sous-classes.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

---

# 8. Les points bonus, les talents et les sous-classes

### Q29. Combien de points bonus on gagne par activité
*[IMPORTANT - à décider avant le GDD]*

En plus des stats qui montent toutes seules, le joueur gagne des "points bonus" en faisant des choses : finir des missions, le Donjon du Jour, découvrir de nouveaux monstres, battre un boss pour la première fois. Le joueur place ces points où il veut dans les 5 stats. Ils restent pour toujours, même après un Rebirth.

- [x] (a) Mission = 1 point. Donjon du Jour = 2. Nouveau monstre = 1. Premier boss d'une zone = 3. Nouvelle zone = 2. Sans limite.
- [ ] (b) Mêmes chiffres, mais avec une limite globale (genre 1000 points). Au-delà, ça donne de l'or.
- [ ] (c) Plus le joueur en a, plus les suivants sont durs à gagner.
- [] (d) Un seul gros paquet par jour (ex. 5 points/jour quoi que tu fasses), pour éviter le farm.
- [ ] (e) Points seulement pour les exploits (battre un boss, atteindre une couche), rien pour les missions répétables.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q30. Est-ce qu'on peut en avoir beaucoup trop ?
*[IMPORTANT - à décider avant le GDD]*

Ces points restent pour toujours et s'ajoutent à chaque partie. Sur plusieurs mois, un joueur pourrait avoir des centaines de points et devenir énorme partout : Vitesse au maximum, Vie gigantesque, etc.

- [ ] (a) Non, c'est un problème acceptable : c'est la récompense des joueurs fidèles.
- [ ] (b) Oui : on met une limite pour que ça reste raisonnable.
- [x] (c) Le mode Cauchemar devient plus dur en même temps, donc ça s'équilibre tout seul.
- [ ] (d) Pas de limite, mais les tout derniers points coûtent une fortune (le rythme s'effondre).
- [ ] (e) Au-delà d'un seuil, les points deviennent des récompenses jolies (titres, effets), pas de la puissance.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q31. Changer ses points de place
*[peut attendre plus tard]*

Le joueur a mis ses points dans la Force, mais il veut finalement les mettre dans la Vie.

- [ ] (a) Gratuit, au feu de camp.
- [ ] (b) Gratuit, mais une seule fois par jour.
- [x] (c) Ça coûte de l'or, ou des Robux.
- [ ] (d) Gratuit toujours, de partout.
- [ ] (e) Gratuit au feu de camp, plus les 3 premiers changements de la partie gratuits partout.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q32. Les pouvoirs qu'on perd au Rebirth
*[IMPORTANT - à décider avant le GDD]*

Les "talents" sont un arbre où on gagne 1 point tous les 5 niveaux. Certains talents débloquent tes pouvoirs. Au Rebirth, on repart niveau 1 et l'arbre se vide. Donc juste après un Rebirth, le héros n'a plus aucun pouvoir tant qu'il n'a pas re-atteint les niveaux 5, 10, 15.

- [ ] (a) C'est voulu : on re-débloque ses pouvoirs en remontant les niveaux.
- [ ] (b) Non : on garde ses 3 pouvoirs équipés, seul le reste de l'arbre se vide.
- [ ] (c) On offre le 1er pouvoir au niveau 1 après un Rebirth, les 2 autres se re-débloquent.
- [ ] (d) Les talents ne se vident PAS au Rebirth : ils deviennent permanents comme les points bonus.
- [x] (e) Au Rebirth, le joueur choisit : garder ses talents OU les échanger contre un bonus.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q33. Ce que change une sous-classe
*[IMPORTANT - à décider avant le GDD]*

Après 5 Rebirths, le joueur choisit une "sous-classe". Guerrier : Berserker (Force + Vitesse) ou Gardien (Vie + Force). Mage : Destructeur (Magie + Chance) ou Sage (Magie + Vie). On peut re-choisir aux Rebirths 10, 15, 20...

- [ ] (a) Juste la façon dont les stats montent toutes seules (le tableau de la Q25).
- [ ] (b) Le tableau des stats, ET ça débloque des pouvoirs en plus.
- [ ] (c) Le tableau des stats, ET un effet spécial (ex. Berserker : plus de dégâts quand il a peu de vie).
- [x] (d) Le tableau des stats, un pouvoir, ET un look différent pour le héros.
- [ ] (e) Ça change carrément la façon de jouer (ex. Gardien renvoie des dégâts, Sage soigne les familiers).
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q34. Avant le 5e Rebirth, pas de sous-classe
*[peut attendre plus tard]*

Un joueur qui vient de commencer (entre 0 et 4 Rebirths) n'a pas encore de sous-classe.

- [x] (a) Ses stats montent avec un tableau "Guerrier de base" ou "Mage de base", neutre.
- [ ] (b) Il choisit une sous-classe provisoire dès le début.
- [ ] (c) Ses stats montent un peu moins vite tant qu'il n'a pas de sous-classe.
- [ ] (d) La 1ère sous-classe se débloque bien plus tôt (Rebirth 1 ou 2).
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

---

# 9. Le Rebirth (recommencer plus fort)

### Q35. Ce qu'on garde et ce qu'on perd au Rebirth
*[IMPORTANT - à décider avant le GDD]*

Le Rebirth = recommencer sa partie pour devenir plus fort sur la durée. On garde : objets, familiers, points de départ débloqués. On perd : niveau, stats du niveau, or, distance.

- [x] (a) Confirmé, c'est exactement ça.
- [ ] (b) Pareil, mais je veux aussi garder l'or.
- [ ] (c) Pareil, mais je veux aussi garder la distance atteinte.
- [ ] (d) Pareil, mais on repart niveau 5 au lieu de niveau 1.
- [ ] (e) Le joueur choisit UNE chose à garder en plus (or OU distance OU un peu de niveau).
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q36. Repartir de loin après un Rebirth
*[IMPORTANT - à décider avant le GDD]*

Tous les 10 km, le joueur débloque un point de départ. On garde ces points après un Rebirth. Mais après un Rebirth, on est niveau 1. Un niveau 1 qui va direct au km 120 se fait tuer en une seconde.

- [ ] (a) Oui, choix libre, même si c'est du suicide (jeu libre).
- [ ] (b) Non : après un Rebirth, on repart forcément du km 0.
- [x] (c) On peut partir de plus loin, mais pas au-delà de la moitié de son record.
- [ ] (d) On garde les points de départ, mais ils se "réactivent" un par un en re-jouant (vite).
- [ ] (e) On peut partir de loin, mais le héros arrive avec un bouclier temporaire le temps de s'adapter.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q37. Les récompenses des Rebirths 15 et 20
*[IMPORTANT - à décider avant le GDD]*

Il y a une récompense spéciale tous les 5 Rebirths. Rebirth 5 : choisir sa sous-classe. Rebirth 10 : un 4e emplacement de familier. Rebirths 15 et 20 : pas encore décidés.

- [ ] (a) Rebirth 15 : garder l'arbre de talents complet malgré le Rebirth. Rebirth 20 : un point de départ offert plus loin.
- [ ] (b) Un emplacement d'objet en plus, ou un familier de plus.
- [ ] (c) Un bonus permanent de gain d'or ou d'expérience.
- [ ] (d) Rebirth 15 : deux sous-classes actives en même temps. Rebirth 20 : un 4e pouvoir.
- [ ] (e) Le déblocage d'un mode de jeu (un donjon spécial, un boss caché).
- [ ] Autre — j'écris précisément ce que je veux :Rebirth	Fonctionnalité majeure
R15	🌳 Arbre de talents avancé — débloque une nouvelle branche de talents avec des choix beaucoup plus puissants et spécialisés. et persiste même après la mort
R20	🌀 Donjon dimensionnel — nouveau mode de jeu avec plusieurs niveaux de difficulté, boss exclusifs et récompenses uniques.
R25	⚔️ Double spécialisation — permet d'équiper 2 sous-classes simultanément et de créer des builds hybrides.
R30	👑 Système de maîtrise — chaque arme, sous-classe ou style de combat peut être maîtrisé. Plus tu l'utilises, plus tu débloques des capacités et bonus spécifiques.

**Ma réponse :** _____

### Q38. Le bonus donné par chaque Rebirth
*[peut attendre plus tard]*

Chaque Rebirth rend le joueur un peu plus efficace. On a dit : +25% d'expérience par Rebirth, plus un bonus sur les stats qui montent avec le niveau.

- [ ] (a) +10% d'efficacité des points par Rebirth (au Rebirth 3, points 30% plus forts).
- [ ] (b) +25%, comme l'expérience.
- [ ] (c) Je veux tester en jouant avant de choisir.
- [x] (d) Un bonus qui grossit : +10% au R1, +12% au R2, +14% au R3... (ça accélère).
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

---

# 10. Le mode difficile (Cauchemar)

### Q39. Comment on débloque le mode Cauchemar
*[peut attendre plus tard]*

Chaque zone a un mode plus dur : Cauchemar I, puis II, III... Les monstres tapent plus fort mais donnent de meilleures récompenses. Pour Cauchemar I sur une zone, on a dit qu'il faut tuer le boss de cette zone 100 fois. Il y a aussi une porte globale : battre le boss de la couche 6 une fois.

- [x] (a) 100 kills du boss pour Cauchemar I, puis environ 25 de plus par palier suivant.
- [ ] (b) 50 kills, c'est suffisant.
- [ ] (c) Plus de 100 kills.
- [ ] (d) Pas basé sur les kills : basé sur le fait d'avoir fini la couche avec un certain niveau ou équipement.
- [ ] (e) Une seule grande porte (boss couche 6) débloque le Cauchemar I partout d'un coup.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q40. De combien les monstres deviennent plus forts en Cauchemar
*[IMPORTANT - à décider avant le GDD]*

À chaque palier de Cauchemar, les monstres de la zone deviennent plus forts, et les récompenses (or, expérience, points bonus, chances d'objets rares) montent aussi. Personne n'a choisi de combien.

- [ ] (a) Monstres ×2 (vie et dégâts), récompenses ×1,8, meilleures chances d'objets rares.
- [x] (b) Monstres ×3, récompenses ×2,5, chances d'objets inchangées (c'est la quantité qui compte).
- [ ] (c) Tout ×1,5 par palier (des deux côtés).
- [ ] (d) Monstres ×2,5, récompenses ×2, ET les monstres gagnent une nouvelle capacité méchante.
- [ ] (e) Le joueur règle la difficulté avec un curseur, les récompenses suivent automatiquement.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q41. Jusqu'où va le Cauchemar
*[peut attendre plus tard]*

Cauchemar I, II, III... ça pourrait continuer sans fin.

- [x] (a) Infini, pour les joueurs très accros.
- [ ] (b) Ça s'arrête à Cauchemar V, ou X.
- [ ] (c) Infini, mais les récompenses arrêtent d'augmenter après un moment (juste pour la fierté).
- [ ] (d) Ça s'arrête à Cauchemar III au lancement, on en rajoute dans les mises à jour.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q42. Le Cauchemar et la vieille idée "Ascension"
*[IMPORTANT - à décider avant le GDD]*

Dans les vieux plans, il y avait "l'Ascension" : tous les 10 Rebirths, choisir un changement permanent du monde (monstres +50% de vie mais objets +100%). Maintenant on a le mode Cauchemar. Les deux idées se ressemblent beaucoup.

- [x] (a) On oublie l'Ascension : le Cauchemar la remplace complètement.
- [ ] (b) On garde les deux : Cauchemar zone par zone, Ascension pour un grand choix global tous les 10 Rebirths.
- [ ] (c) On garde le nom "Ascension" mais avec les règles du Cauchemar.
- [ ] (d) L'Ascension devient un petit choix mineur ; le Cauchemar est la vraie difficulté.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q43. Farmer le Cauchemar en laissant le jeu tourner
*[IMPORTANT - à décider avant le GDD]*

On a dit que farmer le Cauchemar en laissant le jeu tourner tout seul est autorisé. Mais il faut tenir un bouton pour que le héros marche (voir Q3).

- [ ] (a) Même solution que la Q3, on applique la même chose ici.
- [x] (b) En mode Cauchemar seulement, le héros avance tout seul.
- [ ] (c) On retire l'idée : il faut tenir le bouton, même en Cauchemar.
- [ ] (d) Le Cauchemar se joue dans une petite arène fixe : pas de marche, les monstres arrivent en vagues.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

---

# 11. La vitesse du jeu

### Q44. Ce que la vitesse rapide change
*[IMPORTANT - à décider avant le GDD]*

Un réglage permet d'accélérer tout le jeu (×1,5 ou ×2). Le héros marche plus vite, les combats vont plus vite, mais les monstres aussi. On ne gagne aucune puissance, juste du temps.

- [x] (a) Tout est accéléré pareil (marche, combats, recharges de pouvoirs, soin). Comme si l'horloge tournait plus vite.
- [ ] (b) Seule la marche est accélérée, les combats restent normaux.
- [ ] (c) Marche + combats accélérés, mais les pouvoirs gardent leur vraie durée de recharge (donc on en lance moins par combat).
- [ ] (d) Le joueur choisit dans les options ce qui est accéléré.
- [ ] (e) Tout est accéléré SAUF les récompenses : l'or et l'expérience par minute restent comme en ×1.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q45. Le ×2 gratuit contre le ×2 payant
*[IMPORTANT - à décider avant le GDD]*

Le ×2 est gratuit une fois qu'on a battu le boss de la couche 12. Mais on le vend aussi contre des Robux pour ceux qui n'y sont pas encore.

- [ ] (a) Le pass Robux donne le ×2 tout de suite, sinon il faut finir la couche 12. Les deux mènent au même ×2.
- [x] (b) Le pass Robux donne même un ×3 que les joueurs gratuits n'ont jamais.
- [ ] (c) Pas de ×2 payant du tout : seulement gagné en jeu.
- [ ] (d) Le pass payant donne le ×2 tout de suite ET reste utile après (petit bonus de confort en plus).
- [ ] (e) Le ×2 est gratuit pour tout le monde dès le début, on ne le vend pas.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q46. La vitesse et le Donjon du Jour
*[peut attendre plus tard]*

Le Donjon du Jour est une course chronométrée, la même pour tous ce jour-là. Si certains ont le ×2 et d'autres non, les temps ne sont pas comparables.

- [x] (a) Le Donjon force tout le monde en ×1, pas de vitesse rapide dedans.
- [ ] (b) Le Donjon force tout le monde en ×2 (donc le pass vitesse ne donne aucun avantage ici).
- [ ] (c) La vitesse est autorisée, tant pis, le classement récompense quand même.
- [ ] (d) Deux classements séparés : un "vitesse ×1", un "vitesse libre".
- [ ] (e) Le classement compte le temps "de jeu" et pas le temps réel, donc la vitesse ne change rien au score.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

---

# 12. Les objets et le sac

### Q47. Quand le sac est plein et qu'un boss lâche un objet
*[IMPORTANT - à décider avant le GDD]*

Le sac a 100 places. Quand il est plein, les nouveaux objets sont refusés. Un boss ne lâche qu'un seul objet, et seulement quand on le tue.

- [ ] (a) L'objet du boss est perdu, message "sac plein". Tant pis, fallait faire de la place.
- [ ] (b) L'objet du boss force l'entrée en vendant automatiquement ton pire objet non équipé.
- [x] (c) Une fenêtre s'ouvre : "garder (vends un objet) ou jeter le nouveau ?"
- [ ] (d) Les objets de boss ont une place réservée à part, jamais bloquée par le sac plein.
- [ ] (e) Le sac déborde de +5 places temporaires à vider avant de pouvoir continuer.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q48. Le rangement du sac par défaut
*[peut attendre plus tard]*

Quand on ouvre le sac, les objets sont rangés dans un certain ordre.

- [ ] (a) Les plus rares en premier.
- [ ] (b) Les plus puissants en premier.
- [ ] (c) Les plus récents en premier (le dernier ramassé en haut).
- [x] (d) Rangés par emplacement (toutes les armes, puis tous les casques...).
- [ ] (e) Rangés par set (les pièces qui vont ensemble, côte à côte).
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q49. La fusion coûte-t-elle de l'or ?
*[peut attendre plus tard]*

La fusion transforme plusieurs copies du même objet en une version plus rare (3 communs → 1 rare). Aujourd'hui c'est gratuit, ça coûte juste les objets.

- [ ] (a) Gratuit, ça coûte seulement les objets.
- [ ] (b) Ça coûte aussi un peu d'or (petit montant).
- [x] (c) Ça coûte de l'or, de plus en plus cher selon la rareté visée.
- [ ] (d) Gratuit, mais une limite de fusions par jour, sauf si on paie.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q50. Changer d'arme = changer de classe en plein combat
*[IMPORTANT - à décider avant le GDD]*

Équiper une épée fait de toi un Guerrier, une baguette un Mage. Tes talents et tes pouvoirs sont ceux de ta classe. Si tu changes d'arme au milieu d'une partie, tes talents ne correspondent plus.

- [ ] (a) Un message d'avertissement clair avant de valider ("tu vas perdre l'accès à tes pouvoirs Guerrier").
- [x] (b) Interdit de changer de type d'arme hors du feu de camp.
- [ ] (c) Autorisé sans prévenir, le joueur se débrouille.
- [ ] (d) Le jeu garde deux jeux de talents séparés (un Guerrier, un Mage) et bascule tout seul.
- [ ] (e) Autorisé, mais tous les pouvoirs se rechargent à fond (petit temps mort).
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q51. Le "niveau" affiché sur un objet
*[peut attendre plus tard]*

Chaque objet montre un niveau (ex. "Lv. 100"), celui du boss d'où il vient. Ce niveau ne sert à rien dans les calculs, c'est juste une indication. Un objet Lv. 400 marche très bien sur un héros niveau 1.

- [ ] (a) On l'affiche comme aujourd'hui (petit, à côté du nom).
- [x] (b) On l'affiche gros, pour aider à comparer vite.
- [ ] (c) On le cache complètement (ça embrouille plus qu'autre chose).
- [ ] (d) On le remplace par un mot ("vieux / récent / tout neuf") relatif à ta progression.
- [ ] (e) On le remplace par la zone d'origine ("Couche 4").
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

---

# 13. Les familiers

### Q52. Combien de familiers différents au lancement
*[IMPORTANT - à décider avant le GDD]*

Avant on prévoyait 40 familiers "fées". Maintenant chaque familier est une mini-version d'un monstre. Donc le nombre de familiers dépend du nombre de monstres et boss (environ 3-4 monstres par couche × 12 couches + 12 boss ≈ 50-60).

- [ ] (a) Un familier pour CHAQUE monstre et boss (~50-60).
- [ ] (b) Un familier seulement pour les boss (~12-15). Plus simple, plus prestigieux.
- [x] (c) Un familier par monstre normal + une version "dorée" spéciale pour chaque boss.
- [ ] (d) On garde ~40, on ne fait pas un familier pour tous les monstres.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q53. Le rôle d'un familier (attaque / bouclier / soin)
*[IMPORTANT - à décider avant le GDD]*

Chaque familier a un rôle fixe. On a dit que le rôle dépend de la "famille" du monstre : les bêtes attaquent, les golems/blindés protègent, les fantômes soignent.

- [ ] (a) Confirmé : le rôle est fixé par la famille (bêtes = attaque, blindés = bouclier, fantômes = soin).
- [ ] (b) Le rôle est écrit sur chaque familier individuellement (pas de règle par famille).
- [] (c) Le joueur choisit le rôle de chaque familier.
- [ ] (d) Chaque familier peut faire 2 rôles, le joueur choisit lequel est actif.
- [ ] (e) Le rôle dépend de la rareté (commun = attaque, rare = bouclier, épique+ = soin).
- [ ] Autre — j'écris précisément ce que je veux : chaques famillier peut tomber en soit heal soit dps soit tank mais le type de famille rentra le pet plus fort donc bete tombé en dps sera le meilleur choix que si j'avais une bete heal 

**Ma réponse :** _____

### Q54. Le familier qui soigne : en combat ou seulement au repos ?
*[IMPORTANT - à décider avant le GDD]*

Un document dit que le familier soigneur ne soigne QUE quand on est au feu de camp. Un autre (les dessins du combat de boss) dit qu'il soigne PENDANT le combat. Les deux ne sont pas d'accord.

- [x] (a) Le soigneur soigne pendant les combats (utile contre les boss).
- [ ] (b) Le soigneur ne soigne qu'au feu de camp (soin de combat = trop fort).
- [ ] (c) Le soigneur soigne peu en combat, beaucoup au feu de camp.
- [ ] (d) Le soigneur soigne en combat, mais seulement contre les boss, pas les monstres normaux.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q55. Jouer sans aucun familier
*[peut attendre plus tard]*

On peut équiper jusqu'à 3 familiers (4 après le Rebirth 10). Un nouveau joueur n'en a aucun.

- [ ] (a) Le combat marche très bien sans familier, ils sont un bonus.
- [ ] (b) Le jeu prête un familier commun de base tant qu'on n'en a pas.
- [ ] (c) Sans familier, le héros a un petit malus (les familiers sont attendus).
- [x] (d) Le cadeau de fin de tutoriel est justement un premier familier (voir Q5).
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q56. Le pouvoir déclenché d'un familier
*[peut attendre plus tard]*

On a dit que chaque familier a un effet permanent (toujours actif) PLUS un petit pouvoir qui se déclenche de temps en temps.

- [ ] (a) Le pouvoir du familier se déclenche tout seul quand il est prêt.
- [ ] (b) Le joueur déclenche le pouvoir du familier à la main (encore des boutons).
- [x] (c) Pas de pouvoir déclenché, juste l'effet permanent (plus simple).
- [ ] (d) Le pouvoir se déclenche dans des situations précises (soin quand tu es bas, bouclier quand un boss charge).
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

---

# 14. Le Codex (la collection de monstres)

### Q57. À quoi sert le Codex
*[IMPORTANT - à décider avant le GDD]*

Le Codex est un carnet qui se remplit tout seul : chaque monstre tué y ajoute une carte avec un dessin, une phrase d'histoire, et un petit bonus permanent (+0,5% de dégâts contre cette famille de monstres).

- [ ] (a) Confirmé : +0,5% de dégâts par carte, contre la famille du monstre.
- [x] (b) Le bonus est plus gros mais se débloque seulement quand toute une famille est complète.
- [ ] (c) Pas de bonus de puissance : juste des récompenses (or, points bonus, cosmétiques) aux paliers de complétion.
- [] (d) Bonus de +0,5%, mais qui s'applique à TOUT (pas seulement contre cette famille).
- [ ] (e) Chaque découverte donne des points bonus (voir Q29), pas un bonus permanent caché.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q58. "Découvrir" un monstre = le voir ou le tuer ?
*[peut attendre plus tard]*

- [ ] (a) Il faut le tuer une fois.
- [ ] (b) Le voir apparaître suffit.
- [ ] (c) Le voir = carte à moitié révélée ; le tuer = carte complète + bonus.
- [x] (d) Il faut le tuer 10 fois pour la carte complète.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q59. Le bonus par famille a-t-il une limite ?
*[peut attendre plus tard]*

Il y a 5 familles. Chaque carte donne +0,5%. Avec des dizaines de monstres, ça peut monter haut.

- [x] (a) Pas de limite, ça récompense la collection.
- [ ] (b) Limité à +10% par famille.
- [ ] (c) Chaque famille compte au maximum 10 cartes utiles pour le bonus.
- [ ] (d) Le bonus diminue par carte (première +0,5%, dixième +0,1%...).
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q60. L'onglet "Objets" du Codex
*[peut attendre plus tard]*

En plus des monstres, le Codex a un onglet qui liste les objets.

- [ ] (a) Chaque objet vu au moins une fois y apparaît, avec sa provenance.
- [ ] (b) Seulement les objets que tu possèdes en ce moment.
- [x] (c) Tous les objets du jeu, en silhouette tant que pas trouvés (montre ce qui reste à chercher).
- [ ] (d) Pas d'onglet objets au lancement.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

---

# 15. L'or et les boutiques

### Q61. L'or quand on a déjà tout acheté
*[IMPORTANT - à décider avant le GDD]*

On gagne de l'or tout le temps en tuant des monstres. Les boutiques vendent des armes et armures, mais au bout d'un moment on a mieux (grâce aux boss). Le seul truc qui coûte de l'or sans fin, c'est le Rebirth (de plus en plus cher).

- [ ] (a) Le Rebirth suffit : c'est un coût sans fin qui grimpe tout seul.
- [ ] (b) On ajoute des achats en or pour toujours : décorations du feu de camp, couleurs, un peu d'or à chaque fusion et chaque changement de points.
- [ ] (c) On peut échanger de l'or contre des paliers de Cauchemar ou de meilleures chances d'objets.
- [ ] (d) On ajoute une boutique "de luxe" au feu de camp qui vend des objets au hasard, très chers.
- [ ] (e) L'or sert à "améliorer" un objet qu'on aime pour le garder à jour.
- [x] Autre — j'écris précisément ce que je veux : b+c+d+e

**Ma réponse :** _____

### Q62. Pas de boutique avant le km 50
*[peut attendre plus tard]*

La première boutique est au km 50. Donc pour les 4 premiers boss (km 10 à 40), le joueur ne peut pas dépenser son or, il ne fait que ramasser des objets.

- [ ] (a) C'est OK, la boutique à km 50 c'est très bien.
- [ ] (b) On met une petite boutique dès le km 10.
- [ ] (c) On met une boutique tous les 20 km au lieu de 50.
- [x] (d) Avant le km 50, un marchand ambulant apparaît parfois au hasard.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q63. Comment les boutiques renouvellent leur stock
*[peut attendre plus tard]*

Chaque boutique vend 5 objets. On a dit qu'elles se mettent à jour quand le joueur progresse.

- [ ] (a) Le stock se met à jour dès que le joueur atteint une nouvelle zone.
- [ ] (b) Le stock change tous les jours (vrai jour).
- [x] (c) Le joueur peut payer un peu d'or pour renouveler le stock tout de suite.
- [ ] (d) Le stock est fixe par boutique (les mêmes 5 objets pour toujours).
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q64. Les nombres qui gonflent avec le temps
*[IMPORTANT - à décider avant le GDD]*

Plus on avance, plus les monstres donnent d'or. Le prix du Rebirth, lui, double presque à chaque fois. Il faut que les deux restent à peu près synchro, sinon le Rebirth devient soit gratuit, soit impossible.

- [ ] (a) On vérifie en jouant que "gagner de quoi payer le prochain Rebirth" prend toujours à peu près le même temps.
- [ ] (b) Le prix du Rebirth suit automatiquement l'or que tu gagnes (pas une formule fixe).
- [ ] (c) On accepte que le Rebirth devienne "facile" en or avec le temps (le vrai frein, c'est de remonter les niveaux).
- [ ] (d) On plafonne l'or gagné pour éviter que ça explose.
- [x] Autre — j'écris précisément ce que je veux : **[x] Autre — j’écris précisément ce que je veux :**

Je veux que **les gains d’or augmentent fortement à chaque étape de progression**, mais que le **coût du Rebirth augmente toujours plus rapidement que les revenus du joueur**.

Par exemple, si les gains d’or sont multipliés par **2**, le coût du Rebirth pourrait être multiplié par **3**, puis **3,1**, **3,4**, **3,7**, etc. Le multiplicateur du Rebirth doit donc progressivement prendre de l'avance sur celui des gains d'or.

L'objectif est que le joueur ait **toujours un Rebirth à atteindre** : même si ses gains d'or deviennent énormes avec le temps, il ne doit jamais pouvoir accumuler naturellement assez d'or pour payer plusieurs Rebirths d'affilée ou rendre le prochain Rebirth trivial.

Cependant, l'écart doit rester contrôlé afin que le temps nécessaire pour atteindre le prochain Rebirth augmente progressivement sans devenir excessivement long.

**En résumé : les nombres doivent exploser, les gains d'or doivent augmenter rapidement, mais le coût du Rebirth doit toujours rester devant les gains du joueur.**


**Ma réponse :** _____

### Q65. L'or lâché par les boss
*[peut attendre plus tard]*

Quand un boss meurt, une fois sur deux il donne de l'or ou un bonus d'expérience au lieu d'un objet.

- [ ] (a) C'est un gros paquet d'or, une vraie récompense.
- [ ] (b) C'est surtout du bonus d'expérience (aide à remonter les niveaux, surtout après un Rebirth).
- [x] (c) Le joueur choisit : or ou expérience.
- [ ] (d) Ça devient de l'or ET de l'expérience, en plus petit.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

---

# 16. Le feu de camp

### Q66. Ce qu'on fait au feu de camp en solo
*[IMPORTANT - à décider avant le GDD]*

Le feu de camp apparaît tous les 50 km. Plus tard il deviendra un lieu social (voir d'autres joueurs, échanger). Au lancement, c'est solo.

- [ ] (a) On s'y soigne à fond, on change ses talents et ses points gratuitement, on accède à la boutique.
- [ ] (b) Juste un point de repos et de sauvegarde, rien de spécial à faire.
- [ ] (c) Comme (a), plus on y gère ses familiers et ses cosmétiques.
- [ ] (d) Comme (a), plus le tableau des missions et la récompense du jour à récupérer ici.
- [ ] (e) Comme (a), plus un coffre gratuit ou un mini-jeu à chaque passage.
- [x] Autre — j'écris précisément ce que je veux : je veux vraiment le feu de camp comme un lieu de repos, on s'y soigne, on peut changer de classe, faire les dungeon et raid, voir le tableau de mission, gerer les familiers et les cosmetiques, les récompenses a recuprerer, et un gros coffre de cadeau gratuit toutes les heures

**Ma réponse :** _____

### Q67. Le soin au feu de camp
*[peut attendre plus tard]*

- [ ] (a) Soin complet et instantané en arrivant.
- [ ] (b) Soin rapide (quelques secondes) tant qu'on reste.
- [ ] (c) Soin lent : ça encourage à faire autre chose en attendant.
- [ ] (d) Soin complet + un petit bonus temporaire pour les prochains km.
- [x] Autre — j'écris précisément ce que je veux : C+D
**Ma réponse :** _____

### Q68. Où est la boutique
*[peut attendre plus tard]*

Les documents parlent de boutiques "le long du parcours" ET d'une boutique "au feu de camp". Ce n'est pas clair.

- [ ] (a) La boutique EST au feu de camp (tous les 50 km), pas ailleurs.
- [x] (b) Des petites boutiques le long du chemin + une plus grande au feu de camp.
- [ ] (c) Des boutiques séparées le long du chemin ; le feu de camp n'en a pas.
- [ ] (d) Une seule boutique, accessible depuis le menu partout, sans se déplacer.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

---

# 17. Les missions

### Q69. Les types de missions
*[IMPORTANT - à décider avant le GDD]*

Le joueur reçoit 3 missions par jour. Ce sont de petits objectifs ("tue 20 monstres", "avance de 15 km").

- [ ] (a) Objectifs de combat simples (tuer X monstres, tuer un boss, avancer de X km).
- [ ] (b) Comme (a), plus des objectifs variés (utiliser des pouvoirs, équiper un objet rare, faire une fusion).
- [ ] (c) Comme (b), plus une mission "difficile" par jour qui rapporte plus.
- [ ] (d) Des missions qui s'adaptent à où tu en es (un débutant et un vétéran n'ont pas les mêmes).
- [ ] (e) Une chaîne de missions qui se suivent (finis la 1 pour débloquer la 2).
- [x] Autre — j'écris précisément ce que je veux : je veux une chaine de missions avec 10missions par jours 7 facile 2 dur et 1 très dur

**Ma réponse :** _____

### Q70. Empêcher de tricher en laissant le jeu tourner
*[IMPORTANT - à décider avant le GDD]*

Si une mission dit "tue 50 monstres", un joueur pourrait laisser son héros farmer tout seul sans jouer. On veut que les missions demandent une vraie présence.

- [ ] (a) Les missions demandent des actions qu'un joueur inactif ne fait pas (lancer tel pouvoir, battre un boss, atteindre un nouveau lieu).
- [ ] (b) Une mission ne se valide que si le joueur a bougé ou cliqué récemment.
- [x] (c) On s'en fiche : farmer les missions en laissant tourner, c'est OK dans ce genre de jeu.
- [ ] (d) Les récompenses de mission sont petites, donc tricher n'en vaut pas la peine.
- [ ] (e) Les missions sont liées à la progression (avancer, battre des boss) : impossible à farmer sur place.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q71. Chaque combien on change de missions
*[peut attendre plus tard]*

- [ ] (a) 3 nouvelles chaque jour.
- [ ] (b) 3 par jour + 3 par semaine (plus grosses).
- [ ] (c) 3 par jour, plus une "saison" de missions longues en fond.
- [ ] (d) Le joueur garde une mission non finie jusqu'à ce qu'il la termine.
- [x] Autre — j'écris précisément ce que je veux : comme pour la Q69 je veux une chaine de missions de 10 mission par jours, si il ne fini pas en 24h tant pis pour lui il perd les recompense et le bonus pour avoir fini les 10 missions (qui est de quelques point de competence qui reste après le rebirth)
**Ma réponse :** _____

### Q72. Refaire le tirage des missions
*[peut attendre plus tard]*

Si une mission ne plaît pas, on peut la remplacer par une autre.

- [x] (a) 1 changement gratuit par jour.
- [ ] (b) 1 gratuit, les suivants coûtent de l'or.
- [ ] (c) Changements illimités et gratuits.
- [ ] (d) Changement contre Robux seulement.
- [ ] (e) Pas de changement possible, on fait avec.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

---

# 18. Le Donjon du Jour

### Q73. Ce qu'il y a dans le Donjon du Jour
*[IMPORTANT - à décider avant le GDD]*

Chaque jour, un mini-parcours de 5 salles + 1 boss, le même pour tous les joueurs ce jour-là, à finir le plus vite possible. Dure environ 4 minutes.

- [ ] (a) 5 salles de monstres + 1 boss, tirés au hasard parmi le contenu déjà existant.
- [ ] (b) Comme (a), plus des salles à défi (pas de soin, dégâts ×2...) pour pimenter.
- [ ] (c) Comme (a), plus des petits coffres optionnels qui coûtent du temps (risque contre récompense).
- [ ] (d) Un boss unique "du donjon" qu'on ne trouve nulle part ailleurs.
- [ ] (e) Un thème par jour (jour des bêtes, jour des morts-vivants...).
- [x] Autre — j'écris précisément ce que je veux :**Ma réponse :**

Je veux combiner **A + B + C + E + D**.

Le donjon sera composé de **5 salles de monstres suivies d’un boss**, avec des ennemis tirés aléatoirement parmi le contenu déjà disponible.

En plus de ces salles classiques, certaines salles pourront proposer des **défis avec des règles spéciales** (absence de soin, dégâts multipliés, ennemis renforcés, etc.) afin de rendre chaque run différent.

Le joueur pourra également trouver des **petits coffres optionnels** qui demandent un investissement en temps ou présentent un risque, avec des récompenses plus intéressantes en contrepartie.

Un **thème différent pourra être appliqué chaque jour** (bêtes, morts-vivants, etc.), modifiant les ennemis et/ou les récompenses disponibles dans le donjon.

Enfin, le donjon aura à terme un **boss unique exclusif**, qui ne pourra être rencontré nulle part ailleurs. Les assets spécifiques à ce boss seront créés ultérieurement, lorsque le reste du contenu sera suffisamment avancé.

L'objectif est que le donjon soit **rejouable, imprévisible et progressivement enrichi**, plutôt qu'un simple parcours identique à chaque tentative.

**Ma réponse :** _____

### Q74. La récompense garantie du Donjon
*[IMPORTANT - à décider avant le GDD]*

Tout le monde qui finit le donjon gagne au moins un objet "Rare ou mieux".

- [ ] (a) 1 objet Rare+ garanti par jour.
- [ ] (b) 1 objet Rare+ + de l'or + de l'expérience.
- [ ] (c) La récompense dépend de ton temps (plus tu es rapide, mieux c'est).
- [ ] (d) 1 objet Rare+ + des points bonus (voir Q29).
- [ ] (e) 1 objet Rare+ + de la monnaie de pass de saison.
- [x] Autre — j'écris précisément ce que je veux :Je veux que le Donjon du Jour fonctionne par étages et par difficulté croissante, plutôt que d'être limité à une seule complétion par jour ou d'être farmable à l'infini.

Le joueur commence le Donjon du Jour à un étage adapté à sa progression. Chaque fois qu'il termine le donjon, il peut choisir de continuer à l'étage suivant, avec une difficulté plus élevée et des récompenses plus importantes.

Plus le joueur monte, plus les ennemis deviennent puissants et plus les récompenses augmentent. Un joueur niveau 400 sera donc naturellement capable d'aller plus loin et plus rapidement qu'un joueur niveau 100, tout en ayant accès à des récompenses supérieures.

Cependant, le joueur doit prendre une décision à chaque étage : continuer pour obtenir de meilleures récompenses ou s'arrêter avant de prendre trop de risques.

Si le joueur meurt dans le donjon, il perd les récompenses des étages qu'il n'a pas sécurisées. Il doit donc apprendre à évaluer sa puissance et décider lui-même jusqu'où il peut aller.

Le système doit créer une véritable boucle de « Risk vs Reward » :

Je gagne → je peux continuer → la difficulté augmente → les récompenses augmentent → je décide de m'arrêter ou de risquer davantage.

Le Donjon du Jour est donc limité dans le temps (un thème/donjon différent chaque jour), mais sa progression en difficulté est potentiellement très élevée, afin que même les joueurs très avancés aient toujours un objectif à dépasser.
**Ma réponse :** _____

### Q75. Une seule tentative qui compte par jour
*[peut attendre plus tard]*

On a dit 1 essai classé par jour.

- [ ] (a) 1 essai classé, mais on peut s'entraîner autant qu'on veut sans que ça compte.
- [ ] (b) 1 seul essai tout court, pas d'entraînement.
- [ ] (c) 3 essais classés, on garde le meilleur.
- [ ] (d) Essais illimités classés, on garde le meilleur temps.
- [x] Autre — j'écris précisément ce que je veux :le joueur a droit a une clé pour rentré par jours, si il reussi le donjon il peut passer a l'etage supperieure etc si il meurt sa clé disparait et ne peux plus retenter sa chance sauf si il récuper d'autre clé via les missions jouralière, raid, fin de boss de donjon etc 

**Ma réponse :** _____

### Q76. Les récompenses du classement du donjon
*[peut attendre plus tard]*

Les meilleurs temps du jour gagnent un truc en plus. On a dit "matériaux cosmétiques" pour le top 100.

- [ ] (a) Des matériaux pour fabriquer des cosmétiques (aucune puissance).
- [ ] (b) De l'or : beaucoup pour le top 10, un peu pour le top 100.
- [ ] (c) Un badge ou un titre "top 10 du jour".
- [ ] (d) De la monnaie de pass de saison.
- [x] Autre — j'écris précisément ce que je veux : je veux les meilleurs temps du jours mais par etage, même si le donjon change par jour garde 7 themes qui restent donc lundi toujours le meme theme mardi aussi mercredi aussi etc etc, pour les top 100 meilleur temps donne de l'xp et de l'or + 1 point de competence qui reste après le rebirth, pour le top 10 donne un titre, (genre champion du dungon X) mais il faut bien garder en tête que imaginons je suis level 400 et que lundi j'arrive a l'etage 50 du donjon du jour, alors lundi prochain pour le même donjon je recommence a l'etage 50 impossible d'aller dans les étages supperieux pour eviter qu'un level 400 vienne chercher le record du level 100 alors que le level 100 n'est pas aussi fort et n'a pas jouer aussi longtemps que le level 400

**Ma réponse :** _____

---

# 19. Les raisons de revenir jouer demain

### Q77. Le contenu de la récompense du jour
*[IMPORTANT - à décider avant le GDD]*

Chaque jour, en ouvrant le jeu, le joueur récupère un cadeau. Plus il vient de jours d'affilée, plus c'est gros, sur un cycle de 7 jours.

- [ ] (a) De l'or, qui augmente jour après jour (jour 7 = gros paquet).
- [ ] (b) Un mélange : or les petits jours, un familier ou un objet rare le jour 7.
- [ ] (c) De la monnaie de pass de saison.
- [ ] (d) Le joueur choisit parmi 3 cadeaux chaque jour.
- [ ] (e) Des points bonus (voir Q29) le jour 7.
- [x] Autre — Je veux un système de récompenses quotidiennes basé sur 7 jours consécutifs, avec une progression claire de la valeur des récompenses. Plus le joueur maintient sa série, plus les récompenses deviennent importantes.

Jour 1
Bonus d'Or + XP pendant 4 heures.
Jour 2
Bonus d'Or + XP pendant 6 heures.
1 clé de Donjon du Jour.
Jour 3
1 familier aléatoire parmi les familiers disponibles dans le contenu actuel du joueur.
Le familier obtenu possède 20 % de puissance totale supplémentaire par rapport au même familier obtenu normalement dans une zone.
Bonus d'Or + XP pendant 6 heures.
Jour 4
Bonus d'Or + XP pendant 6 heures.
2 clés de Donjon du Jour.
Points de Pass de Combat.
Jour 5

Le joueur reçoit toutes les récompenses des jours précédents x2 :

Bonus d'Or + XP pendant 6 heures. x2
2 clés de Donjon du Jour. x2
Points de Pass de Combat. x2
Jour 6 — Set d'équipement

Le joueur reçoit un set d'équipement complet.

Règles du set :

Qualité Épique, jamais supérieure à Épique.
Niveau du set adapté au niveau du joueur.
Le set provient toujours d'une zone située une zone en dessous de la meilleure zone actuellement atteinte par le joueur.
Exemple : si le joueur a atteint la zone 500, il reçoit le set complet du boss de la zone 400.
Le set est toujours complet et contient toutes les pièces nécessaires.
Le joueur pourra ensuite améliorer ce set grâce au système de Fusion lorsqu'il sera disponible.
Le set ne doit donc pas remplacer directement l'équipement de la zone actuelle : il constitue une récompense puissante que le joueur peut ensuite améliorer.

UI du Jour 6 :

Avant le déblocage, l'interface affiche l'image du set en noir/silhouette, comme s'il était encore verrouillé.
Lorsque le joueur atteint le Jour 6 et récupère la récompense, l'image réelle du set est révélée.
Jour 7 — Arme ultime du cycle

Le joueur reçoit une arme spéciale extrêmement puissante, destinée à représenter la récompense finale du cycle de 7 jours.

Règles :

L'arme doit être environ 30 % plus puissante que l'équipement correspondant à la meilleure zone actuellement atteinte par le joueur.
Elle doit être adaptée à la progression du joueur afin de rester intéressante quel que soit son niveau.
Cette arme constitue volontairement une récompense exceptionnelle et doit donner au joueur une sensation de jackpot lorsqu'il termine les 7 jours.
Règle générale du système

Le cycle est conçu pour créer une montée en puissance progressive :

J1 → Boost
J2 → Boost + Donjon
J3 → Familier amélioré + Boost
J4 → Boost + Donjon + Pass
J5 → Récompenses précédentes combinées x2 sauf pour le familier 
J6 → Set Épique complet
J7 → Arme exceptionnelle +30 %

L'objectif est que chaque jour ait une raison d'être, avec une récompense de plus en plus importante et un véritable sentiment d'accomplissement au Jour 7.

**Ma réponse :** _____

### Q78. La série de jours qui se casse
*[peut attendre plus tard]*

On a dit qu'on a 48h de marge avant de perdre sa série.

- [x] (a) 48h de marge, puis retour au jour 1.
- [ ] (b) On ne perd jamais la série, elle avance juste quand on vient.
- [ ] (c) Perdre la série renvoie 3 jours en arrière, pas au jour 1.
- [ ] (d) Un objet (gagné ou acheté) protège la série une fois.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q79. Prévenir le joueur de revenir
*[peut attendre plus tard]*

Roblox ne peut pas envoyer de notification sur le téléphone comme les vraies applis. On a surtout le badge qui clignote dans le jeu, et le système de notifications Roblox (limité).

- [ ] (a) Juste le badge qui clignote quand on relance le jeu.
- [ ] (b) Comme (a), plus les notifications Roblox (l'icône du jeu qui pastille dans l'appli Roblox).
- [ ] (c) Comme (b), plus un rappel Discord pour ceux qui ont rejoint le serveur.
- [x] (d) On ne fait rien de spécial.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q80. Les événements spéciaux
*[peut attendre plus tard]*

Beaucoup de jeux Roblox font des événements limités dans le temps (fêtes, week-ends double or...).

- [x] (a) Aucun au lancement, on en ajoute après.
- [ ] (b) Un petit "week-end double or" prêt dès le lancement.
- [ ] (c) Un événement de lancement (cadeau pour les tout premiers joueurs).
- [ ] (d) Un événement par mois, planifié à l'avance.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

---

# 20. Les classements

### Q81. Quels classements au lancement
*[IMPORTANT - à décider avant le GDD]*

- [ ] (a) Meilleure distance (de tous les temps) + nombre de Rebirths.
- [ ] (b) Comme (a), plus distance "cette saison" (remise à zéro régulièrement).
- [ ] (c) Comme (b), plus le temps du Donjon du Jour.
- [ ] (d) Comme (c), plus un classement "complétion du Codex".
- [ ] (e) Comme (c), plus un classement par couche (le plus loin en Cauchemar sur telle couche).
- [x] Autre — j'écris précisément ce que je veux : je veux meilleure distance all time, nombre de ribirths all time, niveau de difficulté cauchemard all time et roblux spend all time

**Ma réponse :** _____

### Q82. Chaque combien la saison se remet à zéro
*[peut attendre plus tard]*

- [ ] (a) Chaque semaine.
- [ ] (b) Toutes les 8 semaines (comme le pass de saison).
- [ ] (c) Chaque mois.
- [ ] (d) Deux classements : un hebdomadaire, un mensuel.
- [x] Autre — j'écris précisément ce que je veux : le passe de saison chanche tout les 8 semaines mais le top leaderboards reste a vie, 

**Ma réponse :** _____

### Q83. Les récompenses de classement
*[peut attendre plus tard]*

- [] (a) Cosmétiques + un titre à côté du nom.
- [ ] (b) Comme (a), plus de l'or.
- [ ] (c) Comme (a), plus de la monnaie de pass.
- [ ] (d) Juste la fierté, aucune récompense.
- [x] Autre — j'écris précisément ce que je veux, je veux C+B et dans le feu de camp Créer un **podium des meilleurs joueurs**, inspiré du podium olympique, avec **3 statues représentant le Top 3 du classement**.

* **1er place :** statue du joueur Top 1, positionnée sur la marche la plus haute.
* **2e place :** statue du joueur Top 2, positionnée sur la marche intermédiaire.
* **3e place :** statue du joueur Top 3, positionnée sur la marche la plus basse.

Les statues doivent représenter visuellement **l'avatar des joueurs concernés** et le podium doit être mis à jour automatiquement lorsque le classement change.

Le podium doit avoir une apparence prestigieuse et être placé dans une zone visible du jeu afin de donner aux joueurs un **objectif de compétition et de prestige**.

L'apparence du podium doit rappeler clairement celui d'une **cérémonie de remise de médailles**, avec une distinction visuelle évidente entre les trois places.
 mais je veux que le podium soit uniquement pour le top distances

**Ma réponse :** _____

### Q84. Empêcher la triche au classement
*[IMPORTANT - à décider avant le GDD]*

Des tricheurs peuvent essayer de fausser leur distance ou leur temps avec des logiciels.

- [x] (a) Le serveur du jeu vérifie tout (position, temps) et ignore les valeurs impossibles.
- [ ] (b) Comme (a), plus un contrôle humain du top 10 avant de donner les récompenses.
- [ ] (c) Comme (a), plus les scores trop beaux pour être vrais sont mis de côté automatiquement.
- [ ] (d) On accepte que le classement soit un peu "sale", ce n'est pas grave.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

---

# 21. Le Pass de saison

### Q85. Comment on gagne de l'expérience de pass
*[IMPORTANT - à décider avant le GDD]*

Le pass de saison a environ 50 paliers. On monte les paliers en gagnant de l'"expérience de pass" en jouant.

- [ ] (a) On en gagne en faisant à peu près tout (combattre, donjon, missions), à peu près pareil partout.
- [ ] (b) Surtout via les missions du jour et le Donjon du Jour (pas juste en farmant).
- [ ] (c) Un maximum d'expérience de pass par jour, pour que tout le monde reste au même rythme.
- [ ] (d) On en gagne en combattant, mais les missions donnent un gros bonus.
- [x] Autre — j'écris précisément ce que je veux : on peut gagner des points d'xp de passe un peu partout mais la quantité differe, très peu en tuant mob normal, un peu plus boss de fin de zone, encore plus dans les boss de fin de donjon et de raid et enormement a chaques fin de 100 km (uniquement une fois par saison impossible de farmer le boss level 100 quand je suis level 600 pour farmer le pass, idem pour les mobs, si les enemeis sont trop faibles pour moi, aucun gain, le moyen le plus rapide de remplir le passe de saison et de finir les 10 quetes journalières)
**Ma réponse :** _____

### Q86. La monnaie "gemmes / œufs" de la piste gratuite
*[IMPORTANT - à décider avant le GDD]*

Les dessins parlent de "or, œufs, gemmes" comme récompenses du pass. Les œufs et gemmes n'existent pas encore dans le jeu.

- [ ] (a) Pas de nouvelle monnaie : le pass donne de l'or, des familiers, des objets, des cosmétiques. C'est tout.
- [x] (b) On ajoute UNE monnaie premium (gemmes), gagnable un peu gratuitement et achetable en Robux, pour la boutique cosmétique.
- [ ] (c) Les "œufs" = des familiers surprise, pas une monnaie. Pas de gemmes.
- [ ] (d) On ajoute œufs (familiers) ET gemmes (cosmétiques), deux choses différentes.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q87. Ce qu'il y a dans la piste payante
*[peut attendre plus tard]*

La piste premium coûte des Robux (~799). On a dit ~80% cosmétique + un peu de confort.

- [ ] (a) 80% cosmétiques + 20% confort (or bonus, un peu d'expérience).
- [ ] (b) 100% cosmétiques, zéro effet sur le jeu.
- [ ] (c) Cosmétiques + les mêmes récompenses que la piste gratuite, mais en double.
- [ ] (d) Cosmétiques + un familier exclusif de saison.
- [x] Autre — j'écris précisément ce que je veux : la piste premium doit etre basé sur le cosmetique, aucun stuff en + ni op par rapport a la piste gratuit, mais le confort est bien plus attendu en piste premium ( Boost d'xp x3, or x3 chance de loot x3 chance de loot un familier x3 ticket de fusion gratuit + clé de donjon gratuite + potion de instant revive gratuite aussi etc etc tout les bonus d'un rpg)

**Ma réponse :** _____

### Q88. Après le dernier palier
*[peut attendre plus tard]*

Quand on a fini les 50 paliers avant la fin de la saison.

- [ ] (a) Des paliers bonus à l'infini qui donnent juste de l'or.
- [x] (b) Rien, on a fini, on attend la saison suivante.
- [ ] (c) Des paliers bonus qui donnent de la monnaie premium.
- [ ] (d) Un cosmétique "prestige" tous les 10 paliers bonus.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

---

# 22. Ce qu'on achète avec des Robux

### Q89. Le prix des pass de confort
*[IMPORTANT - à décider avant le GDD]*

On vend des "pass" permanents : ×2 or, ×2 expérience, plus de place dans le sac, VIP, avance automatique, vitesse ×2.

- [ ] (a) Pas chers (~50-100 R$ chacun) pour que beaucoup de gens achètent.
- [ ] (b) Prix moyens (~200-400 R$).
- [ ] (c) Chers (~500-800 R$) mais très puissants.
- [ ] (d) Un seul gros pack "tout compris" à ~1000 R$ au lieu de les vendre séparément.
- [x] (e) Mélange : les petits (place de sac) pas chers, les gros (×2 or) chers.
- [] Autre  

**Ma réponse :** (e) — grille validée dans `design/economy/monetization.md` : Grand Sac 149 · ×2 XP 249 · ×2 Or 349 · Pass Vitesse 499 · VIP 699 · Collectionneur 999 · Bundle Ultimate 1799. Pack de Départ 99. Plafonds durs ×3 partout, `max()` jamais empilé.

### Q90. Le pack de départ
*[IMPORTANT - à décider avant le GDD]*

Une offre unique, une seule fois par compte, pour les nouveaux joueurs qui accrochent. Les dessins disent : 199 R$, 5000 or, un familier rare, un set cosmétique complet.

- [ ] (a) On garde exactement ça (199 R$ : or + familier rare + cosmétique).
- [x] (b) Moins cher (~99 R$) avec un peu moins dedans.
- [ ] (c) Plus gros (~299 R$) avec en plus un pass de confort inclus.
- [ ] (d) Le même contenu, mais proposé seulement après le 1er ou le 2e Rebirth (joueur accroché).
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** (b) — 99 R$, 1 seul achat/compte. Contenu : 150 gemmes + boost ×2 tout 24 h + 25 slots sac + 3 clés de donjon + cadre/couleur exclusifs. Apparaît UNE fois, après la fin du tuto ET (km 30 atteint OU login jour 2), jamais au join.

### Q91. La réanimation payante (revive)
*[IMPORTANT - à décider avant le GDD]*

Quand le héros meurt, on propose de le faire revivre sur place contre des Robux (les dessins disent 50 R$), au lieu de recommencer au point de départ.

- [ ] (a) 50 R$, sans limite (on peut revivre autant qu'on veut si on paie à chaque fois).
- [ ] (b) 50 R$, mais une seule fois par vie.
- [ ] (c) Le prix monte à chaque revive dans la même vie (50, puis 100...).
- [ ] (d) Gratuit une fois par jour, payant ensuite.
- [x] (e) Pas de revive payante du tout (la mort fait partie du jeu).
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** (e) au lancement — la revive existe seulement comme OBJET GAGNÉ (récompense 7 jours, missions, pass premium). On rouvre la revive payante (49 R$, 1/run max, sans minuteur) plus tard SI les données montrent un point de rage-quit net.

### Q92. Le coffre surprise
*[IMPORTANT - à décider avant le GDD]*

Un coffre qu'on ouvre contre des Robux (ou une monnaie premium) et qui donne un cosmétique au hasard. Les chances doivent être affichées (obligatoire sur Roblox). Rien dedans ne rend plus fort.

- [ ] (a) Coffre 100% cosmétique, chances affichées, prix ~50-100 R$ l'ouverture.
- [x] (b) Comme (a), plus une règle "au bout de 50 ouvertures sans rare, la 50e est rare garantie".
- [ ] (c) Coffre payable aussi avec de l'or (pas que des Robux).
- [ ] (d) Pas de coffre surprise du tout : on vend chaque cosmétique directement à prix fixe.
- [ ] (e) Un coffre gratuit 1x/jour + des coffres payants en plus.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** (b) — 100% cosmétique, poids réels affichés, pitié à ~20 ouvertures (rare garanti) et ~80 (prestige garanti), ET chaque cosmétique achetable directement en gemmes. Payable en Robux (99 / 449 pour 5+1) ou en gemmes. `PolicyService` vérifié avant affichage.

### Q93. Le ×2 expérience est-il "juste" ?
*[IMPORTANT - à décider avant le GDD]*

La règle qu'on s'est fixée : rien de ce qu'on achète ne doit rendre plus fort, seulement faire gagner du temps ou être joli. Or le ×2 expérience fait monter les niveaux 2 fois plus vite, donc les stats montent 2 fois plus vite. C'est du temps gagné, mais ça ressemble à de la puissance.

- [x] (a) C'est OK : c'est juste plus rapide, un joueur gratuit atteint les mêmes stats au final.
- [ ] (b) On le transforme en "×2 expérience de pass de saison" seulement (pas les niveaux du héros).
- [ ] (c) On le retire : on garde juste ×2 or + le confort.
- [ ] (d) On le garde, mais on le rend aussi gagnable gratuitement (ex. après la couche 12).
- [ ] (e) On le fusionne avec le ×2 or en un seul pass, assumé comme un accélérateur de temps.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** (a) — c'est le booster le plus sûr : auto-plafonné par le niveau max (Q26), il t'amène à ton plafond plus vite puis ne fait plus rien jusqu'au rebirth suivant. Message d'achat honnête : « atteins ton plafond de niveau plus vite », pas « deviens plus fort ». Plafond ×3 (avec le pass premium, `max()`).

### Q94. Roblox Premium
*[peut attendre plus tard]*

Roblox pousse les joueurs "Premium" (abonnés payants) vers les jeux qui les récompensent. On a prévu : +10% d'or et une récompense du jour exclusive pour eux.

- [x] (a) Confirmé : +10% or + récompense du jour exclusive.
- [ ] (b) Juste la récompense du jour exclusive, pas de bonus d'or.
- [x] (c) Comme (a), plus un cosmétique "Premium" offert.
- [ ] (d) On ne fait rien de spécial pour les Premium.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** (a) + (c) — +10% or (fondu dans le plafond ×3, ne le dépasse jamais) + coffre quotidien de feu de camp exclusif + un cadre "Premium".

---

# 23. Quand le héros meurt

### Q95. Ce qu'on perd exactement en mourant
*[IMPORTANT - à décider avant le GDD]*

Attention : "mourir" et "faire un Rebirth", c'est différent. Le Rebirth remet à zéro plein de choses. Mourir, c'est juste mourir. Il faut décider ce que ça coûte.

- [ ] (a) Rien sauf sa position : on recommence au dernier point de départ choisi. On garde niveau, or, expérience, objets.
- [ ] (b) On garde tout, mais on perd un peu d'or (genre 10%).
- [ ] (c) On garde tout, mais la progression de la zone en cours est perdue (les monstres tués reviennent).
- [ ] (d) On garde tout, et même sa position (on réapparaît sur place après quelques secondes).
- [ ] (e) On perd l'expérience "en trop" pas encore transformée en niveau.
- [x] Autre — j'écris précisément ce que je veux : on garde tout, et on revient au dernier checkpoint enregistré, si j'ai enregistré mon checkpoint au km zero alors que je suis mort au km 500 je recommence depuis le début.

**Ma réponse :** _____

### Q96. Si mourir ne coûte presque rien, pourquoi payer pour revivre ?
*[IMPORTANT - à décider avant le GDD]*

Si la mort renvoie juste au point de départ sans rien perdre, la réanimation payante (Q91) sert surtout à ne pas refaire le chemin.

- [x] (a) C'est ça : on paie pour ne pas refaire les km déjà parcourus (gain de temps).
- [ ] (b) La mort fait perdre quelque chose (voir Q95) et revivre l'annule.
- [ ] (c) Revivre garde un bonus de partie (série de victoires, etc.) qui saute sinon.
- [ ] (d) On enlève la revive payante, elle n'a pas assez de valeur.
- [x] Autre — j'écris précisément ce que je veux : la potion revive sert égelement imaginons si le boss de fin de zone reste 4% de pv et que je suis mort alors je peux revive et finir le combat penant ma mort et mon choix de revive le mob ne perd aucune vie tant que je n'ai pas choisi

**Ma réponse :** _____

### Q97. Le délai avant de rejouer
*[peut attendre plus tard]*

- [ ] (a) Aucun, on recommence tout de suite.
- [ ] (b) Un court écran de mort (3-5 secondes) avant le bouton recommencer.
- [x] (c) Un écran de mort avec un résumé (distance, record) qu'on ferme quand on veut.
- [ ] (d) Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q98. Le bouton par défaut sur l'écran de mort
*[peut attendre plus tard]*

L'écran de mort a deux boutons : "recommencer" et "revivre (Robux)".

- [ ] (a) "Recommencer" est le gros bouton bien visible, "revivre" petit à côté.
- [x] (b) Les deux de la même taille.
- [ ] (c) "Revivre" mis en avant (plus de revenus), mais "recommencer" toujours clair.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

---

# 24. L'histoire de La Descente

### Q99. Qui écrit les dialogues des 12 boss
*[IMPORTANT - à décider avant le GDD]*

Chaque boss est un personnage avec un nom, une rancune, et 2-3 phrases qu'il dit. Il revient plus loin avec de nouvelles phrases qui rappellent la 1ère rencontre. Ça fait environ 12 boss × 6 phrases = beaucoup de texte à écrire.

- [x] (a) On écrit tout dès le lancement (les 12 boss, 1ère et 2e rencontre).
- [ ] (b) On écrit juste 1-2 phrases par boss au lancement, on étoffe après.
- [ ] (c) On écrit à fond les 3-4 premiers boss ; les autres ont juste un nom au lancement.
- [ ] (d) Pas de dialogues au lancement : juste des noms et des ambiances. Les dialogues arrivent en mise à jour.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q100. L'écran entre deux couches
*[peut attendre plus tard]*

Quand on passe d'une couche à la suivante (tous les 10 km).

- [x] (a) Une carte plein écran (nom de la couche + une phrase d'ambiance) qu'on peut passer.
- [ ] (b) Juste une bannière qui glisse en haut, sans couper le jeu.
- [ ] (c) Un court fondu au noir avec le nom de la couche.
- [ ] (d) Rien : le décor change, c'est tout.
- [x] Autre — j'écris précisément ce que je veux :reponse a mais ca doit durer 5 secondes max et passer automatiquement a la couche suivante

**Ma réponse :** _____

### Q101. Les couches 13, 14, 15
*[peut attendre plus tard]*

Après la couche 12, le jeu boucle (on recommence les couches en plus dur). On a prévu d'ajouter des couches 13-15 après le lancement.

- [x] (a) Boucle infinie au lancement, couches 13-15 dans le mois qui suit.
- [ ] (b) Couches 13-15 dès le lancement (plus de travail).
- [ ] (c) Pas de vraie boucle : après la 12, on ne fait plus que du Cauchemar sur les couches existantes.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

---

# 25. Les dessins, les sons, aider tout le monde à jouer

### Q102. Les images au lancement (compte Roblox bloqué)
*[IMPORTANT - à décider avant le GDD]*

Le compte Roblox est sanctionné : on ne peut pas mettre en ligne de nouvelles images. Le jeu tourne donc avec des rectangles de couleur dessinés par le code, et quelques images déjà en ligne (certaines ont été retirées car signalées).

- [ ] (a) On lance avec les décors en rectangles de couleur. On remplacera par de vraies images quand le compte sera débloqué.
- [x] (b) On attend le déblocage du compte avant de lancer (le jeu doit être joli).
- [ ] (c) On lance avec les images déjà en ligne pour les héros et monstres + des décors en couleur + du texte pour ce qui manque.
- [ ] (d) On cherche un autre moyen de mettre des images en ligne (autre compte, partenaire).
- [x] Autre — j'écris précisément ce que je veux : je trouverai des assets gratuits que tu peux utiliser tu devrais juste me dire le theme voulu, et la quantité d'assets neccesaire

**Ma réponse :** _____

### Q103. Les sons (pas de mise en ligne possible)
*[IMPORTANT - à décider avant le GDD]*

Pareil : on ne peut pas mettre en ligne nos propres musiques et sons. Roblox a une bibliothèque de sons gratuits utilisables.

- [x] (a) On utilise seulement des sons de la bibliothèque Roblox au lancement.
- [ ] (b) On lance quasi sans son, on ajoute la musique après le déblocage.
- [ ] (c) On utilise la bibliothèque Roblox et on remplace par du sur-mesure plus tard.
- [ ] (d) On achète des sons à des créateurs qui les ont déjà mis en ligne (utilisables sans rien uploader).
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q104. Les joueurs qui distinguent mal les couleurs
*[IMPORTANT - à décider avant le GDD]*

Le jeu utilise beaucoup la couleur : bordure grise / bleue / violette / orange / rouge pour la rareté, et une teinte de couleur pour dire si un monstre est dangereux. Quelqu'un qui voit mal les couleurs est perdu.

- [x] (a) On ajoute un mot ou un symbole en plus de la couleur (ex. "Épique", une petite icône).
- [ ] (b) Un mode "formes" dans les options (chaque rareté a une forme de bordure différente).
- [ ] (c) Les deux (mot + option formes).
- [ ] (d) On garde juste la couleur, on verra plus tard.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q105. Les autres options pour aider à jouer
*[peut attendre plus tard]*

On a déjà prévu : baisser le volume, réduire les animations qui bougent, changer la taille des nombres de dégâts.

- [ ] (a) Ça suffit pour le lancement.
- [ ] (b) Comme (a), plus une option "grosses écritures" pour tous les textes.
- [ ] (c) Comme (a), plus pouvoir jouer entièrement à une main (tout accessible d'un pouce).
- [ ] (d) Comme (a), plus un mode "moins de clignotements" (pour l'épilepsie).
- [x] (e) Tout ça à la fois.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

---

# 26. Savoir ce que font les joueurs

### Q106. Ce qu'on veut mesurer
*[IMPORTANT - à décider avant le GDD]*

Pour améliorer le jeu après le lancement, on enregistre discrètement des infos : où les joueurs arrêtent de jouer, où ils meurent, quand ils achètent. Aucune info personnelle.

- [ ] (a) Le minimum : arrivée dans le jeu, 1er boss battu, 1er Rebirth, 1er achat.
- [ ] (b) Comme (a), plus où les joueurs meurent le plus (pour repérer les murs de difficulté).
- [ ] (c) Comme (b), plus quels pouvoirs / familiers / objets sont utilisés (pour équilibrer).
- [ ] (d) Comme (c), plus combien de temps dure une session et à quel jour les gens arrêtent de revenir.
- [x] (e) Tout ça.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q107. Tester deux versions en même temps
*[peut attendre plus tard]*

On peut montrer une version A à la moitié des joueurs et une version B à l'autre moitié pour voir laquelle marche mieux.

- [ ] (a) Oui, dès le lancement, sur des petits trucs (prix, difficulté du 1er boss).
- [ ] (b) Seulement après le lancement, quand il y a assez de joueurs.
- [x] (c) Non, on décide nous-mêmes, c'est plus simple.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

---

# 27. Les bugs et les situations bizarres

### Q108. Le joueur se déconnecte en plein combat de boss
*[IMPORTANT - à décider avant le GDD]*

- [] (a) Le combat est perdu ; il réapparaît au dernier point de départ à sa reconnexion.
- [x] (b) Le combat de boss est "sauvegardé" et reprend où il en était.
- [ ] (c) Il réapparaît juste avant le boss, en pleine vie.
- [ ] (d) Le boss est considéré comme non battu, mais il garde l'or et l'expérience gagnés avant la déconnexion.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q109. La sauvegarde ne répond pas (panne côté Roblox)
*[IMPORTANT - à décider avant le GDD]*

Parfois le système qui sauvegarde les parties est en panne quelques minutes. Si on laisse jouer, la partie ne sera pas sauvée et le joueur perd sa progression en se déconnectant.

- [x] (a) On laisse jouer avec un gros message "attention, ta progression n'est pas sauvegardée en ce moment".
- [ ] (b) On empêche de jouer tant que la sauvegarde ne marche pas (écran d'attente).
- [ ] (c) On laisse jouer normalement sans rien dire, on réessaie de sauver en fond.
- [ ] (d) On laisse jouer, mais on bloque les achats et le Rebirth tant que ça ne sauve pas.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q110. Faire un Rebirth en plein combat
*[peut attendre plus tard]*

Le Rebirth se fait depuis le château. Si on peut ouvrir le château pendant un combat (voir Q10)...

- [ ] (a) Impossible : on ne peut pas ouvrir le château pendant un combat.
- [x] (b) Possible : le combat est abandonné et le Rebirth se fait.
- [ ] (c) Possible seulement si le héros n'est pas en combat à cet instant précis.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q111. Zéro familier équipé
*[peut attendre plus tard]*

- [x] (a) Le combat marche normalement, juste sans les bonus des familiers.
- [ ] (b) Impossible d'entrer en combat sans au moins 1 familier.
- [ ] (c) Le jeu en équipe un automatiquement si tu en as dans ton sac.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q112. Les nombres deviennent gigantesques
*[peut attendre plus tard]*

Après beaucoup de Rebirths, l'or et les dégâts peuvent devenir des nombres énormes (millions, milliards). On les affiche avec des lettres (K, M, Md, T).

- [ ] (a) On garde K / M / Md / T et on plafonne les stats à une valeur très haute pour éviter les bugs.
- [x] (b) On ajoute d'autres lettres au-delà de T.
- [ ] (c) On passe en écriture scientifique ("1,5e12") quand c'est trop grand.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

---

# 28. Combien de choses au lancement

### Q113. Combien de monstres différents
*[IMPORTANT - à décider avant le GDD]*

Aujourd'hui, seule la couche 1 a des monstres (4). Il en faut pour les 12 couches.

- [ ] (a) 3 monstres par couche (~36 en tout).
- [ ] (b) 4 par couche (~48).
- [x] (c) 5-6 par couche (~60-70), plus de variété.
- [ ] (d) 3 par couche, et les monstres des couches précédentes reviennent mélangés.
- [ ] Autre — j'écris précisément le nombre que je veux : ________________________________

**Ma réponse :** _____

### Q114. Combien de missions différentes dans la liste
*[peut attendre plus tard]*

On tire 3 missions par jour dans une liste. Si la liste est courte, on revoit vite les mêmes.

- [ ] (a) Environ 15 missions différentes.
- [ ] (b) Environ 30.
- [x] (c) Environ 50.
- [ ] (d) On commence avec ~15 et on en rajoute chaque mois.
- [x] Autre — j'écris précisément ce que je veux : sauf que j'ai dix 10 missions journalieres

**Ma réponse :** _____

### Q115. Combien de cosmétiques à vendre au lancement
*[IMPORTANT - à décider avant le GDD]*

La boutique vend des skins de héros, des auras de familier, des styles de nombres de dégâts, du mobilier de feu de camp, des plaques de nom.

- [ ] (a) Peu (~10-15 en tout) mais on en ajoute souvent.
- [x] (b) Un bon paquet (~30-40) pour que la boutique soit riche au lancement.
- [ ] (c) Beaucoup (~60+), gros travail.
- [ ] (d) Juste ce qu'il faut pour remplir le pass de saison + 5-6 en boutique.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q116. Combien de talents par branche
*[peut attendre plus tard]*

Il y a 3 branches de talents (Fureur, Gardien, Tactique). On gagne 1 point tous les 5 niveaux.

- [ ] (a) Environ 5 talents par branche (~15 en tout).
- [ ] (b) Environ 8 par branche (~24).
- [x] (c) Environ 10+ par branche (gros arbre).
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

---

# 29. Les nombres exacts à choisir

### Q117. La table de montée des stats
*[IMPORTANT - à décider avant le GDD]*

C'est le tableau "combien chaque stat gagne par niveau, pour chaque classe et sous-classe" (lié à la Q25). Il faut vraiment le remplir avant d'écrire le GDD.

- [ ] (a) Je le remplis moi-même (je donne les chiffres).
- [ ] (b) Tu me proposes un tableau de départ et je corrige.
- [x] (c) On part de "5 points/niveau répartis en pourcentages", tu proposes les pourcentages par classe.
- [ ] (d) On teste plusieurs versions en jeu avant de figer.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q118. Les gros multiplicateurs à figer
*[IMPORTANT - à décider avant le GDD]*

Plusieurs nombres importants ne sont pas encore choisis : force du Cauchemar, expérience de pass, bonus de Rebirth, prix en Robux.

- [x] (a) Tu me proposes une valeur pour chacun et je valide tout d'un coup.
- [ ] (b) On les décide un par un plus tard, section par section.
- [ ] (c) On met des valeurs "au pif" pour lancer et on ajuste avec les vrais joueurs.
- [ ] Autre — j'écris précisément ce que je veux : ________________________________

**Ma réponse :** _____

### Q119. Comment on vérifie que le jeu est bien équilibré
*[peut attendre plus tard]*

"Équilibré" = ni trop dur ni trop facile, et un joueur qui ne paie pas peut tout finir.

- [ ] (a) Tu joues toi-même du début à la fin et tu notes ce qui coince.
- [ ] (b) On fait jouer quelques testeurs et on regarde leurs retours.
- [x] (c) On calcule sur tableur avant, on ajuste en jouant après.
- [ ] (d) On lance en "test discret" (amis seulement) quelques jours d'abord.
- [x] Autre — j'écris précisément ce que je veux : je veux quand même que le jeu sois dur pas impossible mais pas facile non plus 
**Ma réponse :** _____

---

# Ce qui est DÉJÀ décidé (ne pas rouvrir ces débats)

Ces choix sont figés. Les questions ci-dessus tournent **autour** d'eux.

**Le socle**
- Jeu 100% écran (pas de monde 3D, pas de personnage Roblox). Écran **paysage uniquement**.
- Le coin haut-gauche de l'écran reste toujours libre (menu + chat de Roblox).
- Le serveur décide de tout (or, expérience, objets, achats). On ne fait confiance à rien de ce que le joueur envoie.
- Sauvegarde solide (ProfileStore), pas de gains quand le jeu est fermé.

**Le combat**
- Attaque automatique seule (plus de "taper l'écran"). Le héros frappe toujours en premier.
- Combat jusqu'à la mort de l'un des deux. On gagne si (ma vie × mes dégâts) dépasse (sa vie × ses dégâts).
- Cadence de base : 1 coup toutes les 2,2 secondes. Vitesse maximum : 1 coup toutes les 0,5 s (Vitesse 200).
- Hors combat : on récupère 2% de vie par seconde. Le jeu est **volontairement difficile** — mourir souvent fait partie du jeu.
- **Déplacement = tenir gauche ou droite** (clavier / tactile / manette), environ 9 secondes pour parcourir 1 km. Le héros marche en avant ou en arrière **librement**, entre les étapes et entre les zones. La direction est **purement visuelle** (le héros approche l'ennemi par la gauche ou par la droite) : **aucun effet sur les dégâts, aucun ciblage**. Il n'y a **pas de "posture de combat"**. Le tutoriel apprend le déplacement.

**L'équipement (gardé tel quel de la vieille spec)**
- 6 emplacements : Arme, Casque, Plastron, Jambières, Bottes, Familier.
- 5 raretés = de purs multiplicateurs : Commun ×1 / Rare ×1,5 / Épique ×2,2 / Légendaire ×3,5 / Mythique ×6.
- Le niveau d'un objet est juste indicatif : il ne bloque **jamais** l'équipement.
- Sets Guerrier et Mage symétriques, bonus à 2/3/4 pièces, même voie seulement.
- Fusion stricte du même objet exact : 3 Communs → 1 Rare, 4 Rares → 1 Épique, 5 Épiques → 1 Légendaire, 6 Légendaires → 1 Mythique.
- La défense (DEF/RES) vient **uniquement** de l'équipement, jamais des points de stat.
- Sac de 100 places. Sac plein = objet refusé. Filtres de ramassage automatique (rareté minimum + cases Guerrier/Mage) sur la page du sac elle-même.

**La progression**
- Les stats montent **toutes seules** à chaque niveau (selon une table classe × sous-classe — à remplir, voir Q25/Q117). Plus d'allocation manuelle au niveau.
- La classe (Guerrier/Mage) est pilotée par l'arme équipée.
- Sous-classe choisie au Rebirth 5, re-choix possible aux Rebirths 10, 15, 20...
- "Points bonus" gagnés uniquement en jouant activement (missions, Donjon, Codex, jalons). Placés à la main dans les 5 stats. **Permanents** (survivent au Rebirth).
- Talents : 3 branches, 1 point tous les 5 niveaux, remise à zéro gratuite au feu de camp. Débloquent les 3 pouvoirs actifs.
- Rebirth : infini, garde équipement/familiers/points de départ, remet à zéro niveau/points-du-niveau/or/distance. Coût = 10 000 × 2,2^(n-1). +25% d'expérience par Rebirth.
- Calendrier des Rebirths : R5 = sous-classe, R10 = 4e familier (équipe 3 → 4), R15/R20 = à décider (Q37).

**Le monde : "La Descente"**
- 12 couches nommées (Plaine de l'Aube → Fin de Toute Chose), un boss-personnage par couche.
- Boss récurrents : ils reviennent ~6 couches plus bas, plus forts, avec du dialogue en rappel.
- Après la couche 12 : boucle infinie. Couches 13-15 après le lancement.
- Un boss tous les 10 km ; gros boss tous les 100 km. Butin de boss : 1 seul tirage par kill, pourcentages constants à toutes les zones.
- Points de départ tous les 10 km, sélectionnables. Feux de camp tous les 50 km. 1ère boutique au km 50.

**Le mode Cauchemar (ladder de difficulté façon Diablo, décidé cette session)**
- Chaque couche a son propre ladder Cauchemar I → II → III...
- Porte globale : battre le boss de la couche 6 une fois.
- Couches 1-6 : nettoyer 100× le boss → Cauchemar I. Palier suivant ~25× de plus.
- Couches 7-12 : débloquées d'un bloc après avoir tué le boss de la couche 12.
- Permanent (survit au Rebirth). Meilleures récompenses aux hauts paliers (dont cosmétiques exclusifs, aucune puissance).

**La vitesse du jeu**
- Multiplicateur uniforme (combat + marche), décidé par le serveur, **aucun gain de puissance** (l'ennemi accélère aussi).
- ×1 toujours dispo · ×1,5 gratuit après le boss de la couche 6 · ×2 gratuit après le boss de la couche 12 OU achat en Robux.

**Les familiers (refonte décidée cette session)**
- Fini les fées : chaque familier est une mini-version d'un monstre ou boss.
- Drop : 0,5% par monstre tué, 0,1% par boss tué.
- Rôle (attaque/bouclier/soin) fixé par la famille du Codex.
- Rareté + fusion comme l'équipement. Équipe de 3 (4 après le Rebirth 10).

**La monétisation (incluse au lancement)**
- Pass de saison (8 semaines, piste gratuite + piste premium en Robux, ~50 paliers).
- Boutique 100% cosmétique + coffre surprise avec chances affichées.
- Pass de confort : ×2 or, ×2 expérience, +places de sac, VIP.
- Réanimation payante (paiement fiable, jamais compté deux fois).
- Pack de départ unique. Game pass Vitesse ×2.
- **Règle d'or : un joueur qui ne paie pas peut finir tout le contenu.** Tout achat = gain de temps, confort, ou joli — jamais de la puissance pure.

**Le social**
- Au lancement : solo + classements saisonniers seulement.
- Plus tard (v1.1-v1.2) : feux de camp partagés, échange, raids en équipe, guildes.

**Les contraintes**
- Compte Roblox sanctionné → **aucune mise en ligne d'image ou de son** pour l'instant. On utilise des rectangles de couleur et du texte.
- Le combat est déjà largement codé — on fait évoluer l'existant, pas repartir de zéro.
