#!/bin/bash
# Configure uv PyPI mirror
# Sets UV_INDEX_URL and UV_DEFAULT_INDEX via environment or config
set -e
source "$(dirname "$(realpath "$0")")/../../lib/common.sh"

MIRROR_URL="${1:-https://pypi.tuna.tsinghua.edu.cn/simple}"
UV_CONFIG="${UV_CONFIG_FILE:-$HOME/.config/uv/uv.toml}"
UV_CONFIG_DIR="$(dirname "$UV_CONFIG")"

log_info "Configuring uv PyPI mirror: $MIRROR_URL"

mkdir -p "$UV_CONFIG_DIR"

if [ -f "$UV_CONFIG" ]; then
    log_warn "Backing up existing $UV_CONFIG"
    n=0
    while [ -f "${UV_CONFIG}.bac.${n}" ]; do n=$((n + 1)); done
    cp "$UV_CONFIG" "${UV_CONFIG}.bac.${n}"
fi

# Write uv config with mirror
cat > "$UV_CONFIG" <<EOF
[pip]
index-url = "$MIRROR_URL"
EOF

log_info "uv mirror configured at $UV_CONFIG"
log_info "You can also set it via environment:"
log_info "  export UV_DEFAULT_INDEX=$MIRROR_URL"
