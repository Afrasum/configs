-- mason / mason-lspconfig 2.x — bruker automatic_enable + vim.lsp.config()
-- (handlers-API-et er fjernet i 2.x; krever Neovim 0.11+)
return {
  "mason-org/mason.nvim",
  dependencies = {
    "mason-org/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    require("mason").setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    require("mason-lspconfig").setup({
      ensure_installed = {
        "ts_ls",
        "html",
        "cssls",
        "tailwindcss",
        "svelte",
        "lua_ls",
        "graphql",
        "emmet_ls",
        "prismals",
        "pyright",
        "rust_analyzer",
        "gopls",
        -- clangd: aktiveres separat via system-pakke (Mason har ingen aarch64-Linux-binær)
      },
      -- automatic_enable = true er default → kaller vim.lsp.enable() for alle installerte
    })

    require("mason-tool-installer").setup({
      ensure_installed = {
        "prettier",
        "stylua",
        "eslint_d",
        "clang-format",
        "gofumpt",
        "goimports",
      },
    })
  end,
}
