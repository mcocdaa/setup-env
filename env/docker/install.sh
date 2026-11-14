#!/bin/bash
# Docker Engine installation
# 1. Download the official install script
# 2. Patch out -qq and >/dev/null so we can see progress
# 3. Run the installer (keeps -y / DEBIAN_FRONTEND — trusted official script)
set -e
# shellcheck source=/dev/null
source "$(dirname "$(realpath "$0")")/../../lib/common.sh"

show_help() {
    cat <<EOF
Usage: main.sh docker install [options]

Download and install Docker Engine.

Steps:
  1. Download get.docker.com install script (if not cached)
  2. Patch -qq and >/dev/null to show install progress
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

# Patch: only remove -qq quiet flags and >/dev/null so output is visible
# Keep -y and DEBIAN_FRONTEND — it's the trusted official Docker installer
log_info "Patching -qq and >/dev/null to show install progress..."
sed -i 's/-qq//g' "$DOCKER_SCRIPT"
sed -i 's| >/dev/null||g' "$DOCKER_SCRIPT"

# Run the installer
log_info "Running Docker installer..."
sudo sh "$DOCKER_SCRIPT" "$@"

log_info "Docker installation complete."
