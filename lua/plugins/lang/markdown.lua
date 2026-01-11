-- Lang: Markdown rendering + helper tools.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "markdown",
        "markdown_inline",
        "html",
        "latex",
      })
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-mini/mini.icons",
    },
    opts = {
      render_modes = { "n", "c" },
      debounce = 120,
      max_file_size = 5,
      heading = {
        position = "inline",
        icons = { "󰉫 ", "󰉬 ", "󰉭 ", "󰉮 ", "󰉯 ", "󰉰 " },
      },
      code = {
        style = "full",
        border = "thin",
        language_icon = true,
        language_name = true,
      },
      bullet = {
        icons = { "•", "◦", "▪", "▫" },
      },
      pipe_table = {
        preset = "round",
        style = "full",
        cell = "padded",
        padding = 1,
      },
    },
  },
  {
    "yousefhadder/markdown-plus.nvim",
    ft = { "markdown" },
    opts = {
      toc = {
        initial_depth = 3,
      },
    },
  },
}
