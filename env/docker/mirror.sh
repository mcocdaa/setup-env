#!/bin/bash
# Configure Docker registry mirrors via daemon.json
set -e
source "$(dirname "$(realpath "$0")")/../../lib/common.sh"

DOCKER_ETC="/etc/docker"
DAEMON_SRC="$ENV_DIR/daemon.json"
DAEMON_DST="$DOCKER_ETC/daemon.json"

log_info "Configuring Docker registry mirrors..."

# Ensure /etc/docker exists
if [ ! -d "$DOCKER_ETC" ]; then
    log_info "Creating $DOCKER_ETC ..."
    sudo mkdir -p "$DOCKER_ETC"
fi

# Backup then copy daemon.json
sudo bash -c "$(declare -f bac_cp); $(declare -f log_info); $(declare -f log_warn); $(declare -f log_error); bac_cp '$DAEMON_SRC' '$DAEMON_DST'"

log_info "Docker daemon.json written. Restart docker to apply:"
log_info "  sudo systemctl restart docker"
