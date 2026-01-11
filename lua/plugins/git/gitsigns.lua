-- Git: refresh gitsigns after external git changes.
return {
  {
    "lewis6991/gitsigns.nvim",
    opts = function(_, opts)
      opts.watch_gitdir = vim.tbl_deep_extend("force", opts.watch_gitdir or {}, {
        enable = true,
        interval = 1000,
        follow_files = true,
      })
    end,
    init = function()
      vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "BufWritePost" }, {
        callback = function()
          if package.loaded.gitsigns then
            require("gitsigns").refresh()
          end
        end,
      })
    end,
  },
}
