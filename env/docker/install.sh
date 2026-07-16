#!/bin/bash
# Docker Engine installation
# 1. Download the official install script
# 2. Patch out -qq quiet flags so we can see progress
# 3. Run the installer
set -e
source "$(dirname "$(realpath "$0")")/../../lib/common.sh"

log_info "Installing Docker Engine..."

# Download the official Docker install script
DOCKER_SCRIPT="$ENV_DIR/install_docker.sh"
if [ ! -f "$DOCKER_SCRIPT" ]; then
    log_info "Downloading Docker install script..."
    curl -fsSL https://get.docker.com -o "$DOCKER_SCRIPT"
fi

# Patch: remove -qq flags so output is visible (not silent)
# The official script uses -q or -qq on apt-get/dnf commands
log_info "Patching quiet flags (-qq) to show install progress..."
sed -i 's/-qq//g' "$DOCKER_SCRIPT"

# Run the installer
log_info "Running Docker installer..."
sudo sh "$DOCKER_SCRIPT" "$@"

log_info "Docker installation complete."
