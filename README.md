# backlog-md-docker

Run [Backlog.md](https://github.com/MrLesk/Backlog.md) with Docker as the only requirement.

Backlog.md is the work of its authors and is MIT licensed (see [LICENSES/Backlog.md.LICENSE](LICENSES/Backlog.md.LICENSE)).
This repository is only a wrapper around it: a Docker image with the official release binary, and a
`backlog-md-docker` command that runs it. Bugs in Backlog.md itself belong upstream.

## How it works

One long-lived container runs the Backlog.md web UI against your backlog folder. Every
`backlog-md-docker <args>` call runs `backlog <args>` inside that container with `docker exec`, starting it
first when it is not running. Files are written as your own user.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/dayan3847/backlog-md-docker/master/install.sh | bash
```

It installs the command in `~/.local/bin`, and its bash completion where the bash-completion package loads it
from. The first call pulls the image from GHCR.

Or from a clone, to work on it:

```bash
git clone https://github.com/dayan3847/backlog-md-docker.git ~/backlog-md-docker && cd ~/backlog-md-docker
```

From the clone, link the command and, optionally, its completion:

```bash
mkdir -p ~/.local/bin && ln -s "$PWD/backlog-md-docker" ~/.local/bin/backlog-md-docker
```

```bash
mkdir -p ~/.local/share/bash-completion/completions && ln -s "$PWD/completions/backlog-md-docker.bash" ~/.local/share/bash-completion/completions/backlog-md-docker
```

A clone is updated with `git pull`; `--self-update` leaves the links alone.

## Usage

```bash
backlog-md-docker --init                                   # first time only
backlog-md-docker task create "Write the README"
backlog-md-docker task list --plain
backlog-md-docker browser                                  # prints the web UI's URL
```

By default every call, from any folder, uses the same global backlog in `~/backlog-hq`.

## Settings

Environment variables, then the config file, then the defaults. The config file is
`~/.config/backlog-md-docker.conf`, or the one `BACKLOG_MD_DOCKER_CONFIG` points to.

| Variable                      | Default        | Meaning                                       |
|-------------------------------|----------------|-----------------------------------------------|
| `BACKLOG_MD_DOCKER_DIR`       | `~/backlog-hq` | Folder holding the backlog; created if missing |
| `BACKLOG_MD_DOCKER_CONTAINER` | `backlog-md`   | Container name                                |
| `BACKLOG_MD_DOCKER_PORT`      | `6420`         | Web UI port, published on `127.0.0.1` only    |
| `DOCKER_CONTEXT`              | Docker's own   | Docker context to run on                      |

The config file holds one `KEY=value` per line, without quotes; lines starting with `#` are skipped:

```bash
BACKLOG_MD_DOCKER_DIR=~/work/backlog
DOCKER_CONTEXT=default
```

## Own options

Every argument passes through to `backlog`, except:

- `browser`: only prints the web UI's URL, since the UI is always running while the container is.
- `--stop`: stop and remove the container. The next call starts a fresh one.
- `--self-update`: install the latest command from this repository.
- `--install-claude`: write Claude Code's rules for this backlog to `ai/rules/default.md` in the backlog folder,
  and link that folder as `${CLAUDE_CONFIG_DIR:-~/.claude}/rules/backlog-md-docker`, so Claude uses the backlog
  from any folder. Your own rules go in other files of `ai/rules/` and travel with the backlog; `default.md` is
  regenerated on every run and git-ignored. Run it again after an update, and on every machine.
- `--init`: initialize the backlog without prompts: project "HQ", no Git, 4-digit IDs, no browser
  auto-open, no agent instruction files. Change anything afterwards with `backlog-md-docker config`, or run
  `init` for upstream's prompts.

## License

MIT, see [LICENSE](LICENSE). Backlog.md's own license is in [LICENSES/Backlog.md.LICENSE](LICENSES/Backlog.md.LICENSE).
