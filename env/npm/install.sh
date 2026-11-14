#!/bin/bash
# npm / Node.js installation via apt
set -e
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=/dev/null
source "$ROOT_DIR/lib/common.sh"

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
  APT_MIRROR=https://mirrors.tuna.tsinghua.edu.cn main.sh npm install
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
    APT_MIRROR_SCRIPT="$ROOT_DIR/env/apt/mirror.sh"
    if [ -f "$APT_MIRROR_SCRIPT" ]; then
        bash "$APT_MIRROR_SCRIPT" "$APT_MIRROR"
    fi
fi

# Install Node.js and npm via apt
sudo apt-get update
sudo apt-get install nodejs npm

log_info "Node.js $(node --version 2>/dev/null || echo '?') installed."
log_info "npm $(npm --version 2>/dev/null || echo '?') installed."
