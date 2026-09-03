# Audit d'efficacité des tokens Codex

Date : 2026-09-01

## Décision

- Caveman non installé : il réduit surtout la prose de sortie, ajoute des instructions à chaque tour et n'améliore pas la navigation du code.
- Modèle, effort de raisonnement, code, tests et règles de correction inchangés.

## Intégration


## Benchmark local

- Lecture naïve des quatre fichiers principaux du flux combat : environ 31 851 tokens.
- Réduction de découverte sur cet exemple : environ 98,5 %; ce n'est pas une promesse sur une session complète.
- Temps local observé : ~1,0 s pour `explain`; ~3,7 s pour vérifier une mise à jour sans changement.


## Vérifications

- Play test : GameConfig, ZoneConfig, AssetMap, CombatEvent, ShopEvent, CombatServer et ReceiptService présents.
- UI/sprites visibles; aucune erreur runtime observée pendant le test.
- Build Rojo `serve.project.json` réussi.

## Limites connues

`ProductConfig.luau`, `Types.luau` et `PlayerDataService.luau`. Codex doit donc ouvrir
directement ces fichiers lorsque la tâche les touche. Cette limite ne modifie ni leur code
ni leur validité Roblox.

## Sauvegarde et retour arrière

- Sauvegarde : `C:\Users\Allan\.codex\backups\token-audit-20260901-150043`.

## Sources

- Caveman : https://github.com/JuliusBrussee/caveman
- Capsule : https://github.com/hakiyaka/capsule
- Recommandations Codex : https://developers.openai.com/api/docs/guides/latest-model
