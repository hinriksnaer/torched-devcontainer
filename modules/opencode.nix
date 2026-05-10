# OpenCode -- AI coding assistant (opencode.ai).
# Installs the package. Vertex AI env vars are handled by vertex.nix.
#
# The nixpkgs opencode package has a makeBinaryWrapper that triggers
# a glibc ld.so assertion on non-NixOS (stale INTERP segment layout
# from an older makeBinaryWrapper build). We bypass the broken wrapper
# and exec the real binary directly, providing the PATH prefix for
# ripgrep that the wrapper was supposed to set up.
{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.devSetup.opencode;
  wrapped = pkgs.writeShellScriptBin "opencode" ''
    export PATH="${pkgs.ripgrep}/bin''${PATH:+:$PATH}"
    exec ${pkgs.opencode}/bin/.opencode-wrapped "$@"
  '';
in {
  options.devSetup.opencode = {
    enable = lib.mkEnableOption "OpenCode AI coding assistant";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [wrapped];
  };
}
