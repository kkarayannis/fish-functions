#!/usr/bin/env bash
# Install fish functions to the user's fish functions directory.
# Defaults to ~/.config/fish/functions but respects $XDG_CONFIG_HOME.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/functions"

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
DEST_DIR="$CONFIG_HOME/fish/functions"

if [ ! -d "$SRC_DIR" ]; then
    echo "Error: source directory not found: $SRC_DIR" >&2
    exit 1
fi

mkdir -p "$DEST_DIR"

shopt -s nullglob
files=("$SRC_DIR"/*.fish)
shopt -u nullglob

if [ ${#files[@]} -eq 0 ]; then
    echo "Error: no .fish files found in $SRC_DIR" >&2
    exit 1
fi

echo "Installing fish functions to: $DEST_DIR"
echo

for src in "${files[@]}"; do
    name="$(basename "$src")"
    dest="$DEST_DIR/$name"

    if [ -e "$dest" ]; then
        backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
        echo "  ! $name already exists, backing up to $(basename "$backup")"
        mv "$dest" "$backup"
    fi

    cp "$src" "$dest"
    echo "  + installed $name"
done

echo
echo "Done. Open a new fish shell or run 'exec fish' to pick up the new functions."
