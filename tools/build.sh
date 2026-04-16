#!/usr/bin/env bash
set -euo pipefail

# Build the Rojo project into a .rbxl file
rojo build default.project.json -o build.rbxl
