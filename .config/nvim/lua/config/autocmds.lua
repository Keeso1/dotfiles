-- after/ftplugin/cs.lua
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.cs",
    callback = function()
        vim.lsp.buf.format({ name = "roslyn" })
    end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "zaibatsu",
  callback = function()
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#ff5faf" })
	vim.api.nvim_set_hl(0, "FloatBorder", { bg = "#ff5faf" })
  end,
})
