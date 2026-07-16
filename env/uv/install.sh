#!/bin/bash
# uv installation — fast Python package and project manager
set -e
source "$(dirname "$(realpath "$0")")/../../lib/common.sh"

log_info "Installing uv..."

# Official uv installer
curl -LsSf https://astral.sh/uv/install.sh | sh

log_info "uv installation complete."
log_info "Restart your shell or run: source ~/.bashrc"
