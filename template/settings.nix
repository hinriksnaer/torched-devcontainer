{
  # ── Git identity ──────────────────────────────────────
  git = {
    name = "Your Name";
    email = "you@company.com";
  };

  # ── Terminal tools ────────────────────────────────────
  # All tools are enabled by default.
  # Provide an attrset to configure, or set false to disable.
  tools = {
    # Shared Vertex AI backend for AI coding tools
    vertex = {
      project = "itpc-gcp-ai-eng-claude";
      region = "global";
    };

    opencode = true; # AI coding assistant (opencode.ai)
    claude-code = true; # Anthropic Claude Code CLI
    direnv = true; # auto-activate devShell on cd (works with VS Code)
    zsh = true; # minimal zsh with completions and history

    # Available but disabled by default -- uncomment to enable:
    # cli-tools = true;   # starship prompt, fzf, zoxide, bat, lsd, ripgrep, fd
  };

  # ── CUDA / PyTorch development shell ──────────────────
  devShell = {
    cudaVisibleDevices = ""; # "" = all GPUs, or e.g. "0,1"
    workspace = "$HOME/workspace"; # where projects are cloned and built

    projects = {
      pytorch = {
        repo = "https://github.com/pytorch/pytorch.git";
        branch = "viable/strict";
        cudaArch = "9.0"; # e.g. "8.0", "8.0;9.0"
        maxJobs = 16;
        buildTests = false;

        # Override or add any PyTorch build environment variable.
        # These merge on top of the defaults below.
        env = {
          # USE_FBGEMM = "1";
          # USE_NNPACK = "1";
          # CCACHE_MAXSIZE = "50G";
        };
      };

      helion = {
        repo = "https://github.com/pytorch/helion.git";
        branch = "main";
        torchIndex = "nightly/cu130";
        backends = ["cute"]; # CUTLASS support enabled
      };

      # Uncomment to enable vLLM:
      # vllm = {
      #   repo       = "https://github.com/vllm-project/vllm.git";
      #   branch     = "main";
      #   torchIndex = "nightly/cu130";
      # };
    };
  };

  # ── Container environment ─────────────────────────────
  container = {
    username = "root";
  };
}
