#!/bin/bash
# uv installation — fast Python package and project manager
set -e
source "$(dirname "$(realpath "$0")")/../../lib/common.sh"

show_help() {
    cat <<EOF
Usage: main.sh uv install

Install uv — a fast Python package and project manager (by Astral).

Downloads and runs: https://astral.sh/uv/install.sh

Options:
  -h, --help    Show this help message
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    show_help
    exit 0
fi

log_info "Installing uv..."

# Official uv installer
curl -LsSf https://astral.sh/uv/install.sh | sh

log_info "uv installation complete."
log_info "Restart your shell or run: source ~/.bashrc"
