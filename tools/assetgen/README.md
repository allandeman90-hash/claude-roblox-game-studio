# assetgen — pipeline d'assets pixel-art (ComfyUI → Roblox)

Génère **des centaines de sprites PNG pixel-art cohérents** pour *Quête minute*
via une instance **ComfyUI locale**, les post-traite (fond transparent, taille
32/64, palette limitée), les upload sur Roblox via **Open Cloud**, et écrit le
mapping `nom → rbxassetid` dans `src/ReplicatedStorage/AssetMap.luau`.

Le jeu ne lit **que** `AssetMap.luau`. Ce dossier est 100 % hors-jeu : lancer un
script ici ne touche jamais le gameplay.

## État actuel (2026-08-30)

**Générateur primaire : PixelLab (MCP)** — pixel-art natif, plus fiable que SDXL
pour des sprites à sujet unique. `tools/assetgen/pixellab_plan.yaml` liste les
**40 créations gratuites** (2 héros, 3 pets-fées, 12 boss, 23 monstres) via
`create_image_pixflux` (1 génération/asset).

> Le serveur MCP `pixellab` est ajouté (scope user, connecté) mais ses outils
> ne se chargent qu'**au démarrage de Claude Code** — il faut **relancer Claude
> Code** pour que `mcp__pixellab__*` soit disponible.

**Générateur de secours : ComfyUI + SDXL** (local) — pour les ~280 assets
restants une fois les 40 PixelLab épuisées. Installé et fonctionnel :

| | |
|---|---|
| ComfyUI portable v0.34.0 | `C:\ComfyUI\ComfyUI_windows_portable\` |
| Lancer | double-clic `run_nvidia_gpu.bat` (déjà patché `--lowvram` pour la 4 Go) → <http://127.0.0.1:8188> |
| Checkpoint | `models\checkpoints\sd_xl_base_1.0.safetensors` |
| LoRA pixel-art | `models\loras\pixel-art-xl.safetensors` |
| VAE | `models\vae\sdxl_vae.safetensors` |
| ComfyUI-Manager | installé (`custom_nodes\ComfyUI-Manager`) |
| GPU vu par ComfyUI | `cuda:0 RTX 3050 Laptop`, `LOW_VRAM`, pytorch 2.13+cu130 |

`style.yaml` et `workflow_api.json` sont déjà réglés sur ces 3 fichiers.
Avant une grosse session : ferme Chrome / OneDrive / Discord (la RAM est juste).

```
manifest.yaml       déclaratif — 1 entrée par asset (id, prompt, taille, fond)
style.yaml          config ComfyUI + style de prompt commun + politique de seed
workflow_api.json   graphe ComfyUI (format API) — modèles en placeholders
generate.py         manifest → ComfyUI → PNG bruts dans out_raw/
postprocess.py      out_raw/ → fond transparent + resize + quantize → assets/images/
upload.py           assets/images/**.png → Open Cloud → AssetMap.luau
```

---

## 1. Installer ComfyUI (Windows, pas-à-pas)

1. **Télécharger** la version portable :
   <https://github.com/comfyanonymous/ComfyUI/releases> → `ComfyUI_windows_portable_nvidia.7z`
   (version CPU dispo aussi, plus lente).
2. Extraire dans p. ex. `C:\ComfyUI_windows_portable\`.
3. Lancer `run_nvidia_gpu.bat` (ou `run_cpu.bat`). L'UI s'ouvre sur
   <http://127.0.0.1:8188>.
4. Installer **ComfyUI-Manager** (facilite l'ajout de modèles/nœuds) :
   ```
   cd ComfyUI_windows_portable\ComfyUI\custom_nodes
   git clone https://github.com/ltdrdata/ComfyUI-Manager
   ```
   Redémarrer ComfyUI. Un bouton *Manager* apparaît dans l'UI.

### Modèles recommandés pour du sprite pixel-art de jeu

**Route SDXL (qualité, GPU ≥ 6 Go)** — la plus cohérente :

| Rôle | Fichier | Où | Dossier ComfyUI |
|---|---|---|---|
| Checkpoint | `sd_xl_base_1.0.safetensors` | huggingface `stabilityai/stable-diffusion-xl-base-1.0` | `models/checkpoints/` |
| LoRA pixel-art | `pixel-art-xl.safetensors` | huggingface `nerijs/pixel-art-xl` | `models/loras/` |

Rendu à **1024×1024**, LoRA force ~1.0, `euler` / `normal`, 20-25 steps, CFG 7.
`postprocess.py` réduit ensuite en nearest-neighbor (÷16 → 64 px, ÷32 → 32 px).

**Route SD1.5 (GPU faible / CPU)** — plus rapide, un peu moins net :

| Rôle | Fichier | Où |
|---|---|---|
| Checkpoint | `dreamshaper_8.safetensors` | civitai « DreamShaper » |
| LoRA pixel-art | `pixel_art_style.safetensors` (ou équivalent) | civitai « Pixel Art Style » |

Rendu 512×512, reste identique.

> La LoRA est **optionnelle** dans le workflow : si `style.yaml → comfyui.lora`
> est vide, `generate.py` recâble le graphe pour l'ignorer.

---

## 2. Brancher ton workflow

Deux options :

**A. Tu utilises le template fourni.** Ouvre `workflow_api.json`, remplace
`PUT_CHECKPOINT_HERE.safetensors` et `PUT_PIXEL_LORA_HERE.safetensors` par les
noms exacts de tes fichiers (tels qu'ils apparaissent dans les menus ComfyUI).
Renseigne aussi `style.yaml → comfyui.checkpoint` / `comfyui.lora`.

**B. Tu construis ton propre graphe dans ComfyUI.** Une fois qu'il te plaît :
*menu ⚙ → Enable Dev mode options*, puis **Save (API Format)**. Remplace
`workflow_api.json` par ce fichier, et adapte la table `comfyui.nodes` de
`style.yaml` (id de nœud → rôle) — les id sont visibles dans le JSON.

Le graphe **doit** contenir : un chargeur de checkpoint, deux `CLIPTextEncode`
(positif / négatif), un `EmptyLatentImage`, un `KSampler`, un `VAEDecode`, un
`SaveImage`. La LoRA est facultative.

---

## 3. Environnement Python

```
cd tools/assetgen
python -m pip install -r requirements.txt
```

`rembg` (détourage IA de secours) est commenté dans `requirements.txt` — décommente
si tu veux le fallback (`onnxruntime` ~200 Mo).

---

## 4. Générer (quand tout est prêt — pas maintenant)

```
# 1. rendu brut (ComfyUI doit tourner)
python generate.py --only ui              # une catégorie
python generate.py --id slime             # un seul asset
python generate.py                        # tout le manifeste

# 2. post-traitement → assets/images/
python postprocess.py --only ui
python postprocess.py                     # tout ce qui est dans out_raw/

# 3. revue visuelle des PNG dans assets/images/ … puis :

# 4. upload Roblox + génération de AssetMap.luau
setx ROBLOX_API_KEY "xxxxx"        (une fois ; ou variable de session)
set  ROBLOX_CREATOR_ID=<userId ou groupId>
set  ROBLOX_CREATOR_TYPE=User      (ou Group)
python upload.py
```

`generate.py` et `upload.py` mettent en cache (`/.cache/`) : relancer ne
régénère et ne réuploade que ce qui a changé.

---

## 5. Clé Open Cloud (upload.py)

1. <https://create.roblox.com/dashboard/credentials> → **Create API Key**.
2. Scope : **`asset` → Read and Write**. IP : `0.0.0.0/0` (ou ton IP).
3. La clé se passe **uniquement** par variable d'environnement `ROBLOX_API_KEY`.
   Elle n'est jamais écrite sur disque ni commitée.

`ROBLOX_CREATOR_ID` = ton user id (upload sur ton compte) ou un group id.
`ROBLOX_CREATOR_TYPE` = `User` ou `Group`.

---

## 6. Intégration jeu (étape suivante, après les assets)

Une fois `AssetMap.luau` peuplé :

- `CombatClient` : `require(AssetMap)` ; skull, pet, portails, sprites
  héros/ennemis pointent vers `AssetMap[...]` au lieu de Frames colorés / emojis.
- `RpgGui` : ajout d'`ImageLabel "Sprite"` dans `HeroSlot` / `EnemyStep1/2`,
  `Icon` dans `DeathBox` et `EquipOverlay/RowTemplate`.
- `CombatServer.sendUpdate` : + `enemyId` / `petId` / `heroVoie` dans le payload.

Aucune logique de combat / éco / data touchée.
