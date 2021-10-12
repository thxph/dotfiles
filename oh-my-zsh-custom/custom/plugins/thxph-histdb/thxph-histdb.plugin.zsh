
if [[ uname == 'Darwin' ]]; then
    export HISTDB_TABULATE_CMD=(sed -e $'s/\x1f/\t/g')
fi

source $HOME/.oh-my-zsh/custom/plugins/zsh-histdb/sqlite-history.zsh
autoload -Uz add-zsh-hook

export HISTDB_FZF_DEFAULT_MODE=4
source $HOME/.oh-my-zsh/custom/plugins/zsh-histdb-fzf/fzf-histdb.zsh
bindkey '^R' histdb-fzf-widget


