# Zsh -- shell setup for containers.
# Includes starship prompt, fzf, autosuggestions, history search,
# syntax highlighting, and lsd. No vi-mode or aliases -- layer those on top.
{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.devSetup.zsh;
in {
  options.devSetup.zsh = {
    enable = lib.mkEnableOption "Zsh shell";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      autosuggestion.strategy = ["history" "completion"];
      historySubstringSearch.enable = true;
      plugins = [
        {
          name = "fast-syntax-highlighting";
          src = pkgs.zsh-fast-syntax-highlighting;
          file = "share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh";
        }
      ];

      # Nix profile paths for non-NixOS hosts (containers)
      envExtra = ''
        if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
          . "$HOME/.nix-profile/etc/profile.d/nix.sh"
        fi
        if [ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
          . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
        fi
      '';

      initContent = lib.mkOrder 600 ''
        fast-theme base16 >/dev/null 2>&1 || true
      '';

      history = {
        size = 10000;
        save = 10000;
        ignoreDups = true;
        ignoreAllDups = true;
        ignoreSpace = true;
        share = true;
      };
    };

    # Starship prompt
    programs.starship = {
      enable = true;
      settings = {
        hostname.disabled = true;
        username.disabled = true;
        character = {
          success_symbol = "[>](bold green)";
          error_symbol = "[>](bold red)";
        };
      };
    };

    # Fuzzy finder (Ctrl+R for history, Ctrl+T for files)
    programs.fzf = {
      enable = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      defaultOptions = ["--height 40%" "--border"];
    };

    # fd (used by fzf)
    programs.fd.enable = true;

    # lsd (modern ls)
    programs.lsd.enable = true;

    # Keep bash functional for non-NixOS hosts that default to it
    programs.bash.enable = true;
  };
}
