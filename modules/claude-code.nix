# Claude Code -- Anthropic's agentic coding CLI.
# Installs the package. Vertex AI env vars are handled by vertex.nix.
{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.devSetup.claude-code;
in {
  options.devSetup.claude-code = {
    enable = lib.mkEnableOption "Claude Code CLI";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.claude-code];
  };
}
