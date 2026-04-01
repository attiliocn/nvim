# Neovim Configuration Analysis (Desktop + Android/Termux)

## Current Configuration Structure

This config uses `lazy.nvim` as plugin manager and loads plugin specs from `lua/plugins/*.lua`.

### Folder Layout

```text
.
├── init.lua
├── lazy-lock.json
└── lua
    ├── plugins.lua
    ├── vim-options.lua
    └── plugins
        ├── catppuccin.lua
        ├── lsp-config.lua
        ├── neotree.lua
        ├── telescope.lua
        └── treesitter.lua
```

### Load Flow

1. `init.lua` bootstraps `lazy.nvim` into Neovim runtime path.
2. `init.lua` loads `vim-options.lua`.
3. `require("lazy").setup("plugins")` tells lazy.nvim to discover specs under `lua/plugins/`.
4. `lazy-lock.json` pins exact plugin commits.

## Installed Plugins (Current)

Installed plugins are inferred from `lazy-lock.json` and plugin specs in `lua/plugins/`.

| Plugin | Source | Config File | Purpose | Notes |
|---|---|---|---|---|
| lazy.nvim | folke/lazy.nvim | bootstrap in `init.lua` | Plugin manager | Core of this setup |
| catppuccin | catppuccin/nvim | `lua/plugins/catppuccin.lua` | Theme/colorscheme | Loaded eagerly (`lazy=false`, high priority) |
| nvim-treesitter | nvim-treesitter/nvim-treesitter | `lua/plugins/treesitter.lua` | Syntax highlighting + indentation | `ensure_installed = { lua, python, bash, markdown }` |
| telescope.nvim | nvim-telescope/telescope.nvim | `lua/plugins/telescope.lua` | Fuzzy finder for files/grep | Pinned tag `0.1.6`; depends on plenary |
| plenary.nvim | nvim-lua/plenary.nvim | dependency only | Lua utility library | Dependency for Telescope + Neo-tree |
| neo-tree.nvim | nvim-neo-tree/neo-tree.nvim | `lua/plugins/neotree.lua` | File explorer sidebar | Depends on plenary, nui, devicons |
| nui.nvim | MunifTanjim/nui.nvim | dependency only | UI components | Neo-tree dependency |
| nvim-web-devicons | nvim-tree/nvim-web-devicons | dependency only | Filetype icons | Neo-tree dependency |
| mason.nvim | williamboman/mason.nvim | `lua/plugins/lsp-config.lua` | External tool/LSP installer | LSP installation manager |
| mason-lspconfig.nvim | williamboman/mason-lspconfig.nvim | `lua/plugins/lsp-config.lua` | Bridge Mason + lspconfig | Ensures `lua_ls`, `marksman`, `bashls`, `pyright` |
| nvim-lspconfig | neovim/nvim-lspconfig | `lua/plugins/lsp-config.lua` | LSP client configuration | Explicit setup for 4 servers |


## Dependency Structure

### Dependency Graph (plugin-level)

```text
lazy.nvim
└── loads all specs from lua/plugins/

telescope.nvim
└── plenary.nvim

neo-tree.nvim
├── plenary.nvim
├── nui.nvim
└── nvim-web-devicons

mason-lspconfig.nvim
├── mason.nvim
└── nvim-lspconfig (integration target)
```

### Configuration Topology

- `init.lua` is the only entrypoint.
- `vim-options.lua` contains global/editor options and global keymaps.
- Each plugin has a dedicated file in `lua/plugins/` except lockfile-only dependencies.
- `lua/plugins.lua` currently returns an empty table and is effectively unused.

## Replacement Suggestions

Important: Not every plugin should be replaced. Replacements below are where architecture/performance gains are meaningful, especially for Android/Termux.

### Keep + Update In Place (recommended)

- `lazy.nvim`: still a gold-standard plugin manager.
- `nvim-treesitter`: still foundational for syntax quality.
- `nvim-lspconfig` + `mason.nvim` + `mason-lspconfig.nvim`: still standard baseline for LSP management.
- `catppuccin`: still widely used and stable.

### Consider Replacing

1. File explorer
- Current: `neo-tree.nvim`
- Replacement: `stevearc/oil.nvim` (primary) or `echasnovski/mini.files` (ultra-light)
- Why: lower UI/dependency overhead, typically faster startup and interaction on constrained/mobile hardware.

2. Fuzzy finder
- Current: `telescope.nvim` (tag `0.1.6`)
- Replacement: `ibhagwan/fzf-lua` (primary performance-focused) or `echasnovski/mini.pick` (lightweight Lua-native)
- Why: faster search UX on large repos and lower latency in Termux environments.

3. Markdown workflow
- Current: None
- Replacement: `MeanderingProgrammer/render-markdown.nvim` for in-editor rendering, optionally paired with terminal tools (`glow`) for quick preview.
- Why: avoids heavyweight browser/node workflow on mobile while preserving readability.

## Key Findings and Analysis

1. The architecture is clean and modular: one plugin per file, easy to reason about.
2. Current choices are desktop-friendly but somewhat heavy for Termux (`neo-tree`, `telescope`, markdown browser preview build chain).
3. There is a plugin spec issue in `lua/plugins/markdown-preview.lua`: a `vim.keymap.set(...)` call is placed as a raw table value in the spec, which is non-standard and should be moved into `init` or `config`.
4. `lua/plugins.lua` is currently an empty placeholder and could be removed or used as a platform switchboard.

## Implementation Plan: `is_termux` Conditional Logic

Goal: keep desktop UX rich while making Android/Termux startup and runtime noticeably faster.

### Phase 1: Add platform detection module

Create `lua/core/platform.lua`:

```lua
local M = {}

M.is_linux = vim.fn.has("linux") == 1
M.is_termux = M.is_linux and (
  vim.env.TERMUX_VERSION ~= nil or
  (vim.env.PREFIX and vim.env.PREFIX:match("com.termux")) ~= nil
)

return M
```

Use it from `init.lua`:

```lua
local platform = require("core.platform")
vim.g.is_termux = platform.is_termux
```

### Phase 2: Introduce conditional plugin loading

- In each plugin spec, add `enabled = not vim.g.is_termux` for heavy desktop-only plugins.
- Prefer `cond = function() return not vim.g.is_termux end` if runtime checks are needed.

Initial candidates to disable on Termux:
- `neo-tree.nvim`
- `markdown-preview.nvim`

Initial candidates to swap on Termux:
- `telescope.nvim` -> `mini.pick` or `fzf-lua`

### Phase 3: Split profiles for clarity

Suggested structure:

```text
lua/plugins/
  shared/
  desktop/
  termux/
```

- Keep common plugins in `shared`.
- Add only optimized alternatives in `termux`.
- Load set conditionally in `init.lua` or via `import` blocks in lazy spec.

### Phase 4: Tune LSP and Treesitter for mobile

- Limit `ensure_installed` list to daily drivers on Termux.
- Disable expensive features per filetype where needed.
- Consider skipping automatic Mason installs on Termux and relying on preinstalled tools.

### Phase 5: Add measurable performance checks

- Measure startup with `nvim --startuptime` before/after.
- Track plugin load time with lazy.nvim profiler.
- Keep a target budget (example): sub-120ms startup in Termux shells.

### Phase 6: Safe migration sequence

1. Implement detection and no-op flags.
2. Gate heavy plugins behind `is_termux`.
3. Introduce replacements one by one.
4. Update keymaps to avoid missing-command errors when plugins are disabled.
5. Refresh lockfile and retest both desktop and Termux.

## Suggested Next Actions

2. Add `core/platform.lua` and global `vim.g.is_termux`.
3. Gate `neo-tree` and markdown preview on desktop only.
4. Decide telescope strategy: update in place vs replace with `fzf-lua`/`mini.pick` on Termux.
5. Optionally evaluate plugin replacements with startup benchmarks before adopting them.