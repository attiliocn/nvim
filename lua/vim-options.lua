-- Wrap long lines at convenient break points (e.g. spaces) instead of splitting words.
vim.cmd('set linebreak')

-- Insert spaces when pressing Tab instead of literal tab characters.
vim.cmd('set expandtab')
-- Render a tab character visually as 4 columns.
vim.cmd('set tabstop=4')
-- Round indentation to the nearest multiple of shiftwidth.
vim.cmd('set shiftround')
-- Use 4 spaces for each indent/outdent operation.
vim.cmd('set shiftwidth=4')
-- Allow backspace over autoindent, line breaks, and insertion start.
vim.cmd('set backspace=2')

-- Preserve current line indentation when starting a new line.
vim.cmd('set autoindent')

-- Reload files changed outside Neovim when they are checked.
vim.cmd('set autoread')
-- Automatically save modified buffers before certain commands.
vim.cmd('set autowrite')

-- Show absolute line numbers in the sign/number column.
vim.cmd('set number')
-- Highlight the current cursor line for easier focus.
vim.cmd('set cursorline')

-- Always show a statusline for the active window setup.
vim.cmd('set laststatus=2')
-- Display incomplete commands in the status area while typing.
vim.cmd('set showcmd')

-- Use Space as the leader key prefix for custom mappings.
vim.g.mapleader = " "
-- Clear search highlight with <leader>h in normal mode.
vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')

