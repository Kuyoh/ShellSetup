ARG VARIANT="hirsute"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

USER root

WORKDIR /workspace
COPY linux/setup-shell.sh /workspace/setup-shell.sh
RUN /bin/bash /workspace/setup-shell.sh vscode && \
    rm /workspace/setup-shell.sh

USER vscode

CMD [ "/usr/bin/zsh" ]


