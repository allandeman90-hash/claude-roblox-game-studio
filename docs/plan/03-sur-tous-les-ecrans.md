# Quête Minute — Sur Tous les Écrans

> Le jeu tourne **uniquement en paysage** sur Roblox — orientation verrouillée. Une seule
> interface GUI qui se met à l'échelle d'un téléphone large à un moniteur 16:9. Le **coin
> haut-gauche reste libre** pour le HUD Roblox imposé (☰ menu + 💬 chat).
> Rendu visuel : `claude.ai/code/artifact/a959c35f-ef2d-489a-9db6-20b9eb5a2401`

Ce qui change d'un appareil à l'autre, c'est la **largeur disponible** et le **mode d'entrée**.

---

## L'écran de combat sur les 4 familles d'appareils

Même disposition 3 colonnes paysage partout : panneau héros à gauche, scène large au centre,
panneau ennemi + or à droite, barre de compétences centrée en bas, piste de couche pleine largeur.

### Android — téléphone · paysage ~19,5:9

Perçage caméra sur le bord gauche, boutons latéraux. Beaucoup de largeur : les 3 colonnes
s'étirent, la scène de combat est très large. Cibles tactiles ≥ 44 px. Le marqueur `☰ 💬 Roblox`
en pointillé dans le coin ; infos de jeu centrées ; la barre de PV démarre après le retrait.

### iPhone — paysage

Dynamic Island sur le **bord gauche** (pill vertical), barre d'accueil en bas. Le contenu
s'insère à l'intérieur (`ScreenGui.ScreenInsets = CoreUISafeInsets`), le ☰ Roblox reste dégagé.
Même HUD que l'Android.

### iPad — paysage 4:3

Plus carré : les panneaux latéraux prennent plus de hauteur, la scène reste centrale, cibles
tactiles agrandies. Caméra sur le bord haut.

### PC — 16:9

Barre Roblox en haut (☰ + nom du jeu + icônes chat/joueurs/⚙). Indices clavier `[ Q ] [ W ] [ E
] · A / D : se déplacer` sous les compétences. Infobulle au survol souris (`survol : Loup Sauvage
— Bête`). Scène encore plus large. Le chat Roblox s'ouvre en bas-gauche.

---

## Le menu titre — téléphone vs PC

Même disposition paysage : logo à gauche, actions à droite. Sur téléphone les boutons sont plus
gros et regroupés (2 rangées de 3) ; sur PC ils s'étalent avec plus d'air.

---

## Comment ça tient sur tout

| | |
|---|---|
| **Un seul ScreenGui** | Positions en `UDim2` Scale + `UIAspectRatioConstraint` ; pas de version « mobile » séparée à maintenir. |
| **Orientation** | Verrouillée paysage (`ScreenOrientation = LandscapeSensor` côté client). Aucun écran portrait à concevoir. |
| **HUD Roblox imposé** | Bouton ☰ menu + 💬 chat en haut-gauche, non déplaçables. On lit `GuiService.TopbarInset` et on n'y met **rien d'important** ; les infos de jeu sont centrées. `PlayerList` et `Backpack` désactivés → coin haut-droit libre. |
| **Largeur variable** | Téléphone ~2,17:1 → beaucoup de largeur. iPad 4:3 → plus carré, panneaux plus hauts. Le contenu s'adapte par `flex`, pas de rupture. |
| **Safe area iOS** | `ScreenGui.ScreenInsets = CoreUISafeInsets` : le contenu s'insère seul autour de l'île (bord gauche) et de la barre d'accueil. |
| **Zones d'appui** | Compétences en bas au centre, JOUER à droite — atteignables aux deux pouces en tenant l'appareil en paysage. |
| **Texte** | `TextScaled` + `UITextSizeConstraint` : lisible du petit téléphone au 1440p. |
| **Entrées** | Tactile : tap sur les tuiles. Clavier : `Q W E` compétences, `A / D` déplacement. Manette : gâchettes + stick. Mêmes actions. |
| **Perf** | Aucune instance GUI créée par frame (pool de dégâts). Cible 60 fps téléphone milieu de gamme, 30 fps plancher. |
