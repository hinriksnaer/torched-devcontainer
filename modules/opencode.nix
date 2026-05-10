# OpenCode -- AI coding assistant (opencode.ai).
# Installs the package. Vertex AI env vars are handled by vertex.nix.
{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.devSetup.opencode;
in {
  options.devSetup.opencode = {
    enable = lib.mkEnableOption "OpenCode AI coding assistant";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.opencode];
  };
}
