# Common aliases
alias ls="ls --color=auto"
alias grep="grep --color=auto"

# SSH but using proxy jump
alias sshj="PROXY_JUMP=1 ssh"
alias sshj-tunnel="PROXY_JUMP=1 ssh-tunnel"

# Wrap tmux to avoid issues with direnv environment loading
alias tmux='direnv exec / tmux'
