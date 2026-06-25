#!/bin/bash
# install.sh — Installs solana-bridge-skill into the local Solana AI Kit environment
# Usage: ./install.sh [optional: custom target path]

set -e

SKILL_NAME="solana-bridge-skill"
DEFAULT_TARGET="../../skills/$SKILL_NAME"
TARGET_DIR="${1:-$DEFAULT_TARGET}"

echo "=========================================================="
echo "  Installing $SKILL_NAME"
echo "  Target: $TARGET_DIR"
echo "=========================================================="

# Check that skill/ folder exists in current directory
if [ ! -d "./skill" ]; then
  echo "ERROR: skill/ folder not found. Run this script from the repo root."
  exit 1
fi

# Clear any legacy instances to avoid stale file pollution on re-runs
if [ -d "$TARGET_DIR" ]; then
  rm -rf "$TARGET_DIR"/*
fi

# Create target directory and copy clean submodules
mkdir -p "$TARGET_DIR"
cp -r skill/* "$TARGET_DIR/"

echo ""
echo "✔ Skill installed successfully."
echo "✔ Location: $TARGET_DIR"
echo ""
echo "To activate, open Claude Code in your Solana AI Kit workspace."
echo "The agent will now route Anchor IDL and frontend queries through this skill."
echo "=========================================================="
