#!/bin/bash
# Configure npm registry mirror
# Usage: mirror.sh [registry_url]
set -e
source "$(dirname "$(realpath "$0")")/../../lib/common.sh"

REGISTRY="${1:-https://registry.npmmirror.com}"

log_info "Configuring npm registry mirror: $REGISTRY"

# Set npm registry
npm config set registry "$REGISTRY"

log_info "npm registry set to: $(npm config get registry)"
