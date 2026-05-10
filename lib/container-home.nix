# mkContainerHome -- simple config attrset -> homeManagerConfiguration.
#
# Accepts the user's settings.nix and returns a complete Home Manager
# configuration ready for `home-manager switch --flake .#default`.
#
# All modules are always imported. Enable/disable is handled via
# module options so the option namespace is always defined.
{
  home-manager,
  nixtorch,
  nixpkgs,
  modulesPath,
}: userConfig: let
  lib = nixpkgs.lib;
  system = "x86_64-linux";
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  # ── Resolve user config ───────────────────────────────
  git = userConfig.git or {};
  tools = userConfig.tools or {};
  container = userConfig.container or {};
  devShell = userConfig.devShell or {};

  # Tool enable/disable: true | false | attrset (= enabled with config)
  toolEnabled = name: default: let
    val = tools.${name} or default;
  in
    if builtins.isAttrs val
    then true
    else if builtins.isBool val
    then val
    else default;

  # Extract attrset config from a tool value (returns {} for booleans)
  toolConfig = name: let
    val = tools.${name} or {};
  in
    if builtins.isAttrs val
    then val
    else {};

  # ── Container settings ────────────────────────────────
  username = container.username or "root";
  homeDir =
    if username == "root"
    then "/root"
    else "/home/${username}";

  workspace = devShell.workspace or "$HOME/workspace";

  # ── Vertex config ─────────────────────────────────────
  vertexCfg = toolConfig "vertex";

  # ── CLI tool ────────────────────────────────────────────
  torched = pkgs.writeShellApplication {
    name = "torched";
    runtimeInputs = with pkgs; [coreutils nix home-manager];
    text = builtins.readFile (modulesPath + "/../cli/torched.sh");
  };

  # ── All modules (always imported for option definitions) ──
  allModules = [
    (modulesPath + "/git.nix")
    (modulesPath + "/vertex.nix")
    (modulesPath + "/opencode.nix")
    (modulesPath + "/claude-code.nix")
    (modulesPath + "/direnv.nix")
    (modulesPath + "/zsh.nix")
    (modulesPath + "/container.nix")
  ];
in
  home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules =
      allModules
      ++ [
        {
          home.username = username;
          home.homeDirectory = homeDir;
          home.stateVersion = "24.11";
          home.packages = [torched];

          # Wire user config into module options
          devSetup = {
            git = {
              name = git.name or "";
              email = git.email or "";
            };

            vertex = {
              project = vertexCfg.project or "";
              region = vertexCfg.region or "global";
            };

            opencode.enable = toolEnabled "opencode" true;
            claude-code.enable = toolEnabled "claude-code" true;
            direnv.enable = toolEnabled "direnv" true;
            zsh.enable = toolEnabled "zsh" true;

            container = {
              inherit workspace;
              configDir = container.configDir or "$HOME/workspace/settings";
            };
          };
        }
      ];
  }
