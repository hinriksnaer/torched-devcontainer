# torched-devcontainer

Nix-based team dev environment for PyTorch containers on OpenShift.

Provides a minimal container image (Fedora + Nix), a one-command bootstrap
that sets up git, AI coding tools (OpenCode, Claude Code), zsh, and direnv,
and a nixtorch devShell for CUDA/PyTorch development.

## Quick start

Connect to your pod:

```bash
oc exec -it deployment/<username>-dev -n <username> -- zsh
```

Home-manager runs automatically on pod startup. The environment is ready
to use immediately. To customize, edit your settings and apply:

```bash
vim ~/settings/settings.nix   # set git name/email, toggle tools
torched apply
```

## CLI

```bash
torched apply    # apply home-manager config
torched update   # update flake inputs + apply
torched status   # show installed tools, nix store, flake inputs
torched help     # usage
```

## Build PyTorch

```bash
cd ~/workspace
nixtorch build pytorch
nixtorch status
```

## Settings reference

All settings live in `~/settings/settings.nix`. Here are all available options
with their defaults:

```nix
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

    opencode = true;    # AI coding assistant (opencode.ai)
    claude-code = true; # Anthropic Claude Code CLI
    direnv = true;      # auto-activate devShell on cd (works with VS Code)
    zsh = true;         # minimal zsh with completions and history

    # Available but disabled by default -- uncomment to enable:
    # cli-tools = true; # starship prompt, fzf, zoxide, bat, lsd, ripgrep, fd
  };

  # ── CUDA / PyTorch development shell ──────────────────
  devShell = {
    cudaVisibleDevices = "";              # "" = all GPUs, or e.g. "0,1"
    workspace = "$HOME/workspace";       # where projects are cloned and built

    projects = {
      pytorch = {
        repo = "https://github.com/pytorch/pytorch.git";
        branch = "viable/strict";
        cudaArch = "9.0";                # e.g. "8.0", "8.0;9.0"
        maxJobs = 16;
        buildTests = false;

        # Override or add any PyTorch build environment variable.
        # These merge on top of the defaults.
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
        backends = ["cute"];             # CUTLASS support enabled
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
```

## Configuration

Edit settings and re-apply:

```bash
vim ~/settings/settings.nix
torched apply
```

### Disable a tool

```nix
tools = {
  opencode = false;
};
```

### Enable an optional tool

```nix
tools = {
  cli-tools = true;
};
```

## OpenShift deployment

### Prerequisites

- Namespace with SSH key and gcloud secrets already configured

### Deploy

```bash
cd openshift
./create-pvc.sh <username>    # creates block storage PVCs (one-time)
./deploy.sh <username>        # applies deployment YAML
oc scale deployment <username>-dev -n <username> --replicas=1
```

### Connect

```bash
oc exec -it deployment/<username>-dev -n <username> -- zsh
```

### SSH access

The container runs sshd on port 22. Use `oc port-forward` to connect:

```bash
# In a terminal on your laptop:
oc port-forward deployment/<username>-dev -n <username> 2222:22

# Then SSH in:
ssh -p 2222 root@localhost
```

For VS Code Remote-SSH, add to `~/.ssh/config`:

```
Host openshift-dev
  HostName localhost
  Port 2222
  User root
```

Then connect to `openshift-dev` in VS Code.

### Teardown

```bash
./openshift/teardown.sh <username>   # deletes deployment, keeps PVCs
```

## Architecture

```
torched-devcontainer (this repo)
  ├── lib.mkContainerHome    settings.nix -> home-manager config
  ├── lib.mkDevShell         re-exports nixtorch
  ├── torched CLI            apply / update / status
  └── templates.default      nix flake init scaffold
          │
          ├── nixtorch       CUDA toolkit, PyTorch build env, CLI
          └── home-manager   git, opencode, claude-code, direnv, zsh
```

Team members depend only on this repo. Personal configurations
(e.g. neovim, tmux, themes) layer on top via separate home-manager imports.

## Related

- [nixtorch](https://github.com/hinriksnaer/nixtorch) -- CUDA development shell for PyTorch, Helion, and vLLM
