{
  description = "torched-devcontainer - team container dev environment for PyTorch development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixtorch = {
      url = "github:hinriksnaer/nixtorch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixtorch,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    # ── Formatter (nix fmt) ──
    formatter.${system} = pkgs.alejandra;

    # ── Library functions ──
    lib = {
      # Simple config -> complete homeManagerConfiguration
      mkContainerHome = import ./lib/container-home.nix {
        inherit home-manager nixtorch nixpkgs;
        modulesPath = ./modules;
      };

      # Re-export nixtorch's mkDevShell for convenience
      mkDevShell = nixtorch.lib.mkDevShell;
    };

    # ── Individual modules (for advanced users / kernix consumption) ──
    homeManagerModules = {
      git = ./modules/git.nix;
      vertex = ./modules/vertex.nix;
      opencode = ./modules/opencode.nix;
      claude-code = ./modules/claude-code.nix;
      direnv = ./modules/direnv.nix;
      zsh = ./modules/zsh.nix;
      container = ./modules/container.nix;
    };

    # ── Standardized team devShell ──
    devShells.${system}.default = nixtorch.lib.mkDevShell {
      cudaVisibleDevices = "";
      workspace = "$HOME/workspace";
      projects = {
        pytorch = {
          cudaArch = "9.0";
          maxJobs = 16;
        };
        helion = {
          torchIndex = "nightly/cu130";
          backends = ["cute"];
        };
      };
    };

    # ── Template ──
    templates.default = {
      path = ./template;
      description = "PyTorch container dev environment with terminal tooling";
      welcomeText = ''
        PyTorch container dev environment created.

         1. mkdir ~/settings && cd ~/settings
        2. Edit settings.nix (at minimum: git name and email)
        3. Run: nix run home-manager/master -- switch --flake .#default
        4. cd into your workspace -- direnv auto-activates the devShell

        To build PyTorch: nixtorch build pytorch
        To update:        cd ~/settings && nix flake update && home-manager switch --flake .#default
      '';
    };
  };
}
