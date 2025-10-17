# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal Nix configuration repository using home-manager for macOS (aarch64-darwin). It manages dotfiles, packages, and development environments across multiple machines without using nix-darwin. Some macOS applications are managed via Homebrew (see `Brewfile`).

## Development Workflow

**IMPORTANT**: When iterating on changes to this repository, use the development shell:

```bash
just shell
# or: nix develop
```

This provides an isolated environment with all necessary tools (nixpkgs-fmt, nil LSP, just) and displays helpful commands on entry. This is the **preferred way to test changes** before applying them to your system.

### Testing Changes Safely

1. Enter the dev shell: `just shell`
2. Make your edits to `.nix` files
3. Format code: `just fmt`
4. Test build (doesn't activate): `just build`
5. Review the build output in `./result`
6. If satisfied, apply changes: `just switch`
7. If issues occur, rollback: `home-manager generations` then `<path-to-previous-generation>/activate`

### Common Commands

All commands are managed through `just` (see `justfile`):

- **Enter dev shell**: `just shell` - Enters the development shell with all tools
- **Build configuration**: `just build` - Builds the home-manager configuration for the current host
- **Activate configuration**: `just activate` - Activates the current build
- **Apply changes**: `just switch` (alias: `just home`) - Builds and activates in one step
- **View history**: `just history` - Shows profile generations
- **Update dependencies**: `just update` - Updates `flake.lock`
- **Clean up**: `just gc` - Garbage collects old profiles and store paths (7+ days old)
- **Format code**: `just fmt` - Formats Nix files using `nixpkgs-fmt`
- **Debug build**: `just debug` - Builds with `--show-trace --verbose`
- **Clean artifacts**: `just clean` - Removes `result` symlink

The hostname is automatically detected using `scutil --get LocalHostName` and must match a `homeConfigurations` entry in `flake.nix`.

## Architecture

### Flake Structure

The root `flake.nix` defines:
- **Inputs**: nixpkgs (unstable), home-manager, nix-index-database, claude-code overlay
- **System support**: Only `aarch64-darwin` (Apple Silicon Macs)
- **Home configurations**: Per-hostname entries (currently `asm-mbp-14` and `asm-mba-13`)
- **Config options**: `allowUnfree = true` and `input-fonts.acceptLicense = true`

### Configuration Layout

- **`home/`**: Home-manager modules for user environment
  - `default.nix`: Entry point, imports core modules (files, environment, nix, packages)
  - `packages.nix`: Main package list and program configurations (git, nvim, tmux, zsh, etc.)
  - `files.nix`: Dotfile mappings from `home/etc/` and `home/scripts/` to home directory
  - `environment.nix`: `$PATH`, session variables, and shell aliases
  - `git.nix`, `nvim.nix`, `tmux.nix`, `zsh.nix`, etc.: Specific tool configurations
  - `emacs/`: Work-in-progress Emacs configuration (currently commented out in imports)
  - `etc/`: Dotfiles for various tools (alacritty, kitty, ghostty, mise, ipython, etc.)
  - `scripts/`: Custom shell scripts symlinked to `~/bin`

- **`modules/`**: Unused nix-darwin modules (kept for reference)
  - `darwin.nix`, `homebrew.nix`, `nix-core.nix`, `system.nix`

### Key Design Patterns

1. **Hostname-based configs**: Each machine has a separate `homeConfigurations` entry in `flake.nix`
2. **Modular imports**: Tool-specific configs are split into separate `.nix` files in `home/`
3. **Declarative dotfiles**: Config files in `home/etc/` are linked via `home.file` in `files.nix`
4. **Mixed package management**: Nix packages + Homebrew for GUI apps (`Brewfile`)
5. **Custom package overrides**: See `displayplacer.nix` for example of importing custom packages

### Important Configuration Notes

- Username is hardcoded as `"asm"` in `home/default.nix`
- State version is `"23.05"` (frozen for stability)
- Manual pages are disabled for performance (`manual.manpages.enable = false`)
- Editor is `nvim` (see `EDITOR` and `VISUAL` in `environment.nix`)
- Shell is `zsh` (though bash and fish configs also exist)

## Adding a New Machine

1. Get the hostname: `scutil --get LocalHostName`
2. Add a new entry in `flake.nix` under `homeConfigurations`:
   ```nix
   homeConfigurations."new-hostname" = home-manager.lib.homeManagerConfiguration homeManagerConfigs."aarch64-darwin";
   ```
3. Run `just switch` to build and activate

## Adding New Packages

1. Add package to `home.packages` list in `home/packages.nix`
2. For programs with home-manager modules, add config under `programs.<name>` in `packages.nix` or create a new file
3. Run `just switch` to rebuild

## Working with Dotfiles

- Dotfiles live in `home/etc/`
- Add new dotfiles by creating them in `home/etc/` and adding mappings in `home/files.nix`
- Use `pkgs.replaceVars` for files needing Nix store path substitution (see alacritty.toml example)

## Homebrew Integration

- Cask/formula definitions: `Brewfile` (Ruby DSL)
- Install/update: `brew bundle install` (from repo root)
- Note: This repository prefers not to use nix-darwin, hence the hybrid approach
