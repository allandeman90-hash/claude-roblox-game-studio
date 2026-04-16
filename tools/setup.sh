#!/usr/bin/env bash
set -euo pipefail

# Install toolchain via Aftman and packages via Wally
aftman install && wally install && echo "Setup complete"
