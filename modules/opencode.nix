# OpenCode -- AI coding assistant (opencode.ai).
# Installs the package. Vertex AI env vars are handled by vertex.nix.
#
# The nixpkgs opencode binary (Bun-compiled) triggers a glibc 2.42
# ld.so assertion on non-NixOS systems. Both the makeBinaryWrapper
# and the real binary fail with Nix's glibc. We patchelf the real
# binary to use the system dynamic linker (glibc 2.40 on Fedora),
# which is compatible since only GLIBC_2.34 symbols are needed.
{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.devSetup.opencode;
  patched = pkgs.runCommand "opencode-patched" {
    nativeBuildInputs = [pkgs.patchelf];
  } ''
    mkdir -p $out/bin
    cp ${pkgs.opencode}/bin/.opencode-wrapped $out/bin/opencode
    chmod +x $out/bin/opencode
    patchelf --set-interpreter /lib64/ld-linux-x86-64.so.2 $out/bin/opencode
  '';
  wrapped = pkgs.writeShellScriptBin "opencode" ''
    export PATH="${pkgs.ripgrep}/bin''${PATH:+:$PATH}"
    exec ${patched}/bin/opencode "$@"
  '';
in {
  options.devSetup.opencode = {
    enable = lib.mkEnableOption "OpenCode AI coding assistant";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [wrapped];
  };
}
