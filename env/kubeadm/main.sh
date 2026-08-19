#!/bin/bash
# kubeadm env — kubeadm-based Kubernetes (containerd runtime)
set -e
ENV_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"

show_help() {
    cat <<EOF
Usage: main.sh kubeadm <command> [args...]

Commands:
  mirror      Configure containerd registry mirrors
              Copies env/kubeadm/certs.d/<registry>/hosts.toml to
              /etc/containerd/certs.d/<registry>/hosts.toml for each registry.
              Backs up existing files before overwriting.

  -h, --help  Show this help message

Examples:
  main.sh kubeadm mirror
  main.sh kubeadm mirror -h     (show mirror help)
EOF
}

COMMAND="${1:-install}"

if [ "$COMMAND" = "-h" ] || [ "$COMMAND" = "--help" ]; then
    show_help
    exit 0
fi

shift

case "$COMMAND" in
    mirror)
        exec bash "$ENV_DIR/$COMMAND.sh" "$@"
        ;;
    *)
        echo "Unknown command: $COMMAND"
        echo "Run 'main.sh kubeadm -h' for usage."
        exit 1
        ;;
esac
