#!/bin/bash
# pre-commit env — git hook framework
set -e
ENV_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"

show_help() {
    cat <<EOF
Usage: main.sh pre-commit <command> [args...]

Commands:
  install     Install pre-commit (git hook framework)
              Prefers uv tool -> pipx -> apt-get -> pip fallback.

  -h, --help  Show this help message

Examples:
  main.sh pre-commit install
  main.sh pre-commit install -h    (show install help)
EOF
}

COMMAND="${1:-install}"

if [ "$COMMAND" = "-h" ] || [ "$COMMAND" = "--help" ]; then
    show_help
    exit 0
fi

[[ $# -gt 0 ]] && shift

case "$COMMAND" in
    install)
        exec bash "$ENV_DIR/install.sh" "$@"
        ;;
    *)
        echo "Unknown command: $COMMAND"
        echo "Run 'main.sh pre-commit -h' for usage."
        exit 1
        ;;
esac
