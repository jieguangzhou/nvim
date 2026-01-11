# Plugin Map

This document lists the custom plugins configured in this repo and their purpose.
It does not enumerate LazyVim's built-ins.

## ai
- `lua/plugins/ai/copilot.lua`: GitHub Copilot completion.

## editor
- `lua/plugins/editor/flash.lua`: Disable `flash.nvim` default `s` mapping.
- `lua/plugins/editor/neo-tree.lua`: Refresh neo-tree on focus to avoid stale git/file markers.

## git
- `lua/plugins/git/gitsigns.lua`: Refresh gitsigns after external git changes.
- `lua/plugins/git/neogit.lua`: Neogit UI with diffview integration.

## lang
- `lua/plugins/lang/markdown.lua`: Render markdown + Markdown utilities.
- `lua/plugins/lang/python.lua`: Python LSP (Pyright) + Ruff with stable roots and consistent encoding.

## ui
- `lua/plugins/ui/colorscheme.lua`: Gruvbox colorscheme selection.
- `lua/plugins/ui/noice.lua`: Noice cmdline popup with stable highlighting.
- `lua/plugins/ui/snacks.lua`: Snacks UI tweaks (disable scroll).

## core
- `lua/config/options.lua`: Base options and globals.
- `lua/config/keymaps.lua`: Custom keymaps.
- `lua/config/autocmds.lua`: Custom autocmds.
