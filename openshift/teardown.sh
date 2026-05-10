#!/usr/bin/env bash
# Tear down a user's dev environment.
# Usage: ./teardown.sh <username>

set -euo pipefail

USERNAME="${1:?Usage: $0 <username>}"

echo "Deleting deployment for ${USERNAME}..."
oc delete deployment "${USERNAME}-dev" -n "${USERNAME}" --ignore-not-found

echo "Deployment deleted. PVC preserved."
echo "To also delete the Nix store PVC: oc delete pvc nix-store-${USERNAME} -n ${USERNAME}"
