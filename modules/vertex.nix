# Vertex AI -- shared credentials and environment for AI coding tools.
# Sets env vars consumed by both OpenCode and Claude Code.
# google-cloud-sdk is installed for authentication (gcloud auth).
{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.devSetup.vertex;
  hasVertex = cfg.project != "";
in {
  options.devSetup.vertex = {
    project = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Google Cloud Vertex AI project ID.";
    };

    region = lib.mkOption {
      type = lib.types.str;
      default = "global";
      description = "Cloud ML / Vertex AI region.";
    };
  };

  config = lib.mkIf hasVertex {
    home.packages = [pkgs.google-cloud-sdk];

    home.sessionVariables = {
      CLAUDE_CODE_USE_VERTEX = "1";
      CLOUD_ML_REGION = cfg.region;
      ANTHROPIC_VERTEX_PROJECT_ID = cfg.project;
      GOOGLE_CLOUD_PROJECT = cfg.project;
      VERTEX_LOCATION = cfg.region;
    };
  };
}
