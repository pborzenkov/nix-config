zstyle ':completion:*' menu select

zmodload zsh/complist
bindkey -M menuselect -rp '^['

bindkey -M menuselect '^M' accept-line
bindkey -M menuselect '^C' send-break
bindkey -M menuselect '^D' accept-and-infer-next-history
bindkey -M menuselect '^U' undo
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history #
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'f' vi-forward-word
bindkey -M menuselect 'b' vi-backward-word
bindkey -M menuselect '}' vi-forward-blank-word
bindkey -M menuselect '{' vi-backward-blank-word
