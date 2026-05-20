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

## System dependencies

These must be installed before launching Emacs — elpaca cannot install them.

### libvterm (required for the terminal)

The `vterm` package compiles a C extension against libvterm. Emacs will error on startup if it is missing.

```bash
# Arch
pacman -S libvterm
# Ubuntu/Debian
apt install libvterm-dev
# macOS
brew install libvterm
```

### Nerd Fonts (required for icons)

`doom-modeline` and `centaur-tabs` use `nerd-icons` for icons in the modeline and tab bar. Without the fonts installed you will see boxes or question marks instead of icons. Run this once after first launch:

```
M-x nerd-icons-install-fonts
```

### C compiler (required for tree-sitter grammars)

Tree-sitter grammars are downloaded and compiled automatically on demand when you first open a relevant file. A C compiler must be present for this to work.

```bash
# Arch
pacman -S gcc
# Ubuntu/Debian
apt install build-essential
# macOS
xcode-select --install
```

## LSP servers

eglot will activate automatically for a language if its server is found in `PATH`. Install whichever you need:

| Language | Server | Install |
|----------|--------|---------|
| C / C++ | `clangd` | `pacman -S clang` / `apt install clangd` / `brew install llvm` |
| JS / TS / React | `typescript-language-server` | `npm i -g typescript-language-server typescript` |
| CMake | `cmake-language-server` | `pip install cmake-language-server` |
