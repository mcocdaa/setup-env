#!/bin/bash
# Docker Engine installation
# 1. Download the official install script
# 2. Patch out silent/non-interactive flags so user can see & confirm
# 3. Run the installer
set -e
source "$(dirname "$(realpath "$0")")/../../lib/common.sh"

show_help() {
    cat <<EOF
Usage: main.sh docker install [options]

Download and install Docker Engine.

Steps:
  1. Download get.docker.com install script (if not cached)
  2. Patch silent/non-interactive flags to make install interactive
  3. Run the installer with sudo

Options:
  -h, --help    Show this help message

All other options are passed through to the Docker installer.
Run 'sudo sh install_docker.sh --help' after download for installer options.
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    show_help
    exit 0
fi

log_info "Installing Docker Engine..."

ENV_DIR="$(dirname "$(realpath "$0")")"
DOCKER_SCRIPT="$ENV_DIR/install_docker.sh"

if [ ! -f "$DOCKER_SCRIPT" ]; then
    log_info "Downloading Docker install script..."
    curl -fsSL https://get.docker.com -o "$DOCKER_SCRIPT"
fi

# Patch: remove silent/non-interactive flags so user can see output and confirm
log_info "Patching install script to be interactive (removing -y, -q, DEBIAN_FRONTEND, >/dev/null)..."

# Remove DEBIAN_FRONTEND=noninteractive
sed -i 's/DEBIAN_FRONTEND=noninteractive //g' "$DOCKER_SCRIPT"

# Remove -y (assume-yes) flags — standalone and in flag lists
sed -i 's/ -y / /g' "$DOCKER_SCRIPT"
sed -i 's/ -y"/"/g' "$DOCKER_SCRIPT"

# Remove -y -q from pkg_manager_flags variables (inside quotes)
# Order matters: strip quoted patterns before generic -q/-y removal
sed -i 's/"-y -q --best"/"--best"/g' "$DOCKER_SCRIPT"
sed -i 's/"-y -q"/""/g' "$DOCKER_SCRIPT"

# Remove -qq and -q (quiet) flags — must come AFTER quoted-var patches
sed -i 's/-qq//g' "$DOCKER_SCRIPT"
sed -i 's/ -q / /g' "$DOCKER_SCRIPT"

# Remove any remaining "-y --best" (leftover from "-y -q --best" after -q removal)
sed -i 's/"-y --best"/"--best"/g' "$DOCKER_SCRIPT"

# Remove >/dev/null output suppression (but keep 2>/dev/null)
sed -i 's| >/dev/null||g' "$DOCKER_SCRIPT"

log_info "Patched. Running Docker installer (interactive)..."
sudo sh "$DOCKER_SCRIPT" "$@"

log_info "Docker installation complete."
