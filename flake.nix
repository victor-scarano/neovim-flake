# TODO: create a home manager module? (neovim.enable = true) (vimAlias = true)
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

			runtime = with pkgs; [
				clang-tools
				lua-language-server
				nixd
				pyright
				ripgrep
				rust-analyzer
				taplo
				vscode-langservers-extracted
				yazi
				zls
			];

			config = pkgs.neovimUtils.makeNeovimConfig {
				# do these even work?
				# vimAlias = true;
				# wrapRc = false;
				luaRcContent = builtins.readFile ./init.lua;
				plugins = plugins;
			};

			wrapped = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped config;

			# is there an easier way to add runtime dependencies to the path?
			# https://github.com/mrcjkb/haskell-tools.nvim/blob/master/nix/haskell-tooling-overlay.nix
			derivation = pkgs.stdenv.mkDerivation {
				name = "nvim";
				buildInputs = [ pkgs.makeWrapper ];
				dontUnpack = true;
				installPhase = ''
					mkdir -p $out/bin
					makeWrapper ${wrapped}/bin/nvim $out/bin/nvim --prefix PATH : "${pkgs.lib.makeBinPath runtime}"
				'';
			};
		in {
			packages.default = derivation;
		}) // {
			nixosModules.my-neovim = { config, lib, pkgs, ... }: {
				options.my-neovim = {
					enable = lib.mkOption {
						type = lib.types.bool;
						default = false;
						description = "";
					};
				};

				config = lib.mkIf config.my-neovim.enable {
					home.packages = [ self.packages.default ];
				};
			};
		};
} 
