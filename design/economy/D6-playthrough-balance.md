# D6 — Playthrough de balance (GATE)

**Statut :** tableur 2026-09-01. Modèle sur les paramètres validés D1-D5. Verdict `/balance-check` en fin.
Le jeu doit être **DUR** (Q119).

Paramètres injectés :
```
Stats     : 4 auto/niv (Guerrier 45 POW / 40 VIT / 10 SPD / 5 LUK) + 1 libre/5niv
Ennemi    : combatBaseForLevel, refPointsPerLevel 4.7, enemyAttackInterval 2.0
Mob niv   : round(km × 3.5)          [PRÉREQUIS CODE - voir §0]
XP        : xpForNextLevel(n) = round(6 + 0.5·n^1.10) ; Σ→L100 = 4331 (vérifié Studio)
Or        : base.gold 8 · goldPerLevel 1.026 ; coût rebirth 10000·2.2^(n-1)
Rebirth   : skillMult(n) = 1 + 0.10n + 0.01n(n-1) ; xpMult(n) = 1 + 0.25n
Arme      : weaponBase 100 ; rareté 1.0/1.5/2.2/3.5/6.0 ; arme boss = ×2.5 boutique
Armure    : armorStatBase 6 · zoneScaling 1.30 · hpPctPerPiece 0.10 ; Guerrier DEF only (0 RES)
Cauchemar : hp ×1.55^k · atk ×1.35^k · récompense ×1.80^k
```

---

## 0. PRÉREQUIS CODE (non fait — bloque la validation)

`EnemyService.levelForKm` fait encore la vieille rampe (`mob niv ≈ km`). La décision de session
**`mob niv = round(km × 3.5)`** n'est pas dans le code. Requis avant tout playtest :

| Fichier | Change |
|---|---|
| `GameConfig.Enemy` | + `levelPerKm = 3.5` |
| `EnemyService.levelForKm(km)` | `→ math.max(1, math.round(km * (E.levelPerKm or 3.5)))` |
| `EnemyService.rollBoss` | niveau boss `→ round(km * levelPerKm)` (km 10 → L35, km 30 → L105) |

Tout le tableur ci-dessous suppose ce change appliqué.

---

## 1. Progression f2p — Guerrier R0, courbe A, re-marche ×1.9

Aucun checkpoint avant km 50 → mort = retour km 0 → re-kills. Facteur de re-marche XP ≈ **×1.9**
(sensibilité ×1.4 / ×2.3 en §5).

| km | zone | mob niv | XP cumulée (×1.9) | **niveau joueur** | état |
|---|---|---|---|---|---|
| 5 | 1 | 18 | 257 | ~21 | on meurt beaucoup (ratio nu ~0.6) |
| 10 | 2 | 35 | 842 | ~41 | boss C1 (Roi Gobelin L35) = mur si sous-équipé |
| 15 | 2 | 53 | 1 355 | ~55 | |
| 20 | 3 | 70 | 2 527 | ~76 | boss C2 (Golem L70) |
| 25 | 3 | 88 | 3 552 | ~90 | |
| 27 | 3 | 95 | ~4 300 | **~100 → CAP** | 1er mur de niveau |
| 30 | 3 | 105 | 5 900 (gaspillée) | 100 (gelé) | **boss C3 (Sorcière L105, magique)** |
| 35 | 4 | 123 | — | 100 | mobs +23 niv sur le joueur |
| 40 | 4 | 140 | — | 100 | mobs +40 niv |

**1er mur de niveau : km ~27** (fenêtre ×1.4→×2.3 : **km 25-30**). Cible Q26 (25-35) : ✓ bas de fourchette,
cohérent avec le choix « cycle rebirth rapide » (courbe A).

---

## 2. Combat au mur — Guerrier L100 + arme boutique RARE de zone

physATK = 370 (L100) × (1 + weaponPct) ; weaponPct = 100·1.30^(z-1)·1.5/100 ; cadence 1.31 s ;
DEF = 4 × 6·1.30^(z-1)·1.5 ; HP = 822 × 1.4 (4 pièces) = 1151.
Mob = combatBaseForLevel(L) × roster moyen (hp ×1.025 / atk ×1.053). 5/6 physiques (DEF compte),
1/6 caster magique (RES 0 → plein dégât).

| km | mob niv | joueur DPS | joueur PV×DPS | mob PV×DPS (vers joueur) | ratio | verdict |
|---|---|---|---|---|---|---|
| 27 | 95 | 1 006 | 1.16 M | 0.17 M | **6.6** | joueur écrase |
| 40 | 140 | 1 222 | 1.41 M | 0.35 M | **4.0** | joueur écrase |
| 55 | 193 | 1 504 | 1.73 M | 0.60 M | **2.9** | joueur gagne large |
| 70 | 245 | 1 504 | 1.73 M | 1.00 M | **1.7** | joueur gagne |
| 86 | 300 | 1 504 | 1.73 M | 1.45 M | **1.2** | tendu |
| 97 | 340 | 1 504 | 1.73 M | 1.86 M | **0.93** | **mur combat** |

### ⚠️ Le mur combat tombe km ~95, PAS km 27

**Cause :** les mobs (`combatBaseForLevel`) grandissent **linéairement** avec le niveau (donc
linéairement avec le km), l'équipement grandit **géométriquement** (×1.30/zone). Géométrique ×
constante bat linéaire → un Guerrier équipé RARE dépasse le cap de niveau et **continue** jusqu'à
~km 95. Le nombre `100 + 20·rebirths` ne barre rien tel quel.

L'or suit la même logique : revenu/zone ×2.46, prix gear/zone ×1.35 → le gear devient **plus**
abordable avec le temps. **Aucun mur économique non plus.**

---

## 3. BLOCANT — il faut une pénalité d'écart de niveau

Pour que `100 + 20·rebirths` soit un vrai mur (GDD : « le mur EST la raison du Rebirth »), il faut
que `mobNiv ≫ joueurNiv` fasse mal, indépendamment du gear. Proposition :

```lua
-- GameConfig.Combat  (nouveau)
levelGapGrace     = 5        -- pas de pénalité tant que l'écart <= 5
levelGapDmgStep   = 0.028    -- -2.8% de dégâts infligés par niveau d'écart au-delà de la grâce
levelGapDmgFloor  = 0.12     -- plancher (on tape toujours un peu)
levelGapTakenStep = 0.022    -- +2.2% de dégâts subis par niveau d'écart
levelGapTakenCap  = 3.0

function GameConfig.Combat.levelGapOut(playerLvl, mobLvl)   -- multiplie les dégâts DU joueur
    local gap = math.max(0, (mobLvl or 1) - (playerLvl or 1) - GameConfig.Combat.levelGapGrace)
    return math.max(GameConfig.Combat.levelGapDmgFloor, 1 - GameConfig.Combat.levelGapDmgStep * gap)
end
function GameConfig.Combat.levelGapIn(playerLvl, mobLvl)    -- multiplie les dégâts SUR le joueur
    local gap = math.max(0, (mobLvl or 1) - (playerLvl or 1) - GameConfig.Combat.levelGapGrace)
    return math.min(GameConfig.Combat.levelGapTakenCap, 1 + GameConfig.Combat.levelGapTakenStep * gap)
end
```

Effet (Guerrier L100 équipé RARE, PV×DPS 1.73 M brut) :

| km | mob niv | écart | dégâts joueur × | dégâts subis × | joueur PV×DPS eff. | mob PV×DPS eff. | ratio |
|---|---|---|---|---|---|---|---|
| 30 | 105 | 0 | 1.00 | 1.00 | 1.73 M | 0.24 M | 7.2 |
| 35 | 123 | 18 | 0.64 | 1.29 | 1.11 M | 0.42 M | 2.6 |
| 40 | 140 | 35 | 0.16 | 1.66 | 0.28 M | 0.58 M | **0.48 → mur** |
| 45 | 158 | 53 | 0.12 | 2.06 | 0.21 M | 0.90 M | 0.23 |

→ **mur combat km ~37-40** pour un Guerrier équipé RARE (km ~33-36 sous-équipé, km ~42 équipé ÉPIQUE).
Fenêtre **km 33-42**. Encore un poil au-dessus de 25-35 ; `levelGapDmgStep 0.028 → 0.035` resserre à
km 30-37. **À trancher par le proprio + C1 (combat-gdd) + G-track pour l'implémentation.**

**Alternative** (si le proprio refuse la pénalité) : accepter « mur km 33-45 équipé / 25-30 nu » et
ajuster la cible GDD. Mais alors le level cap fait peu, et le pitch de Rebirth est mou.

---

## 4. Les 4 cibles `/balance-check`

| # | Cible | Résultat | Verdict |
|---|---|---|---|
| 1 | f2p bat boss C3 + 1 rebirth ≤ **X h** | modèle : **~1.3 h** (50 min → km 30/L95 · +10 min retries boss C3 · +20 min farm 10k or au mur). **X = 1.5 h** | ✅ (si §3 en place) |
| 2 | 1er mur km **25-35** | mur de **niveau** km 25-30 ✓ ; mur **ressenti** km 33-42 (avec §3) / km 95 (sans §3) | ⚠️ **CONDITIONNEL — §3 requis** |
| 3 | arme boutique ≤ **60 %** arme boss même zone | à rareté égale : `1.0 / 2.5 = 40 %` | ✅ |
| 4 | retraversée post-rebirth ~**20 %** du temps | modèle : **~17 %** (km 15→30 en ~7 min vs ~50 min, gear conservé + XP ×1.25) | ✅ |

---

## 5. Sensibilité — facteur de re-marche

| re-marche | mur de niveau | commentaire |
|---|---|---|
| ×1.4 (morts rares) | km ~30 | haut de la fenêtre |
| ×1.9 (référence) | km ~27 | |
| ×2.3 (morts fréquentes, pas de checkpoint) | km ~25 | bas de la fenêtre |

Bouton de calage fin (D6/K3) : `xpForNextLevel` coefficient `0.5 → 0.6` (Σ ~5100, mur +3-4 km) ou
`refPointsPerLevel 4.7 → 4.4` (mobs plus faibles, joueur pousse plus loin).

---

## 6. Check risque `skillMult(5) = ×1.70` à R5

R5 : les points GAGNÉS (auto + libres + gagnés) ×1.70. Mob inchangé (`combatBaseForLevel` ne scale
pas au rebirth). Un joueur R5 re-levelé L100 a ~1.67× les stats d'un R0 L100 → **écrase km 0-30**
(mob niv ≤ 105) : ratio PV×DPS ~2.8. **Faceroll confirmé : ~20-40 niveaux post-rebirth triviaux.**

**Bornage :**
- Checkpoint post-rebirth ≤ moitié record (Q36) → le joueur R5 (record ~km 60) redémarre km 30,
  saute les km triviaux. Le faceroll effectif = ~10-15 min, pas 30+.
- Le joueur VEUT ce coup de boost (pilier 2 « la mort fait avancer »).

**Recommandation :** garder `skillMult(n) = 1 + 0.10n + 0.01n(n-1)` pour le 1er playtest. **Valve de
sécurité prête** si K3 montre >15 min de contenu trivial post-rebirth : scinder en
- `skillMult(n)` (courbe actuelle) → **points libres + gagnés uniquement**
- `autoStatMult(n) = 1 + 0.05n` → **points auto** (R5 ×1.25 au lieu de ×1.70)
→ faceroll ~15-20 niveaux. Implémentation = G1 (StatsService doit séparer auto / gagné).

---

## 7. Verdict `/balance-check`

**CONDITIONAL PASS — 1 blocant, 1 valve de sécurité.**

| | |
|---|---|
| ✅ Cibles 1, 3, 4 | atteintes sur le modèle |
| ⚠️ Cible 2 | **BLOCANT** : sans pénalité d'écart de niveau (§3), le level cap ne barre rien (mur km 95). Avec §3 : mur km 33-42 → resserrer `levelGapDmgStep` à ~0.035 pour viser 30-37. Décision proprio + C1 + implémentation G-track. |
| ⚠️ Risque R5 | géré ; valve `autoStatMult` prête, décision reportée à K3 |
| 🔲 Prérequis §0 | `mob niv = round(km×3.5)` à écrire dans `EnemyService` avant tout playtest |

Le jeu est **DUR** au bon endroit (début brutal, boss C3 tendu, mur qui pousse au Rebirth) **à
condition** d'implémenter §0 + §3. Validation finale en jeu = **K3**.
