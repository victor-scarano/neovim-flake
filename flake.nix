{
    description = "My Neovim Flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, flake-utils, ... }:
        flake-utils.lib.eachDefaultSystem (system: let
			pkgs = import nixpkgs { inherit system; };
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
				# TODO: enable parsers based on config
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
						c.enable = lib.mkEnableOption "C";
						lua.enable = lib.mkEnableOption "Lua";
						markdown.enable = lib.mkEnableOption "Markdown";
						nix.enable = lib.mkEnableOption "Nix";
						python.enable = lib.mkEnableOption "Python";
						rust.enable = lib.mkEnableOption "Rust";
						toml.enable = lib.mkEnableOption "TOML";
						zig.enable = lib.mkEnableOption "Zig";

						/* TODO
						json.enable = lib.mkEnableOption "JSON";
						javascript.enable = lib.mkEnableOption "JavaScript";
						java.enable = lib.mkEnableOption "Java";
						html.enable = lib.mkEnableOption "HTML";
						go.enable = lib.mkEnableOption "Go";
						css.enable = lib.mkEnableOption "CSS";
						yaml, xml, wgsl, vimdoc, vim, tmux, sway, sql, ron,
						regex, latex, javadoc, asm, typst
						*/
					};
					# TODO: colorschemes
					# TODO: alias
					# TODO: set defualt editor ($EDITOR)
				};

				config = lib.mkIf config.my-neovim.enable {
					home.packages = lib.flatten [
						self.packages.${pkgs.system}.default
						pkgs.yazi
						pkgs.ripgrep
						(lib.optional config.my-neovim.languages.c.enable pkgs.clang-tools)
						(lib.optional config.my-neovim.languages.lua.enable pkgs.lua-language-server)
						(lib.optional config.my-neovim.languages.markdown.enable pkgs.vscode-langservers-extracted)
						(lib.optional config.my-neovim.languages.nix.enable pkgs.nixd)
						(lib.optional config.my-neovim.languages.python.enable pkgs.pyright)
						(lib.optional config.my-neovim.languages.rust.enable pkgs.rust-analyzer)
						(lib.optional config.my-neovim.languages.toml.enable pkgs.taplo)
						(lib.optional config.my-neovim.languages.zig.enable pkgs.zls)
					];
				};
			};
		};
}
