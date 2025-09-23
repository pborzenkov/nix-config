{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.pbor.yazi;
in
{
  options = {
    pbor.yazi.enable = (lib.mkEnableOption "Enable yazi") // {
      default = config.pbor.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    hm = {
      programs.yazi = {
        enable = true;
        enableFishIntegration = true;
        keymap = {
          mgr.keymap = [
            {
              on = "<Esc>";
              run = "escape";
              desc = "Exit visual mode, clear selection, or cancel search";
            }
            {
              on = "q";
              run = "quit";
              desc = "Quick the process";
            }
            {
              on = "<C-c>";
              run = "close";
              desc = "Close the current tab, or quit if it's last";
            }

            {
              on = "k";
              run = "arrow prev";
              desc = "Previous file";
            }
            {
              on = "j";
              run = "arrow next";
              desc = "Next file";
            }
            {
              on = "<C-u>";
              run = "arrow -50%";
              desc = "Move cursor up half page";
            }
            {
              on = "<C-d>";
              run = "arrow 50%";
              desc = "Move cursor down half page";
            }
            {
              on = "<C-b>";
              run = "arrow -100%";
              desc = "Move cursor up one page";
            }
            {
              on = "<C-f>";
              run = "arrow 100%";
              desc = "Move cursor down one page";
            }
            {
              on = [
                "g"
                "g"
              ];
              run = "arrow top";
              desc = "Go to top";
            }
            {
              on = "G";
              run = "arrow bot";
              desc = "Go to bottom";
            }

            {
              on = "h";
              run = "leave";
              desc = "Back to the parent directory";
            }
            {
              on = "l";
              run = "enter";
              desc = "Enter the child directory";
            }
            {
              on = "H";
              run = "back";
              desc = "Back to previous directory";
            }
            {
              on = "L";
              run = "forward";
              desc = "Forward to next directory";
            }

            {
              on = "<Space>";
              run = [
                "toggle"
                "arrow next"
              ];
              desc = "Toggle the current selection state";
            }
            {
              on = "<C-a>";
              run = "toggle_all --state=on";
              desc = "Select all files";
            }
            {
              on = "<C-r>";
              run = "toggle_all";
              desc = "Invert selection of all files";
            }
            {
              on = "v";
              run = "visual_mode";
              desc = "Enter visual mode (selection mode)";
            }
            {
              on = "V";
              run = "visual_mode --unset";
              desc = "Enter visual mode (unset mode)";
            }

            {
              on = "K";
              run = "seek -5";
              desc = "Seek up 5 units in the preview";
            }
            {
              on = "J";
              run = "seek 5";
              desc = "Seek down 5 units in the preview";
            }

            {
              on = "<Tab>";
              run = "spot";
              desc = "Spot hovered file";
            }

            {
              on = "o";
              run = "open";
              desc = "Open selected files";
            }
            {
              on = "O";
              run = "open --interactive";
              desc = "Open selected files interactively";
            }
            {
              on = "<C-o>";
              run = [
                "open"
                "quit"
              ];
              desc = "Open selected files and quit";
            }
            {
              on = "y";
              run = "yank";
              desc = "Yank selected files (copy)";
            }
            {
              on = "x";
              run = "yank --cut";
              desc = "Yank selected files (cut)";
            }
            {
              on = "p";
              run = "paste";
              desc = "Paste yanked files";
            }
            {
              on = "P";
              run = "paste --force";
              desc = "Paste yanked files (overwrite if the destination exists)";
            }
            {
              on = "-";
              run = "link";
              desc = "Symlink the absolute path of yanked files";
            }
            {
              on = "_";
              run = "link --relative";
              desc = "Symlink the relative path of yanked files";
            }
            {
              on = "=";
              run = "hardlink";
              desc = "Hardlink yanked files";
            }
            {
              on = "Y";
              run = "unyank";
              desc = "Cancel the yank status";
            }
            {
              on = "X";
              run = "unyank";
              desc = "Cancel the yank status";
            }
            {
              on = "d";
              run = "remove --permanently";
              desc = "Permanently delete selected files";
            }
            {
              on = "a";
              run = "create";
              desc = "Create a file (ends with / for directories)";
            }
            {
              on = "r";
              run = "rename --cursor=before_ext";
              desc = "Rename selected file(s)";
            }
            {
              on = ";";
              run = "shell --interactive";
              desc = "Run a shell command";
            }
            {
              on = ":";
              run = "shell --block --interactive";
              desc = "Run a shell command (block until finishes)";
            }
            {
              on = ".";
              run = "hidden toggle";
              desc = "Toggle the visibility of hidden files";
            }
            {
              on = "s";
              run = "search --via=fd";
              desc = "Search files by name via fd";
            }
            {
              on = "S";
              run = "search --via=rg";
              desc = "Search files by content via ripgrep";
            }
            {
              on = "<C-s>";
              run = "escape --search";
              desc = "Cancel the ongoing search";
            }

            {
              on = "M";
              run = "plugin mount";
              desc = "Mount/unmount external devices";
            }
            {
              on = "z";
              run = "plugin zoxide";
              desc = "Jump to a directory via zoxide";
            }
            {
              on = "w";
              run = "tasks:show";
              desc = "Show task manager";
            }

            {
              on = [
                "m"
                "s"
              ];
              run = "linemode size";
              desc = "Linemode: size";
            }
            {
              on = [
                "m"
                "p"
              ];
              run = "linemode permissions";
              desc = "Linemode: permissions";
            }
            {
              on = [
                "m"
                "b"
              ];
              run = "linemode btime";
              desc = "Linemode: btime";
            }
            {
              on = [
                "m"
                "m"
              ];
              run = "linemode mtime";
              desc = "Linemode: mtime";
            }
            {
              on = [
                "m"
                "o"
              ];
              run = "linemode owner";
              desc = "Linemode: owner";
            }
            {
              on = [
                "m"
                "n"
              ];
              run = "linemode none";
              desc = "Linemode: none";
            }

            {
              on = [
                "c"
                "c"
              ];
              run = "copy path";
              desc = "Copy the file path";
            }
            {
              on = [
                "c"
                "d"
              ];
              run = "copy dirname";
              desc = "Copy the directory path";
            }
            {
              on = [
                "c"
                "f"
              ];
              run = "copy filename";
              desc = "Copy the filename";
            }
            {
              on = [
                "c"
                "n"
              ];
              run = "copy name_without_ext";
              desc = "Copy the filename without extension";
            }

            {
              on = "f";
              run = "filter --smart";
              desc = "Filter files";
            }

            {
              on = "/";
              run = "find --smart";
              desc = "Find next file";
            }
            {
              on = "?";
              run = "find --previous --smart";
              desc = "Find previous file";
            }
            {
              on = "n";
              run = "find_arrow";
              desc = "Next found";
            }
            {
              on = "N";
              run = "find_arrow --previous";
              desc = "Previous found";
            }

            {
              on = [
                ","
                "m"
              ];
              run = [
                "sort mtime --reverse=no"
                "linemode mtime"
              ];
              desc = "Sort by modified time";
            }
            {
              on = [
                ","
                "M"
              ];
              run = [
                "sort mtime --reverse"
                "linemode mtime"
              ];
              desc = "Sort by modified time (reverse)";
            }
            {
              on = [
                ","
                "b"
              ];
              run = [
                "sort btime --reverse=no"
                "linemode btime"
              ];
              desc = "Sort by birth time";
            }
            {
              on = [
                ","
                "B"
              ];
              run = [
                "sort btime --reverse"
                "linemode btime"
              ];
              desc = "Sort by birth time (reverse)";
            }
            {
              on = [
                ","
                "e"
              ];
              run = "sort extension --reverse=no";
              desc = "Sort by extension";
            }
            {
              on = [
                ","
                "E"
              ];
              run = "sort extension --reverse";
              desc = "Sort by extension (reverse)";
            }
            {
              on = [
                ","
                "a"
              ];
              run = "sort alphabetical --reverse=no";
              desc = "Sort alphabetically";
            }
            {
              on = [
                ","
                "A"
              ];
              run = "sort alphabetical --reverse";
              desc = "Sort alphabetically (reverse)";
            }
            {
              on = [
                ","
                "n"
              ];
              run = "sort natural --reverse=no";
              desc = "Sort naturally";
            }
            {
              on = [
                ","
                "N"
              ];
              run = "sort natural --reverse";
              desc = "Sort naturally (reverse)";
            }
            {
              on = [
                ","
                "s"
              ];
              run = [
                "sort size --reverse=no"
                "linemode size"
              ];
              desc = "Sort by size";
            }
            {
              on = [
                ","
                "S"
              ];
              run = [
                "sort size --reverse"
                "linemode size"
              ];
              desc = "Sort by size (reverse)";
            }
            {
              on = [
                ","
                "r"
              ];
              run = "sort random --reverse=no";
              desc = "Sort randomly";
            }

            {
              on = [
                "g"
                "h"
              ];
              run = "cd ~";
              desc = "Go home";
            }
            {
              on = [
                "g"
                "d"
              ];
              run = "cd ~/down";
              desc = "Go ~/down";
            }
            {
              on = [
                "g"
                "<Space>"
              ];
              run = "cd --interactive";
              desc = "Jump interactively";
            }
            {
              on = [
                "g"
                "f"
              ];
              run = "follow";
              desc = "Follow hovered symlink";
            }

            {
              on = "t";
              run = "tab_create --current";
              desc = "Create a new tab with CWD";
            }
            {
              on = "1";
              run = "tab_switch 0";
              desc = "Switch to first tab";
            }
            {
              on = "2";
              run = "tab_switch 1";
              desc = "Switch to second tab";
            }
            {
              on = "3";
              run = "tab_switch 2";
              desc = "Switch to third tab";
            }
            {
              on = "4";
              run = "tab_switch 3";
              desc = "Switch to fourth tab";
            }
            {
              on = "5";
              run = "tab_switch 4";
              desc = "Switch to fifth tab";
            }
            {
              on = "6";
              run = "tab_switch 5";
              desc = "Switch to sixth tab";
            }
            {
              on = "7";
              run = "tab_switch 6";
              desc = "Switch to seventh tab";
            }
            {
              on = "8";
              run = "tab_switch 7";
              desc = "Switch to eighth tab";
            }
            {
              on = "9";
              run = "tab_switch 8";
              desc = "Switch to ninth tab";
            }
            {
              on = "[";
              run = "tab_switch -1 --relative";
              desc = "Switch to previous tab";
            }
            {
              on = "]";
              run = "tab_switch 1 --relative";
              desc = "Switch to next tab";
            }
            {
              on = "{";
              run = "tab_swap -1";
              desc = "Swap current tab with previous tab";
            }
            {
              on = "}";
              run = "tab_swap 1";
              desc = "Swap current tab with next tab";
            }

            {
              on = "~";
              run = "help";
              desc = "Open help";
            }
          ];
        };
        settings = {
          open.prepend_rules = [
            {
              name = "**VIDEO_TS/";
              use = [
                "play"
                "reveal"
              ];
            }
          ];
          opener = {
            edit = [
              {
                run = ''hx "$@"'';
                desc = "Edit";
                block = true;
              }
            ];
            play = [
              {
                run = ''mpv --fs "$@"'';
                orphan = true;
              }
            ];
          };
        };
        plugins = {
          mount = pkgs.yaziPlugins.mount;
        };
      };
      stylix.targets.yazi.enable = true;
    };
  };
}
