#!/bin/bash
# Setup Python venv for ASC JWT generation
set -euo pipefail
VENV_DIR="$HOME/.config/shikki/.venv"
if [ ! -f "$VENV_DIR/bin/python3" ]; then
    echo "Creating Python venv for ASC tools..."
    python3 -m venv "$VENV_DIR"
    "$VENV_DIR/bin/pip" install -q PyJWT cryptography
    echo "Done: $VENV_DIR"
else
    echo "Venv already exists: $VENV_DIR"
fi
