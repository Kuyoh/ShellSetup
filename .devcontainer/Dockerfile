# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.217.1/containers/ubuntu/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version (use hirsuite or bionic on local arm64/Apple Silicon): hirsute, focal, bionic
ARG VARIANT="hirsute"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

USER root

WORKDIR /workspace
COPY debian-base/setup-shell.sh /workspace/setup-shell.sh
RUN /bin/bash /workspace/setup-shell.sh vscode && \
    rm /workspace/setup-shell.sh

USER vscode

SHELL [ "/usr/bin/zsh" ]
CMD [ "/usr/bin/zsh" ]


