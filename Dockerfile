# Backlog.md (https://github.com/MrLesk/Backlog.md) as a container, so nothing but Docker is installed on the host.
#
# Run it through the `backlog-md-docker` command, not directly: it starts this container with the web UI and
# runs every CLI call in it with `docker exec`.
#
# Build: docker build -t ghcr.io/dayan3847/backlog-md-docker:<BACKLOG_VERSION> .
#
# No user is baked in: the command runs the container with the host user's UID/GID, so the files it writes
# to the backlog keep that owner.

# Debian, not Alpine: the release binary is compiled with Bun and links against glibc.
FROM debian:bookworm-slim

ARG BACKLOG_VERSION=1.55.3
# Set by BuildKit to the platform being built (amd64, arm64).
ARG TARGETARCH

# Nothing connects over HTTPS at runtime, so no ca-certificates.
RUN apt-get update \
    && apt-get install -y --no-install-recommends socat \
    && rm -rf /var/lib/apt/lists/*

# Upstream names its release binaries x64/arm64.
ADD --chmod=755 https://github.com/MrLesk/Backlog.md/releases/download/v${BACKLOG_VERSION}/backlog-bun-linux-${TARGETARCH/amd64/x64} /usr/local/bin/backlog
COPY LICENSES/Backlog.md.LICENSE /usr/share/doc/backlog/LICENSE

WORKDIR /work

# `backlog browser` only binds to the container's loopback, so socat relays it on 6421 for the published port.
EXPOSE 6421
CMD ["sh", "-c", "socat TCP-LISTEN:6421,fork,reuseaddr TCP:127.0.0.1:6420 & exec backlog browser --no-open --port 6420"]
