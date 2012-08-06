#!/usr/bin/env bash
set -e

here="$(dirname "$0")"
here="$(cd "$here"; pwd)"

find "$here/oh-my-zsh-custom/custom" -depth 1 -print0 | xargs -0 -L 1 -I % ln -sfhv % "oh-my-zsh/custom/"
find "$here/oh-my-zsh-custom/themes" -depth 1 -print0 | xargs -0 -L 1 -I % ln -sfhv % "oh-my-zsh/themes/"

for file in "$here"/*; do
    name="$(basename "$file")"
    if [[ !( " initialize.bash oh-my-zsh-custom readme.md " =~ " $name " || -d $file/.git ) ]]; then
        echo $file
    fi
done
