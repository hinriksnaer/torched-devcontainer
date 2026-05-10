{
  description = "PyTorch container dev environment";

  inputs.dev-setup.url = "github:hinriksnaer/torched-devcontainer";

  outputs = {dev-setup, ...}: let
    settings = import ./settings.nix;
  in {
    homeConfigurations.default = dev-setup.lib.mkContainerHome settings;
    devShells.x86_64-linux.default = dev-setup.lib.mkDevShell settings.devShell;
  };
}
