# Neovim Config (Desktop + Android/Termux)

This repository contains a Lua-based Neovim setup managed with lazy.nvim, designed to run on both desktop Linux and Android via Termux.

## Setup

1. Clone this repo into your Neovim config path:

```bash
git clone <your-repo-url> ~/.config/nvim
```

2. Start Neovim:

```bash
nvim
```

3. Let lazy.nvim install plugins automatically.

4. Optional after first start:

```vim
:Lazy sync
:Mason
```

## Requirements

- Neovim 0.9+
- git
- ripgrep (recommended for Telescope live_grep)
- Node.js + yarn (only if using markdown-preview.nvim build flow)

## What You Get

- Theme: Catppuccin
- Syntax and parsing: Treesitter
- Fuzzy search: Telescope
- File explorer: Neo-tree
- LSP stack: Mason + Mason-lspconfig + nvim-lspconfig

## Project Structure

```text
init.lua                 # bootstrap + top-level setup
lazy-lock.json           # pinned plugin commits
lua/vim-options.lua      # editor options + basic keymaps
lua/plugins/*.lua        # plugin specifications
```

## Useful Commands

- `:Lazy` plugin manager UI
- `:Lazy sync` install/update plugins from specs
- `:Mason` manage LSP servers and external tools
- `:checkhealth` verify local environment

## Default Keymaps (from current config)

- `<C-p>` find files (Telescope)
- `<leader>fg` live grep (Telescope)
- `<C-n>` toggle Neo-tree
- `<leader>h` clear search highlight

## Desktop vs Termux

This config currently shares one profile across both platforms. A Termux-optimized path is planned using an `is_termux` conditional to disable heavy desktop-only plugins and keep startup fast on mobile.

For full technical analysis, dependency map, plugin freshness audit, and migration plan, see AGENTS.md.
