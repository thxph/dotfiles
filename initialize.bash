#!/usr/bin/env bash
set -e

here="$(dirname "$0")"
here="$(cd "$here"; pwd)"

(cd $here; git submodule init)
(cd $here; git submodule update)


for file in "$here"/*; do
    name="$(basename "$file")"
    if [[ !( " initialize.bash oh-my-zsh-custom readme.md " =~ " $name " ) ]]; then
        if [[ -e "$HOME/.$name" ]]; then
            rm -rv "$HOME/.$name"
        fi
        if [[ `uname` == 'Linux' ]]; then
            ln -sfv $file "$HOME/.$name"
        elif [[ `uname` == 'Darwin' ]]; then
            ln -sfhv $file "$HOME/.$name"
        fi
    fi
done


if [[ `uname` == 'Linux' ]]; then
    find "$here/oh-my-zsh-custom/custom" -maxdepth 1 -mindepth 1 -type f -print0 | xargs -0 -L 1 -I % ln -sfv % "$HOME/.oh-my-zsh/custom/"
    find "$here/oh-my-zsh-custom/themes" -maxdepth 1 -mindepth 1 -print0 | xargs -0 -L 1 -I % ln -sfv % "$HOME/.oh-my-zsh/themes/"
    find "$here/oh-my-zsh-custom/custom/plugins/" -maxdepth 1 -mindepth 1 -print0 | xargs -0 -L 1 -I % ln -sfv % "$HOME/.oh-my-zsh/custom/plugins/"
elif [[ `uname` == 'Darwin' ]]; then
    find "$here/oh-my-zsh-custom/custom" -type f -depth 1 -print0 | xargs -0 -L 1 -I % ln -sfhv % "$HOME/.oh-my-zsh/custom/"
    find "$here/oh-my-zsh-custom/themes" -type f -depth 1 -print0 | xargs -0 -L 1 -I % ln -sfhv % "$HOME/.oh-my-zsh/themes/"
    find "$here/oh-my-zsh-custom/custom/plugins" -depth 1 -print0 | xargs -0 -L 1 -I % ln -sfhv % "$HOME/.oh-my-zsh/custom/plugins/"
fi
