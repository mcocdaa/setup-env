#!/bin/bash
# pre-commit installation via pip
# pre-commit is a framework for managing and maintaining
# multi-language pre-commit hooks.
set -e
source "$(dirname "$(realpath "$0")")/../../lib/common.sh"

show_help() {
    cat <<EOF
Usage: main.sh pre-commit install

Install pre-commit — a framework for managing git pre-commit hooks.

Uses pip (or pip3) to install. Requires Python.

After install, set up hooks in your repo:
  cd <your-repo>
  pre-commit sample-config > .pre-commit-config.yaml   # create config
  pre-commit install                                     # install hooks
  pre-commit run --all-files                             # first run

Options:
  -h, --help    Show this help message
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    show_help
    exit 0
fi

log_info "Installing pre-commit..."

# Find pip (try pip3 first since it's the explicit Python 3 version)
PIP=""
for p in pip3 pip; do
    if command -v "$p" &>/dev/null; then
        PIP="$p"
        break
    fi
done

if [ -z "$PIP" ]; then
    log_error "pip not found. Install Python + pip first (or run './main.sh uv install')."
    exit 1
fi

log_info "Using: $PIP"
$PIP install pre-commit

log_info "pre-commit $(pre-commit --version 2>/dev/null) installed."
log_info "Setup in a repo: cd <repo> && pre-commit install"
