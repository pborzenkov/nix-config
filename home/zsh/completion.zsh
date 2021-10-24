zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path "$HOME/.zsh/cache"
zstyle ':completion:*' completer _complete _match _approximate

zstyle ':completion:*:match:*' original only
zstyle ':completion:*' matcher-list 'm:{[:lower:]}=[{:upper:}]' 'r:|[._-/]=* r:|=*'

zstyle ':completion:*:approximate:*' max-errors 2 numeric

zstyle ':completion:*' squeeze-slashes true
