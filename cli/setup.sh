#!/usr/bin/env bash
# Bootstrap torched-devcontainer settings in ~/settings.
# Initializes the template, prompts for git identity, and runs home-manager switch.
set -euo pipefail

SETTINGS_DIR="$HOME/settings"
FLAKE_REF="github:hinriksnaer/torched-devcontainer"

# ── Check if already initialized ────────────────────────
if [ -f "$SETTINGS_DIR/flake.nix" ]; then
  echo "Settings already initialized at $SETTINGS_DIR"
  echo "To update: cd $SETTINGS_DIR && nix flake update && home-manager switch --flake .#default"
  exit 0
fi

# ── Initialize template ────────────────────────────────
echo "Initializing settings at $SETTINGS_DIR..."
mkdir -p "$SETTINGS_DIR"
cd "$SETTINGS_DIR"
nix flake init -t "$FLAKE_REF"

# ── Prompt for git identity ─────────────────────────────
echo ""
read -rp "Git name: " GIT_NAME
read -rp "Git email: " GIT_EMAIL

if [ -n "$GIT_NAME" ]; then
  sed -i "s/Your Name/$GIT_NAME/" settings.nix
fi
if [ -n "$GIT_EMAIL" ]; then
  sed -i "s/you@company.com/$GIT_EMAIL/" settings.nix
fi

echo ""
echo "Settings written to $SETTINGS_DIR/settings.nix"
echo "Review and edit if needed: vim $SETTINGS_DIR/settings.nix"
echo ""

# ── Apply home-manager configuration ───────────────────
read -rp "Apply home-manager config now? [Y/n] " APPLY
APPLY="${APPLY:-Y}"

if [[ "$APPLY" =~ ^[Yy]$ ]]; then
  echo "Applying home-manager configuration..."
  nix run home-manager/master -- switch -b backup --flake "$SETTINGS_DIR#default"
  echo ""
  echo "Done! Your environment is ready."
  echo "cd ~/workspace to enter the devShell."
else
  echo ""
  echo "Skipped. Apply later with:"
  echo "  nix run home-manager/master -- switch -b backup --flake $SETTINGS_DIR#default"
fi
