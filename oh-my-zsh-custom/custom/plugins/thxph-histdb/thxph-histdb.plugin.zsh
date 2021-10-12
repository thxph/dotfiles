
if [[ uname == 'Darwin' ]]; then
    export HISTDB_TABULATE_CMD=(sed -e $'s/\x1f/\t/g')
fi

source $HOME/.oh-my-zsh/custom/plugins/zsh-histdb/sqlite-history.zsh
autoload -Uz add-zsh-hook

bindkey '^R' histdb-fzf-widget

