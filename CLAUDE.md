# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a comprehensive dotfiles repository for Unix-like systems (Linux and macOS) that provides a unified development environment configuration. The repository uses symlinks to manage configuration files and includes setup automation.

## Installation and Management

### Initial Setup
- Run `./initialize.bash` to set up the dotfiles environment
- This script handles git submodules, creates necessary directories, and sets up symlinks
- The script is interactive and prompts for confirmation before making changes

### Key Setup Tasks
- `./initialize.bash` - Main setup script that:
  - Initializes and updates git submodules
  - Creates symlinks for dotfiles (excluding specific files like `bin`, `config`, `initialize.bash`, `oh-my-zsh-custom`, `readme.md`)
  - Sets up directories: `~/.config`, `~/bin`, `~/.vimbackup`, `~/.fonts`
  - Optionally installs packages, powerline, fonts, and neovim
  - Configures git user settings
  - Installs and configures fzf

## Architecture and Structure

### Core Components

1. **Shell Configuration (Zsh/Oh-My-Zsh)**
   - Main config: `zshrc` → `~/.zshrc`
   - Environment: `zshenv` → `~/.zshenv`
   - Theme: Custom "tessa" theme in `oh-my-zsh-custom/themes/`
   - Custom plugins: `thxph-fzf`, `thanh`, and various Oh-My-Zsh plugins
   - Platform-specific plugin loading (macOS vs Linux)

2. **Vim/Neovim Configuration**
   - Main config: `vimrc` → `~/.vimrc`
   - Plugin manager: vim-plug
   - Neovim compatibility with shared config (`~/.vim` → `~/.config/nvim`)
   - Go development focused with vim-go plugin
   - Uses onedark theme with airline status line

3. **Tmux Configuration**
   - Config: `tmux/tmux.conf` → `~/.tmux.conf`
   - Powerline integration with tmux-powerline plugin
   - GNU Screen-style prefix key (backtick)
   - Mouse support enabled
   - TPM (Tmux Plugin Manager) integration

4. **Git Configuration**
   - Base config: `gitconfig` → `~/.gitconfig`
   - Personal config: Includes `~/.gitconfigp` (created during setup)
   - URL rewriting for GitHub/Bitbucket SSH access
   - Global gitignore: `gitignore` → `~/.gitignore`

5. **Development Environment**
   - Go: GOPATH set to `~/go`, Go binaries in PATH
   - Node.js: NVM support with lazy loading (`load-nvm()` function)
   - Java: jenv integration when available
   - Rust: Cargo environment loaded when available
   - ASDF: Version manager integration
   - Flutter: PATH configuration

### Directory Structure
- Root level: Primary dotfiles (direct symlinks to `~/.*`)
- `config/`: XDG config directory files (symlinked to `~/.config/`)
- `bin/`: User scripts and binaries (symlinked to `~/bin/`)
- `oh-my-zsh/`: Git submodule of Oh-My-Zsh framework
- `oh-my-zsh-custom/`: Custom zsh configurations, themes, and plugins
- `vim/`: Vim plugin directory and additional vim files
- `tmux/`: Tmux configuration and powerline setup

### Platform Differences
- **macOS**: Uses Homebrew paths, includes macOS-specific Oh-My-Zsh plugins
- **Linux**: Distribution-specific package installation (Debian/Manjaro support)
- **Universal**: Cross-platform PATH management and environment variables

## Development Workflow

### Making Changes
- Edit configuration files directly in the repository
- Changes are immediately active due to symlink structure
- Test changes in a new shell session
- Commit changes with meaningful messages

### Adding New Configurations
- Add new dotfiles to repository root for `~/.*` files
- Add XDG config files to `config/` directory
- Update `initialize.bash` if new symlinks or setup steps are needed
- Exclude files from symlinking by adding to the exclusion list in `mkln()` function

### Vim Plugin Management
- Add plugins to `vimrc` in the `call plug#begin()` section
- Run `:PlugInstall` in Vim to install new plugins
- Run `:PlugUpdate` to update existing plugins

### Zsh Customization
- Add custom functions/aliases to `oh-my-zsh-custom/custom/` files
- Create new plugins in `oh-my-zsh-custom/custom/plugins/`
- Modify theme in `oh-my-zsh-custom/themes/tessa.zsh-theme`

## Important Notes

- The repository uses git submodules (oh-my-zsh)
- Backup directory for vim: `~/.vimbackup/`
- Custom Oh-My-Zsh configurations override default settings
- Platform-specific configurations are handled dynamically
- Local zsh overrides can be added to `~/.zshrc-tlocal`