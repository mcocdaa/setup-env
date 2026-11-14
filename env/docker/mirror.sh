#!/bin/bash
# Configure Docker registry mirrors via daemon.json
set -e
ROOT_DIR="$(cd "$(dirname "$(realpath "$0")")/../.." && pwd)"
# shellcheck source=/dev/null
source "$ROOT_DIR/lib/common.sh"

show_help() {
    cat <<EOF
Usage: main.sh docker mirror

Configure Docker registry mirrors.

Steps:
  1. Ensure /etc/docker/ exists
  2. Backup existing daemon.json (→ daemon.json.bac.N) if present
  3. Copy env/docker/daemon.json to /etc/docker/daemon.json

After running, restart Docker to apply:
  sudo systemctl restart docker

Options:
  -h, --help    Show this help message
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    show_help
    exit 0
fi

ENV_DIR="$(dirname "$(realpath "$0")")"
DOCKER_ETC="/etc/docker"
DAEMON_SRC="$ENV_DIR/daemon.json"
DAEMON_DST="$DOCKER_ETC/daemon.json"

log_info "Configuring Docker registry mirrors..."

# Ensure /etc/docker exists
if [ ! -d "$DOCKER_ETC" ]; then
    log_info "Creating $DOCKER_ETC ..."
    sudo mkdir -p "$DOCKER_ETC"
fi

# Backup then copy daemon.json using positional parameters
sudo bash -c '
    # shellcheck source=/dev/null
    source "$1"
    bac_cp "$2" "$3"
' _ "$ROOT_DIR/lib/common.sh" "$DAEMON_SRC" "$DAEMON_DST"

log_info "Docker daemon.json written. Restart docker to apply:"
log_info "  sudo systemctl restart docker"
