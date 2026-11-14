#!/bin/bash
# @openai/codex (OpenAI Codex CLI) installation via npm
set -e
# shellcheck source=/dev/null
source "$(dirname "$(realpath "$0")")/../../lib/common.sh"

show_help() {
    cat <<EOF
Usage: main.sh npm-codex install

Install @openai/codex globally via npm.

Requires: npm (install first with: main.sh npm install)

Options:
  -h, --help    Show this help message
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    show_help
    exit 0
fi

log_info "Installing @openai/codex..."

# Ensure npm is available
if ! command -v npm &>/dev/null; then
    log_error "npm is not installed. Run './main.sh npm install' first."
    exit 1
fi

npm install -g @openai/codex

log_info "@openai/codex installation complete."
