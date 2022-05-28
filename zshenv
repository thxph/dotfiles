#!/usr/bin/env zsh

#zmodload zsh/zprof

if [[ -d /usr/local/go/bin ]]; then
    path_prepend=( /usr/local/go/bin $path_prepend )
fi

if [[ -d $HOME/.jenv/bin ]]; then
    path_prepend=( $HOME/.jenv/shims $path_prepend )
    path_append=( $path_append $HOME/.jenv/bin )
    path=( $path_prepend $path $path_append )
    typeset -U path
    eval "$(jenv init -)"
fi

function load-nvm() {
    export NVM_DIR="$HOME/.config/nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
}

typeset -U manpath
manpath=( $manpath )

export EDITOR=`which ex`
export CLICOLOR=1
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
if [[ $TERM != *(256color) ]]; then
    export TERM=xterm-256color
fi

# unset pushdignoredups & autopushd so zsh scripts behave normally
setopt NO_pushd_ignore_dups
setopt NO_auto_pushd
# expand dot files
setopt dotglob


# for OS X
if uname | grep Darwin >> /dev/null; then
    # env for stuff installed by macports
    export TERMINFO=/opt/local/share/terminfo
    manpath=(/opt/local/man /usr/local/man $manpath)
    cdpath=($cdpath ~/Documents)
    bindkey "\e[3~" delete-char
elif uname | grep Linux >> /dev/null; then
    export XDG_CONFIG_HOME="$HOME/.config"
fi

# set PATH
if uname | grep Darwin >> /dev/null; then
    path_prepend=( $path_prepend /usr/local/bin )
    path_append=( $path_append /usr/texbin /usr/local/opt/python/libexec/bin ~/Library/Python/2.7/bin )
fi
export GOPATH=$HOME/go
path=( $path_prepend $path $path_append $HOME/go/bin $HOME/wip/bin $HOME/bin . )
typeset -U path

export path_prepend
export path_append

# use nvim
export VISUAL=`which nvim`

if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi
