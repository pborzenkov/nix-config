{ config, lib, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    disableConfirmationPrompt = true;
    escapeTime = 0;
    historyLimit = 5000;
    keyMode = "vi";
    terminal = "tmux-256color";
    extraConfig = with config.lib.base16.theme; ''
      unbind -Troot C-b
      set-option -g prefix None

      bind -n M-D detach-client

      bind -n M-n new-window
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t 9
      bind -n M-0 select-window -t 10

      bind -n M-v split-window -h
      bind -n M-b split-window -v
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      bind -n M-H resize-pane -L
      bind -n M-J resize-pane -D
      bind -n M-K resize-pane -U
      bind -n M-L resize-pane -R
      bind -n M-f resize-pane -Z

      bind -n M-: command-prompt

      bind -n M-[ copy-mode
      bind -Tcopy-mode-vi y send-keys -X copy-selection-and-cancel
      bind -Tcopy-mode-vi v send-keys -X begin-selection
      bind -Tcopy-mode-vi C-v send-keys -X rectangle-toggle
      bind -n M-p paste-buffer

      set-option -g status-style "fg=#${base04-hex},bg=#${base01-hex}"
      set-window-option -g window-status-style "fg=#${base04-hex},bg=default"
      set-window-option -g window-status-current-style "fg=#${base0A-hex},bg=default"
      set-option -g pane-border-style "fg=#${base01-hex}"
      set-option -g pane-active-border-style "fg=#${base04-hex}"
      set-option -g message-style "fg=#${base05-hex},bg=#${base01-hex}"
      set-option -g display-panes-active-colour "#${base0B-hex}"
      set-option -g display-panes-colour "#${base0A-hex}"
      set-window-option -g clock-mode-colour "#${base0B-hex}"
      set-window-option -g mode-style "fg=#${base04-hex},bg=#${base02-hex}"
      set-window-option -g window-status-bell-style "fg=#${base01-hex},bg=#${base08-hex}"

      set-option -sa terminal-overrides ",xterm-256color:RGB"
    '';
  };
}
