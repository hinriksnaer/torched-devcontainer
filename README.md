# torched-devcontainer

Nix-based team dev environment for PyTorch containers on OpenShift.

Provides a minimal container image (Fedora + Nix), a one-command bootstrap
that sets up git, AI coding tools (OpenCode, Claude Code), zsh, and direnv,
and a nixtorch devShell for CUDA/PyTorch development.

## Quick start

SSH into your pod and run:

```bash
nix run github:hinriksnaer/torched-devcontainer#setup
```

This creates `~/settings`, prompts for your git identity, and applies
the home-manager configuration. Once done, `cd ~/workspace` to enter
the nixtorch devShell.

## Build PyTorch

```bash
cd ~/workspace
nixtorch build pytorch
nixtorch status
```

## Configuration

All settings live in `~/settings/settings.nix`. Edit and re-apply:

```bash
vim ~/settings/settings.nix
home-manager switch --flake ~/settings#default
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
  cli-tools = true;   # starship, fzf, zoxide, bat, lsd, ripgrep, fd
};
```

## Update

Pull the latest modules and packages:

```bash
cd ~/settings && nix flake update && home-manager switch --flake .#default
```

## OpenShift deployment

### Prerequisites

- Namespace with SSH key and gcloud secrets already configured
- Home PVC (`pytorch-ibmc-storage-<username>`) already exists

### Deploy

```bash
cd openshift
./create-pvc.sh <username>    # creates nix-store PVC
./deploy.sh <username>        # applies deployment YAML
oc scale deployment <username>-dev -n <username> --replicas=1
```

### Connect

```bash
oc exec -it deployment/<username>-dev -n <username> -- bash
```

### Teardown

```bash
./openshift/teardown.sh <username>   # deletes deployment, keeps PVCs
```

## Architecture

```
torched-devcontainer (this repo)
  ├── lib.mkContainerHome    settings.nix -> home-manager config
  ├── lib.mkDevShell         re-exports nixtorch
  └── templates.default      nix flake init scaffold
          │
          ├── nixtorch       CUDA toolkit, PyTorch build env, CLI
          └── home-manager   git, opencode, claude-code, direnv, zsh
```

Team members depend only on this repo. Personal configurations
(e.g. neovim, tmux, themes) layer on top via separate home-manager imports.
