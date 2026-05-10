# torched-devcontainer

Nix-based team dev environment for PyTorch containers on OpenShift.

Provides a minimal container image (Fedora + Nix), a one-command bootstrap
that sets up git, AI coding tools (OpenCode, Claude Code), zsh, and direnv,
and a nixtorch devShell for CUDA/PyTorch development.

## Quick start

Connect to your pod and run:

```bash
vim ~/settings/settings.nix   # set git name/email
nix run home-manager/master -- switch -b backup --flake ~/settings#default
```

The `~/settings` directory with the template is auto-created on pod startup.
After the first switch, `home-manager` is on PATH and zsh becomes the
default shell on your next session. Reconnect to enter zsh:

```bash
exit
oc exec -it deployment/<username>-dev -n <username> -- zsh
```

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
home-manager switch -b backup --flake ~/settings#default
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

### Deploy

```bash
cd openshift
./create-pvc.sh <username>    # creates Nix store PVC (block storage, one-time)
./deploy.sh <username>        # applies deployment YAML
oc scale deployment <username>-dev -n <username> --replicas=1
```

### Connect

```bash
oc exec -it deployment/<username>-dev -n <username> -- zsh
```

### Teardown

```bash
./openshift/teardown.sh <username>   # deletes deployment, keeps PVC
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
