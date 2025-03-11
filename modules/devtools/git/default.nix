{
  config,
  lib,
  pborlib,
  pkgs,
  ...
}: let
  cfg = config.pbor.devtools.git;
in {
  imports = pborlib.allDirs ./.;

  options = {
    pbor.devtools.git.enable = (lib.mkEnableOption "Enable git") // {default = config.pbor.devtools.enable;};
  };

  config = lib.mkIf cfg.enable {
    hm.programs.git = {
      enable = true;
      package = pkgs.gitFull;

      extraConfig = {
        color = {
          ui = "auto";
        };

        core = {
          editor = "hx";
        };

        pull = {
          rebase = true;
        };

        pager = lib.genAttrs ["diff" "log" "show"] (
          name: "delta --navigate"
        );

        sendemail = {
          smtpserver = "smtp.fastmail.com";
          smtpuser = "pavel@borzenkov.net";
          smtpencryption = "ssl";
          smtpserverport = 465;
        };

        "credential \"smtp://pavel%40borzenkov.net@smtp.fastmail.com%3a465\"" = {
          helper = ''!f() { test "$1" = get && echo "password=$(rbw get fastmail.com/git)"; }; f'';
        };
      };

      userEmail = "pavel@borzenkov.net";
      userName = "Pavel Borzenkov";

      delta = {
        enable = true;
        options = {
          syntax-theme = "base16";
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
  };
}
