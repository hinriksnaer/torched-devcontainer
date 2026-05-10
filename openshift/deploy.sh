#!/usr/bin/env bash
# Deploy a user's dev environment to OpenShift.
# Usage: ./deploy.sh <username> [settings_repo] [hm_profile]
#
# Examples:
#   ./deploy.sh alice                                                      # template defaults
#   ./deploy.sh alice git@github.com:alice/my-config.git                   # custom repo, default profile
#   ./deploy.sh alice git@github.com:hinriksnaer/kernix.git root@container # custom repo + profile

set -euo pipefail

USERNAME="${1:?Usage: $0 <username> [settings_repo] [hm_profile]}"
SETTINGS_REPO="${2:-}"
HM_PROFILE="${3:-default}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Deploying dev environment for ${USERNAME}..."
echo "  Profile: ${HM_PROFILE}"
[ -n "$SETTINGS_REPO" ] && echo "  Repo:    ${SETTINGS_REPO}"

sed -e "s|<username>|${USERNAME}|g" \
    -e "s|<settings_repo>|${SETTINGS_REPO}|g" \
    -e "s|<hm_profile>|${HM_PROFILE}|g" \
    "${SCRIPT_DIR}/deployment.yml" | oc apply -f -

echo "Deployed (replicas=0). Scale up with:"
echo "  oc scale deployment ${USERNAME}-dev -n ${USERNAME} --replicas=1"
