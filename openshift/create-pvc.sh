#!/usr/bin/env bash
# Create persistent volume claims for a user's dev environment.
# Uses NFS (nfs-rwx) for shared, persistent storage backed by the
# cluster's NVMe-backed NFS server.
# Usage: ./create-pvc.sh <username>

set -euo pipefail

USERNAME="${1:?Usage: $0 <username>}"

echo "Creating PVCs for ${USERNAME}..."

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
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: home-${USERNAME}
  namespace: ${USERNAME}
spec:
  accessModes: [ReadWriteMany]
  storageClassName: nfs-rwx
  resources:
    requests:
      storage: 100Gi
EOF

echo "PVCs created (NFS -- ReadWriteMany, backed by cluster NFS server)."
