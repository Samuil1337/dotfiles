# Lines configured by zsh-newuser-install
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt autocd beep nomatch
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/smuil/.zshrc'

autoload -Uz compinit promptinit
compinit
promptinit
# End of lines added by compinstall
prompt walters

# Shortcuts
alias gp='git pull'
alias ll='ls -la'
alias tmppkg='BUILDDIR=/tmp/makepkg makepkg'
alias config='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'

# Personalisation
alias diff='diff --color=auto'
alias ip='ip --color=auto'
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Fishiness
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

neofetch
