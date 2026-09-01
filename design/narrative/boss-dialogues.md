# La Descente — dialogues des 12 Gardiens (E2)

**Version :** 1.0
**Dernière mise à jour :** 2026-09-01
**Auteur :** narrative-director (Track E — livrable E2)
**Statut :** Approuvé (proprio, 2026-09-01)
**Source de vérité :** design/narrative/la-descente.md (bible E1), §4/§5/§6/§9
**Alimente :** implémentation dialogue (luau-gameplay-programmer via lead-programmer),
localisation (Track F).

---

## 1. Conventions de livraison

- **Stockage.** Toutes ces lignes sont **pré-approuvées et stockées côté serveur**
  (`ServerStorage`). Elles ne passent **pas** par `TextService:FilterStringAsync` au
  runtime. Le nom du héros saisi par le joueur, lui, passe par le filtre natif,
  séparément — il n'apparaît jamais dans ces lignes.
- **Bulle de Gardien.** 1 bulle = **1 phrase**, lisible en < 5 s. Les rencontres
  affichent 2-3 bulles à la suite (arrivée) puis 1 bulle (chute). Chaque bulle
  s'avance au tap ; un bouton **Passer** saute toute la séquence.
- **Voix du héros.** 1 à 2 répliques courtes par rencontre. Jamais héroïque —
  constat, fatigue, tendresse. Marquées `[arrivée]` / `[chute]`.
- **Béhémoth ne parle pas.** Ses « lignes » sont du **texte narrateur en italique**
  (grondement, tremblement, lassitude), affiché dans un **bandeau bas d'écran de
  style distinct de la bulle de dialogue**, sans bulle ni portrait. Le héros, lui,
  parle normalement.
- **Ton.** Public 10-16, pas de juron, chat-filter-safe. Mélancolie, pas désespoir :
  la note finale de chaque bloc reste « la prochaine fois, plus loin ».
- **Gueules (big boss, tous les 100 km).** Réutilisent les lignes d'**arrivée de la
  1ʳᵉ rencontre** du Gardien concerné, sans ligne de chute dédiée. À reconfirmer
  selon le scope combat (C3).

---

## 2. Roi Gobelin — C1 Plaine de l'Aube (km 10) · C7 Ruines d'Aethel (km 70)

### 1ʳᵉ rencontre (km 10)
**Roi Gobelin**
1. « Cette couronne, je l'ai prise sur des chevaliers qui revenaient toujours. »
2. « Mes gars, eux, sont restés en bas. »
3. « L'escalier est fermé. Fais demi-tour. »

**Chute**
- « Descends, alors. Tu les croiseras avant moi. »

**Héros**
- `[arrivée]` « Encore un qui monte la garde pour des morts. »
- `[chute]` « Il cherchait sa bande. Je cherche du monde aussi, plus bas. »

### 2ᵈᵉ rencontre (km 70 — Ruines d'Aethel)
**Roi Gobelin** *(couronne fêlée, cape disparue)*
1. « J'ai descendu ton escalier. Jusqu'au bout. »
2. « Ils n'y étaient nulle part. »
3. « Et toi, tu montes encore. Ça, je ne peux pas le voir. »

**Chute**
- « Garde la couronne. Elle ne m'a jamais servi. »

**Héros**
- `[arrivée]` « La couronne ne tient plus sur sa tête. »
- `[chute]` « Repose-toi. J'ai regardé, moi aussi. Il n'y a personne. »

---

## 3. Golem de Pierre — C2 Carrière des Runes (km 20) · C8 Terres Brisées (km 80)

### 1ʳᵉ rencontre (km 20)
**Golem de Pierre**
1. « Le mur n'est pas fini. Personne ne passe. »
2. « J'attends le maçon. Il va venir. »
3. « Recule. »

**Chute**
- « Dis-lui que j'ai tenu. »

**Héros**
- `[arrivée]` « Personne ne viendra finir ce mur. »
- `[chute]` « Il attendait des ordres. On ne lui en a jamais donné d'autres. »

### 2ᵈᵉ rencontre (km 80 — Terres Brisées)
**Golem de Pierre** *(runes éteintes par plaques, gravures neuves sur les bras)*
1. « Le maçon n'est pas venu. J'ai gravé le reste moi-même. »
2. « Une consigne dit de t'arrêter. Je ne sais plus laquelle. »
3. « Alors je m'arrête sur toi. »

**Chute**
- « Le mur... ce n'était qu'un ordre. »

**Héros**
- `[arrivée]` « Il écrit ses propres ordres, maintenant. »
- `[chute]` « Tu peux poser ton bloc. C'est fini. »

---

## 4. Sorcière des Bois — C3 Bois des Murmures (km 30) · C9 Landes du Deuil (km 90)

### 1ʳᵉ rencontre (km 30)
**Sorcière des Bois**
1. « J'ai appelé le Château. Il a envoyé des épées. »
2. « Ces racines tiennent trois couches. Tu veux les couper ? »
3. « Tourne les talons. Le corbeau te montrera la sortie. »

**Chute**
- « Veille sur lui. Le dernier oiseau. »

**Héros**
- `[arrivée]` « Elle est devenue l'arbre qu'elle gardait. »
- `[chute]` « Je ne coupe rien. Je ne fais que passer. »

### 2ᵈᵉ rencontre (km 90 — Landes du Deuil)
**Sorcière des Bois** *(un paquet de feuilles mortes, une plume)*
1. « Le bois est tombé. Les racines avec. »
2. « Le corbeau n'a pas suivi. »
3. « Tu sens encore la surface. Je ne le supporte pas. »

**Chute**
- « Plus rien à tenir. Enfin. »

**Héros**
- `[arrivée]` « Il ne restait qu'une plume. »
- `[chute]` « L'air d'en haut. Je le lui aurais donné, si je pouvais. »

---

## 5. Colosse des Cendres — C4 Champs de Cendres (km 40) · C10 Forge de Fer (km 100)

### 1ʳᵉ rencontre (km 40)
**Colosse des Cendres**
1. « On nous a dit de brûler une ligne. L'armée a brûlé avec. »
2. « Je la marche encore. Quelqu'un doit le faire. »
3. « Ne franchis pas la cicatrice. »

**Chute**
- « Repos. Enfin repos. »

**Héros**
- `[arrivée]` « L'ordre était mauvais. Il le sait. Il marche quand même. »
- `[chute]` « Toute une armée, dans cette cendre. »

### 2ᵈᵉ rencontre (km 100 — Forge de Fer)
**Colosse des Cendres** *(plaques boulonnées sur les fissures, reliés à un haut-fourneau)*
1. « Ils m'ont trouvé sur la ligne. Ils m'ont mis au fourneau. »
2. « Je brûle pour eux, maintenant. Plus contre la Faille. »
3. « Ne traîne pas. Fais vite. »

**Chute**
- « Merci. C'était long. »

**Héros**
- `[arrivée]` « Ils l'ont changé en charbon pour leurs machines. »
- `[chute]` « Je fais vite. Promis. »

---

## 6. Liche Glaciale — C5 Toundra des Âmes (km 50) · C11 Faille du Vide (km 110)

### 1ʳᵉ rencontre (km 50)
**Liche Glaciale**
1. « C'est moi qui ai ordonné la première descente. Aucun n'est remonté. »
2. « Alors je suis descendue. Ma cour dort dans cette glace. »
3. « Ta chaleur les réveille. Repars. »

**Chute**
- « Laisse-les dormir encore un peu. »

**Héros**
- `[arrivée]` « Elle a envoyé les premiers. Elle ne se le pardonne pas. »
- `[chute]` « Une cour entière sous mes pieds. »

### 2ᵈᵉ rencontre (km 110 — Faille du Vide)
**Liche Glaciale** *(plus de glace, les bras refermés sur un vide où l'urne était)*
1. « Le Vide ne veut pas de ma glace. La cour a coulé plus bas. »
2. « Mes bras se referment sur rien. »
3. « Tu as brisé le mensonge. J'aurais presque envie de te remercier. »

**Chute**
- « Presque. »

**Héros**
- `[arrivée]` « Ses bras tenaient une urne vide depuis le début. »
- `[chute]` « Il n'y a plus de faux-semblant à garder. »

---

## 7. Tyran des Abysses — C6 Côte des Naufrages (km 60) · C12 Fin de Toute Chose (km 120)

> **Note gameplay :** la 1ʳᵉ défaite du Tyran ouvre le mode Cauchemar (bible §7). Les
> lignes ne changent pas ; l'effet est signalé par l'UI, pas par le dialogue.

### 1ʳᵉ rencontre (km 60)
**Tyran des Abysses**
1. « J'étais là avant votre toute première marche. »
2. « Vous avez versé votre mer chez moi. Elle est venue pleine de noyés. »
3. « La fosse reste fermée. Retourne à ta lumière. »

**Chute**
- « Vous inonderez tout. Comme le reste. »

**Héros**
- `[arrivée]` « Il vivait ici avant nous tous. »
- `[chute]` « On a noyé sa maison pour se rassurer. »

### 2ᵈᵉ rencontre (km 120 — Fin de Toute Chose)
**Tyran des Abysses** *(trident en béquille, bernacles sèches, aucune eau alentour)*
1. « Il n'y a plus de mer. Nulle part. »
2. « J'étais là avant vous, je serai là après. Ça ne console de rien. »
3. « Passe. Je n'ai plus de porte à tenir. »

**Chute**
- « Rends-moi à l'eau. S'il en reste. »

**Héros**
- `[arrivée]` « Il a marché jusqu'au bout du monde pour chercher l'océan. »
- `[chute]` « Il n'y a plus rien à garder, ici. »

---

## 8. Archimage Déchu — C7 Ruines d'Aethel (km 70) · boucle C1 Plaine de l'Aube (km 130)

### 1ʳᵉ rencontre (km 70)
**Archimage Déchu**
1. « J'ai prévenu la cité. Elle a ri. Elle est tombée la nuit même. »
2. « Sous nous dort un livre qui décrit ce qui t'attend au fond. »
3. « Réponds juste, ou fais demi-tour. Tu n'es pas prêt à lire. »

**Chute**
- « Tu sauras. Et tu regretteras de savoir. »

**Héros**
- `[arrivée]` « Il a eu raison trop tôt. Personne ne pardonne ça. »
- `[chute]` « Je ne veux pas lire ce livre. »

### 2ᵈᵉ rencontre (km 130 — boucle, Plaine de l'Aube)
**Archimage Déchu** *(l'éclat violet presque éteint, il lit le champ qui s'effrite)*
1. « Je remonte l'histoire. Je cherche sa première page. »
2. « Les notes de la première expédition. Le début de tout ceci. »
3. « Je te reconnais sans me souvenir de toi. Le motif se répète. »

**Chute**
- « La première page le disait déjà : ça recommence. »

**Héros**
- `[arrivée]` « Son cristal ne brille presque plus. »
- `[chute]` « On s'est déjà battus. Ni lui ni moi ne savons plus où. »

---

## 9. Béhémoth — C8 Terres Brisées (km 80) · boucle C2 Carrière des Runes (km 140)

> **Format spécial.** Béhémoth **ne parle pas**. Pas de bulle, pas de portrait. Ses
> « lignes » = **texte narrateur en italique** dans un bandeau bas d'écran au style
> distinct de la bulle. Même règle de rythme : 2-3 fragments à l'arrivée, 1 à la
> chute, tap pour avancer, Passer disponible. Le héros parle normalement.

### 1ʳᵉ rencontre (km 80)
**Narrateur** *(italique)*
1. *Le sol se soulève avant qu'on la voie.*
2. *Quelque chose de très vieux vient de cesser de dormir.*
3. *Un grondement monte du roc — plus une plainte qu'une menace.*

**Chute** *(italique)*
- *La grande tête retombe. Le tremblement s'éteint. Pour elle, ça ressemble peut-être à du repos.*

**Héros**
- `[arrivée]` « Désolé de t'avoir réveillée. »
- `[chute]` « Elle voulait juste dormir. »

### 2ᵈᵉ rencontre (km 140 — boucle, Carrière des Runes)
**Narrateur** *(italique)*
1. *Elle s'est terrée au fond d'une fosse. La poussière retombe sur elle comme une couverture.*
2. *Elle ne charge pas. Elle se replie et gronde bas : pars.*
3. *Le tremblement est plus faible qu'avant. Même la fatigue se fatigue.*

**Chute** *(italique)*
- *Elle s'affaisse là où elle voulait rester. Cette fois, peut-être qu'elle dormira.*

**Héros**
- `[arrivée]` « Je ne voulais pas de ce combat non plus. »
- `[chute]` « Elle n'a pas bougé. Pas une seule fois. »

---

## 10. Spectre Hurlant — C9 Landes du Deuil (km 90) · boucle C3 Bois des Murmures (km 150)

> Le Spectre est un **chœur** : il dit « nous ».

### 1ʳᵉ rencontre (km 90)
**Spectre Hurlant**
1. « Nous sommes tous ceux qu'aucun feu n'a rattrapés. »
2. « Ton cœur bat. Ce bruit nous est insupportable. »
3. « Personne ne nous a pleurés. Reste, ou fais taire ce cœur. »

**Chute**
- « Souviens-toi de nous. Toi, au moins. »

**Héros**
- `[arrivée]` « Tous ceux tombés sans feu pour les tenir. »
- `[chute]` « Je me souviendrai. C'est tout ce que je peux. »

### 2ᵈᵉ rencontre (km 150 — boucle, Bois des Murmures)
**Spectre Hurlant** *(réduit à un murmure, il suit entre les arbres sans crier)*
1. « Nous n'avons plus la force de crier. »
2. « Nous suivons ton cœur. C'est le dernier qui bat par ici. »
3. « Ne nous chasse pas. Laisse-nous seulement derrière toi. »

**Chute**
- « Merci d'avoir écouté. Si peu que ce soit. »

**Héros**
- `[arrivée]` « Le cri s'est éteint. Reste un murmure qui suit. »
- `[chute]` « Vous pouvez marcher avec moi un moment. »

---

## 11. Dragon de Fer — C10 Forge de Fer (km 100) · boucle C4 Champs de Cendres (km 160)

> Machine sans esprit : voix **mécanique, TOUT EN CAPITALES**, phrases de consigne.
> La casse capitale est volontaire (contraste machine) — à conserver en localisation.

### 1ʳᵉ rencontre (km 100)
**Dragon de Fer**
1. « FORAGE EN COURS. NE PAS INTERROMPRE. »
2. « LES ÉQUIPES SONT PARTIES. LA CONSIGNE TIENT : PLUS PROFOND. »
3. « OBSTACLE DÉTECTÉ. RETRAIT CONSEILLÉ. »

**Chute**
- « FORAGE... INTERROMPU. »

**Héros**
- `[arrivée]` « Personne ne l'a jamais éteinte. »
- `[chute]` « Ce sont ses tunnels qui font tout s'effondrer. »

### 2ᵈᵉ rencontre (km 160 — boucle, Champs de Cendres)
**Dragon de Fer** *(ailes grippées, tourne en cercle autour du vieux pare-feu)*
1. « NOUVELLE AFFECTATION : PATROUILLE DE LA LIGNE. »
2. « UNITÉ PRÉCÉDENTE RÉAFFECTÉE À LA FORGE. »
3. « LA LIGNE SERA TENUE. RECULE. »

**Chute**
- « POSTE... VACANT. »

**Héros**
- `[arrivée]` « Une machine qui monte la garde d'un mort. »
- `[chute]` « Le Colosse marchait ici. Maintenant, c'est elle. »

---

## 12. Œil du Vide — C11 Faille du Vide (km 110) · boucle C5 Toundra des Âmes (km 170)

### 1ʳᵉ rencontre (km 110)
**Œil du Vide**
1. « Je regarde cette descente depuis le premier chevalier tombé. »
2. « Les guetteurs que j'ai gardés voulaient voir le fond. Ils sont tous là. »
3. « Tu es intéressant. Reste dans mon champ un moment. »

**Chute**
- « Continue. Je te suis des yeux. »

**Héros**
- `[arrivée]` « La Faille a fini par ouvrir un œil. »
- `[chute]` « Tous ces regards, pris dans le sien. »

### 2ᵈᵉ rencontre (km 170 — boucle, Toundra des Âmes)
**Œil du Vide** *(givre sur la pupille, les petits yeux pris dans la glace)*
1. « Le givre a pris mes yeux. Tous. »
2. « Je t'entends bouger. Je ne te vois plus. »
3. « Approche. Que je regarde une dernière fois. »

**Chute**
- « Alors c'est le noir. Pour moi aussi. »

**Héros**
- `[arrivée]` « Même la Faille finit par ne plus voir. »
- `[chute]` « Repose tes regards. Ça suffit. »

---

## 13. Avatar de la Fin — C12 Fin de Toute Chose (km 120) · boucle C6 Côte des Naufrages (km 180)

### 1ʳᵉ rencontre (km 120)
**Avatar de la Fin**
1. « Chaque lame plantée en moi a été levée par quelqu'un comme toi. »
2. « Je n'ai jamais frappé le premier. Je n'en ai pas besoin. »
3. « Tu peux me vaincre. La Faille descendra quand même. »

**Chute**
- « Tu vois ? Rien n'a changé. »

**Héros**
- `[arrivée]` « Ce n'est pas un monstre. C'est la direction de la chute. »
- `[chute]` « La prochaine fois. Plus loin. »

### 2ᵈᵉ rencontre (km 180 — boucle, Côte des Naufrages)
**Avatar de la Fin** *(dans la marée, une des deux lames tombée, il regarde vers le haut)*
1. « J'ai marché. Pour la première fois. »
2. « Une lame est tombée en chemin. Je ne l'ai pas ramassée. »
3. « Je voulais voir d'où vous venez tous. Là-haut. »

**Chute**
- « Le début ressemble beaucoup à la fin. Continue quand même. »

**Héros**
- `[arrivée]` « Il a bougé. Je ne savais pas qu'il pouvait. »
- `[chute]` « La prochaine fois. Plus loin. »

---

## 14. Note d'implémentation

- **Répliques héros `[chute]` — 1ʳᵉ victoire seulement.** Elles ne se jouent qu'au
  premier kill de chaque Gardien (rencontre 1 et rencontre 2 comptées séparément).
  Aux kills suivants (boucle infinie, Cauchemar, farm), seules les bulles du Gardien
  + la réplique héros `[arrivée]` peuvent jouer ; `[chute]` est sautée.
  - Suggestion de stockage : flag `firstKill[gardienId]` (ou `firstKill[gardienId .. "_r2"]`
    pour la 2ᵈᵉ rencontre) dans le profil joueur. Si le codex tient déjà un
    kill-count par slug de boss, réutiliser `killCount == 1` au moment de la chute
    plutôt qu'ajouter un champ.
  - Le flag persiste à travers Rebirth (c'est un souvenir, pas une ressource).
- **Bulles Gardien `[arrivée]` / `[chute]`.** Séquence avançable au tap, bouton
  **Passer** global. Chaque bulle : 1 phrase, cible < 5 s de lecture.
- **Béhémoth.** Router vers le composant « bandeau narrateur » (style distinct de la
  bulle), pas vers le système de bulles de dialogue. Italique, pas de portrait.
- **Dragon de Fer.** Chaîne stockée en capitales ; ne pas appliquer de
  transformation de casse à l'affichage (garder tel quel en localisation).
- **Localisation.** Toutes les clés sous un namespace `boss_dialogue.*`
  (ex. `boss_dialogue.roi_gobelin.r1.arrivee.1`). Gérées comme chaînes serveur,
  hors filtre runtime.

---

## 15. Questions ouvertes

1. **Gueules (100 km).** Réutiliser les lignes d'arrivée de la 1ʳᵉ rencontre (choix
   actuel) ou écrire 1 bulle unique « forme de domaine » par Gueule ? Dépend de C3.
2. **Béhémoth — bandeau narrateur.** Confirmer avec l'UI dialogue qu'un style
   « bandeau bas » distinct de la bulle existe (ou est à créer).
