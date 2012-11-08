
let g:LatexBox_latexmk_options = '-pvc'
let g:LatexBox_viewer = 'skim'

setlocal formatoptions+=wa
imap <buffer> [[ \begin{
nmap <buffer> <f5> <plug>LatexChangeEnv
vmap <buffer> <f7> <plug>LatexWrapSelection

