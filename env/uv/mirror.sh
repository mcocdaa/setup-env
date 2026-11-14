#!/bin/bash
# Configure uv PyPI mirror
set -e
# shellcheck source=/dev/null
source "$(dirname "$(realpath "$0")")/../../lib/common.sh"

show_help() {
    cat <<EOF
Usage: main.sh uv mirror [url]

Configure the PyPI index mirror for uv.

Mirror URL is read from env/uv/mirror.conf (edit that file to change default).
CLI argument overrides the config file.

Writes [[index]] configuration to ~/.config/uv/uv.toml.
Backs up existing uv.toml if present.

Default mirror: https://pypi.tuna.tsinghua.edu.cn/simple

Options:
  -h, --help    Show this help message

Examples:
  main.sh uv mirror
  main.sh uv mirror https://mirrors.aliyun.com/pypi/simple/
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    show_help
    exit 0
fi

ENV_DIR="$(dirname "$(realpath "$0")")"

# Load mirror config from file (default)
MIRROR_CONF="$ENV_DIR/mirror.conf"
if [ -f "$MIRROR_CONF" ]; then
    # shellcheck source=/dev/null
    source "$MIRROR_CONF"
fi

# CLI argument overrides config file
if [ -n "${1:-}" ]; then
    MIRROR_URL="$1"
fi

MIRROR_URL="${MIRROR_URL:-https://pypi.tuna.tsinghua.edu.cn/simple}"
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

# Write valid uv.toml [[index]] configuration
cat > "$UV_CONFIG" <<EOF
[[index]]
url = "${MIRROR_URL}"
default = true
EOF

log_info "uv mirror configured at $UV_CONFIG"
log_info "You can also set it via environment:"
log_info "  export UV_DEFAULT_INDEX=$MIRROR_URL"
