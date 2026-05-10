# Container glue -- Kubernetes/OpenShift pod environment setup.
# Handles non-login shell paths, session variables, and direnv workspace.
{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.devSetup.container;
  homeDir = config.home.homeDirectory;
in {
  options.devSetup.container = {
    workspace = lib.mkOption {
      type = lib.types.str;
      default = "$HOME/workspace";
      description = "Working directory where projects are cloned and built.";
    };

    configDir = lib.mkOption {
      type = lib.types.str;
      default = "$HOME/config";
      description = "Path to this flake (for direnv .envrc generation).";
    };
  };

  config = {
    # Terminal settings that oc exec doesn't propagate
    home.sessionVariables = {
      USER = config.home.username;
      TERM = "xterm-256color";
      COLORTERM = "truecolor";
      LANG = "C.UTF-8";
    };

    # oc exec starts a non-login shell that only sources .bashrc, not .profile.
    # Ensure Nix paths and session vars are loaded, then hand off to zsh
    # for interactive sessions if it's enabled and available.
    programs.bash.initExtra = ''
      [ -f "${homeDir}/.nix-profile/etc/profile.d/nix.sh" ] && . "${homeDir}/.nix-profile/etc/profile.d/nix.sh"
      [ -f "${homeDir}/.nix-profile/etc/profile.d/hm-session-vars.sh" ] && . "${homeDir}/.nix-profile/etc/profile.d/hm-session-vars.sh"
    ''
      + lib.optionalString config.devSetup.zsh.enable ''

        # Switch to zsh for interactive sessions (oc exec, ssh, etc.)
        if [ -t 0 ] && [ -z "$ZSH_VERSION" ] && command -v zsh >/dev/null 2>&1; then
          exec zsh -l
        fi
      '';

    # Auto-activate devShell when cd-ing into workspace
    home.activation.setupDirenv = lib.mkIf config.devSetup.direnv.enable (
      config.lib.dag.entryAfter ["linkGeneration"] ''
        mkdir -p "${cfg.workspace}"
        envrc="${cfg.workspace}/.envrc"
        if [ ! -f "$envrc" ] || ! grep -q "use flake ${cfg.configDir}" "$envrc" 2>/dev/null; then
          echo "use flake ${cfg.configDir}" > "$envrc"
        fi
        ${pkgs.direnv}/bin/direnv allow "$envrc" 2>/dev/null || true
      ''
    );
  };
}
