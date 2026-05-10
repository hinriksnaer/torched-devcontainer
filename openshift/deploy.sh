#!/usr/bin/env bash
# Deploy a user's dev environment to OpenShift.
# Usage: ./deploy.sh <username>

set -euo pipefail

USERNAME="${1:?Usage: $0 <username>}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Deploying dev environment for ${USERNAME}..."
sed "s/<username>/${USERNAME}/g" "${SCRIPT_DIR}/deployment.yml" | oc apply -f -

echo "Deployed (replicas=0). Scale up with:"
echo "  oc scale deployment ${USERNAME}-dev -n ${USERNAME} --replicas=1"
