#!/bin/bash
# openclaw installation via npm
set -e
source "$(dirname "$(realpath "$0")")/../../lib/common.sh"

log_info "Installing openclaw..."

# Ensure npm is available
if ! command -v npm &>/dev/null; then
    log_error "npm is not installed. Run './main.sh npm install' first."
    exit 1
fi

npm install -g openclaw

log_info "openclaw installation complete."
