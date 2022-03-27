{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraConfig = ''
      let base16colorspace=256
      colorscheme base16-${config.themes.base16.scheme}

      lua require('init')
    '';

    plugins = with pkgs.vimPlugins; lib.forEach [
      base16-vim

      vim-nix
      vim-terraform

      nvim-lspconfig
      completion-nvim

      nvim-treesitter

      popup-nvim
      plenary-nvim
      telescope-nvim
      nvim-web-devicons

      vim-oscyank
    ]
      (x: { plugin = x; });
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  xdg.configFile.nvim = {
    source = ./neovim;
    recursive = true;
  };

  xdg.configFile."nvim/parser/cpp.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-cpp}/parser";
  xdg.configFile."nvim/parser/go.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-go}/parser";
  xdg.configFile."nvim/parser/lua.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-lua}/parser";
  xdg.configFile."nvim/parser/nix.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-nix}/parser";
  xdg.configFile."nvim/parser/rust.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-rust}/parser";
}
