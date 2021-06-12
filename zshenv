#!/usr/bin/env zsh

#zmodload zsh/zprof

if [[ -d /usr/local/go/bin ]]; then
    path_prepend=( /usr/local/go/bin $path_prepend )
fi

if [[ -d $HOME/.jenv/bin ]]; then
    path_prepend=( $HOME/.jenv/shims $path_prepend )
    path_append=( $path_append $HOME/.jenv/bin )
    eval "$($HOME/.jenv/bin/jenv init -)"
fi

function load-nvm() {
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
        nvm use --silent "$NVM_AUTO_LOAD_VERSION" > /dev/null
    fi
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

. "$HOME/.cargo/env"
