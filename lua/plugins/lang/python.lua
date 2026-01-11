-- Lang: Python tooling (Pyright + Ruff) with stable root and LSP attach behavior.
local ruff = vim.g.lazyvim_python_ruff or "ruff"

local function pyright_workspace_root(fname)
  if type(fname) == "number" then
    fname = vim.api.nvim_buf_get_name(fname)
  end
  if type(fname) ~= "string" or fname == "" then
    return nil
  end
  local dir = vim.fs.dirname(fname)
  local git_dir = vim.fs.find(".git", { path = dir, upward = true })[1]
  if git_dir then
    return vim.fs.dirname(git_dir)
  end
  local marker = vim.fs.find({
    "pyproject.toml",
    "pyrightconfig.json",
    "setup.py",
    "setup.cfg",
    "Pipfile",
  }, { path = dir, upward = true })[1]
  if marker then
    return vim.fs.dirname(marker)
  end
  return dir
end

local function ensure_pyright_extra_paths(client, bufnr)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  if fname == "" then
    return
  end
  local root = pyright_workspace_root(fname)
  local settings = vim.tbl_deep_extend("force", {}, client.config.settings or {})
  settings.python = settings.python or {}
  settings.python.analysis = settings.python.analysis or {}
  local extra = settings.python.analysis.extraPaths or {}
  if not vim.tbl_contains(extra, root) then
    table.insert(extra, root)
  end
  settings.python.analysis.extraPaths = extra
  if not vim.deep_equal(client.config.settings, settings) then
    client.config.settings = settings
    client.notify("workspace/didChangeConfiguration", { settings = settings })
  end
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "ninja", "rst" } },
  },
  {
    "neovim/nvim-lspconfig",
    init = function()
      local function ensure_pyright_attached(bufnr, tries)
        tries = tries or 0
        if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= "python" then
          return
        end
        if vim.lsp.get_clients({ bufnr = bufnr, name = "pyright" })[1] then
          return
        end
        local cfg = vim.lsp.config.pyright
        if not cfg then
          if tries < 5 then
            vim.defer_fn(function()
              ensure_pyright_attached(bufnr, tries + 1)
            end, 200)
          end
          return
        end
        local root = pyright_workspace_root(bufnr)
        if not root or root == "" then
          return
        end
        local launch = vim.tbl_deep_extend("force", {}, cfg, { bufnr = bufnr, root_dir = root })
        vim.lsp.start(launch)
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        callback = function(args)
          ensure_pyright_attached(args.buf)
        end,
      })
    end,
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.setup = opts.setup or {}
      local capabilities = vim.tbl_deep_extend("force", {}, opts.capabilities or {}, {
        general = { positionEncodings = { "utf-16" } },
      })

      opts.servers.pyright = opts.servers.pyright or {}
      opts.servers.pyright.autostart = true
      opts.servers.pyright.mason = false
      opts.servers.pyright.cmd = { "pyright-langserver", "--stdio" }
      opts.servers.pyright.root_dir = pyright_workspace_root
      opts.servers.pyright.settings = vim.tbl_deep_extend("force", {
        python = {
          analysis = {
            autoSearchPaths = true,
            extraPaths = {},
          },
        },
      }, opts.servers.pyright.settings or {})
      opts.servers.pyright.enabled = true
      opts.servers.pyright.capabilities = capabilities
      local pyright_on_attach = opts.servers.pyright.on_attach
      opts.servers.pyright.on_attach = function(client, bufnr)
        if pyright_on_attach then
          pyright_on_attach(client, bufnr)
        end
        ensure_pyright_extra_paths(client, bufnr)
      end
      local pyright_on_new_config = opts.servers.pyright.on_new_config
      opts.servers.pyright.on_new_config = function(new_config, root_dir)
        if pyright_on_new_config then
          pyright_on_new_config(new_config, root_dir)
        end
        local settings = new_config.settings or {}
        new_config.settings = settings
        settings.python = settings.python or {}
        settings.python.analysis = settings.python.analysis or {}
        local extra = settings.python.analysis.extraPaths or {}
        local function add_path(path)
          if path and path ~= "" and not vim.tbl_contains(extra, path) then
            table.insert(extra, path)
          end
        end
        add_path(root_dir)
        settings.python.analysis.extraPaths = extra
      end

      opts.servers[ruff] = opts.servers[ruff] or {}
      opts.servers[ruff] = vim.tbl_deep_extend("force", {
        cmd_env = { RUFF_TRACE = "messages" },
        init_options = {
          settings = {
            logLevel = "error",
          },
        },
        keys = {
          {
            "<leader>co",
            LazyVim.lsp.action["source.organizeImports"],
            desc = "Organize Imports",
          },
        },
      }, opts.servers[ruff])
      opts.servers[ruff].enabled = true
      opts.servers[ruff].capabilities = capabilities
      local ruff_setup = opts.setup[ruff]
      opts.setup[ruff] = function(...)
        if ruff_setup then
          ruff_setup(...)
        end
        Snacks.util.lsp.on({ name = ruff }, function(_, client)
          -- Disable hover in favor of Pyright
          client.server_capabilities.hoverProvider = false
        end)
      end

      -- Explicitly disable other Python LSPs
      opts.servers.jedi_language_server = { enabled = false }
      opts.servers.basedpyright = { enabled = false }
    end,
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "nvim-neotest/neotest-python",
    },
    opts = {
      adapters = {
        ["neotest-python"] = {
          -- runner = "pytest",
          -- python = ".venv/bin/python",
        },
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      "mfussenegger/nvim-dap-python",
      -- stylua: ignore
      keys = {
        { "<leader>dPt", function() require("dap-python").test_method() end, desc = "Debug Method", ft = "python" },
        { "<leader>dPc", function() require("dap-python").test_class() end, desc = "Debug Class", ft = "python" },
      },
      config = function()
        if vim.fn.has("win32") == 1 then
          require("dap-python").setup(LazyVim.get_pkg_path("debugpy", "/venv/Scripts/pythonw.exe"))
        else
          require("dap-python").setup(LazyVim.get_pkg_path("debugpy", "/venv/bin/python"))
        end
      end,
    },
  },
  {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp",
    cmd = "VenvSelect",
    enabled = function()
      return LazyVim.has("telescope.nvim")
    end,
    opts = {
      settings = {
        options = {
          notify_user_on_venv_activation = true,
        },
      },
    },
    ft = "python",
    keys = { { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" } },
  },
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    opts = function(_, opts)
      opts.auto_brackets = opts.auto_brackets or {}
      table.insert(opts.auto_brackets, "python")
    end,
  },
  {
    -- Avoid overriding adapters provided by nvim-dap-python
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = {
      handlers = {
        python = function() end,
      },
    },
  },
}
