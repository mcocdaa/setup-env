#!/bin/bash
# openclaw env — npm global package
set -e
ENV_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"

show_help() {
    cat <<EOF
Usage: main.sh openclaw <command>

Commands:
  install     Install openclaw globally via npm
              Requires npm to be installed first (main.sh npm install).

  -h, --help  Show this help message

Examples:
  main.sh openclaw install
  main.sh openclaw install -h  (show install help)
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
        echo "Run 'main.sh openclaw -h' for usage."
        exit 1
        ;;
esac
