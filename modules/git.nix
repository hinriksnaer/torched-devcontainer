# Git -- identity and opinionated defaults.
# Activates when name is non-empty.
{
  config,
  lib,
  ...
}: let
  cfg = config.devSetup.git;
in {
  options.devSetup.git = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Git user name.";
    };

    email = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Git user email.";
    };
  };

  config = lib.mkIf (cfg.name != "") {
    programs.git = {
      enable = true;
      signing.format = "openpgp";
      settings = {
        user.name = cfg.name;
        user.email = cfg.email;
        core.editor = "nvim";
        init.defaultBranch = "main";
        pull.rebase = false;
      };
    };
  };
}
