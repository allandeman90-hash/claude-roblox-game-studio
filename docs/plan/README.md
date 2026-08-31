# Plan de production — Quête Minute

Sauvegarde markdown des 6 documents de planification (artifacts claude.ai).
Générés le 2026-08-30 / 31 à partir d'une lecture complète du repo.

| # | Fichier | Artifact | Rôle |
|---|---------|----------|------|
| 00 | [`00-plan-complet.md`](00-plan-complet.md) | `4d515533` | **Le document de travail unique.** Vision + cadre technique + catalogue des 51 skills + ~50 prompts (P0.1 … P7.6), chacun avec ses skills, son intention et son critère de validation. |
| 01 | [`01-directors-cut.md`](01-directors-cut.md) | `dbf3e8d6` | La vision retenue en détail — 23 upgrades taggés Keep / Reshape / Add, liste de coupe pour le lancement, table de fusion avec la roadmap. |
| 02 | [`02-maquettes.md`](02-maquettes.md) | `eb8ecc96` | Les 14 écrans (menus, combat, boss, talents, inventaire, feu de camp, donjon, pass, boutique, codex, château, mort, La Descente) — layout paysage + annotations. |
| 03 | [`03-sur-tous-les-ecrans.md`](03-sur-tous-les-ecrans.md) | `a959c35f` | L'écran de combat rendu sur Android / iPhone / iPad / PC — une seule GUI paysage, mise à l'échelle continue, coin HUD Roblox réservé. |
| 04 | [`04-playbook-prompts.md`](04-playbook-prompts.md) | `95cfa612` | Le préambule + ~50 prompts prêts à coller (version sans les intentions de design — repris et enrichis dans `00`). |
| 05 | [`05-ship-roadmap.md`](05-ship-roadmap.md) | `c3744d9e` | La roadmap « sortir un jeu complet » en 8 phases, ~28 jours (fondue dans `00`, conservée pour référence). |

## Contexte

- **Vision retenue :** le « Director's Cut » (`01`), pas l'ancien `GAME_SPEC.md`. On garde de GAME_SPEC **uniquement le système d'équipement**.
- **Orientation :** paysage verrouillée. Coin haut-gauche réservé au HUD Roblox (☰ + chat) sur chaque écran.
- **Blocage :** compte Roblox modéré (sprite Béhémoth, appel rejeté) → aucun upload d'asset jusqu'au débannissement. Phases P0–P6 = travail local, non bloqué.
- **Le fichier de travail est `00-plan-complet.md`.** Quand on colle un prompt `P0.1` / `P2.5` etc., il vient de là.
