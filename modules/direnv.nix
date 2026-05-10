# Direnv + nix-direnv -- auto-enters nix develop environments on cd.
# Integrates with VS Code via the direnv extension.
{
  config,
  lib,
  ...
}: let
  cfg = config.devSetup.direnv;
in {
  options.devSetup.direnv = {
    enable = lib.mkEnableOption "direnv with nix-direnv integration";
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
