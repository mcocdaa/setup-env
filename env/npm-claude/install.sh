#!/bin/bash
# @anthropic-ai/claude-code (Claude Code CLI) installation via npm
set -e
source "$(dirname "$(realpath "$0")")/../../lib/common.sh"

log_info "Installing @anthropic-ai/claude-code..."

# Ensure npm is available
if ! command -v npm &>/dev/null; then
    log_error "npm is not installed. Run './main.sh npm install' first."
    exit 1
fi

npm install -g @anthropic-ai/claude-code

log_info "@anthropic-ai/claude-code installation complete."
