# Quête Minute — Playbook de Prompts

> Le préambule + ~50 prompts prêts à coller, dans l'ordre.
> Artifact : `claude.ai/code/artifact/95cfa612-6b1f-4737-be9c-e6abed07ec6a`
>
> **Repris et enrichi dans [`00-plan-complet.md`](00-plan-complet.md)** — c'est là que se
> trouvent les mêmes prompts avec, en plus, l'intention de design (« Pourquoi ») et les skills
> à lancer pour chaque étape. Ce fichier conserve la version « prompts seuls ».

---

## Comment l'utiliser

1. Colle **le préambule** au début de chaque session Claude Code (ou une fois si le contexte tient).
2. Colle **un prompt**. Laisse-moi te montrer un plan + des extraits, valide, laisse-moi construire.
3. J'implémente, je pousse vers Studio, je lance un Play test, je te rapporte. Tu valides le « ✓ Fini quand ».
4. Tu me dis de commit. On passe au prompt suivant.
5. Un prompt trop gros ? Dis-moi de le découper — je le fais.

---

## Préambule

```
Projet : Quête Minute (RPG auto-battler 2D Roblox, repo local). On suit le plan
"Director's Cut" et les maquettes paysage — je te les décris si besoin, sinon
récupère-les de ta mémoire projet.

RÈGLES NON NÉGOCIABLES :
1. 100% GUI. Aucun monde 3D, aucun Humanoid, aucune caméra, aucun personnage.
2. Orientation VERROUILLÉE paysage. Le coin haut-gauche est réservé au HUD Roblox
   (bouton ☰ menu + chat) : jamais de bouton, texte lisible ou barre importante là.
   Lis GuiService.TopbarInset pour caler. Désactive PlayerList et Backpack via
   StarterGui:SetCoreGuiEnabled. Infos de jeu centrées ou à droite.
3. Serveur autoritaire pour TOUT état (or, xp, loot, stats, achats, progression).
   Valide type + plage + cohérence de chaque argument de RemoteEvent. Rate-limit
   chaque action déclenchée par le client. Aucun RemoteFunction client→serveur.
4. Garde le système d'ÉQUIPEMENT de GAME_SPEC.md tel quel. Tout le reste suit le
   Director's Cut.
5. N'uploade AUCUN asset (compte modéré). Fallback texte / Frames procéduraux.
6. Protocole du repo : montre-moi un plan puis des extraits, demande avant Write/Edit,
   aucun commit sans mon accord.
7. Style Luau : .claude/docs/luau-style-guide.md. task.wait/spawn/defer, jamais
   wait/spawn/delay. pcall autour de tout appel de service externe. Services cachés
   en haut de module.
8. Après chaque changement : pousse vers Roblox Studio via le MCP, lance un test
   Play, lis la console, rapporte-moi toute erreur Lua.

Réponds "compris" et attends mon premier prompt.
```

---

## Les ~50 prompts

La liste complète (P0.1 … P7.6) avec le texte de chaque prompt se trouve dans
[`00-plan-complet.md`](00-plan-complet.md), section par section, avec les skills à lancer.

| Phase | Prompts | Contenu |
|-------|---------|---------|
| **P0** — Débloquer | P0.1–P0.10 | commits · assets modérés · mode dev · 4 bugs · sauvegarde · socle paysage+HUD · GDD |
| **P1** — Le monde | P1.1–P1.9 | rosters 2-12 · 50 armes · 96 armures · 40 pets · « La Descente » + boss récurrents · moteur de mécaniques de boss · codex · décor procédural · audit des nombres |
| **P2** — 1ʳᵉ session | P2.1–P2.12 | chargement · menu · création · 3-pet party · moteur de compétences · arbre de talents (back+UI) · HUD compétences+pets · FTUE · réglages · inventaire complet · château |
| **P3** — Rétention | P3.1–P3.11 | récompense quotidienne · missions · codes · classements · collections · donjon du jour · pass de saison · ligne objectif · analytics |
| **P4** — Monétisation | P4.1–P4.7 | note de design · game passes · ProcessReceipt idempotent · cosmétiques/transmog · boutique + prompts contextuels · premium · Roblox Premium |
| **P5** — Polish | P5.0–P5.8 | passe /team-polish · son + groupes + sliders · SFX · musique par biome · VFX · pool de dégâts · intro boss · game-feel GUI · QA multi-appareil |
| **P6** — Durcir | P6.1–P6.6 | audit sécu · résilience data · perf · tests TestEZ · playthrough de balance · cas limites |
| **P7** — Publier | P7.0–P7.6 | *(bloqué débannissement)* clé Open Cloud · place · maturité · IDs+badges · CI/CD · soft launch · public |

> Entre les phases : `/gate-check` ou `/milestone-review`, `/retrospective`, et `/sprint-plan` +
> `/estimate` avant la suivante. Si en retard : `/scope-check`.
>
> Le bloc social lourd (feux de camp partagés, échange, Ascension, défis, raids co-op, crews) se
> construit en post-lancement, une fois qu'il y a des joueurs pour le remplir.
