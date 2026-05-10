# Minimal container image for PyTorch development.
# Nix manages all development dependencies -- this image only bootstraps Nix.
# CUDA toolkit/cuDNN come from nixtorch (Nix packages); NVIDIA driver libs
# are injected at runtime by the GPU operator.
#
# Distro-agnostic: switch BASE_IMAGE for Fedora, CentOS Stream, or RHEL.
#   fedora:41
#   quay.io/centos/centos:stream9
#   registry.access.redhat.com/ubi9/ubi:latest

ARG BASE_IMAGE=fedora:41
FROM ${BASE_IMAGE}

USER root

# Install Nix and minimal bootstrap tools
RUN dnf install -y \
        nix \
        git \
        curl \
    && dnf clean all

# Enable flakes
RUN mkdir -p /root/.config/nix \
    && echo 'experimental-features = nix-command flakes' > /root/.config/nix/nix.conf

# Ensure Nix is on PATH for non-login shells (oc exec)
RUN echo '[ -f /root/.nix-profile/etc/profile.d/nix.sh ] && . /root/.nix-profile/etc/profile.d/nix.sh' >> /root/.bashrc

# Pre-seed SSH known hosts (GitHub, GitLab)
# Actual SSH keys are mounted as K8s secrets at runtime.
RUN mkdir -p -m 0700 /root/.ssh \
    && ssh-keyscan github.com gitlab.com >> /root/.ssh/known_hosts 2>/dev/null

WORKDIR /root
CMD ["/bin/bash"]
