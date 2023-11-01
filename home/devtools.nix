{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
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

  home.packages =
    [
      # Common
      pkgs.man-pages
      pkgs.man-pages-posix
      pkgs.gnumake
      pkgs.just

      # Nix
      pkgs.cachix
      pkgs.nix-prefetch-git
      pkgs.nix-prefetch-github
      pkgs.nix-update
      pkgs.nixpkgs-review
      pkgs.nil
      pkgs.alejandra
      inputs.devenv.packages.x86_64-linux.default

      # Go
      pkgs.go
      pkgs.gopls
      pkgs.golangci-lint

      # Rust
      pkgs.cargo
      pkgs.rustc
      pkgs.rust-analyzer
      pkgs.cargo-nextest

      # Erlang
      pkgs.erlang
      pkgs.erlang-ls
      pkgs.rebar3

      # Elixir
      pkgs.elixir
      pkgs.elixir-ls

      pkgs.act
      pkgs.efm-langserver
      pkgs.sumneko-lua-language-server
      pkgs.terraform-ls
      pkgs.ltex-ls
      pkgs.radare2
      pkgs.teleport_12
      pkgs.prox
      pkgs.hurl
    ]
    ++ lib.optionals (pkgs.stdenv.isLinux) [
      pkgs.gcc
      pkgs.gdb
      pkgs.bcc
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
