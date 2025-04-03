return {
  -- Autocompletion Engine
  {
    "saghen/blink.cmp",
    event = "InsertEnter", -- Load dependency plugins correctly and on InsertEnter
    dependencies = {
      -- Snippet Engine & Snippets sources
      {
        "L3MON4D3/LuaSnip",
        build = (not vim.uv.os_uname().sysname:find("Windows"))
            and "make install_jsregexp"
          or nil, -- Recommended build step for regex support in snippets
        dependencies = {
          -- Collection of common snippets
          "rafamadriz/friendly-snippets",
          config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
            -- You can add custom snippet directories here if needed:
            -- require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets" })
          end,
        },
      },
      -- Optional: If you want snippet integration beyond basic preset,
      -- though blink.cmp might handle basic luasnip integration via preset
      -- "moyiz/blink-luasnip.nvim",

      -- Other potential sources (add if needed, like path, emoji, etc.)
      "hrsh7th/cmp-path", -- If you want path completion
      "hrsh7th/cmp-buffer", -- If you want buffer text completion
      -- Add other source plugins like emoji, dictionary etc. if you were using them
      -- "moyiz/blink-emoji.nvim",
      -- "Kaiser-Yang/blink-cmp-dictionary",
    },
    opts = function()
      local cmp = require("blink.cmp")
      local types = require("blink.cmp.config.types") -- Useful for keymap actions

      return {
        -- === Enable/Disable ===
        enabled = function()
          -- Disable completion in specific buffers like Telescope, etc.
          local buftype = vim.bo.buftype
          if buftype == "prompt" or buftype == "nofile" then
            return false
          end
          -- Example: Disable in comments (requires nvim-treesitter context)
          -- local context = require("cmp.config.context")
          -- if context.isInSyntaxGroup("Comment") then return false end
          return true
        end,

        -- === Sources ===
        -- List of sources active by default for all filetypes
        sources = {
          default = {
            "lsp",
            "snippets", -- Or "luasnip" if using blink-luasnip directly
            "buffer",
            "path",
            -- Add other sources like "emoji", "dictionary" here if installed/enabled
          },
          -- Configuration for individual source providers
          providers = {
            lsp = {
              name = "LSP",
              module = "blink.cmp.sources.lsp",
              enabled = true,
              kind = " LSP", -- Customize the kind display
              score_offset = 90, -- High priority
              min_keyword_length = 1,
            },
            snippets = {
              name = "Snippets",
              module = "blink.cmp.sources.snippets", -- Use built-in snippets source
              enabled = true,
              kind = " Snippets",
              score_offset = 80,
            },
            buffer = {
              name = "Buffer",
              module = "blink.cmp.sources.buffer",
              enabled = true,
              kind = " Buffer",
              score_offset = 50,
              min_keyword_length = 3,
              max_items = 5,
            },
            path = {
              name = "Path",
              module = "blink.cmp.sources.path",
              enabled = true,
              kind = " Path",
              score_offset = 60,
            },
            -- Configure other providers (emoji, dictionary) if you add them
          },
        },

        -- === Keybindings ===
        -- IMPORTANT: Define mappings directly to avoid preset issues
        keymap = {
          mapping = {
            -- Snippet Navigation (requires LuaSnip and integration)
            ["<Tab>"] = { "i", "s" }, -- Try snippet first in insert/select modes
            ["<S-Tab>"] = { "i", "s" }, -- Try snippet backward first

            -- Completion Selection
            ["<Up>"] = { "select_prev", "fallback" },
            ["<Down>"] = { "select_next", "fallback" },
            ["<C-p>"] = { "select_prev", "fallback" },
            ["<C-n>"] = { "select_next", "fallback" },

            -- Documentation Scrolling
            ["<PageUp>"] = { "scroll_documentation_up", "fallback" },
            ["<PageDown>"] = { "scroll_documentation_down", "fallback" },
            ["<C-k>"] = { "scroll_documentation_up", "fallback" }, -- Alternative
            ["<C-j>"] = { "scroll_documentation_down", "fallback" }, -- Alternative

            -- Completion Control
            ["<C-Space>"] = { "complete", "fallback" }, -- Manually trigger
            ["<C-e>"] = { "abort", "fallback" }, -- Close menu

            -- Confirmation
            ["<CR>"] = { "confirm", { select = true } }, -- Confirm selection (select = true helps confirm implicit selection)
            -- ["<C-y>"] = { "confirm", "fallback" }, -- Optional alternative confirm
          },
          -- DO NOT use 'preset = "default"' here, define 'mapping' instead
        },

        -- === Appearance (Completion Menu & Documentation) ===
        completion = {
          menu = {
            border = "single", -- Or "rounded", "double", "shadow", etc.
            -- You can customize item kinds, formatting here if desired
            -- format_item = function(entry) ... end
          },
          documentation = {
            auto_show = true,
            window = {
              border = "single",
            },
          },
          keyword = {
            -- 'prefix' matches only text before cursor
            -- 'full' matches text before and after cursor
            range = "prefix",
          },
        },

        -- === Snippet Engine Integration ===
        snippets = {
          preset = "luasnip", -- Tell blink.cmp to use LuaSnip
          -- Configure snippet source options if needed (using the 'providers.snippets' table above is preferred)
          -- opts = { use_show_condition = true, show_autosnippets = true }
        },

        -- === Fuzzy Matching (Optional Customization) ===
        -- fuzzy = {
        --   use_typo_resistance = false,
        --   use_frecency = true,
        --   use_proximity = false,
        -- },

        -- === Command Line Completion ===
        cmdline = {
          enabled = true,
          sources = {
            default = { "cmdline", "path", "buffer" },
            providers = {
              cmdline = {
                name = "Cmdline",
                module = "blink.cmp.sources.cmdline",
                enabled = true,
              },
            },
          },
        },
      }
    end,
    config = function(_, opts)
      -- Explicitly call setup - Good practice especially if opts function does complex things
      require("blink.cmp").setup(opts)
      print("blink.cmp setup called.") -- Add print statement for debugging
    end,
  },

  -- Ensure LSP config is loaded *before* cmp if not handled by lazy.nvim dependencies automatically
  -- Example: { "neovim/nvim-lspconfig", dependencies = { "mason.nvim" } }

  -- Optional but recommended: UI enhancements for LSP/Completion
  {
    "nvimdev/lsp-rainbow.nvim", -- Colorizes matching brackets based on LSP scope
    event = "LspAttach",
  },
  {
    "utilyre/sentiment.nvim", -- Enhanced diagnostic visualization
    event = "LspAttach",
    opts = {},
    config = true, -- Runs require('sentiment').setup({})
  },
  {
    "folke/trouble.nvim", -- Better diagnostics list
    cmd = { "TroubleToggle", "Trouble" },
    opts = { use_diagnostic_signs = true },
  },
}
