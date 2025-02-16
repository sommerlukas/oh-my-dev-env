return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function () 
      local configs = require("nvim-treesitter.configs")

      configs.setup({
          ensure_installed = { "lua", "vim", "vimdoc", "c", "cpp", "llvm", "tablegen", "markdown" },
          sync_install = false,
          highlight = { enable = true },
          indent = { enable = true },  
        })
    end
  },

  {
    "neovim/nvim-lspconfig"
  },

  {
    'hrsh7th/nvim-cmp'
  },

  {
    'hrsh7th/cmp-nvim-lsp'
  }
}
