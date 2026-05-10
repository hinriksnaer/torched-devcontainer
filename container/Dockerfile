# Minimal container image for PyTorch development.
# Nix manages all development dependencies -- this image only bootstraps Nix.
# CUDA toolkit/cuDNN come from nixtorch (Nix packages); NVIDIA driver libs
# are injected at runtime by the GPU operator.
#
# CI pre-builds the HM config and devShell closures and imports them
# into the image so home-manager switch and nix develop are instant.
#
# Distro-agnostic: switch BASE_IMAGE for Fedora, CentOS Stream, or RHEL.
#   fedora:41
#   quay.io/centos/centos:stream9
#   registry.access.redhat.com/ubi9/ubi:latest

ARG BASE_IMAGE=fedora:41
FROM ${BASE_IMAGE}

USER root

# Install Nix, zsh, dropbear (lightweight SSH), and minimal bootstrap tools
RUN dnf install -y \
        nix \
        git \
        curl \
        zsh \
        dropbear \
    && dnf clean all

# Configure Nix: enable flakes, disable build users (single-user container)
RUN mkdir -p /root/.config/nix \
    && printf 'experimental-features = nix-command flakes\nbuild-users-group =\n' > /root/.config/nix/nix.conf

# Set USER env var (required by home-manager, not set by oc exec)
ENV USER=root

# Set zsh as default shell
RUN chsh -s /bin/zsh root

# Ensure Nix is on PATH for non-login shells (oc exec)
RUN echo '[ -f /root/.nix-profile/etc/profile.d/nix.sh ] && . /root/.nix-profile/etc/profile.d/nix.sh' >> /root/.bashrc \
    && echo '[ -f /root/.nix-profile/etc/profile.d/nix.sh ] && . /root/.nix-profile/etc/profile.d/nix.sh' >> /root/.zshrc

# Import pre-built Nix closures (HM config + devShell).
# The closure.nar is bind-mounted from the build context (built by CI),
# not copied into image layers. Skipped gracefully for local builds.
RUN --mount=type=bind,source=.,target=/ctx \
    if [ -f /ctx/closure.nar ]; then \
      echo "Importing pre-built Nix closures..." \
      && nix-store --import < /ctx/closure.nar \
      && echo "Done."; \
    else \
      echo "No closure.nar found -- skipping pre-bake (packages will be fetched at runtime)."; \
    fi

WORKDIR /root
CMD ["/bin/bash"]
