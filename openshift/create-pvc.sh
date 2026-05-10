#!/usr/bin/env bash
# Create persistent volume claims for a user's dev environment.
# Usage: ./create-pvc.sh <username>

set -euo pipefail

USERNAME="${1:?Usage: $0 <username>}"

echo "Creating PVCs for ${USERNAME}..."

oc apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pytorch-ibmc-storage-${USERNAME}
  namespace: ${USERNAME}
spec:
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 100Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nix-store-${USERNAME}
  namespace: ${USERNAME}
spec:
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 50Gi
EOF

echo "PVCs created."
