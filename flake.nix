# TODO: create a home manager module? (vimAlias = true)
# TODO: set binary as user's defualt editor ($EDITOR)
{
    description = "My Neovim Flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, flake-utils, ... }:
        flake-utils.lib.eachDefaultSystem (system: let
			pkgs = import nixpkgs {
				inherit system;
				# config.allowUnfree = true;
			};

			plugins = with pkgs.vimPlugins; [
				bamboo-nvim
				catppuccin-nvim
				cmp-nvim-lsp
				crates-nvim
				gitsigns-nvim
				indent-blankline-nvim # indent-blankline-nvim-lua
				lualine-nvim
				nvim-autopairs
				nvim-cmp
				nvim-lspconfig
				nvim-tree-lua
				nvim-treesitter
				nvim-treesitter-context
				nvim-treesitter-parsers.zig
				nvim-treesitter-parsers.rust
				nvim-treesitter-parsers.markdown
				nvim-treesitter-parsers.markdown_inline
				nvim-treesitter-parsers.toml
				nvim-treesitter-parsers.nix
				nvim-treesitter-parsers.lua
				nvim-treesitter-parsers.python
				# other treesitter parsers: yaml, xml, wgsl, vimdoc, vim, tmux, sway, sql, ron, regex, latex, json, javascript, javadoc, java, html, go, css, c, asm, typst
				nvim-ufo
				nvim-web-devicons
				telescope-nvim
				vscode-nvim
				yazi-nvim
			];

			derivation = (pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped) (pkgs.neovimUtils.makeNeovimConfig {
				luaRcContent = builtins.readFile ./init.lua;
				plugins = plugins;
			});
		in {
			packages.default = derivation;
		}) // {
			homeModules.my-neovim = { config, lib, pkgs, ... }: {
				options.my-neovim = {
					enable = lib.mkEnableOption "my-neovim";
					languages = {
						rust.enable = lib.mkEnableOption "Rust";
						zig.enable = lib.mkEnableOption "Zig";
						markdown.enable = lib.mkEnableOption "Markdown";
						toml.enable = lib.mkEnableOption "TOML";
						nix.enable = lib.mkEnableOption "Nix";
						lua.enable = lib.mkEnableOption "Lua";
						python.enable = lib.mkEnableOption "Python";
						/* TODO
						json.enable = lib.mkEnableOption "JSON";
						javascript.enable = lib.mkEnableOption "JavaScript";
						java.enable = lib.mkEnableOption "Java";
						html.enable = lib.mkEnableOption "HTML";
						go.enable = lib.mkEnableOption "Go";
						css.enable = lib.mkEnableOption "CSS";
						c.enable = lib.mkEnableOption "C";
						# yaml, xml, wgsl, vimdoc, vim, tmux, sway, sql, ron, regex, latex, javadoc, asm, typst
						*/
					};
					# colorschemes.catppuccin.enable = lib.mkEnableOption "Catppuccin";
				};

				config = lib.mkIf config.my-neovim.enable {
					home.packages = lib.flatten [
						self.packages.${pkgs.system}.default
						pkgs.yazi

						# TODO: these need to be optional
						(lib.optional config.my-neovim.languages.rust.enable pkgs.rust-analyzer)
						# clang-tools
						# lua-language-server
						# nixd
						# pyright
						# ripgrep
						# taplo
						# vscode-langservers-extracted
						# zls
					]; # ++ (lib.optional config.my-neovim.languages.rust.enable pkgs.rust-analyzer);
				};
			};
		};
}
