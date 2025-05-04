vim.api.nvim_set_option("clipboard", "unnamed")

vim.g.mapleader = ' ' -- set space as leader

-- Bootstrap Packer if not installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({
      'git',
      'clone',
      '--depth',
      '1',
      'https://github.com/wbthomason/packer.nvim',
      install_path
    })
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- Plugin setup
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
  }
  use { 'madskjeldgaard/fzf-sc', requires = { 'vijaymarupudi/nvim-fzf', 'davidgranstrom/scnvim' } }
  -- use { 'davidgranstrom/scnvim-rmux' }
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    requires = { { 'nvim-lua/plenary.nvim' } }
  }
  use { 'davidgranstrom/scnvim-tmux' }
  use { 'davidgranstrom/telescope-scdoc.nvim' }
  use { "catppuccin/nvim", as = "catppuccin" }
  use { 'tpope/vim-commentary' }
  use { 'jiangmiao/auto-pairs' }
  use { 'hrsh7th/nvim-cmp' }
  use {'L3MON4D3/LuaSnip'} 
  use {'quangnguyen30192/cmp-nvim-tags'} -- completion source for tags
  use {'saadparwaiz1/cmp_luasnip'} -- completion source for luasnip snippets
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  }
  if packer_bootstrap then
    require('packer').sync()
  end
end)

require('nvim-treesitter').setup({
  ensure_installed = { "c", "lua", "vim", "supercollider", "python" },
  auto_install = true,
  ident = { enable = true },
})

-- theme
require("catppuccin").setup({
  flavour = "mocha", -- latte, frappe, macchiato, mocha
  transparent_background = true, -- disables setting the background color.
    color_overrides = {
            all = {
                text = "#ffffff",
                overlay2 = "#7287fd", -- comments
                yellow = "#e64553",
                peach = "#fe640b",
                pink = "#ea76cb",
                flamingo = "#a6d189",
            },
        }
    })
vim.cmd.colorscheme "catppuccin"

require('telescope').setup {}
require 'telescope'.load_extension('scdoc')

--
-- scnvim setup
local scnvim = require 'scnvim'
local map = scnvim.map
local map_expr = scnvim.map_expr
scnvim.setup({
  keymaps = {
    ['<M-e>'] = map('editor.send_line', { 'i', 'n' }),
    ['<C-e>'] = {
      map('editor.send_block', { 'i', 'n' }),
      map('editor.send_selection', 'x'),
    },
    ['<CR>'] = {
      map('editor.send_block', { 'n' }),
      map('editor.send_selection', 'x'),
    },
    ['<C-P>'] = map('postwin.toggle'),
    ['<M-P>'] = map('postwin.toggle', 'i'),
    ['<M-L>'] = map('postwin.clear', { 'n', 'i' }),
    ['<C-k>'] = map('signature.show', { 'n', 'i' }),
    ['<M-s>'] = map('sclang.hard_stop', { 'n', 'x', 'i' }),
    ['<M-.>'] = map('sclang.hard_stop', { 'n', 'x', 'i' }),
    ['<leader>st'] = map('sclang.start'),
    ['<leader>sk'] = map('sclang.recompile'),
    ['<M-b>'] = map_expr('s.boot'),
    ['<M-m>'] = map_expr('s.meter'),
  },
  editor = {
    highlight = {
      color = 'IncSearch',
    },
  },
  -- postwin = {
  --   float = {
  --     enabled = true,
  --   },
    postwin = {
    highlight = false,
    auto_toggle_error = true,
    scrollback = 5000,
    horizontal = true,
    direction = 'right',
    size = nil,
    fixed_size = nil,
    keymaps = nil,
    float = {
      enabled = true,
      row = 0,
      col = function()
        return vim.o.columns
      end,
      width = 42,
      height = 10,
      config = {
        border = 'rounded',
      },
      callback = function(id)
        vim.api.nvim_win_set_option(id, 'winblend', 10)
      end,
    },},
  extensions = {
    ['fzf-sc'] = {
      search_plugin = 'nvim-fzf',
    },
    tmux = {
      path = vim.fn.tempname(),
      horizontal = true,
      size = '10%',
      cmd = 'tail',
      args = { '-F', '$1' }
    },
  },
})

scnvim.load_extension 'tmux'
scnvim.load_extension('fzf-sc')

-- settings.lua
vim.opt.compatible = false
vim.opt.showmatch = true
vim.opt.ignorecase = true
vim.opt.mouse = "a"
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.autoindent = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wildmode = { "longest", "list" }
-- vim.opt.colorcolumn = "80"
-- vim.opt.cursorline = true
vim.opt.ttyfast = true

--vim.cmd("filetype plugin indent on")
--vim.cmd("syntax on")
--vim.cmd("filetype plugin on")


-- Keyboard mapping
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

local builtin = require('telescope.builtin')
vim.keymap.set("n", "<A-c>", ":SCNvimStart<CR>", { noremap = true, silent = true })
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = 'Telescope old files' })
vim.keymap.set('n', '<leader>fm', builtin.marks, { desc = 'Telescope marks' })
vim.keymap.set('n', '<leader>fr', builtin.registers, { desc = 'Telescope regs' })
vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = 'Telescope keymaps' })
vim.keymap.set('n', '<leader>fs', ":SCNvimExt fzf-sc.fuzz<CR>", { desc = 'Telescope sc-fzf' })
vim.keymap.set('n', '<Tab>', ':bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<S-Tab>', ':bprev<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<leader>x', ':bd<CR>', { desc = 'Close buffer' })
vim.keymap.set('n', '<leader>sf', '<cmd>SCNvimEvalBuffer<CR>', { desc = "Eval SC buffer" })

-- Reload init.lua
vim.keymap.set('n', '<leader>rr', function()
  -- Reload the init.lua file
  vim.cmd('luafile $MYVIMRC')
  print("init.lua reloaded")
end, { desc = "Reload init.lua" })

-- Disable <Space>
map("n", "<Space>", "<Nop>", opts)
map("v", "<Space>", "<Nop>", opts)

-- Save with Ctrl+S
map("n", "<C-s>", ":w!<CR>", opts)
map("v", "<C-s>", ":w!<CR>", opts)

-- Quit with Ctrl+Q
map("n", "<C-q>", ":q!<CR>", opts)
map("v", "<C-q>", ":q!<CR>", opts)

-- Scroll and center
map("n", "<C-d>", "<C-d>zz", opts)
map("v", "<C-d>", "<C-d>zz", opts)
map("n", "<C-u>", "<C-u>zz", opts)
map("v", "<C-u>", "<C-u>zz", opts)

-- Center cursor after search
map("n", "n", "nzz", opts)
map("n", "N", "Nzz", opts)
map("n", "*", "*zz", opts)

-- Cursor movement in insert mode
map("i", "<C-j>", "<Down>", opts)
map("i", "<C-h>", "<Left>", opts)
map("i", "<C-k>", "<Up>", opts)
map("i", "<C-l>", "<Right>", opts)

-- Jump to next "(" at beginning of a line
vim.keymap.set('n', '<A-]>', "/^(<CR>", { noremap = true })

-- Jump to previous "(" at beginning of a line
vim.keymap.set('n', '<A-[>', "?^(<CR>", { noremap = true })


---
-- luasnip
---

vim.g.scnvim_snippet_format = 'luasnip'
require("luasnip").add_snippets("supercollider", require("scnvim/utils").get_snippets())

---
-- cmp 
---

local cmp = require'cmp'

local next_item = function(fallback)
  if cmp.visible() then
    cmp.select_next_item()
  elseif has_words_before() then
    cmp.complete()
  else
    fallback()
  end
end

local prev_item = function(fallback)
  if cmp.visible() then
    cmp.select_prev_item()
  else
    fallback()
  end
end

cmp.setup({
	snippet = {
		expand = function(args)
		require('luasnip').lsp_expand(args.body) -- for `luasnip` users.
		-- vim.fn["UltiSnips#Anon"](args.body) -- for `ultisnips` users.
		end,
		},
	sources = {
		{ name = 'tags', max_item_count = 3 },
		-- { name = 'luasnip', max_item_count = 2 }, -- for luasnip users
		{ name = "buffer",  max_item_count = 1 }, -- text within current buffer
  		{ name = "path",  max_item_count = 1 }
	},
	mapping = cmp.mapping.preset.insert({
   	 	['<A-Tab>'] = cmp.mapping.confirm({ select = true }),
		-- ['<Tab>'] = cmp.mapping(next_item, { 'i', 's' }),
		['<S-Tab>'] = cmp.mapping(prev_item , { 'i', 's' }),
      		['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    	}),
	view = {
		entries = { name = 'custom', separator = '|', selection_order = 'near_cursor' }
	},
	window = {
		completion = cmp.config.window.bordered({
			border = 'single',
		})
	}
})
