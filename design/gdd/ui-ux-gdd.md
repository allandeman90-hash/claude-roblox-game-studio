# UI / UX — Langage de design & framework de composants — GDD système

**Version :** 1.0  
**Dernière mise à jour :** 2026-09-02  
**Auteur :** ux-designer  
**Statut :** Prêt pour implémentation  
**Parent :** `design/gdd/master-gdd.md` (§3 boucle, §10 technique)  
**Références :** `design/specs/inventory-implementation-spec.md` §8, `design/gdd/onboarding-gdd.md`,
`src/StarterGui/RpgGui.gui.json`

---

## 1. Overview & Purpose

Ce GDD est le **langage de design partagé** de tout le jeu — pas un écran en particulier. Chaque
future interface (Inventaire, Boutique, Codex, Feu de camp, Missions...) doit **consommer** ces
composants, couleurs, tailles et règles, pas en inventer de nouveaux à la marge.

**Rôle clé :** c'est le contrat entre `ux-designer` (qui définit ce document) et `ui-programmer`
(qui l'implémente) et `art-director` (qui définit le style visuel).

**Contrainte fondatrice (`master-gdd.md` §1, §10) :** **100 % GUI**, **un seul `ScreenGui`**
natif Roblox, **paysage verrouillé uniquement**, **mobile-first**. Ce document les opérationnalise.

---

## 2. Core Mechanics

### 2.1 Grille de sécurité et zone HUD réservée

- **Coin haut-gauche réservé en permanence** : le menu ☰ et le chat Roblox natifs ne sont **jamais** masqués.
- `ScreenGui.ScreenInsets = "DeviceSafeInsets"` et `IgnoreGuiInset = true`.
- **Grille responsive :** `UDim2` Scale partout, jamais de pixels fixes sauf tailles minimales tactiles.

### 2.2 Système de couches (ZIndex)

| Couche | Plage ZIndex | Contenu |
|---|---|---|
| `WORLD` | 0–1 | Décor de fond |
| `HUD` | 2–9 | HUD permanent |
| `POPUP` | 10–19 | Popups non-modaux |
| `SCREEN` | 20–89 | Overlays écran (Inventaire 20s, Boutique 25s, Feu de camp 30s, Codex 35s) |
| `MODAL` | 90–98 | Confirmations/dialogues (un seul visible) |
| `FTUE_OVERLAY` | 99 | Coach-marks |
| `SYSTEM` | 100 | Bannières critiques |

### 2.3 Système de couleurs

**Palette de base :**

| Rôle | Couleur | RGB |
|---|---|---|
| Fond | Noir | (0, 0, 0) |
| Bordure | Blanc | (255, 255, 255) |
| Texte principal | Blanc cassé | (235, 235, 235) |
| Texte secondaire | Gris | (150, 150, 150) |
| Positif | Vert | (120, 255, 120) |
| Alerte | Rouge | (210, 55, 55) |
| Accent | Jaune-or | (255, 220, 120) |

**Palette de rareté :**

| Rareté | Couleur | RGB | Symbole |
|---|---|---|---|
| Commun | Gris | (170, 170, 170) | aucun |
| Rare | Bleu | (80, 160, 255) | ◆ ×1 |
| Épique | Violet | (190, 110, 255) | ◆ ×2 |
| Légendaire | Orange | (255, 170, 60) | ◆ ×3 |
| Mythique | Rouge | (230, 60, 60) | ★ |

**Règle d'or :** aucune information n'est communiquée **par la couleur seule**. Toujours un symbole, un mot, ou une icône.

### 2.4 Typographie

| Niveau | Usage | MaxTextSize | MinTextSize |
|---|---|---|---|
| Display | Titres | 30 | 14 |
| Heading | Sous-titres | 22 | 12 |
| Body | Texte courant | 18 | 13 |
| Label | Petits libellés | 14 | 10 |

### 2.5 Espacement

Unité de base : **4 px**
Échelle : `4 / 8 / 12 / 16 / 24 / 32` px

### 2.6 Composants

**Bouton :** fond noir, UIStroke blanc 2 px, texte majuscule `[ TEXTE ]`, TextScaled.
**Carte d'objet :** bordure par rareté + symbole + nom + forge level.
**Modale :** titre + contenu scrollable + actions bas.
**Grille :** UIGridLayout, 7 colonnes standard, réduit sur écran étroit.

### 2.7 Zone du pouce

- Actions primaires dans le **tiers bas-droit** (paysage).
- Mode gaucher bascule en bas-gauche via `hudHand` (réglage joueur).

### 2.8 Animation

- Feedback bouton : 0,08–0,12 s.
- Ouverture modale : 0,2–0,25 s, Quad/Out.
- Norme épilepsie : max 3 Hz.
- `reducedMotion` : tweens non essentiels annulés, tween en cours → snap.

---

## 3. Data Schema

```lua
export type UiPrefs = {
    fontScale: number,          -- 0.85 - 1.5, défaut 1.0
    colorblindMode: "off" | "protanopia" | "deuteranopia" | "tritanopia",
    reducedMotion: boolean,
    highContrast: boolean,
    hudHand: "right" | "left",
}
```

---

## 4. Client-Server Split

**Serveur :** persiste `uiPrefs`, valide bornes/enums.
**Client :** rendu, layout responsive, animations, `ModalStack`, application de `uiPrefs`.

---

## 5. RemoteEvents / Functions

- `Ui_PrefsLoaded` — **S→C** : `{prefs: UiPrefs}`
- `Ui_SetPrefs` — **C→S** : `{prefs: Partial<UiPrefs>}`, rate-limit 1/s

---

## 6. Player-Facing UI

### 6.1 Structure écran type

```
[Coins: 1,200]     [Level 12]  [⚙]
         [GAME WORLD]
[Inventaire][Boutique][Quêtes][Feu]
```

### 6.2 Écran plein (SCREEN)

```
TITRE ÉCRAN                    [X]
[Onglet A][Onglet B][Onglet C]
[Filtre 1 ▾][Filtre 2 ▾]
┌───┬───┬───┬───┬───┬───┬───┐
│   │   │   │   │   │   │   │
├───┼───┼───┼───┼───┼───┼───┤
│   │   │   │   │   │   │   │
└───┴───┴───┴───┴───┴───┴───┘
Résumé (ex. "Inventaire: 87/200")
```

### 6.3 Réglages d'accessibilité

Un écran unique : sliders fontScale, sélecteur colorblindMode, toggles reducedMotion/highContrast/hudHand. Application immédiate.

---

## 7. Edge Cases & Error States

1. Écran très étroit : grille 7 → 5 colonnes dynamiquement.
2. Ratio extrême : contenu centré 16:9 max.
3. Texte long (localisé) : TextScaled + UITextSizeConstraint.
4. Deux modales simultanées : ModalStack met en file, une seule visible.
5. Changement colorblindMode : tous écrans rafraîchis en place.
6. Activation reducedMotion : tween en cours → snap à valeur finale.
7. Perte de connexion : indicateur chargement, timeout 8s → erreur.
8. Nom extrêmement long : troncature `…` + tooltip tap.
9. Navigation clavier/manette : contour focus visible, ordre tab cohérent.

---

## 8. Balancing Parameters

```lua
GameConfig.Ui = {
    minTouchTargetPx = 44,
    minContrastRatio = 4.5,
    baseSpacingPx = 4,
    buttonPressTweenSeconds = 0.10,
    modalTweenSeconds = 0.22,
    maxFlashHz = 3,
    fontScaleMin = 0.85,
    fontScaleMax = 1.5,
    fontScaleDefault = 1.0,
    gridColumnsStandard = 7,
    gridColumnsMinNarrow = 5,
    setPrefsRateLimitPerSec = 1,
}
```

---

## 9. Integration Points

**Dépend de :**
- `master-gdd.md` §10 — un seul ScreenGui, ScreenInsets, zone HUD réservée
- `src/StarterGui/RpgGui.gui.json` — conventions en usage

**Alimente :**
- `inventory-implementation-spec.md` §8 — grille 7 colonnes, couleurs rareté, modales
- `onboarding-gdd.md` §6 — coach-marks (FTUE_OVERLAY)
- Tout écran futur (Boutique, Codex, etc.) — doit consommer, pas redéfinir

**Implémentation :**
1. `ui-programmer` crée `StyleConstants.luau` (traduction tables)
2. `ui-programmer` crée `ModalStack` client
3. `art-director` valide/étend palette daltonienne
4. Tests : audit tactile, audit contraste, 3 résolutions

### Critères d'acceptation

- [ ] Tous boutons ≥ 44×44 px, testé 320×568 min
- [ ] Contraste ≥ 4,5:1
- [ ] Aucune info par couleur seule (rareté, équipé, alerte)
- [ ] Coin haut-gauche (menu + chat) jamais recouvert
- [ ] Modales suivent structure §6.2
- [ ] Accessibilité réglable en un écran
- [ ] Aucune animation > 3 Hz ; reducedMotion fonctionne
- [ ] Layout 19,5:9 à 16:9 sans élément coupé
