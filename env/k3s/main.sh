#!/bin/bash
# k3s env — lightweight Kubernetes
set -e
ENV_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"

show_help() {
    cat <<EOF
Usage: main.sh k3s <command> [args...]

Commands:
  install     Install k3s (lightweight Kubernetes)
              Runs the official k3s installer from get.k3s.io.

  mirror      Configure k3s containerd registry mirrors
              Copies registries.yaml to /etc/rancher/k3s/registries.yaml
              Backs up existing file before overwriting.

  -h, --help  Show this help message

Examples:
  main.sh k3s install
  main.sh k3s mirror
  main.sh k3s install -h       (show install help)
EOF
}

COMMAND="${1:-install}"

if [ "$COMMAND" = "-h" ] || [ "$COMMAND" = "--help" ]; then
    show_help
    exit 0
fi

[[ $# -gt 0 ]] && shift

case "$COMMAND" in
    install|mirror)
        exec bash "$ENV_DIR/$COMMAND.sh" "$@"
        ;;
    *)
        echo "Unknown command: $COMMAND"
        echo "Run 'main.sh k3s -h' for usage."
        exit 1
        ;;
esac
