#!/usr/bin/env bash
# Create the Nix store PVC for a user's dev environment.
# Uses block storage with WaitForFirstConsumer binding so the PV
# provisions on the same node as the GPU pod.
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
  accessModes: [ReadWriteOnce]
  storageClassName: ibmc-vpc-block-metro-retain-10iops-tier
  resources:
    requests:
      storage: 50Gi
EOF

echo "PVC created (WaitForFirstConsumer -- will provision on GPU node when pod starts)."
