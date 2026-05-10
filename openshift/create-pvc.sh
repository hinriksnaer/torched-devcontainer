#!/usr/bin/env bash
# Create the Nix store PVC for a user's dev environment.
# The home PVC (pytorch-ibmc-storage-*) is assumed to already exist.
# Usage: ./create-pvc.sh <username>

set -euo pipefail

USERNAME="${1:?Usage: $0 <username>}"

echo "Creating Nix store PVC for ${USERNAME}..."

oc apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nix-store-${USERNAME}
  namespace: ${USERNAME}
spec:
  accessModes: [ReadWriteMany]
  storageClassName: nfs-rwx
  resources:
    requests:
      storage: 50Gi
EOF

echo "PVC created."
