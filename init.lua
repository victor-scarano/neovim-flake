-- folding
	-- TODO: comment folding
	-- TODO: figure out why i cant fold on the last line of a fold
-- lsp
	-- TODO: goto tree
	-- TODO: configure renaming/refactoring symbols
-- https://www.youtube.com/watch?v=xy9sSVx2cfk
	-- TODO: configure yazi
	-- TODO: hover nvim tree should preview file
	-- TODO: configure yazi nvim or oil nvim or both
-- TODO: make use of new completion functionality (https://youtube.com/watch?v=ZiH59zg59kg)
-- TODO: configure which key nvim
-- TODO: maybe configure snake and camel case as words
-- https://github.com/topics/neovim-colorscheme

do -- globals
	vim.g.mapleader = " "
	vim.g.zig_fmt_autosave = 0
end

do -- options
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
	require("vscode").setup()

	vim.cmd.colorscheme("catppuccin")
end

do -- lsp
	-- TODO: figure out how to make this language agnostic

	local servers = {
		"zls",
		"taplo",
		"rust_analyzer",
		"pyright",
		"nixd",
		"lua_ls",
		"cssls",
		"clangd",
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
			documentation = cmp.config.window.bordered({ border = "single" }),
		},
		mapping = cmp.mapping.preset.insert({
			["<Tab>"] = cmp.mapping.confirm({ select = true })
		}),
		sources = {
			{ name = "nvim_lsp" },
			{ name = "buffer" },
			{ name = "path" }
		},
	})

	--[[
	-- this is the neovim 0.11 way of doing completions
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(ev)
			local client = vim.lsp.get_client_by_id(ev.data.client_id)
			if client:supports_method("textDocument/completion") then
				vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
			end
		end
	})
	--]]
end

do -- treesitter
	require("nvim-treesitter.configs").setup({
		highlight = { enable = true },
		indent = { enable = true },
		parser_install_dir = "/dev/null"
	})
end

do -- telescope
	--[[
	require("telescope").setup({
		defaults = {
			border = {
				preview = { 1, 1, 1, 1 },
				prompt = { 1, 1, 1, 1 },
				results = { 1, 1, 1, 1 }
			},
			borderchars = {
				preview = { "─", "│", "─", "│", "┬", "┐", "┘", "┴" },
				prompt = { " ", " ", "─", "│", "│", " ", "─", "└" },
				results = { "─", " ", " ", "│", "┌", "─", " ", "│" },
			},
		},
	})
	--]]
	require("telescope").setup({
		defaults = { border = false } -- temp fix (https://github.com/nvim-telescope/telescope.nvim/issues/3436)
	})
end

do -- lualine
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
end

require("nvim-autopairs").setup()
require("ufo").setup()
require("gitsigns").setup()
require("crates").setup()
require("nvim-web-devicons").setup()
require("treesitter-context").setup({ max_lines = 1 })

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

-- removes search highlights after moving the cursor out of the highlighted text
vim.api.nvim_create_autocmd("CursorMoved", {
	group = vim.api.nvim_create_augroup("auto-hlsearch", { clear = true }),
	callback = function()
		if vim.v.hlsearch == 1 and vim.fn.searchcount().exact_match == 0 then
			vim.schedule(function()
				vim.cmd.nohlsearch()
			end)
		end
	end,
})


do -- keybinds
	local keybinds = {
		{
			mode = "n", key = "<leader>b", action = "<cmd>Telescope buffers<cr>",
			options = { desc = "List open buffers using Telescope.", silent = true },
		},
		{
			mode = "n", key = "<leader>f", action = "<cmd>Telescope find_files<cr>",
			options = { desc = "List files using Telescope.", silent = true },
		},
		{
			mode = "n", key = "<leader>g", action = "<cmd>Telescope live_grep<cr>",
			options = { desc = "Live grep files using Telescope.", silent = true },
		},
		{
			mode = "n", key = "<leader>q", action = "<CMD>bd<CR>",
			options = { desc = "Deletes the current buffer.", silent = true },
		},
		{
			mode = "n", key = "<leader>h", action = "<CMD>lua vim.lsp.buf.hover()<CR>",
			options = { desc = "Displays information about symbol under cursor.", silent = true },
		},
		{
			mode = "n", key = "<leader>d", action = "<CMD>lua vim.lsp.buf.definition()<CR>",
			options = { desc = "Goes to definition of symbol under cursor.", silent = true },
		},
		{
			mode = "n", key = "<leader>a", action = "<CMD>lua vim.lsp.buf.code_action()<CR>",
			options = { desc = "Lists possible code actions under cursor.", silent = true },
		},
		{
			mode = "n", key = "<leader><tab>", action = "<CMD>NvimTreeToggle<CR>",
			options = { desc = "Toggles the directory tree.", silent = true },
		},
		{
			mode = "n", key = "<leader>i", action = "<CMD>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<CR>",
			options = { desc = "Toggles inlay hints.", silent = true },
		},
	}

	for _, keybind in ipairs(keybinds) do
		vim.keymap.set(keybind.mode, keybind.key, keybind.action, keybind.options)
	end
end
