# torched - manage container dev environment
#
# Subcommands:
#   apply        Apply home-manager configuration (default)
#   update       Update flake inputs and apply
#   status       Show environment status
#   help         Show this help

SETTINGS_DIR="${SETTINGS_DIR:-$HOME/settings}"

case "${1:-apply}" in
    apply)
        echo ":: applying home-manager config"
        home-manager switch -b backup --flake "${SETTINGS_DIR}#default" "${@:2}"
        echo ":: done"
        ;;
    update)
        echo ":: updating flake inputs"
        nix flake update --flake "${SETTINGS_DIR}"
        echo ":: applying home-manager config"
        home-manager switch -b backup --flake "${SETTINGS_DIR}#default" "${@:2}"
        echo ":: done — restart shell or run 'direnv reload' to pick up changes"
        ;;
    status)
        echo "torched-devcontainer"
        echo ""
        echo "Settings:  ${SETTINGS_DIR}"
        echo "Workspace: $HOME/workspace"
        echo ""
        echo ":: tools"
        for cmd in opencode claude git direnv zsh; do
            if command -v "$cmd" >/dev/null 2>&1; then
                ver=$("$cmd" --version 2>&1 | head -1)
                printf "  %-12s %s\n" "$cmd" "$ver"
            else
                printf "  %-12s not installed\n" "$cmd"
            fi
        done
        echo ""
        echo ":: nix"
        nix --version
        echo "  store: $(du -sh /nix/store 2>/dev/null | cut -f1)"
        echo ""
        echo ":: flake inputs"
        nix flake metadata "${SETTINGS_DIR}" 2>/dev/null | grep -E "^    └|^    ├" || echo "  (run 'torched apply' first)"
        ;;
    -h|--help|help)
        echo "Usage: torched [command]"
        echo ""
        echo "Commands:"
        echo "  apply      Apply home-manager config (default)"
        echo "  update     Update flake inputs + apply"
        echo "  status     Show environment status"
        echo ""
        echo "Settings dir: ${SETTINGS_DIR}"
        ;;
    *)
        echo "Error: unknown command '${1}'" >&2
        echo "Run 'torched help' for usage" >&2
        exit 1
        ;;
esac
