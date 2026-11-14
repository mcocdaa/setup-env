#!/bin/bash
# Common utilities sourced by all env scripts

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Backup then copy — if dst exists, rename it to dst.bac.N before copying
# Usage: bac_cp <src> <dst>
bac_cp() {
    local src="$1"
    local dst="$2"

    if [ ! -f "$src" ]; then
        log_error "Source file not found: $src"
        return 1
    fi

    if [ -f "$dst" ]; then
        # Find next available .bac.N suffix
        local n=0
        while [ -f "${dst}.bac.${n}" ]; do
            n=$((n + 1))
        done
        log_warn "Backing up '${dst}' -> '${dst}.bac.${n}'"
        cp "$dst" "${dst}.bac.${n}"
    fi

    cp "$src" "$dst"
    log_info "Copied '${src}' -> '${dst}'"
}

# Return the directory of the current env (where this script's caller lives)
# Usage: ENV_DIR=$(env_dir)
env_dir() {
    # Walk up the call stack to find the env dir
    # The caller is inside env/<name>/ so we use BASH_SOURCE
    dirname "$(realpath "${BASH_SOURCE[1]}")"
}

# Root of the install project
ROOT_DIR="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.." && pwd)"
export ROOT_DIR
