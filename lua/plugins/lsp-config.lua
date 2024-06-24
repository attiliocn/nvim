return {
    {
        "williamboman/mason.nvim",
        config = function()
            require('mason').setup() 
        end
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require('mason-lspconfig').setup(
                {
                    ensure_installed = {
                        "lua_ls",
                        "marksman",
                        "bashls",
                        "pyright",
                    }
                }
            )
        end
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            local lspconfig = require('lspconfig')
            lspconfig.lua_ls.setup({})
            lspconfig.marksman.setup({})
            lspconfig.bashls.setup({})
            lspconfig.pyright.setup({})
        end
    }
}