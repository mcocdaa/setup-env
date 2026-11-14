#!/bin/bash
# pre-commit installation (uv tool -> pipx -> apt-get -> pip fallback)
# pre-commit is a framework for managing and maintaining
# multi-language pre-commit hooks.
set -e
# shellcheck source=/dev/null
source "$(dirname "$(realpath "$0")")/../../lib/common.sh"

show_help() {
    cat <<EOF
Usage: main.sh pre-commit install

Install pre-commit — a framework for managing git pre-commit hooks.

Installation preference order:
  1. uv tool install pre-commit
  2. pipx install pre-commit
  3. sudo apt-get install -y pre-commit
  4. pip3/pip install --user --break-system-packages pre-commit

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

if command -v uv &>/dev/null; then
    log_info "Using: uv tool install pre-commit"
    uv tool install pre-commit
elif command -v pipx &>/dev/null; then
    log_info "Using: pipx install pre-commit"
    pipx install pre-commit
elif command -v apt-get &>/dev/null; then
    log_info "Using: apt-get install pre-commit"
    sudo apt-get update
    sudo apt-get install -y pre-commit
else
    PIP=""
    for p in pip3 pip; do
        if command -v "$p" &>/dev/null; then
            PIP="$p"
            break
        fi
    done

    if [ -z "$PIP" ]; then
        log_error "No uv, pipx, apt-get, or pip found. Install uv first (or run './main.sh uv install')."
        exit 1
    fi

    log_info "Using: $PIP"
    if ! "$PIP" install --user --break-system-packages pre-commit; then
        "$PIP" install --user pre-commit
    fi
fi

log_info "pre-commit $(pre-commit --version 2>/dev/null || echo '(ensure ~/.local/bin is in PATH)') installed."
log_info "Setup in a repo: cd <repo> && pre-commit install"
