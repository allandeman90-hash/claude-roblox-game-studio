# La Descente — codex : 72 monstres + 12 Gardiens (E4)

**Version :** 1.0
**Dernière mise à jour :** 2026-09-01
**Auteur :** narrative-director (Track E — livrable E4)
**Statut :** Approuvé (proprio, 2026-09-01)
**Source de vérité :** design/narrative/la-descente.md (bible E1) §6 et §8 ·
`src/ReplicatedStorage/ZoneConfig.luau` (noms, slugs, `famille`, `role`, `petRole`) ·
reponses-consolidees Q57 (bonus de famille), Q58 (lore après 10 kills).
**Alimente :** UI codex (ui-programmer via lead-programmer), economy-designer
(chiffrage des bonus), localisation (Track F).

---

## 1. Conventions

- **Révélation.** Chaque entrée (monstre **et** Gardien) se révèle après
  **10 éliminations**. Les Gardiens atteignent ce seuil via la boucle infinie et
  leur 2ᵈᵉ rencontre. Avant : silhouette noircie, « ? » à la place du nom,
  compteur `x / 10`.
- **Contenu révélé.** Nom, famille, rôle, familier, 1-2 lignes « Avant la chute »
  (ce qu'il était / faisait avant que sa couche tombe — Q58).
- **Familles.** Strictement celles de `ZoneConfig` (`famille`) :
  Bête · Mort-vivant · Élémentaire · Humanoïde · Construct. Jamais réattribuées.
  Les 12 Gardiens reçoivent une famille assignée depuis la bible §6 (voir §6).
- **Ordre.** Monstres groupés par couche C1→C12, dans l'ordre
  `ZoneConfig.Zones[n].enemies`. Gardiens dans l'ordre `ZoneConfig.BossThemes`.
- **Stockage.** Lore **pré-approuvé, stocké serveur**, hors filtre runtime
  (`TextService`). Namespace localisation : `codex.<slug>.lore` où `<slug>` est
  l'`id` ZoneConfig (ex. `codex.mob_c01_rat.lore`, `codex.boss_roi_gobelin.lore`).
- **Ton.** Public 10-16, pas de juron, chat-filter-safe. Jamais de gore ni de
  cruauté montrée : la mélancolie vient de l'absence, du poste tenu pour rien, de
  ceux qui ne sont pas revenus. Le monstre `mob_c09_poupee_suaire` est un
  objet-souvenir (poupée de veillée cousue dans un linceul), **jamais un enfant**.

---

## 2. Les 5 familles

Effectifs réels du roster `ZoneConfig` (72 monstres) :

| Famille | Effectif | Direction du bonus de complétion |
|---|---|---|
| Élémentaire | 18 | + RES magique — s'être accoutumé aux éléments |
| Construct | 17 | + réduction des dégâts subis — ce qui est bâti pour durer |
| Bête | 16 | + vitesse d'attaque — l'instinct du chasseur |
| Mort-vivant | 12 | + régénération hors combat — l'endurance de ce qui ne repose pas |
| Humanoïde | 9 | + or gagné — ils avaient tous des poches |

---

## 3. Récompenses — direction narrative uniquement

> **Chiffrage TBD — economy-designer.** Le narratif fixe la *nature* et le *thème*
> des bonus, pas les valeurs.

- **Par carte révélée (10 kills).** Petit bonus permanent « chasseur » contre cette
  famille (ex. dégâts accrus contre la famille de la créature révélée). Persiste à
  travers Rebirth (c'est un souvenir, pas une ressource).
- **Famille complétée (toutes les cartes d'une famille révélées).** Bonus
  thématique plus fort, selon la table §2.
- **Les 12 Gardiens révélés (capstone).** Récompense distincte à définir. Les
  Gardiens **ne comptent pas** dans la complétion des 5 familles de monstres.

---

## 4. Monstres — 72 entrées

### Couche 1 · Plaine de l'Aube

**Rat** — `mob_c01_rat`
- **Famille :** Bête · rôle chaff · familier Heal
- **Avant la chute :** Ils suivaient les chariots de vivres de la première expédition. Les chariots ne sont jamais remontés ; les rats, si — mais vers le bas.
- **Révélé :** 10 éliminations · **Complétion Bête :** + vitesse d'attaque (TBD).

**Larve de Poussière** — `mob_c01_larve_poussiere`
- **Famille :** Bête · rôle chaff · familier Heal
- **Avant la chute :** La poussière s'amasse là où plus rien ne bouge. Sur le plus vieux sol tombé, elle a fini par ramper toute seule.
- **Révélé :** 10 éliminations · **Complétion Bête :** + vitesse d'attaque (TBD).

**Gobelin Maraudeur** — `mob_c01_gobelin_maraudeur`
- **Famille :** Humanoïde · rôle swift · familier DPS
- **Avant la chute :** Un pillard de la bande qui s'est couronnée sur l'acier de la première expédition. Il fouille encore la frontière, par habitude plus que par faim.
- **Révélé :** 10 éliminations · **Complétion Humanoïde :** + or gagné (TBD).

**Loup Efflanqué** — `mob_c01_loup_efflanque`
- **Famille :** Bête · rôle bruiser · familier Tank
- **Avant la chute :** Chien de garde des villages-frontière. Quand la frontière est tombée, personne n'est venu le détacher.
- **Révélé :** 10 éliminations · **Complétion Bête :** + vitesse d'attaque (TBD).

**Épouvantail** — `mob_c01_epouvantail`
- **Famille :** Construct · rôle caster · familier Heal
- **Avant la chute :** Planté dans les champs pour éloigner les corbeaux des récoltes. Les récoltes sont parties ; lui monte toujours la garde.
- **Révélé :** 10 éliminations · **Complétion Construct :** + réduction des dégâts (TBD).

**Ogre du Sentier** — `mob_c01_ogre_sentier`
- **Famille :** Humanoïde · rôle tank · familier Tank
- **Avant la chute :** Il rançonnait les voyageurs au dernier pont du royaume. Le pont est tombé depuis des âges ; il réclame encore le péage.
- **Révélé :** 10 éliminations · **Complétion Humanoïde :** + or gagné (TBD).

### Couche 2 · Carrière des Runes

**Chien de Gravats** — `mob_c02_chien_gravats`
- **Famille :** Construct · rôle chaff · familier Heal
- **Avant la chute :** Les tailleurs avaient fait un chien de chutes de pierre pour garder le chantier la nuit. Le chantier a fermé ; il garde encore les tas de gravats.
- **Révélé :** 10 éliminations · **Complétion Construct :** + réduction des dégâts (TBD).

**Rampant de la Carrière** — `mob_c02_rampant_carriere`
- **Famille :** Bête · rôle swift · familier DPS
- **Avant la chute :** Une bête fouisseuse qui nichait dans les galeries d'extraction. Elle suit toujours les vieilles veines, même là où il n'y a plus rien à creuser.
- **Révélé :** 10 éliminations · **Complétion Bête :** + vitesse d'attaque (TBD).

**Éclat Runique** — `mob_c02_eclat_runique`
- **Famille :** Élémentaire · rôle caster · familier Heal
- **Avant la chute :** Un fragment de roche-rune encore chargé. La formule qu'on y a gravée devait tenir un mur ; sans mur, elle tourne à vide et mord ce qui passe.
- **Révélé :** 10 éliminations · **Complétion Élémentaire :** + RES magique (TBD).

**Tailleur Maudit** — `mob_c02_tailleur_maudit`
- **Famille :** Humanoïde · rôle bruiser · familier Tank
- **Avant la chute :** Un graveur de runes qui a lu une formule interdite pour finir plus vite. Elle l'a pris au mot : il taille encore, sans jamais s'arrêter.
- **Révélé :** 10 éliminations · **Complétion Humanoïde :** + or gagné (TBD).

**Sentinelle Gravée** — `mob_c02_sentinelle_gravee`
- **Famille :** Construct · rôle elite · familier DPS
- **Avant la chute :** Un pilier-garde couvert des consignes de sécurité du chantier. Il applique le règlement d'un chantier qui n'existe plus.
- **Révélé :** 10 éliminations · **Complétion Construct :** + réduction des dégâts (TBD).

**Colosse de la Carrière** — `mob_c02_colosse_carriere`
- **Famille :** Construct · rôle tank · familier Tank
- **Avant la chute :** Le portefaix des bâtisseurs, taillé pour hisser les blocs d'étai. On l'a laissé chargé ; il porte toujours son dernier bloc.
- **Révélé :** 10 éliminations · **Complétion Construct :** + réduction des dégâts (TBD).

### Couche 3 · Bois des Murmures

**Feu Follet** — `mob_c03_feu_follet`
- **Famille :** Élémentaire · rôle chaff · familier Heal
- **Avant la chute :** La petite flamme qu'on laissait aux carrefours du bois pour guider les voyageurs. Personne ne l'entretient plus ; elle égare au lieu de guider.
- **Révélé :** 10 éliminations · **Complétion Élémentaire :** + RES magique (TBD).

**Sylphe des Ronces** — `mob_c03_sylphe_ronce`
- **Famille :** Élémentaire · rôle swift · familier DPS
- **Avant la chute :** Un esprit d'aubépine qui gardait les lisières. Le bois maudit a durci sa garde en hargne.
- **Révélé :** 10 éliminations · **Complétion Élémentaire :** + RES magique (TBD).

**Loup Sylvestre** — `mob_c03_loup_sylvestre`
- **Famille :** Bête · rôle bruiser · familier Tank
- **Avant la chute :** Un loup ordinaire de la forêt-frontière. Il a mangé des baies que le bois tordu a fait pousser, et n'a plus jamais eu tout à fait la même forme.
- **Révélé :** 10 éliminations · **Complétion Bête :** + vitesse d'attaque (TBD).

**Pendu des Branches** — `mob_c03_pendu_branches`
- **Famille :** Mort-vivant · rôle caster · familier Heal
- **Avant la chute :** Un voyageur perdu dans les cercles de la Sorcière, qui n'a plus trouvé la sortie. Les branches l'ont gardé ; il indique un chemin qui n'existe pas.
- **Révélé :** 10 éliminations · **Complétion Mort-vivant :** + régénération hors combat (TBD).

**Champignon Rôdeur** — `mob_c03_champignon_rodeur`
- **Famille :** Bête · rôle tank · familier Tank
- **Avant la chute :** Une colonie de champignons poussée sur une souche-frontière. Elle s'est mise à marcher pour suivre la dernière lumière, très lentement.
- **Révélé :** 10 éliminations · **Complétion Bête :** + vitesse d'attaque (TBD).

**Tréant Tordu** — `mob_c03_treant_tordu`
- **Famille :** Bête · rôle elite · familier DPS
- **Avant la chute :** Un des grands arbres que la Sorcière tenait par les racines. Quand elle a lâché prise, il a continué de bouger, sans plus savoir vers quoi.
- **Révélé :** 10 éliminations · **Complétion Bête :** + vitesse d'attaque (TBD).

### Couche 4 · Champs de Cendres

**Braise Vive** — `mob_c04_braise_vive`
- **Famille :** Élémentaire · rôle chaff · familier Heal
- **Avant la chute :** Une étincelle du pare-feu d'origine. Allumée pour protéger les couches vertes, elle brûle encore, longtemps après avoir oublié pourquoi.
- **Révélé :** 10 éliminations · **Complétion Élémentaire :** + RES magique (TBD).

**Molosse de Suie** — `mob_c04_molosse_suie`
- **Famille :** Bête · rôle swift · familier DPS
- **Avant la chute :** Le chien d'un guetteur du pare-feu. Il court toujours la ligne de ronde de son maître, dans la cendre.
- **Révélé :** 10 éliminations · **Complétion Bête :** + vitesse d'attaque (TBD).

**Cendreux** — `mob_c04_cendreux`
- **Famille :** Élémentaire · rôle bruiser · familier Tank
- **Avant la chute :** Ce qui reste quand un feu ne s'éteint jamais : une masse de braise qui a pris forme et refuse de refroidir.
- **Révélé :** 10 éliminations · **Complétion Élémentaire :** + RES magique (TBD).

**Porte-Torche** — `mob_c04_porte_torche`
- **Famille :** Humanoïde · rôle caster · familier Heal
- **Avant la chute :** Le soldat chargé de rallumer les foyers du pare-feu chaque nuit. Il fait sa tournée depuis que l'armée a brûlé, torche haute.
- **Révélé :** 10 éliminations · **Complétion Humanoïde :** + or gagné (TBD).

**Fantassin Calciné** — `mob_c04_fantassin_calcine`
- **Famille :** Mort-vivant · rôle elite · familier DPS
- **Avant la chute :** Un des soldats pris par le feu qu'on lui avait ordonné d'allumer. Il tient encore la ligne, arme au poing.
- **Révélé :** 10 éliminations · **Complétion Mort-vivant :** + régénération hors combat (TBD).

**Colosse de Braise** — `mob_c04_colosse_braise`
- **Famille :** Élémentaire · rôle tank · familier Tank
- **Avant la chute :** Le brasier central du pare-feu, tassé et durci en géant. S'éteindre serait un repos ; il n'a jamais reçu l'ordre de s'éteindre.
- **Révélé :** 10 éliminations · **Complétion Élémentaire :** + RES magique (TBD).

### Couche 5 · Toundra des Âmes

**Éclat d'Âme** — `mob_c05_eclat_ame`
- **Famille :** Mort-vivant · rôle chaff · familier Heal
- **Avant la chute :** Un fragment de quelqu'un que le froid n'a pas laissé partir. Trop peu pour se souvenir d'un nom, assez pour errer.
- **Révélé :** 10 éliminations · **Complétion Mort-vivant :** + régénération hors combat (TBD).

**Givreux** — `mob_c05_givreux`
- **Famille :** Élémentaire · rôle swift · familier DPS
- **Avant la chute :** Le gel lui-même, mis en mouvement par la glace de la Liche. Il resserre l'étreinte partout où la chaleur menace de passer.
- **Révélé :** 10 éliminations · **Complétion Élémentaire :** + RES magique (TBD).

**Loup de Givre** — `mob_c05_loup_givre`
- **Famille :** Bête · rôle bruiser · familier Tank
- **Avant la chute :** Un loup des neiges qui suivait les convois funéraires jusqu'à la porte gelée. Il monte encore la garde devant les tombeaux.
- **Révélé :** 10 éliminations · **Complétion Bête :** + vitesse d'attaque (TBD).

**Pleureuse Voilée** — `mob_c05_pleureuse_voilee`
- **Famille :** Mort-vivant · rôle caster · familier Heal
- **Avant la chute :** Une dame de la cour de la Liche, descendue avec sa souveraine pour veiller les morts. Elle veille toujours, le visage couvert.
- **Révélé :** 10 éliminations · **Complétion Mort-vivant :** + régénération hors combat (TBD).

**Marcheur Gelé** — `mob_c05_marcheur_gele`
- **Famille :** Mort-vivant · rôle tank · familier Tank
- **Avant la chute :** Un soldat de la cour prise dans la glace. Le dégel l'a libéré à moitié ; il marche vers une bataille qui a eu lieu il y a des âges.
- **Révélé :** 10 éliminations · **Complétion Mort-vivant :** + régénération hors combat (TBD).

**Titan de Glace** — `mob_c05_titan_glace`
- **Famille :** Élémentaire · rôle elite · familier DPS
- **Avant la chute :** Un pan de la muraille de glace que la Liche a dressée. Il s'est détaché et continue, seul, de vouloir sceller le passage.
- **Révélé :** 10 éliminations · **Complétion Élémentaire :** + RES magique (TBD).

### Couche 6 · Côte des Naufrages

**Feu de Brume** — `mob_c06_feu_brume`
- **Famille :** Élémentaire · rôle chaff · familier Heal
- **Avant la chute :** La lanterne du phare brisé, réduite à une lueur dans l'embrun. Elle cherche encore à prévenir des récifs des navires déjà coulés.
- **Révélé :** 10 éliminations · **Complétion Élémentaire :** + RES magique (TBD).

**Marin Noyé** — `mob_c06_marin_noye`
- **Famille :** Mort-vivant · rôle swift · familier DPS
- **Avant la chute :** Un matelot d'un des navires versés dans la Faille avec la mer. Il rejoint son quart sur un pont qui n'est plus là.
- **Révélé :** 10 éliminations · **Complétion Mort-vivant :** + régénération hors combat (TBD).

**Crabe d'Épave** — `mob_c06_crabe_epave`
- **Famille :** Bête · rôle bruiser · familier Tank
- **Avant la chute :** Un crabe qui a fait sa coquille d'un morceau de coque. Il défend son bout d'épave comme un terrier.
- **Révélé :** 10 éliminations · **Complétion Bête :** + vitesse d'attaque (TBD).

**Murène Dressée** — `mob_c06_murene_dressee`
- **Famille :** Bête · rôle caster · familier Heal
- **Avant la chute :** Une murène de la fosse, longue et patiente. L'eau apportée d'en haut goûtait le sel et les morts ; elle en a gardé de la méfiance.
- **Révélé :** 10 éliminations · **Complétion Bête :** + vitesse d'attaque (TBD).

**Garde Corallien** — `mob_c06_garde_corallien`
- **Famille :** Construct · rôle tank · familier Tank
- **Avant la chute :** Une statue de garde d'un port englouti, prise dans le corail. Elle tient encore la passe qu'elle surveillait de son vivant de pierre.
- **Révélé :** 10 éliminations · **Complétion Construct :** + réduction des dégâts (TBD).

**Léviathan Échoué** — `mob_c06_leviathan_echoue`
- **Famille :** Bête · rôle elite · familier DPS
- **Avant la chute :** Une bête de haute mer, laissée à sec quand le Tyran a été forcé de retenir l'eau. Elle rampe vers un large qui a disparu.
- **Révélé :** 10 éliminations · **Complétion Bête :** + vitesse d'attaque (TBD).

### Couche 7 · Ruines d'Aethel

**Glyphe Flottant** — `mob_c07_glyphe_flottant`
- **Famille :** Élémentaire · rôle chaff · familier Heal
- **Avant la chute :** Un mot d'une leçon d'Aethel, resté en suspens quand la salle s'est effondrée. Il répète sa syllabe à qui passe.
- **Révélé :** 10 éliminations · **Complétion Élémentaire :** + RES magique (TBD).

**Chien d'Albâtre** — `mob_c07_chien_albatre`
- **Famille :** Construct · rôle swift · familier DPS
- **Avant la chute :** Un lévrier de garde sculpté pour les jardins de l'Académie. Il fait toujours sa ronde entre des haies qui ne sont plus là.
- **Révélé :** 10 éliminations · **Complétion Construct :** + réduction des dégâts (TBD).

**Automate Brisé** — `mob_c07_automate_brise`
- **Famille :** Construct · rôle bruiser · familier Tank
- **Avant la chute :** Un serviteur mécanique des salles de lecture. Il porte encore des livres d'un rayon à l'autre, même sans rayons ni livres.
- **Révélé :** 10 éliminations · **Complétion Construct :** + réduction des dégâts (TBD).

**Érudit Spectral** — `mob_c07_erudit_spectral`
- **Famille :** Mort-vivant · rôle caster · familier Heal
- **Avant la chute :** Un maître d'Aethel qui a refusé de fuir la nuit où la cité a compris. Il corrige toujours des copies que personne ne rendra.
- **Révélé :** 10 éliminations · **Complétion Mort-vivant :** + régénération hors combat (TBD).

**Gardien de Marbre** — `mob_c07_gardien_marbre`
- **Famille :** Construct · rôle tank · familier Tank
- **Avant la chute :** La statue-sentinelle de la grande porte de la bibliothèque. Elle garde un seuil qui ne mène plus qu'au vide.
- **Révélé :** 10 éliminations · **Complétion Construct :** + réduction des dégâts (TBD).

**Sphinx Déchu** — `mob_c07_sphinx_dechu`
- **Famille :** Bête · rôle elite · familier DPS
- **Avant la chute :** Le gardien à énigmes de la voûte interdite. Il pose encore sa question ; il a oublié la bonne réponse en même temps que la cité.
- **Révélé :** 10 éliminations · **Complétion Bête :** + vitesse d'attaque (TBD).

### Couche 8 · Terres Brisées

**Fragment Vif** — `mob_c08_fragment_vif`
- **Famille :** Élémentaire · rôle chaff · familier Heal
- **Avant la chute :** Un éclat d'espace détaché quand la géométrie a lâché. Il vibre à la mauvaise fréquence et coupe ce qu'il touche.
- **Révélé :** 10 éliminations · **Complétion Élémentaire :** + RES magique (TBD).

**Rampe des Angles** — `mob_c08_rampe_angles`
- **Famille :** Construct · rôle swift · familier DPS
- **Avant la chute :** Un pan d'escalier d'une tour effondrée, qui a gardé l'habitude de mener quelque part. Il se replie sur les voyageurs.
- **Révélé :** 10 éliminations · **Complétion Construct :** + réduction des dégâts (TBD).

**Errant Défait** — `mob_c08_errant_defait`
- **Famille :** Mort-vivant · rôle bruiser · familier Tank
- **Avant la chute :** Un aventurier venu plus bas que son dernier feu de camp. Personne ne l'a rappelé ; il cherche encore le chemin du retour.
- **Révélé :** 10 éliminations · **Complétion Mort-vivant :** + régénération hors combat (TBD).

**Veilleur Fracturé** — `mob_c08_veilleur_fracture`
- **Famille :** Construct · rôle caster · familier Heal
- **Avant la chute :** Une balise de relevé plantée par les arpenteurs de la Faille. Ses mesures ne collent plus ; elle continue de les crier.
- **Révélé :** 10 éliminations · **Complétion Construct :** + réduction des dégâts (TBD).

**Chien Non-Euclidien** — `mob_c08_chien_non_euclidien`
- **Famille :** Bête · rôle elite · familier DPS
- **Avant la chute :** Un chien de meute d'expédition qui a suivi son maître dans une faille où les angles se replient. Il en est ressorti avec une patte de trop et aucun maître.
- **Révélé :** 10 éliminations · **Complétion Bête :** + vitesse d'attaque (TBD).

**Masse Aberrante** — `mob_c08_masse_aberrante`
- **Famille :** Élémentaire · rôle tank · familier Tank
- **Avant la chute :** De la matière que le sol brisé a repliée sur elle-même trop de fois. Elle roule vers le point bas, comme tout le reste ici.
- **Révélé :** 10 éliminations · **Complétion Élémentaire :** + RES magique (TBD).

### Couche 9 · Landes du Deuil

**Lueur du Deuil** — `mob_c09_lueur_deuil`
- **Famille :** Mort-vivant · rôle chaff · familier Heal
- **Avant la chute :** La petite flamme qu'on posait sur une tombe le soir de la veillée. Il n'y a plus de tombes ; les flammes flottent quand même.
- **Révélé :** 10 éliminations · **Complétion Mort-vivant :** + régénération hors combat (TBD).

**Chien de Cendre et d'Os** — `mob_c09_chien_cendre_os`
- **Famille :** Mort-vivant · rôle swift · familier DPS
- **Avant la chute :** Le chien fidèle d'une famille des landes, resté couché sur un seuil brûlé bien après le départ des siens.
- **Révélé :** 10 éliminations · **Complétion Mort-vivant :** + régénération hors combat (TBD).

**Porte-Étendard** — `mob_c09_porte_etendard`
- **Famille :** Humanoïde · rôle bruiser · familier Tank
- **Avant la chute :** Le porteur de couleurs d'une compagnie tombée sans un feu pour la rattraper. Il tient la hampe droite pour une charge qui n'aura pas lieu.
- **Révélé :** 10 éliminations · **Complétion Humanoïde :** + or gagné (TBD).

**Poupée-Suaire** — `mob_c09_poupee_suaire`
- **Famille :** Construct · rôle caster · familier Heal
- **Avant la chute :** Une poupée de veillée, cousue dans un bout de linceul et laissée sur un banc d'église en signe de deuil. Personne n'est revenu la reprendre.
- **Révélé :** 10 éliminations · **Complétion Construct :** + réduction des dégâts (TBD).

**Spectre de Linceul** — `mob_c09_spectre_linceul`
- **Famille :** Mort-vivant · rôle elite · familier DPS
- **Avant la chute :** Un des tombés au-delà de la neuvième couche, sans nom sur aucune pierre. Il erre en cherchant qui pourrait le pleurer.
- **Révélé :** 10 éliminations · **Complétion Mort-vivant :** + régénération hors combat (TBD).

**Golgoth du Deuil** — `mob_c09_golgoth_deuil`
- **Famille :** Construct · rôle tank · familier Tank
- **Avant la chute :** Un monument du souvenir — une grande figure de pierre — que le chagrin des landes a fini par faire marcher.
- **Révélé :** 10 éliminations · **Complétion Construct :** + réduction des dégâts (TBD).

### Couche 10 · Forge de Fer

**Rivet Vivant** — `mob_c10_rivet_vivant`
- **Famille :** Construct · rôle chaff · familier Heal
- **Avant la chute :** Un boulon de la grande machine, animé par la vibration qui ne s'arrête jamais. Il resserre des plaques que plus personne n'inspecte.
- **Révélé :** 10 éliminations · **Complétion Construct :** + réduction des dégâts (TBD).

**Molosse à Vapeur** — `mob_c10_molosse_vapeur`
- **Famille :** Construct · rôle swift · familier DPS
- **Avant la chute :** Un chien de contremaître en fonte, chauffé à la vapeur, lâché la nuit dans les ateliers. La nuit ne s'est jamais terminée.
- **Révélé :** 10 éliminations · **Complétion Construct :** + réduction des dégâts (TBD).

**Ouvrier de Fonte** — `mob_c10_ouvrier_fonte`
- **Famille :** Humanoïde · rôle bruiser · familier Tank
- **Avant la chute :** Un fondeur qui n'a pas quitté son poste quand les équipes sont parties. Il alimente une coulée pour une commande annulée.
- **Révélé :** 10 éliminations · **Complétion Humanoïde :** + or gagné (TBD).

**Foreuse Naine** — `mob_c10_foreuse_naine`
- **Famille :** Humanoïde · rôle caster · familier Heal
- **Avant la chute :** Une opératrice de perceuse des équipes de forage. Elle relève encore la profondeur atteinte et la crie dans le vide.
- **Révélé :** 10 éliminations · **Complétion Humanoïde :** + or gagné (TBD).

**Contremaître Blindé** — `mob_c10_contremaitre_blinde`
- **Famille :** Humanoïde · rôle tank · familier Tank
- **Avant la chute :** Le chef d'atelier, harnaché de plaques contre la chaleur. Il fait toujours l'appel d'une équipe qui ne répond plus.
- **Révélé :** 10 éliminations · **Complétion Humanoïde :** + or gagné (TBD).

**Marteleur de Forge** — `mob_c10_marteleur_forge`
- **Famille :** Construct · rôle elite · familier DPS
- **Avant la chute :** Le grand marteau-pilon de la halle principale. Il frappe l'enclume au rythme prévu, sur rien.
- **Révélé :** 10 éliminations · **Complétion Construct :** + réduction des dégâts (TBD).

### Couche 11 · Faille du Vide

**Étincelle du Vide** — `mob_c11_etincelle_vide`
- **Famille :** Élémentaire · rôle chaff · familier Heal
- **Avant la chute :** Le peu de lumière qui reste là où la lumière s'arrête. Elle grésille contre le noir et s'accroche à ce qui bouge.
- **Révélé :** 10 éliminations · **Complétion Élémentaire :** + RES magique (TBD).

**Limier du Vide** — `mob_c11_limier_vide`
- **Famille :** Bête · rôle swift · familier DPS
- **Avant la chute :** Un chien d'éclaireur envoyé au seuil pour flairer ce qu'il y avait au-delà. Il en est revenu changé, et cherche encore la piste.
- **Révélé :** 10 éliminations · **Complétion Bête :** + vitesse d'attaque (TBD).

**Rampant d'Ombre** — `mob_c11_rampant_ombre`
- **Famille :** Élémentaire · rôle bruiser · familier Tank
- **Avant la chute :** Une ombre à laquelle plus rien ne fait obstacle depuis que la couche a cessé d'être un lieu. Elle avance là où il n'y a plus de sol.
- **Révélé :** 10 éliminations · **Complétion Élémentaire :** + RES magique (TBD).

**Porteur du Néant** — `mob_c11_porteur_neant`
- **Famille :** Humanoïde · rôle caster · familier Heal
- **Avant la chute :** Un savant qui a voulu emporter un morceau du Vide pour l'étudier. Il le porte toujours, et ça le porte.
- **Révélé :** 10 éliminations · **Complétion Humanoïde :** + or gagné (TBD).

**Veilleur aux Yeux** — `mob_c11_veilleur_yeux`
- **Famille :** Élémentaire · rôle elite · familier DPS
- **Avant la chute :** Un des guetteurs postés au seuil par l'Œil, couvert d'yeux qui ne sont pas les siens. Il regarde partout à la fois, sans rien rapporter à personne.
- **Révélé :** 10 éliminations · **Complétion Élémentaire :** + RES magique (TBD).

**Gueule Béante** — `mob_c11_gueule_beante`
- **Famille :** Bête · rôle tank · familier Tank
- **Avant la chute :** Une bête du seuil, toute en mâchoire, qui avalait ce qui tombait trop près du bord. Elle attend encore, ouverte.
- **Révélé :** 10 éliminations · **Complétion Bête :** + vitesse d'attaque (TBD).

### Couche 12 · Fin de Toute Chose

**Poussière Finale** — `mob_c12_poussiere_finale`
- **Famille :** Élémentaire · rôle chaff · familier Heal
- **Avant la chute :** Ce que devient tout ce qui tombe assez longtemps : de la poussière, tout en bas, qui bouge encore un peu.
- **Révélé :** 10 éliminations · **Complétion Élémentaire :** + RES magique (TBD).

**Ombre Portée** — `mob_c12_ombre_portee`
- **Famille :** Élémentaire · rôle swift · familier DPS
- **Avant la chute :** L'ombre d'un voyageur arrivé jusqu'au fond. Le voyageur est reparti — au feu de camp, ou plus loin — et l'ombre est restée.
- **Révélé :** 10 éliminations · **Complétion Élémentaire :** + RES magique (TBD).

**Reliquat** — `mob_c12_reliquat`
- **Famille :** Mort-vivant · rôle bruiser · familier Tank
- **Avant la chute :** Le peu qui subsiste de quelqu'un qui a touché le fond avant toi. Pas assez pour un nom ; juste assez pour se tenir debout.
- **Révélé :** 10 éliminations · **Complétion Mort-vivant :** + régénération hors combat (TBD).

**Témoin Silencieux** — `mob_c12_temoin_silencieux`
- **Famille :** Construct · rôle caster · familier Heal
- **Avant la chute :** Un des monolithes gravés de la fin. Il a tout consigné et n'a plus rien à dire.
- **Révélé :** 10 éliminations · **Complétion Construct :** + réduction des dégâts (TBD).

**Effondrement** — `mob_c12_effondrement`
- **Famille :** Élémentaire · rôle elite · familier DPS
- **Avant la chute :** Le mouvement lui-même — la chute de toute chose — condensé un instant en une forme qu'on peut frapper.
- **Révélé :** 10 éliminations · **Complétion Élémentaire :** + RES magique (TBD).

**Gardien du Seuil** — `mob_c12_gardien_seuil`
- **Famille :** Construct · rôle tank · familier Tank
- **Avant la chute :** La dernière statue du dernier seuil, dressée par ceux qui espéraient qu'il y aurait une porte à garder. Il n'y en a pas ; il garde quand même.
- **Révélé :** 10 éliminations · **Complétion Construct :** + réduction des dégâts (TBD).

---

## 5. Gardiens — 12 entrées

> Ordre `ZoneConfig.BossThemes`. Famille assignée depuis la bible §6 (voir §6).
> Lore condensé de la bible §6 (« Le Gardien — ce qu'il était »). Le seuil de
> révélation est **10 éliminations**, atteint via la boucle et la 2ᵈᵉ rencontre.
> Les Gardiens comptent pour le capstone « les 12 Gardiens », **pas** pour la
> complétion des 5 familles.

**Roi Gobelin** — `boss_roi_gobelin` · Couche 1, km 10
- **Famille :** Humanoïde
- **Avant la chute :** Pas un roi — un chef de bande qui s'est couronné avec l'acier de la première expédition, morte sur ce champ. Il porte la couronne de ses ennemis pour prouver qu'il les a tous dépassés.

**Golem de Pierre** — `boss_golem_pierre` · Couche 2, km 20
- **Famille :** Construct
- **Avant la chute :** Une chose gravée par les vieux bâtisseurs pour porter le dernier grand bloc jusqu'en bas et sceller la paroi. Ils sont partis sans lui dire d'arrêter ; il tient toujours son poste.

**Sorcière des Bois** — `boss_sorciere_bois` · Couche 3, km 30
- **Famille :** Élémentaire
- **Avant la chute :** La gardienne du bois. Quand la Faille a commencé à l'aspirer, elle s'est enracinée pour le retenir. Aujourd'hui elle *est* le bois — la capuche est vide, il ne reste que le fait de tenir.

**Colosse des Cendres** — `boss_colosse_cendres` · Couche 4, km 40
- **Famille :** Élémentaire
- **Avant la chute :** Un soldat — le plus grand d'une armée envoyée creuser le pare-feu. Le feu a pris l'armée avec le champ ; le Colosse est ce qui reste debout, à marcher la ligne.

**Liche Glaciale** — `boss_liche_glaciale` · Couche 5, km 50
- **Famille :** Mort-vivant
- **Avant la chute :** La souveraine de l'âge où la Faille s'est ouverte — celle qui a ordonné la première descente. Quand les expéditions ont échoué, elle est descendue elle-même, avec sa cour, pour geler la plaie.

**Tyran des Abysses** — `boss_tyran_abysses` · Couche 6, km 60
- **Famille :** Bête
- **Avant la chute :** Quelque chose qui était déjà là : un natif de l'eau profonde, la première chose que la descente a rencontrée qui *appartenait* au lieu. Il s'est cuirassé dans les navires et les armures des noyés.

**Archimage Déchu** — `boss_archimage_dechu` · Couche 7, km 70
- **Famille :** Mort-vivant
- **Avant la chute :** Le chef de l'ordre qui étudiait la Faille. Il a averti tout le monde ; personne n'a écouté. Puis il a appris la vérité et aurait voulu ne pas. Il tient un éclat de ce savoir — la seule chose qui le garde cohérent.

**Béhémoth** — `boss_behemoth` · Couche 8, km 80
- **Famille :** Bête
- **Avant la chute :** Pas une personne. La plus vieille chose de la Faille — une bête enfouie quand la huitième couche était encore une chaîne de montagnes. Les fouilles de la descente l'ont réveillée. Elle veut seulement se rendormir.

**Spectre Hurlant** — `boss_spectre_hurlant` · Couche 9, km 90
- **Famille :** Mort-vivant
- **Avant la chute :** Pas une personne — un chœur. Toutes les âmes tombées au-delà de la neuvième couche sans feu de camp pour les rattraper se rassemblent ici. Le cri, c'est elles toutes à la fois.

**Dragon de Fer** — `boss_dragon_fer` · Couche 10, km 100
- **Famille :** Construct
- **Avant la chute :** Construit, pas né. La plus grosse machine à creuser, façonnée en dragon par les ingénieurs — mascotte, et de quoi effrayer ce qui vivait dessous. Elle a continué de tourner après le départ des équipes.

**Œil du Vide** — `boss_oeil_vide` · Couche 11, km 110
- **Famille :** Élémentaire
- **Avant la chute :** Pas tombé — poussé. La Faille qui regarde en retour : la plaie devenue consciente. Les petits yeux de sa couronne sont tous les guetteurs qu'elle a absorbés.

**Avatar de la Fin** — `boss_avatar_fin` · Couche 12, km 120
- **Famille :** Élémentaire
- **Avant la chute :** Ni un monstre ni une personne : la forme que prend la fin pour qu'on ait quelque chose à combattre. Les deux lames croisées dans ses épaules sont celles de tous ceux qui sont arrivés jusque-là avant toi et ont frappé une fois.

---

## 6. Traçabilité — famille des 12 Gardiens

`ZoneConfig.BossThemes` ne porte pas de champ `famille`. Assignation depuis la
bible §6 (« ce qu'il était »), pour l'affichage codex uniquement :

| Gardien | Famille | Justification (bible §6) |
|---|---|---|
| Roi Gobelin | Humanoïde | Chef de bande gobeline couronné |
| Golem de Pierre | Construct | Chose gravée par les bâtisseurs |
| Sorcière des Bois | Élémentaire | Devenue le bois : feuilles, écorce, plumes |
| Colosse des Cendres | Élémentaire | Géant de charbon et de lave, feu qui ne s'éteint pas |
| Liche Glaciale | Mort-vivant | Souveraine squelette prise dans sa propre glace |
| Tyran des Abysses | Bête | Natif de l'eau profonde, déjà là avant la descente |
| Archimage Déchu | Mort-vivant | Robe habitée, capuche vide, tenu par un éclat |
| Béhémoth | Bête | La plus vieille bête de la Faille, enfouie puis réveillée |
| Spectre Hurlant | Mort-vivant | Chœur des âmes tombées sans feu de camp |
| Dragon de Fer | Construct | Machine à creuser, construite, jamais née |
| Œil du Vide | Élémentaire | La Faille devenue consciente, phénomène et non créature |
| Avatar de la Fin | Élémentaire | La fin faite forme — une force, pas un être |

---

## 7. Suivi Track E (follow-ups pour les autres pistes)

- **Namespaces de localisation à créer :** `boss_dialogue.*` (E2), `layer_card.<slug>.ambiance` (E3), `codex.<slug>.lore` (E4). Tous en chaînes serveur, hors filtre runtime.
- **Composant « bandeau narrateur » (Béhémoth, E2) :** style distinct de la bulle de dialogue, italique, sans portrait — à confirmer / créer avec ui-programmer.
- **`firstKill[gardienId]` / `firstKill[gardienId .. "_r2"]` (E2) :** flag profil pour les répliques héros `[chute]` (1ʳᵉ victoire seulement) — à câbler par luau-gameplay-programmer.
- **Capstone « les 12 Gardiens » (E4 §3) :** récompense à définir + chiffrer — economy-designer.
- **Bonus codex (par carte + par famille, E4 §2/§3) :** chiffrage — economy-designer.
- **Gueules (big boss 100 km, E2 §1) :** réutilisent les lignes d'arrivée R1 ; à reconfirmer selon le scope combat (C3).
