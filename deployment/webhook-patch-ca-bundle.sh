#!/bin/bash

# ROOT=$(cd $(dirname $0)/../../; pwd)

set -o errexit
set -o nounset
set -o pipefail


# export CA_BUNDLE=$(kubectl config view --raw --flatten -o json | jq -r '.clusters[] | select(.name == "'$(kubectl config current-context)'") | .cluster."certificate-authority-data"')

export CA_FBUNDLED=$(cat ca.pem | base64)

# if command -v envsubst >/dev/null 2>&1; then
#     envsubst
# else
    sed -i "s|\${CA_BUNDLE}|${CA_FBUNDLED}|g" mutatingwebhook.yaml
    sed -i "s|\${CA_BUNDLE}|${CA_FBUNDLED}|g" validatingwebhook.yaml
# fi
