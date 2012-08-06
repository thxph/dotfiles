## Command history configuration
HISTFILE=$HOME/.zsh_history
HISTSIZE=200000
SAVEHIST=200000

setopt hist_ignore_dups # ignore duplication command history list
setopt share_history # share command history data

setopt hist_verify
setopt inc_append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_space

setopt SHARE_HISTORY
setopt APPEND_HISTORY

setopt NO_hist_allow_clobber
setopt hist_beep
setopt NO_hist_no_functions
setopt NO_hist_save_no_dups
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt NO_hist_no_store
setopt hist_reduce_blanks

