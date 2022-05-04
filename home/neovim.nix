{ config, lib, pkgs, inputs, ... }:

{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraConfig = ''
      let base16colorspace=256
      colorscheme base16-scheme

      lua require('init')
    '';

    plugins = with pkgs.vimPlugins; lib.forEach [
      (base16-vim.overrideAttrs (old:
        let schemeFile = config.scheme inputs.base16-vim;
        in { patchPhase = ''cp ${schemeFile} colors/base16-scheme.vim''; }
      ))

      vim-nix
      vim-terraform

      nvim-lspconfig
      completion-nvim

      (nvim-treesitter.withPlugins (plugins: with plugins; [
        tree-sitter-cpp
        tree-sitter-go
        tree-sitter-java
        tree-sitter-lua
        tree-sitter-nix
        tree-sitter-perl
        tree-sitter-rust
      ]))

      popup-nvim
      plenary-nvim
      telescope-nvim
      nvim-web-devicons

      vim-oscyank

      editorconfig-nvim
    ]
      (x: { plugin = x; });
  };

  xdg.configFile.nvim = {
    source = ./neovim;
    recursive = true;
  };
}
