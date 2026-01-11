-- UI: Noice cmdline popup with stable highlighting.
return {
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.cmdline = opts.cmdline or {}
      opts.cmdline.enabled = true
      opts.cmdline.format = opts.cmdline.format or {}
      -- Keep popup cmdline + highlight, but avoid TS query errors for vim cmdline.
      opts.cmdline.format.cmdline = vim.tbl_extend(
        "force",
        opts.cmdline.format.cmdline or {},
        { lang = "vim" }
      )
    end,
    config = function(_, opts)
      require("noice").setup(opts)
      -- Force Noice to use Vim syntax (not Treesitter) for cmdline highlight.
      local ts = require("noice.text.treesitter")
      local orig_has_lang = ts.has_lang
      ts.has_lang = function(lang)
        if lang == "vim" then
          return false
        end
        return orig_has_lang(lang)
      end
    end,
  },
}
