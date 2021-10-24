{ config, pkgs, ... }:

{
  programs = {
    go = {
      enable = true;
      goBin = "bin";
      goPath = ".local/share/go";
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;

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
    # Misc
    pkgs.manpages

    # Go
    pkgs.golangci-lint
    pkgs.gopls
    pkgs.gops

    # Rust
    pkgs.cargo
    pkgs.rustc
    pkgs.rust-analyzer
    pkgs.rustfmt
    pkgs.clippy
    pkgs.gcc # for linker

    # Lua
    pkgs.sumneko-lua-language-server

    # Nix
    pkgs.cachix
    pkgs.nixpkgs-fmt
    pkgs.rnix-lsp
    pkgs.nix-prefetch-github
    pkgs.nix-update

    # Tcl
    pkgs.expect

    # Protobuf
    pkgs.protobuf

    # Terraform
    pkgs.terraform_0_14
    pkgs.terraform-ls

    # Kubernetes
    pkgs.kubectl
    pkgs.kubectx
    pkgs.stern
    pkgs.kustomize

    # Jsonnet
    pkgs.jsonnet
    pkgs.jsonnet-bundler

    # Google Cloud
    pkgs.google-cloud-sdk
    pkgs.cloud-sql-proxy

    # Jira
    pkgs.go-jira

    # Postgres
    pkgs.postgresql_13
  ];

  programs.zsh.initExtra = ''
    source ${pkgs.google-cloud-sdk}/google-cloud-sdk/completion.zsh.inc
  '';

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
  };
}
