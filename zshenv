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


# Load nvm if present | Credit to https://github.com/nylen/dotfiles/blob/master/.bashrc_nylen_dotfiles
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    # Load nvm but don't use it yet: we need to do some other hacks first.
    # See https://github.com/creationix/nvm/issues/1261#issuecomment-366879288
    source "$NVM_DIR/nvm.sh" --no-use
    # I don't need this check, and it's slow (loads npm).
    # Do not use the npm `prefix` config; do not report related bugs to nvm ;)
    nvm_die_on_prefix() {
        return 0
    }
    # This also loads npm; let's just skip it.
    nvm_print_npm_version() {
        return 0
    }
    # nvm_resolve_local_alias can also be slow; cache it.
    if [ -s "$NVM_DIR/_default_version" ]; then
        NVM_AUTO_LOAD_VERSION=$(cat "$NVM_DIR/_default_version")
    else
        NVM_AUTO_LOAD_VERSION=$(nvm_resolve_local_alias default)
        echo "$NVM_AUTO_LOAD_VERSION" > "$NVM_DIR/_default_version"
    fi
    nvm use --silent "$NVM_AUTO_LOAD_VERSION"
fi

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
    path=( /usr/local/bin $path /usr/texbin  /usr/local/opt/python/libexec/bin ~/Library/Python/2.7/bin )
fi
export GOPATH=$HOME/go
path=( $path ~/.local/bin ~/bin $HOME/go/bin $HOME/wip/bin . )
typeset -U path

# use nvim
export VISUAL=`which nvim`

