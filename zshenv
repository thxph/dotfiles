#!/usr/bin/env zsh

if [[ -d /usr/local/go/bin ]]; then
    path=( /usr/local/go/bin $path )
fi

if [[ -d $HOME/.jenv/bin ]]; then
    path=( $HOME/.jenv/bin $path )
    eval "$(jenv init -)"
    export JAVA_HOME=$(jenv javahome)
fi

if [[ -d /opt/maven/current ]]; then
    path=( /opt/maven/current/bin $path )
    export M2_HOME=/opt/maven/current
fi


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

typeset -U manpath
manpath=( $manpath )

export EDITOR=/usr/bin/ex
export VISUAL=/usr/bin/vim
export CLICOLOR=1
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export TERM=xterm-256color

# unset pushdignoredups & autopushd so zsh scripts behave normally
setopt NO_pushd_ignore_dups
setopt NO_auto_pushd
# expand dot files
setopt dotglob


# for OS X
if uname | grep Darwin >> /dev/null; then
    # env for stuff installed by macports
    export TERMINFO=/opt/local/share/terminfo
    path=( /usr/texbin /opt/local/sbin/ /opt/local/bin $path ~/Library/Python/2.7/bin
    /opt/local/lib/postgresql83/bin/ )
    manpath=(/opt/local/man /usr/local/man $manpath)
    cdpath=($cdpath ~/Documents)
elif uname | grep Linux >> /dev/null; then
    export XDG_CONFIG_HOME="$HOME/.config"
fi

export GOPATH=$HOME/src/golib:$HOME/src/go:$HOME/wip/go
path=( $path ~/.local/bin ~/bin $HOME/src/go/bin $HOME/wip/go/bin $HOME/src/golib/bin . )

typeset -U path

