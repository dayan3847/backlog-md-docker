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

It installs the command in `~/.local/bin`. The first call pulls the image from GHCR.

Or from a clone, to work on it:

```bash
git clone https://github.com/dayan3847/backlog-md-docker.git
ln -s "$PWD/backlog-md-docker/backlog-md-docker" ~/.local/bin/backlog-md-docker
```

A clone is updated with `git pull`; `--self-update` leaves the link alone.

## Usage

```bash
backlog-md-docker --init                                   # first time only
backlog-md-docker task create "Write the README"
backlog-md-docker task list --plain
backlog-md-docker browser                                  # prints the web UI's URL
```

By default every call, from any folder, uses the same global backlog in `~/backlog-hq`.

## Settings

Environment variables, falling back to the defaults:

| Variable                      | Default        | Meaning                                       |
|-------------------------------|----------------|-----------------------------------------------|
| `BACKLOG_MD_DOCKER_DIR`       | `~/backlog-hq` | Folder holding the backlog; created if missing |
| `BACKLOG_MD_DOCKER_CONTAINER` | `backlog-md`   | Container name                                |
| `BACKLOG_MD_DOCKER_PORT`      | `6420`         | Web UI port, published on `127.0.0.1` only    |

## Own options

Every argument passes through to `backlog`, except:

- `browser`: only prints the web UI's URL, since the UI is always running while the container is.
- `--stop`: stop and remove the container. The next call starts a fresh one.
- `--self-update`: install the latest command from this repository.
- `--install-claude`: write Claude Code's rules for this backlog to
  `${CLAUDE_CONFIG_DIR:-~/.claude}/rules/backlog-md-docker.md`, so Claude uses it from any folder. Run it again
  after an update or after changing the backlog folder.
- `--init`: initialize the backlog without prompts: project "HQ", no Git, 4-digit IDs, no browser
  auto-open, no agent instruction files. Change anything afterwards with `backlog-md-docker config`, or run
  `init` for upstream's prompts.

## License

MIT, see [LICENSE](LICENSE). Backlog.md's own license is in [LICENSES/Backlog.md.LICENSE](LICENSES/Backlog.md.LICENSE).
