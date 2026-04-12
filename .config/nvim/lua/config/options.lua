-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.cmd("let g:netrw_banner = 0")

-- line numbers
vim.opt.number = true
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
-- vim.opt.autoindent = true
-- vim.opt.smartindent = true

-- Appearance
vim.opt.cursorline = true      -- highlight the current line
vim.opt.signcolumn = "yes"     -- always show sign column (prevents layout shift from LSP)
vim.opt.termguicolors = true   -- true color support

-- Misc
vim.opt.undofile = true        -- persistent undo across sessions
vim.opt.updatetime = 250       -- faster CursorHold events (used by LSP hover etc)

-- Searching
vim.opt.ignorecase = true      -- case insensitive search...
vim.opt.smartcase = true       -- ...unless you type a capital

-- Splits
vim.opt.splitright = true      -- vertical splits open to the right
vim.opt.splitbelow = true      -- horizontal splits open below

-- Scrolling
vim.opt.scrolloff = 8          -- keep 8 lines above/below cursor when scrolling
vim.diagnostic.config({
    virtual_text = false,
})
