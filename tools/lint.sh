#!/usr/bin/env bash
set -euo pipefail

# Run selene linter and stylua format check
selene src/ && stylua --check src/
