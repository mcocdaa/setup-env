#!/bin/bash
# k3s installation — lightweight Kubernetes
set -e
# shellcheck source=/dev/null
source "$(dirname "$(realpath "$0")")/../../lib/common.sh"

show_help() {
    cat <<EOF
Usage: main.sh k3s install

Install k3s — a certified Kubernetes distribution for IoT & Edge.

Downloads and runs the official installer: https://get.k3s.io

By default installs server (control plane + worker).
For an agent-only node, set INSTALL_K3S_EXEC="agent":
  curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent" sh -

Options:
  -h, --help    Show this help message

Environment variables (passed through to k3s installer):
  INSTALL_K3S_VERSION    Specific version to install
  INSTALL_K3S_EXEC       "agent" for worker node, empty for server
  INSTALL_K3S_CHANNEL    Release channel (stable, latest, etc.)
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    show_help
    exit 0
fi

log_info "Installing k3s..."

# Download and run the official k3s installer
curl -sfL https://get.k3s.io | sh -s - "$@"

log_info "k3s installation complete."
log_info "Check status: sudo systemctl status k3s"
log_info "Get nodes:   sudo kubectl get nodes"
