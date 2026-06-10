# Oh My Dev Env

Personal development environment bootstrap for Linux. It installs a small `omde`
command, then uses that command to install CLI tools and copy the Neovim and
tmux configuration from this repository into the expected locations.

## Install

Install `omde`:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/sommerlukas/oh-my-dev-env/main/scripts/bootstrap.sh)"
```

Then reload your shell so the `omde` command is available:

```sh
source ~/.zshrc
```

The bootstrap clones this repository to `~/.oh-my-dev-env`, adds `OMDE_DIR` to
`~/.zshrc`, and defines the `omde` shell function.

## Usage

```sh
omde help
omde install all
omde install tools
omde install config
omde py-init [venv_dir]
omde update
```

`omde install all` installs tools first and then installs configuration files.
Running `omde install tools` or `omde install config` lets you do either half
separately.

## Installed Tools

The tool installer checks for existing tools before installing where possible.
Some tools are installed from upstream release archives into `~/bin`; `tmux` is
installed through `apt`.

Tools currently handled by `omde install tools`:

- Neovim `0.11.5`
- clangd `22.1.0`
- ripgrep
- tree-sitter CLI `0.24.7`
- direnv `2.37.1`
- tmux

The installer adds `~/bin` to `PATH` in `~/.zshrc` when it is not already
present.

For clangd and ripgrep, you can ask the script to prefer the system package
manager where supported:

```sh
omde install tools -s
```

## Installed Configuration

`omde install config` copies configuration files from `config/` into your home
directory:

- `config/tmux.conf` -> `~/.tmux.conf`
- `config/init.lua` -> `$XDG_CONFIG_HOME/nvim/init.lua`
- `config/lazy.lua` -> `$XDG_CONFIG_HOME/nvim/lua/config/lazy.lua`
- `config/view.lua` -> `$XDG_CONFIG_HOME/nvim/lua/plugins/view.lua`
- `config/git.lua` -> `$XDG_CONFIG_HOME/nvim/lua/plugins/git.lua`
- `config/files.lua` -> `$XDG_CONFIG_HOME/nvim/lua/plugins/files.lua`
- `config/language.lua` -> `$XDG_CONFIG_HOME/nvim/lua/plugins/language.lua`

Existing target files are moved to the same path with a `.bak` suffix before
the new files are copied.

## Neovim Setup

The Neovim configuration bootstraps `lazy.nvim` automatically and installs the
configured plugins on first start. The setup includes:

- Telescope file and grep pickers
- lualine and bufferline UI
- VS Code and Nordic color schemes
- indentation guides
- treesitter highlighting for common development languages
- LSP setup for clangd, ruff, pyright, and mlir-lsp-server
- nvim-cmp completion from LSP sources
- OSC 52 clipboard support for SSH sessions outside tmux

## Python Projects

Use `omde py-init` inside a Python project to create or update a virtual
environment with the Python tools expected by the Neovim config:

```sh
omde py-init
```

By default this uses the active virtual environment when `VIRTUAL_ENV` is set,
otherwise it creates or reuses `.venv`. You can pass a custom environment path:

```sh
omde py-init .venv
```

The Python tooling installed into that environment is:

- ruff
- pyright

## Updates

Check for updates with:

```sh
omde update
```

The update command expects `~/.oh-my-dev-env` to be a clean checkout on the
`main` branch with no local commits ahead of upstream. When updates are
available, it shows the pending commits and asks before applying them. Updating
pulls the latest repository state and reinstalls the configuration files.

## Requirements

This setup targets Linux on x86_64/amd64. It expects `zsh`, `git`, `curl`,
`wget`, `tar`, `unzip`, `gunzip`, Python 3, and `sudo apt` for packages that are
installed through the system package manager.
