# Zsh -- minimal shell setup for containers.
# Enables zsh, sources Nix paths, sets sane history defaults.
# No plugins, no aliases -- layer those on top via your own HM config.
{
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

      # Nix profile paths for non-NixOS hosts (containers)
      envExtra = ''
        if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
          . "$HOME/.nix-profile/etc/profile.d/nix.sh"
        fi
        if [ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
          . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
        fi
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

    # Keep bash functional for non-NixOS hosts that default to it
    programs.bash.enable = true;
  };
}
