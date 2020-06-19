#!/usr/bin/env zsh

if uname | grep Darwin >> /dev/null; then
    # override path order in /etc/zprofile
    path=( $path_prepend $path $path_append)
    typeset -U path
fi
