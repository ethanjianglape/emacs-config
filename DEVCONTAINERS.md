# Dev Containers

Dev containers define a project's development environment as code (`.devcontainer/devcontainer.json`), giving everyone on the team an identical, reproducible setup regardless of their local machine.

Two connection paths are supported, all commands run via `M-x`.

---

## VDI path — local Docker

The container runs on your machine via Docker. Uses the `devcontainer` CLI, which is the same tool VS Code uses under the hood.

**Prerequisites**
```
npm install -g @devcontainers/cli
```

| Command | Action |
|---------|--------|
| `devcontainer-open` | Start the devcontainer for the current project |
| `my/devcontainer-vterm` | Open a shell inside the container (vterm) |
| `devcontainer-exec` | Run a one-off command inside the container |
| `devcontainer-build` | Rebuild the container image |

---

## Coder path — remote workspace

The container runs on a remote server managed by Coder. Connection is via SSH.

**Prerequisites**
```
coder login <your-coder-url>
M-x my/coder-config-ssh    # run once; re-run if workspaces change
```

| Command | Action |
|---------|--------|
| `my/coder-connect` | Pick a workspace and open its files via TRAMP |
| `my/coder-vterm` | Open a shell in a workspace (vterm) |
| `my/coder-config-ssh` | Refresh SSH config (`coder config-ssh`) |

---

## LSP (eglot)

No extra setup needed. When you open a file via either path, eglot detects the TRAMP connection and runs the language server inside the container. The container image must have the relevant language servers installed.
