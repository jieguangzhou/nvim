-- Editor: disable flash.nvim default "s" mapping to avoid conflicts.
return {
  "folke/flash.nvim",
  keys = {
    { "s", mode = { "n", "x", "o" }, false },
  },
}
