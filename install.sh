#!/usr/bin/env bash
# Installs or updates the backlog-md-docker command in ~/.local/bin, and its bash completion, from the
# repository's master branch.
#
#   curl -fsSL https://raw.githubusercontent.com/dayan3847/backlog-md-docker/master/install.sh | bash

raw="https://raw.githubusercontent.com/dayan3847/backlog-md-docker/master"
bin="$HOME/.local/bin"
target="$bin/backlog-md-docker"
# bash-completion loads it from here by the command's name.
completion="$HOME/.local/share/bash-completion/completions/backlog-md-docker"

for tool in docker curl; do
    command -v "$tool" >/dev/null || { echo "backlog-md-docker: $tool is required." >&2; exit 1; }
done

# Before the command, so it is refreshed even when the command is up to date; a clone's link is left alone.
if [ ! -L "$completion" ]; then
    mkdir -p "$(dirname "$completion")" || exit 1
    curl -fsSL "$raw/completions/backlog-md-docker.bash" -o "$completion" || exit 1
fi

# A symlink is a clone's working copy: replacing it would cut it off from the clone.
if [ -L "$target" ]; then
    echo "$target links to $(readlink -f "$target"); update that clone with git pull."
    exit 0
fi

mkdir -p "$bin" || exit 1
# In the same folder, so the final mv is an atomic replace.
tmp="$(mktemp "$bin/.backlog-md-docker.XXXXXX")" || exit 1
trap 'rm -f "$tmp"' EXIT

curl -fsSL "$raw/backlog-md-docker" -o "$tmp" || exit 1
bash -n "$tmp" || { echo "backlog-md-docker: the download is not a valid script." >&2; exit 1; }

if cmp -s "$tmp" "$target"; then
    echo "backlog-md-docker is up to date."
    exit 0
fi

chmod 755 "$tmp"
mv "$tmp" "$target" || exit 1
echo "Installed $target."

case ":$PATH:" in
    *":$bin:"*) ;;
    *) echo "Add $bin to your PATH to run backlog-md-docker." ;;
esac
