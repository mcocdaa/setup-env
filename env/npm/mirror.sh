#!/bin/bash
# Configure npm registry mirror
set -e
source "$(dirname "$(realpath "$0")")/../../lib/common.sh"

show_help() {
    cat <<EOF
Usage: main.sh npm mirror [registry_url]

Configure the npm registry mirror via 'npm config set registry'.

Registry URL is read from env/npm/mirror.conf (edit that file to change default).
CLI argument overrides the config file.

Default registry: https://registry.npmmirror.com

Options:
  -h, --help    Show this help message

Examples:
  main.sh npm mirror
  main.sh npm mirror https://registry.npmjs.org
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    show_help
    exit 0
fi

ENV_DIR="$(dirname "$(realpath "$0")")"

# Load mirror config from file (default)
MIRROR_CONF="$ENV_DIR/mirror.conf"
if [ -f "$MIRROR_CONF" ]; then
    source "$MIRROR_CONF"
fi

# CLI argument overrides config file
if [ -n "${1:-}" ]; then
    REGISTRY="$1"
fi

REGISTRY="${REGISTRY:-https://registry.npmmirror.com}"

log_info "Configuring npm registry mirror: $REGISTRY"

# Set npm registry
npm config set registry "$REGISTRY"

log_info "npm registry set to: $(npm config get registry)"
