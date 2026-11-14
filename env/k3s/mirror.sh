#!/bin/bash
# Configure k3s containerd registry mirrors
set -e
ROOT_DIR="$(cd "$(dirname "$(realpath "$0")")/../.." && pwd)"
# shellcheck source=/dev/null
source "$ROOT_DIR/lib/common.sh"

show_help() {
    cat <<EOF
Usage: main.sh k3s mirror

Configure k3s containerd registry mirrors.

Steps:
  1. Ensure /etc/rancher/k3s/ exists
  2. Backup existing registries.yaml (→ registries.yaml.bac.N) if present
  3. Copy env/k3s/registries.yaml to /etc/rancher/k3s/registries.yaml

After running, restart k3s to apply:
  sudo systemctl restart k3s        (server)
  sudo systemctl restart k3s-agent  (agent)

Options:
  -h, --help    Show this help message
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    show_help
    exit 0
fi

ENV_DIR="$(dirname "$(realpath "$0")")"
K3S_REG_DIR="/etc/rancher/k3s"
REG_SRC="$ENV_DIR/registries.yaml"
REG_DST="$K3S_REG_DIR/registries.yaml"

log_info "Configuring k3s containerd registry mirrors..."

# Ensure /etc/rancher/k3s exists
if [ ! -d "$K3S_REG_DIR" ]; then
    log_info "Creating $K3S_REG_DIR ..."
    sudo mkdir -p "$K3S_REG_DIR"
fi

# Backup then copy registries.yaml using positional parameters
sudo bash -c '
    # shellcheck source=/dev/null
    source "$1"
    bac_cp "$2" "$3"
' _ "$ROOT_DIR/lib/common.sh" "$REG_SRC" "$REG_DST"

log_info "k3s registries.yaml written. Restart k3s to apply:"
log_info "  sudo systemctl restart k3s         # server"
log_info "  sudo systemctl restart k3s-agent   # agent"
