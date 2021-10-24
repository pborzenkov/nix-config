bindkey '^a' beginning-of-line
bindkey '^e' end-of-line
bindkey '^h' backward-delete-char

bindkey '^b' push-line-or-edit

bindkey '^k' insert-last-word

bindkey '^n' down-line-or-history
bindkey '^p' up-line-or-history

export KEYTIMEOUT=1
export WORDCHARS=''${WORDCHARS/_-/}
