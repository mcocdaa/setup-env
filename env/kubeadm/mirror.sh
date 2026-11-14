#!/bin/bash
# Configure kubeadm containerd registry mirrors via per-registry hosts.toml
set -e
ROOT_DIR="$(cd "$(dirname "$(realpath "$0")")/../.." && pwd)"
# shellcheck source=/dev/null
source "$ROOT_DIR/lib/common.sh"

show_help() {
    cat <<EOF
Usage: main.sh kubeadm mirror

Configure containerd registry mirrors (kubeadm clusters).

Steps:
  1. Pre-check /etc/containerd/config.toml has
     config_path = "/etc/containerd/certs.d"
  2. For each env/kubeadm/certs.d/<registry>/hosts.toml:
     - Ensure /etc/containerd/certs.d/<registry>/ exists
     - Backup existing hosts.toml (→ hosts.toml.bac.N) if present
     - Copy the new hosts.toml
  3. Apply: sudo systemctl restart containerd

After running, restart containerd to apply:
  sudo systemctl restart containerd

Options:
  -h, --help    Show this help message
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    show_help
    exit 0
fi

ENV_DIR="$(dirname "$(realpath "$0")")"
CERTS_SRC="$ENV_DIR/certs.d"
CERTS_DST="/etc/containerd/certs.d"

log_info "Configuring containerd registry mirrors..."

# Pre-check: config_path must point at certs.d, otherwise hosts.toml is ignored
if grep -q 'config_path = "/etc/containerd/certs.d"' /etc/containerd/config.toml 2>/dev/null; then
    log_info "config.toml already uses config_path = /etc/containerd/certs.d (OK)"
else
    log_warn "/etc/containerd/config.toml does NOT set config_path = /etc/containerd/certs.d"
    log_warn "hosts.toml mirrors will NOT take effect. Add it under:"
    log_warn '  [plugins."io.containerd.grpc.v1.cri".registry]'
    log_warn '  config_path = "/etc/containerd/certs.d"'
fi

# Deploy one hosts.toml per registry
found=0
for reg_dir in "$CERTS_SRC"/*/; do
    reg_dir="${reg_dir%/}"
    [ -d "$reg_dir" ] || continue
    reg="$(basename "$reg_dir")"
    src="$reg_dir/hosts.toml"
    [ -f "$src" ] || continue
    found=$((found + 1))

    dst_dir="$CERTS_DST/$reg"
    if [ ! -d "$dst_dir" ]; then
        log_info "Creating $dst_dir ..."
        sudo mkdir -p "$dst_dir"
    fi

    # Backup then copy (needs root for system paths) using positional parameters
    sudo bash -c '
        # shellcheck source=/dev/null
        source "$1"
        bac_cp "$2" "$3"
    ' _ "$ROOT_DIR/lib/common.sh" "$src" "$dst_dir/hosts.toml"
done

if [ "$found" -eq 0 ]; then
    log_error "No hosts.toml found under $CERTS_SRC"
    exit 1
fi

log_info "Containerd registry mirrors written ($found registries)."
log_info "Restart containerd to apply:"
log_info "  sudo systemctl restart containerd"
