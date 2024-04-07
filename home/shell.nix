{
  lib,
  pkgs,
  config,
  ...
}: {
  programs = {
    fish = {
      enable = true;
      interactiveShellInit = ''
        set -U fish_greeting
        base16-${config.scheme.slug}
      '';
      plugins = [
        {
          name = "base16-fish";
          src = pkgs.fetchFromGitHub {
            owner = "tomyun";
            repo = "base16-fish";
            rev = "2f6dd973a9075dabccd26f1cded09508180bf5fe";
            sha256 = "sha256-PebymhVYbL8trDVVXxCvZgc0S5VxI7I1Hv4RMSquTpA=";
          };
        }
      ];
    };
    starship = {
      enable = true;
      enableFishIntegration = true;
      enableTransience = true;
      settings = {
        add_newline = true;
        format = lib.concatStrings [
          "[╭─](20) "
          "$jobs"
          "$directory"
          "$git_branch"
          "$git_status"
          "$git_state"
          "$fill"
          "$direnv"
          "$nix_shell"
          "\n[╰─](20)$character"
        ];
        command_timeout = 100;
        jobs.style = "2";
        directory = {
          fish_style_pwd_dir_length = 1;
          style = "12";
        };
        git_branch = {
          format = "([$symbol$branch(:$remote_branch) ]($style))";
          style = "10";
        };
        git_status = {
          ahead = "⇡\${count}";
          behind = "⇣\${count}";
          diverged = "⇡\${ahead_count} ⇣\${behind_count}";

          conflicted = "=\${count}";
          stashed = "$\${count}";
          deleted = "✘\${count}";
          renamed = "»\${count}";
          modified = "!\${count}";
          staged = "+\${count}";
          untracked = "?\${count}";

          format = "([($conflicted )($stashed )($deleted )($renamed )($staged )($modified )($untracked )($ahead_behind )]($style))";
          style = "16";
        };
        git_state.style = "16";
        fill.symbol = " ";
        direnv = {
          disabled = false;
          symbol = "Ⲇ ";
          format = "[$symbol$allowed]($style) ";
          style = "16";
        };
        nix_shell = {
          symbol = "❄ ";
          format = "[$symbol$state]($style) ";
          style = "6";
        };
        character = {
          success_symbol = "[❯](10)";
          error_symbol = "[❯](9)";
          vimcmd_symbol = "[❮](10)";
        };
      };
    };
  };
}
