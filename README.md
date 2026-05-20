# emacs-config

Personal Emacs configuration. Requires **Emacs 29+**.

Packages are managed by [elpaca](https://github.com/progfolio/elpaca) and will be downloaded and compiled automatically on first launch.

## Modules

| File | Purpose |
|------|---------|
| `early-init.el` | Frame and UI setup before packages load |
| `lisp/init-defaults.el` | Sane built-in defaults |
| `lisp/init-ui.el` | Theme (doom-one), modeline, tabs, fonts |
| `lisp/init-completion.el` | Vertico, Corfu, Consult, Cape |
| `lisp/init-lsp.el` | LSP via eglot, eldoc-box hover docs |
| `lisp/init-languages.el` | Tree-sitter grammars, language modes |
| `lisp/init-git.el` | Magit, diff-hl |
| `lisp/init-projects.el` | Projectile |
| `lisp/init-editor.el` | Editing utilities (apheleia, avy, etc.) |
| `lisp/init-keybinds.el` | Keybindings |

## Installation

### Option A — clone to `~/.emacs.d` (simplest)

```bash
git clone https://github.com/ethanjianglape/emacs-config.git ~/.emacs.d
emacs
```

No extra flags needed — Emacs loads `~/.emacs.d` by default.

### Option B — clone anywhere, use `--init-directory`

```bash
git clone https://github.com/ethanjianglape/emacs-config.git ~/Projects/emacs-config
emacs --init-directory ~/Projects/emacs-config
```

Add a shell alias to avoid typing the flag every time:

```bash
# ~/.zshrc or ~/.bashrc
alias emacs='emacs --init-directory ~/Projects/emacs-config'
```

### Option C — symlink

```bash
git clone https://github.com/ethanjianglape/emacs-config.git ~/Projects/emacs-config
ln -s ~/Projects/emacs-config ~/.emacs.d
emacs
```

## LSP servers

eglot will activate automatically for a language if its server is found in `PATH`. Install whichever you need:

| Language | Server | Install |
|----------|--------|---------|
| C / C++ | `clangd` | `pacman -S clang` / `apt install clangd` / `brew install llvm` |
| JS / TS / React | `typescript-language-server` | `npm i -g typescript-language-server typescript` |
| CMake | `cmake-language-server` | `pip install cmake-language-server` |
