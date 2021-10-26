{ config, lib, pkgs, ... }:

{
  home.packages = [
    pkgs.gitui
  ];

  programs = {
    git = {
      enable = true;

      extraConfig = {
        color = {
          ui = "auto";
        };

        core = {
          editor = "${config.programs.neovim.package}/bin/nvim";
        };

        pull = {
          rebase = true;
        };

        pager = lib.genAttrs [ "diff" "log" "show" ] (
          name: "${pkgs.delta}/bin/delta --navigate"
        );
      };

      ignores = [
        ".*.swp" # vim swap file
        ".envrc" # direnv environment
      ];

      userEmail = "pavel@borzenkov.net";
      userName = "Pavel Borzenkov";

      delta = {
        enable = true;
        options = {
          syntax-theme = config.themes.base16.scheme;
          line-numbers = true;

          width = 1;
          navigate = false;

          hunk-header-style = "file line-number syntax";
          hunk-header-decoration-style = "bold black";

          file-modified-label = "modified:";

          zero-style = "dim";

          minus-style = "bold red";
          minus-non-emph-style = "dim red";
          minus-emph-style = "bold red";
          minus-empty-line-marker-style = "normal normal";

          plus-style = "green normal bold";
          plus-non-emph-style = "dim green";
          plus-emph-style = "bold green";
          plus-empty-line-marker-style = "normal normal";

          whitespace-error-style = "reverse red";
        };
      };
    };

    gh = {
      enable = true;
      settings = {
        editor = "${config.programs.neovim.package}/bin/nvim";
        git_protocol = "ssh";
      };
    };
  };
}
