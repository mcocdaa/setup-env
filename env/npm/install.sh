#!/bin/bash
# npm / Node.js installation via apt
set -e
source "$(dirname "$(realpath "$0")")/../../lib/common.sh"

show_help() {
    cat <<EOF
Usage: main.sh npm install

Install Node.js and npm via apt.

Environment variables:
  APT_MIRROR    Apt mirror URL to configure before install (optional)

Options:
  -h, --help    Show this help message

Examples:
  main.sh npm install
  APT_MIRROR=https://mirrors.tuna.tsinghua.edu.cn/ubuntu main.sh npm install
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    show_help
    exit 0
fi

log_info "Installing Node.js and npm..."

# Optionally configure apt mirror first
APT_MIRROR="${APT_MIRROR:-}"
if [ -n "$APT_MIRROR" ]; then
    log_info "Using apt mirror: $APT_MIRROR"
    MIRROR_SCRIPT="$ENV_DIR/mirror.sh"
    if [ -f "$MIRROR_SCRIPT" ]; then
        bash "$MIRROR_SCRIPT" "$APT_MIRROR"
    fi
fi

# Install Node.js and npm via apt
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs npm

log_info "Node.js $(node --version 2>/dev/null || echo '?') installed."
log_info "npm $(npm --version 2>/dev/null || echo '?') installed."
