{ config, pkgs, ... }:

{
  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv = {
        enable = true;
      };

      config = {
        disable_stdin = true;
        strict_env = false;
      };

      stdlib = ''
        : ''${XDG_CACHE_HOME:=$HOME/.cache}
        declare -A direnv_layout_dirs
        direnv_layout_dir() {
            echo "''${direnv_layout_dirs[$PWD]:=$(
                echo -n "$XDG_CACHE_HOME"/direnv/layouts/
                echo -n "$PWD" | shasum | cut -d ' ' -f 1
            )}"
        }
      '';
    };
  };

  home.packages = [
    # Common
    pkgs.man-pages
    pkgs.gnumake
    pkgs.gcc
    pkgs.gdb
    pkgs.bcc

    # Nix
    pkgs.cachix
    pkgs.nix-prefetch-github
    pkgs.nix-update
    pkgs.nixpkgs-review
    pkgs.rnix-lsp

    # Go
    pkgs.go_1_18
    pkgs.gopls

    # Rust
    (pkgs.rust-bin.stable.latest.default.override { extensions = [ "rust-src" ]; })
    pkgs.rust-analyzer

    pkgs.act
    pkgs.efm-langserver
    pkgs.sumneko-lua-language-server
    pkgs.terraform-ls
  ];

  xdg.configFile = {
    "psqlrc" = {
      text = ''
        \pset expanded
        \pset pager off
        \pset null ø
      '';
      target = "psqlrc";
    };
  };

  home.sessionVariables = {
    PSQLRC = "${config.home.homeDirectory}/${config.xdg.configFile.psqlrc.target}";
    GOPATH = "${config.home.homeDirectory}/.local/share/go";
  };
}
