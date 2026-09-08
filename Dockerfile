# syntax=docker/dockerfile:1.7

# ---------------------------------------------------------------------------
# Base image: elan plus a Lean 4 toolchain.
# The version is set via ARG, but inside a project lean-toolchain overrides it.
# ---------------------------------------------------------------------------
FROM ubuntu:24.04 AS lean-base

ARG LEAN_TOOLCHAIN=leanprover/lean4:stable
ARG USER=lean
ARG UID=1000

ENV DEBIAN_FRONTEND=noninteractive

# git is mandatory: lake resolves dependencies through it.
# less / nano / openssh-client / bash-completion are not required by Lean,
# but without them git inside the container is painful to use interactively:
# no pager for `git log`, no editor for `git commit`, no SSH remotes,
# no tab completion for branches.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      less \
      nano \
      openssh-client \
      bash-completion \
      unzip \
      libgmp-dev \
 && rm -rf /var/lib/apt/lists/*

# ubuntu:24.04 ships a built-in `ubuntu` user occupying UID 1000, which makes
# a plain `useradd --uid 1000` fail with "UID is not unique". Drop whoever
# currently holds the UID, then create ours.
RUN if getent passwd ${UID} > /dev/null; then \
      userdel --remove "$(getent passwd ${UID} | cut -d: -f1)" || true; \
    fi \
 && useradd --create-home --uid ${UID} --shell /bin/bash ${USER}

USER ${USER}
WORKDIR /home/${USER}

ENV ELAN_HOME=/home/${USER}/.elan
ENV PATH=${ELAN_HOME}/bin:${PATH}
ENV EDITOR=nano

# `safe.directory` avoids git's "dubious ownership" refusal when the workspace
# is bind-mounted from a host whose file owner UID differs from this user's.
RUN git config --global --add safe.directory /workspace \
 && git config --global init.defaultBranch main

# Branch name in the prompt plus git tab completion.
RUN printf '%s\n' \
      'source /usr/share/bash-completion/bash_completion' \
      'source /usr/lib/git-core/git-sh-prompt' \
      'GIT_PS1_SHOWDIRTYSTATE=1' \
      'GIT_PS1_SHOWUNTRACKEDFILES=1' \
      'PS1="\[\e[32m\]\u\[\e[0m\]:\[\e[34m\]\w\[\e[33m\]$(__git_ps1 " (%s)")\[\e[0m\]\$ "' \
      >> /home/${USER}/.bashrc

# elan-init.sh fetches the installer binary from release.lean-lang.org, which
# is not always resolvable. Pull the release archive from GitHub instead and
# run the installer directly. Retries cover flaky DNS during the build.
RUN set -eux; \
    case "$(uname -m)" in \
      x86_64)  ELAN_ARCH=x86_64-unknown-linux-gnu ;; \
      aarch64) ELAN_ARCH=aarch64-unknown-linux-gnu ;; \
      *) echo "unsupported architecture: $(uname -m)" >&2; exit 1 ;; \
    esac; \
    curl -sSfL --retry 5 --retry-all-errors --connect-timeout 20 \
      "https://github.com/leanprover/elan/releases/latest/download/elan-${ELAN_ARCH}.tar.gz" \
      | tar -xz -C /tmp; \
    /tmp/elan-init -y --no-modify-path --default-toolchain ${LEAN_TOOLCHAIN}; \
    rm -f /tmp/elan-init; \
    elan --version; \
    lean --version


# ---------------------------------------------------------------------------
# Dependency layer: copy only the project manifest so that Mathlib is cached
# separately from the sources and is not rebuilt on every .lean edit.
# ---------------------------------------------------------------------------
FROM lean-base AS deps

ARG USER=lean
WORKDIR /workspace

COPY --chown=${USER}:${USER} lean-toolchain lakefile.toml lake-manifest.json ./

# Materializes the dependencies from the manifest and downloads prebuilt
# .olean files. Without this, Mathlib is compiled from source (CPU-hours).
RUN lake exe cache get


# ---------------------------------------------------------------------------
# Working image: project sources on top of the built dependencies.
# ---------------------------------------------------------------------------
FROM deps AS dev

ARG USER=lean
COPY --chown=${USER}:${USER} . .

RUN lake build

CMD ["bash"]