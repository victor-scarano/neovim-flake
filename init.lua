-- folding
	-- TODO: comment folding
	-- TODO: why i cant fold on the last line of a fold?
    -- TODO: auto fold all folds by default
-- TODO: configure renaming/refactoring symbols
-- file navigation
	-- TODO: oil
	-- TODO: hover nvim tree should preview file
-- TODO: make use of new completion functionality (https://youtube.com/watch?v=ZiH59zg59kg)
-- TODO: configure which key
-- TODO: configure snake and camel case as words
-- TODO: check out global default bindings for lsp
-- https://github.com/topics/neovim-colorscheme
-- gpanders.com/blog/whats-new-in-neovim-0-11

do -- options
	--globals
	vim.g.mapleader = " "
	vim.g.zig_fmt_autosave = 0
	-- givens
	vim.opt.autoindent = true
	vim.opt.laststatus = 3 -- global status
	vim.opt.number = true
	vim.opt.shiftwidth = 4
	vim.opt.showmode = false
	vim.opt.smartindent = true
	vim.opt.termguicolors = true
	vim.opt.tabstop = 4
	vim.opt.winborder = "single"
	-- ambiguous
	vim.opt.colorcolumn = { 80, 120 }
	vim.opt.expandtab = false
	vim.opt.foldlevel = 99
	vim.opt.foldlevelstart = 99
	vim.opt.relativenumber = true
	vim.opt.scrolloff = 5
	vim.opt.wrap = false
end

do -- colorschemes
	-- TODO: add module options for colorschemes
	require("catppuccin").setup({ transparent_background = true })
	vim.cmd.colorscheme("catppuccin")
end

do -- lsp
	-- TODO: how to make this language agnostic?
	-- TODO: enable inlay hints
	
	local servers = {
		"zls",
		"taplo",
		"rust_analyzer",
		"pyright",
		"nixd",
		"lua_ls",
		"cssls",
		"clangd"
	}

	for _, server in ipairs(servers) do
		require("lspconfig")[server].setup({
			on_attach = function(client, bufnr)
				if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
					vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
				end
			end,
		})
	end
end

do -- completions
	local cmp = require("cmp")
	cmp.setup({
		window = {
			completion = cmp.config.window.bordered({ border = "single" }),
			documentation = cmp.config.window.bordered({ border = "single" })
		},
		mapping = cmp.mapping.preset.insert({
			["<TAB>"] = cmp.mapping.confirm({ select = true })
		}),
		sources = {
			{ name = "nvim_lsp" },
			{ name = "buffer" },
			{ name = "path" },
		}
	})
end

-- temp fix (https://github.com/nvim-telescope/telescope.nvim/issues/3436)
require("telescope").setup({ defaults = { border = false } })
require("nvim-autopairs").setup()
require("ufo").setup()
require("gitsigns").setup()
require("crates").setup()
require("nvim-web-devicons").setup()
require("treesitter-context").setup({ max_lines = 1 })
require("nvim-treesitter.configs").setup({
	highlight = { enable = true },
	indent = { enable = true },
	parser_install_dir = "/dev/null"
})
require("ibl").setup({
	indent = { char = "│" },
	scope = { enabled = false }
})
require("nvim-tree").setup({
    auto_reload_on_write = true,
    disable_netrw = true,
    hijack_directories = { auto_open = true, enable = true },
    hijack_netrw = true,
})
require("lualine").setup({
	options = {
		component_separators = { left = "", right = "" },
		globalstatus = true,
		refresh = { statusline = 1 },
		section_separators = { left = "", right = "" },
		theme = "auto",
	},
	sections = {
		lualine_a = {
			{
				"mode",
				fmt = function(ident)
					local map = {
						["NORMAL"] = "NOR",
						["INSERT"] = "INS",
						["VISUAL"] = "VIS",
						["V-LINE"] = "V-L",
						["V-BLOCK"] = "V-B",
						["REPLACE"] = "REP",
						["COMMAND"] = "CMD",
						["TERMINAL"] = "TERM",
						["EX"] = "EX",
						["SELECT"] = "SEL",
						["S-LINE"] = "S-L",
						["S-BLOCK"] = "S-B",
						["OPERATOR"] = "OPR",
						["MORE"] = "MORE",
						["CONFIRM"] = "CONF",
						["SHELL"] = "SH",
						["MULTICHAR"] = "MCHR",
						["PROMPT"] = "PRMT",
						["BLOCK"] = "BLK",
						["FUNCTION"] = "FUNC",
					}
					return map[ident] or ident
				end,
			},
		},
		lualine_b = { "diff", "diagnostics" },
		lualine_c = { "filename" },
		lualine_x = { "filetype" },
		lualine_y = { "fileformat" },
		lualine_z = { "location" },
	},
})

-- removes search highlights after moving the cursor out of the highlighted text
vim.api.nvim_create_autocmd("CursorMoved", {
	group = vim.api.nvim_create_augroup("auto-hlsearch", { clear = true }),
	callback = function()
		if vim.v.hlsearch == 1 and vim.fn.searchcount().exact_match == 0 then
			vim.schedule(function()
				vim.cmd.nohlsearch()
			end)
		end
	end
})

-- auto fold imports on file open
--[[
vim.api.nvim_create_autocmd("LspNotify", {
	callback = function(args)
		if args.data.method == "textDocument/didOpen" then
			vim.lsp.foldclose("imports", vim.fn.bufwinid(args.buf))
		end
	end
})
--]]

do -- keybinds
	local function leader_bind(key, action, desc)
		if type(action) == "string" then
			action = "<CMD>" .. action .. "<CR>"
		end
		return {
			mode = "n",
			key = "<LEADER>" .. key,
			action = action,
			options = { desc = desc, silent = true }
		}
	end

	local keybinds = {
		-- you can use lua functions for actions
		leader_bind("b", "Telescope buffers", "List open buffers using Telescope."),
		leader_bind("f", "Telescope find_files", "List files using Telescope."),
		leader_bind("g", "Telescope live_grep", "Live grep files using Telescope."),
		leader_bind("q", "bd", "Deletes the current buffer."),
		leader_bind("h", vim.lsp.buf.hover, "Displays information about symbol under cursor."),
		leader_bind("d", vim.lsp.buf.definition, "Goes to definition of symbol under cursor."),
		leader_bind("a", vim.lsp.buf.code_action, "Lists possible code actions under cursor."),
		leader_bind("<TAB>", "NvimTreeToggle", "Toggles the directory tree."),
		leader_bind("i", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, "Toggles inlay hints."),

		-- TODO
		leader_bind("e", vim.diagnostic.open_float, "Show diagnostics."),
		-- Go to next diagnostic
		-- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
		-- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Next diagnostic" })
		-- Open diagnostics for current line
		-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })
	}

	for _, keybind in ipairs(keybinds) do
		vim.keymap.set(keybind.mode, keybind.key, keybind.action, keybind.options)
	end

	vim.api.nvim_create_user_command("Q", "q", {})
	vim.api.nvim_create_user_command("Qa", "qa", {})
	vim.api.nvim_create_user_command("W", "w", {})
	vim.api.nvim_create_user_command("Wq", "wq", {})
	vim.api.nvim_create_user_command("Wa", "wa", {})
	vim.api.nvim_create_user_command("Wqa", "wqa", {})
end
