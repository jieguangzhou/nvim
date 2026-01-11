-- Editor: ensure neo-tree refreshes on focus to avoid stale git/file markers.
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
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
