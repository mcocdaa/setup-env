#!/bin/bash
# npm / Node.js installation via apt
# Configures apt mirror first, then installs nodejs + npm
set -e
source "$(dirname "$(realpath "$0")")/../../lib/common.sh"

log_info "Installing Node.js and npm..."

# Optionally configure apt mirror first
APT_MIRROR="${APT_MIRROR:-}"
if [ -n "$APT_MIRROR" ]; then
    log_info "Using apt mirror: $APT_MIRROR"
    # Configure apt mirror if provided
    MIRROR_SCRIPT="$ENV_DIR/mirror.sh"
    if [ -f "$MIRROR_SCRIPT" ]; then
        bash "$MIRROR_SCRIPT" "$APT_MIRROR"
    fi
fi

# Install Node.js and npm via apt
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs npm

log_info "Node.js $(node --version 2>/dev/null || echo '?') installed."
log_info "npm $(npm --version 2>/dev/null || echo '?') installed."
