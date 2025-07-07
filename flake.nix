{
    description = "My Neovim Flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, flake-utils, ... }:
        flake-utils.lib.eachDefaultSystem (system: let
			pkgs = import nixpkgs { inherit system; };
			plugins = with pkgs.vimPlugins; [
				catppuccin-nvim
				cmp-nvim-lsp
				crates-nvim
				gitsigns-nvim
				indent-blankline-nvim
				lualine-nvim
				nvim-autopairs
				nvim-cmp
				nvim-lspconfig
				nvim-tree-lua
				nvim-treesitter
				nvim-treesitter-context
				nvim-ufo
				nvim-web-devicons
				telescope-nvim
				cmp-nvim-lsp
				nvim-cmp

				nvim-treesitter-parsers.c
				nvim-treesitter-parsers.cpp
				nvim-treesitter-parsers.lua
				nvim-treesitter-parsers.markdown
				nvim-treesitter-parsers.markdown_inline
				nvim-treesitter-parsers.nix
				nvim-treesitter-parsers.python
				nvim-treesitter-parsers.rust
				nvim-treesitter-parsers.toml
				nvim-treesitter-parsers.zig
				
				# yaml, xml, wgsl, vimdoc, vim, tmux, sway, sql, ron, regex,
				# latex, json, javascript, javadoc, java, html, go, css, c, asm,
				# typst
			];
			derivation = (pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped) (pkgs.neovimUtils.makeNeovimConfig {
				customLuaRC = builtins.readFile ./init.lua;
				plugins = plugins;
			});
		in {
			packages.default = derivation;
		}) // {
			homeModules.default = { config, lib, pkgs, ... }: {
				options.neovim = {
					enable = lib.mkEnableOption "Neovim";
					defaultEditor = lib.mkEnableOption "Neovim as the default editor";
					languages = {
						c.enable = lib.mkEnableOption "C";
						lua.enable = lib.mkEnableOption "Lua";
						markdown.enable = lib.mkEnableOption "Markdown";
						nix.enable = lib.mkEnableOption "Nix";
						python.enable = lib.mkEnableOption "Python";
						rust.enable = lib.mkEnableOption "Rust";
						toml.enable = lib.mkEnableOption "TOML";
						zig.enable = lib.mkEnableOption "Zig";
						# TODO: other languages
					};
					# TODO: colorschemes
				};

				config = lib.mkIf config.neovim.enable {
					home.packages = lib.flatten [
						self.packages.${pkgs.system}.default
						pkgs.ripgrep
						(lib.optional config.neovim.languages.c.enable pkgs.clang-tools)
						(lib.optional config.neovim.languages.lua.enable pkgs.lua-language-server)
						(lib.optional config.neovim.languages.markdown.enable pkgs.vscode-langservers-extracted)
						(lib.optional config.neovim.languages.nix.enable pkgs.nixd)
						(lib.optional config.neovim.languages.python.enable pkgs.pyright)
						(lib.optional config.neovim.languages.rust.enable pkgs.rust-analyzer)
						(lib.optional config.neovim.languages.toml.enable pkgs.taplo)
						(lib.optional config.neovim.languages.zig.enable pkgs.zls)
					];

					home.sessionVariables = lib.mkIf config.neovim.defaultEditor {
						EDITOR = "${self.packages.${pkgs.system}.default}/bin/nvim";
						VISUAL = "${self.packages.${pkgs.system}.default}/bin/nvim";
					};
				};
			};
		};
}
