{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.pbor.shell;
in
{
  options = {
    pbor.shell.enable = (lib.mkEnableOption "Enable shell") // {
      default = config.pbor.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.fish.enable = true;
    users.users.pbor.shell = pkgs.fish;

    hm = {
      programs = {
        fish = {
          enable = true;
          interactiveShellInit = ''
            set -U fish_greeting
          '';
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
              "$hostname"
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
            hostname = {
              format = "[$ssh_symbol$hostname]($style) ";
              style = "11";
            };
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
      stylix.targets.fish.enable = true;
    };
  };
}
