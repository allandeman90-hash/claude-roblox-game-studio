# Decision Log

Major decisions with rationale. Append new entries at the bottom.

<!-- Template:
## YYYY-MM-DD — Decision Title

**Decision**: What was decided.

**Context**: Why this decision came up.

**Options Considered**:
1. Option A: rejected — reason
2. Option B: accepted — reason

**Deciders**: user, agent(s)

**Impact**: What changed as a result.
-->

## 2026-08-31 — GDD maître v1.0 + 119 décisions de design

**Decision**: Écriture du GDD maître (`design/gdd/master-gdd.md`) à partir du questionnaire de
119 questions (`design/questions-jeu.md` / `design/reponses-consolidees.md`) + de l'analyse de
monétisation (`design/economy/monetization.md`).

**Context**: Les décisions de design étaient éparpillées entre GAME_SPEC, docs/plan, mémoire et
conversations. Le proprio a répondu à un questionnaire QCM de 119 questions + 6 questions
supplémentaires (N1-N6) sur toute la surface du jeu.

**Décisions structurantes actées**:
- Stats montent automatiquement par classe × sous-classe (fini l'allocation manuelle au niveau) ;
  points de compétence gagnés uniquement par du jeu actif, permanents (survivent au Rebirth).
- Sous-classe au Rebirth 5 (Berserker/Gardien, Destructeur/Sage). Jalons /5 : R10 4e familier,
  R15 branche avancée, R20 donjon dimensionnel, R25 double spé, R30 maîtrise.
- Niveau max = 100 + 20×rebirths ; le mur EST la raison du Rebirth ; 1er mur vers km 25-35.
- Mode Cauchemar = ladder de difficulté par couche, infini (remplace l'idée "Ascension").
- Boss nommé tous les 10 km + big boss de raid tous les 100 km.
- Mort : garde tout, re-marche depuis le dernier feu de camp (auto-checkpoint /50 km),
  monstres réapparus. Château = feu de camp du km 0.
- "Raid" au lancement = donjon solo plus dur ; co-op en v1.1.
- Monétisation incluse au lancement, plafonds ×3, `max()` jamais empilé, un joueur gratuit
  finit tout. Classement "Robux dépensés" → paliers de Soutien non chiffrés.
- Donjon du Jour par étages, 1 clé/jour, mort = clé perdue, 7 thèmes fixes de la semaine.

**Deciders**: proprio (réponses au questionnaire), game-designer, monetization-lead,
analytics-retention-specialist, exploit-security-specialist.

**Impact**: `design/gdd/master-gdd.md` + `systems-index.md` créés. Débloque la Phase 1 (contenu).
23 GDD par système à écrire. Valeurs chiffrées `[À CALER — P1.9]` via /balance-check.
