# uv-backend — mise backend plugin

A [mise](https://mise.jdx.dev) backend plugin that installs and manages PyPI packages using [uv](https://github.com/astral-sh/uv).

Each package is installed into its own isolated virtual environment, so tools never conflict with each other or with the system Python.

## Requirements

- [mise](https://mise.jdx.dev/installing-mise.html) ≥ 2026.1
- [uv](https://docs.astral.sh/uv/getting-started/installation/) available in `PATH`

## Installation

```bash
mise plugin install uv https://github.com/yassintz/mise-uv-backend
```

## Usage

```bash
# List available versions of a PyPI package
mise ls-remote uv:pip

# Install a specific version
mise install uv:black@24.3.0

# Install the latest version
mise install uv:ruff@latest

# Pin a tool in your project
mise use uv:black@24.3.0

# Run the tool directly
mise exec uv:black@24.3.0 -- black --version
```

### `mise.toml` example

```toml
[tools]
"uv:black"  = "24.3.0"
"uv:ruff"   = "latest"
"uv:pip"    = "25.0"
"uv:pytest" = "8.1.0"
```

After adding tools, run:

```bash
mise install
```

## How it works

| Hook | What it does |
| ------ | ------------- |
| `BackendListVersions` | Queries the [PyPI JSON API](https://pypi.org/pypi/{package}/json) and returns all published versions in ascending semantic order |
| `BackendInstall` | Creates a `uv venv` at the mise install path, then runs `uv pip install <tool>==<version>` into it |
| `BackendExecEnv` | Adds `<install_path>/bin` to `PATH` and sets `VIRTUAL_ENV` so the isolated environment is active |

Each tool lives at:

```plaintext
~/.local/share/mise/installs/uv-<tool>/<version>/
```

## Development

```bash
# Clone and link the plugin locally
git clone https://github.com/yassintz/mise-uv-backend
mise plugin link uv ./mise-uv-backend

# Run linting
mise run lint

# Run tests
mise run test

# Run full CI suite
mise run ci
```

### Code quality

- **[stylua](https://github.com/JohnnyMorganz/StyLua)** — Lua formatter
- **[lua-language-server](https://github.com/LuaLS/lua-language-server)** — static analysis
- **[actionlint](https://github.com/rhysd/actionlint)** — GitHub Actions linter
- **[hk](https://hk.jdx.dev)** — pre-commit hook runner (`hk install` to enable)

## License

MIT
