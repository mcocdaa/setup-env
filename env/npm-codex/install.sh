#!/bin/bash
# @anthropic-ai/codex (Claude Codex) installation via npm
set -e
source "$(dirname "$(realpath "$0")")/../../lib/common.sh"

log_info "Installing @anthropic-ai/codex..."

# Ensure npm is available
if ! command -v npm &>/dev/null; then
    log_error "npm is not installed. Run './main.sh npm install' first."
    exit 1
fi

npm install -g @anthropic-ai/codex

log_info "@anthropic-ai/codex installation complete."
