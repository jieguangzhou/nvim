return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      opts.filesystem = opts.filesystem or {}
      opts.filesystem.use_libuv_file_watcher = true
    end,
    init = function()
      local function refresh()
        if not package.loaded["neo-tree"] then
          return
        end
        local ok, manager = pcall(require, "neo-tree.sources.manager")
        if not ok then
          return
        end
        manager.refresh("filesystem")
        manager.refresh("git_status")
      end

      vim.api.nvim_create_autocmd("FocusGained", {
        callback = refresh,
      })
    end,
  },
}
