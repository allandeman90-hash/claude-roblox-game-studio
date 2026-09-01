# La Descente — cartes de couche (E3)

**Version :** 1.0
**Dernière mise à jour :** 2026-09-01
**Auteur :** narrative-director (Track E — livrable E3)
**Statut :** Approuvé (proprio, 2026-09-01)
**Source de vérité :** design/narrative/la-descente.md (bible E1), §6 « Identité » de chaque couche
**Alimente :** UI de transition de couche (ui-programmer via lead-programmer), localisation (Track F).

---

## 1. Conventions

- **Déclencheur.** Affichée automatiquement à chaque **entrée dans une nouvelle
  couche** (transition de zone).
- **Durée.** ~5 s à l'écran, puis fondu. **Skippable** au tap.
- **Contenu.** Titre `Couche {n} — {nom}` + 1 phrase d'ambiance (< 90 caractères).
- **Titre composé.** `Couche {n} — {ZoneConfig.Zones[n].name}`. La source unique du
  nom de couche est `ZoneConfig` — ne jamais re-saisir un nom de couche ici.
- **Boucle infinie / Cauchemar.** La carte **complète** (nom + phrase, ~5 s) se
  **rejoue à chaque entrée** dans la couche, y compris aux passages suivants et en
  Cauchemar. Pas de version dégradée « bandeau seul ».
- **Stockage.** Phrases **pré-approuvées, stockées côté serveur**, hors filtre
  runtime (`TextService`). Namespace localisation : `layer_card.<slug>.ambiance`.
- **Ton.** Environnemental, mélancolique, jamais de gore. Aucune carte ne nomme ni
  ne divulgue l'identité du Gardien de la couche.

---

## 2. Les 12 cartes

| # | Titre | slug loc | Phrase d'ambiance (`layer_card.<slug>.ambiance`) | Car. |
|---|---|---|---|---|
| 1 | Couche 1 — Plaine de l'Aube | `plaine_aube` | « Le premier sol tombé dans la Faille. Au-dessus, les dernières étoiles s'éteignent. » | 82 |
| 2 | Couche 2 — Carrière des Runes | `carriere_runes` | « La pierre se souvient de tout. On y taillait les runes qui étayaient les murs. » | 78 |
| 3 | Couche 3 — Bois des Murmures | `bois_murmures` | « Rien ne pousse droit ici. La dernière chose verte avant la longue pierre. » | 74 |
| 4 | Couche 4 — Champs de Cendres | `champs_cendres` | « Un pare-feu allumé autour de la plaie. Il ne s'est plus jamais éteint. » | 70 |
| 5 | Couche 5 — Toundra des Âmes | `toundra_ames` | « Le froid qui retient. Les morts n'y reposent pas : on les y tient. » | 66 |
| 6 | Couche 6 — Côte des Naufrages | `cote_naufrages` | « On a noyé la Faille sous la mer d'en haut. L'eau a charrié tous les naufrages. » | 78 |
| 7 | Couche 7 — Ruines d'Aethel | `ruines_aethel` | « Aethel a fini par savoir ce qu'était la Faille. Le savoir l'a brisée en une nuit. » | 82 |
| 8 | Couche 8 — Terres Brisées | `terres_brisees` | « Là où la vieille bête marche, les angles cessent de s'accorder. » | 63 |
| 9 | Couche 9 — Landes du Deuil | `landes_deuil` | « L'écho de tout ce qui est tombé. Ici, le deuil a fini par prendre corps. » | 73 |
| 10 | Couche 10 — Forge de Fer | `forge_fer` | « La machine creuse encore. Elle agrandit la Faille en croyant la refermer. » | 74 |
| 11 | Couche 11 — Faille du Vide | `faille_vide` | « Là où la lumière s'arrête. Plus bas, la Faille cesse d'être un lieu. » | 68 |
| 12 | Couche 12 — Fin de Toute Chose | `fin_toute_chose` | « Le fond. Rien après, rien à refermer — seulement l'endroit où tout tombe. » | 74 |

---

## 3. Notes d'implémentation

- Le composant lit `n` (id de zone) → compose le titre depuis `ZoneConfig.Zones[n].name`
  → récupère `layer_card.<slug>.ambiance` par une table de correspondance `n → slug`
  (ci-dessus).
- Rejeu systématique : ne pas mettre en cache « déjà vue » — la carte se réaffiche à
  chaque franchissement de frontière de couche.
- Au-delà de la couche 12 (boucles), `n` recycle via `ZoneConfig.zoneIdFromKm` /
  modulo 12 : la carte de la couche 1 se rejoue en entrant dans la couche 13, etc.
- Carte 8 : « la vieille bête » reste volontairement vague (ne nomme pas Béhémoth).

---

## 4. Traçabilité (Identité bible §6 → phrase)

| # | Identité (bible §6, résumé) | Angle retenu pour la phrase |
|---|---|---|
| 1 | La surface qui s'effrite ; premier sol tombé, ancienne frontière du monde d'en haut | Premier sol tombé + étoiles qui s'éteignent |
| 2 | La pierre se souvient ; on y taillait la roche-rune pour étayer les parois | Mémoire de la pierre + runes d'étai |
| 3 | Rien n'y pousse droit ; dernière chose verte avant la pierre, bois-frontière maudit | Rien ne pousse droit + dernière verdure |
| 4 | Le feu ne s'est jamais éteint ; pare-feu brûlé autour de la Faille | Pare-feu jamais éteint |
| 5 | Le froid qui retient ; les morts y sont tenus, pas au repos | Froid qui retient les morts |
| 6 | Sous la ligne de flottaison ; mer d'en haut versée dans la Faille, noyés et épaves | Mer versée + naufrages charriés |
| 7 | La cité qui a trop su ; Aethel a appris la vérité, brisée en une nuit | Savoir fatal + une nuit |
| 8 | La géométrie lâche ; là où il marche, les angles cessent de s'accorder | Angles qui ne s'accordent plus |
| 9 | L'écho de tout ce qui est tombé ; le deuil rendu physique | Deuil qui prend corps |
| 10 | La machine qui creuse ; industrie sans fin pour « fermer » la Faille | Machine qui agrandit en croyant refermer |
| 11 | Là où la lumière s'arrête ; la Faille cesse d'être un lieu | Lumière qui s'arrête + plus un lieu |
| 12 | Le fond ; rien après | Le fond + rien à refermer |
