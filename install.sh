#!/usr/bin/env bash
# install.sh — Installs solana-bridge-skill into a Solana AI Kit skills directory
# Usage: ./install.sh [optional: custom target path]

set -euo pipefail

SKILL_NAME="solana-bridge-skill"
DEFAULT_TARGET="../../skills/$SKILL_NAME"
TARGET_DIR="${1:-$DEFAULT_TARGET}"
SOURCE_DIR="./skill"

echo "=========================================================="
echo "  Installing $SKILL_NAME"
echo "  Target: $TARGET_DIR"
echo "=========================================================="

# Check that skill/ folder exists in current directory
if [ ! -d "$SOURCE_DIR" ]; then
  echo "ERROR: skill/ folder not found. Run this script from the repo root."
  exit 1
fi

if [ ! -f "$SOURCE_DIR/SKILL.md" ]; then
  echo "ERROR: skill/SKILL.md not found. This does not look like a valid skill repo."
  exit 1
fi

case "$TARGET_DIR" in
  ""|"/"|"$HOME"|".")
    echo "ERROR: Refusing unsafe install target: $TARGET_DIR"
    exit 1
    ;;
esac

TARGET_PARENT="$(dirname "$TARGET_DIR")"
TARGET_NAME="$(basename "$TARGET_DIR")"

if [ "$TARGET_NAME" != "$SKILL_NAME" ]; then
  echo "ERROR: Target directory must be named '$SKILL_NAME' to avoid accidental overwrite."
  echo "       Received: $TARGET_DIR"
  exit 1
fi

# Only replace an existing directory if it already looks like this skill.
if [ -d "$TARGET_DIR" ]; then
  if [ ! -f "$TARGET_DIR/SKILL.md" ]; then
    echo "ERROR: Refusing to overwrite existing directory without SKILL.md: $TARGET_DIR"
    exit 1
  fi
  rm -rf "$TARGET_DIR"
fi

# Create target directory and copy clean submodules.
mkdir -p "$TARGET_PARENT"
mkdir -p "$TARGET_DIR"
cp -R "$SOURCE_DIR"/. "$TARGET_DIR"/

echo ""
echo "✔ Skill installed successfully."
echo "✔ Location: $TARGET_DIR"
echo ""
echo "To activate, open your Solana AI Kit workspace."
echo "Anchor IDL and frontend bridge tasks can now route through this skill."
echo "=========================================================="
