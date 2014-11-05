
if has('vim_starting')
  set nocompatible               " Be iMproved

  " Required:
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" Required:
call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" My Bundles here:
NeoBundle 'Shougo/vimproc', {
            \ 'build' : {
            \     'windows' : 'make -f make_mingw32.mak',
            \     'cygwin' : 'make -f make_cygwin.mak',
            \     'mac' : 'make -f make_mac.mak',
            \     'unix' : 'make -f make_unix.mak',
            \    },
            \ }
NeoBundle 'Shougo/neosnippet.vim'
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'kien/ctrlp.vim'
NeoBundle 'Shougo/vimshell'
NeoBundle 'scrooloose/nerdcommenter'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'Shougo/neocomplete.vim'
NeoBundle 'tomasr/molokai'
NeoBundle 'davidhalter/jedi-vim'
NeoBundle 'tpope/vim-surround'
NeoBundle 'taq/vim-git-branch-info'
NeoBundle 'Raimondi/delimitMate'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'bling/vim-airline'

call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck

" ==============================================================================
" Settings

set backspace=indent,eol,start  " Allow backspacing over everything

set history=1000                " Store 1000 :cmdline history

set showcmd                     " Show imcomplete cmds down the bottom
set showmode                    " Show current mode at the bottom

set incsearch                   " Incremental searching
set hlsearch                    " Highlight searches by default

set nowrap                        " Don't wrap lines
"set linebreak                  " Wrap lines at convenient points

set number                      " Show linenumber
set ruler                       " Show current cursor position all the time

" Keep backup file
set backup
set backupdir =$HOME/.vimbackup

" Indent settings
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab
set autoindent
autocmd FileType ruby set tabstop=2|set shiftwidth=2|set softtabstop=2

set textwidth=72                 " Set textwidth

" Folding settings
set foldmethod=indent           " Fold based on indent
set foldnestmax=7               " Deepest fold is 7 level
set nofoldenable                " Don't fold by default

" Wildmode settings
set wildmode=list:longest       " Make cmdline tab completion similar to bash
set wildmenu                    " Make ^n & ^p to scroll through matches
set wildignore=*.o,*.obj,*~     " Stuff to ignore when tab completing

" Display tabs ans trailing spaces
set list
set listchars=tab:▷⋅,trail:⋅,nbsp:⋅

set formatoptions-=o            " Don't continue comments when pushing o/O ?

" Vertical/Horizontal scroll off settings
set scrolloff=7777
set sidescrolloff=7
set sidescroll=1

" Turn on syntax highlighting
syntax on
set t_Co=256
set background=dark
colorscheme Tomorrow-Night-Eighties

set mouse=a                     " Enable mouse
set ttymouse=xterm2             " Enable mouse even in screen

set hidden                      " Allow vim to hide modified buffers

set ignorecase                  " Ignore case searching
set smartcase                   " Only ignore case when all text is lowercase

set grepprg=grep\ -nH\ $*

"compiler ruby

" ====================================================================
" Settings for neocomplete

"Note: This option must set it in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
        \ }

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
inoremap <expr><C-g>     neocomplete#undo_completion()
inoremap <expr><C-l>     neocomplete#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return neocomplete#close_popup() . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? neocomplete#close_popup() : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><C-y>  neocomplete#close_popup()
inoremap <expr><C-e>  neocomplete#cancel_popup()
" Close popup by <Space>.
"inoremap <expr><Space> pumvisible() ? neocomplete#close_popup() : "\<Space>"

" For cursor moving in insert mode(Not recommended)
"inoremap <expr><Left>  neocomplete#close_popup() . "\<Left>"
"inoremap <expr><Right> neocomplete#close_popup() . "\<Right>"
"inoremap <expr><Up>    neocomplete#close_popup() . "\<Up>"
"inoremap <expr><Down>  neocomplete#close_popup() . "\<Down>"
" Or set this.
"let g:neocomplete#enable_cursor_hold_i = 1
" Or set this.
"let g:neocomplete#enable_insert_char_pre = 1

" AutoComplPop like behavior.
"let g:neocomplete#enable_auto_select = 1

" Shell like behavior(not recommended).
"set completeopt+=longest
"let g:neocomplete#enable_auto_select = 1
"let g:neocomplete#disable_auto_complete = 1
"inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif
"let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
"let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
"let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'

if !exists('g:neocomplete#force_omni_input_patterns')
    let g:neocomplete#force_omni_input_patterns = {}
endif

autocmd FileType python setlocal omnifunc=jedi#completions
let g:jedi#completions_enabled = 0
let g:jedi#auto_vim_configuration = 0
let g:neocomplete#force_omni_input_patterns.python =
            \ '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*'

" ==============================================================================
" Statusline


set statusline=%f               " Filename

"   Display a warning if fileformat isn't unix
set statusline+=%#warningmsg#
set statusline+=%{&ff!='unix'?'['.&ff.']':''}
set statusline+=%*

"   Display a warning if file encoding isn't utf-8
set statusline+=%#warningmsg#
set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}
set statusline+=%*

set statusline+=%h              " Help file flag
set statusline+=%y              " Filetype
set statusline+=%r              " Read-only flag
set statusline+=%m              " Modified flag

" Display an error if &et is wrong, or we've mixed-indenting
set statusline+=%#error#
set statusline+=%{StatuslineTabWarning()}
set statusline+=%*

set statusline+=%{StatuslineTrailingSpaceWarning()}

set statusline+=%{StatuslineLongLineWarning()}

set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

" Display an error if &paste is set
set statusline+=%#error#
set statusline+=%{&paste?'[paste]':''}
set statusline+=%*

set statusline+=%=              " Left/right seperator
set statusline+=%{GitBranchInfoString()}          " Git branch info
set statusline+=%{StatuslineCurrentHighlight()} " Current highlight
set statusline+=%c,             " Cursor column
set statusline+=%l/%L           " Cursor line/total lines
set statusline+=\ %P            " Percent through file

set laststatus=2                " Display status line in all file

" ==============================================================================
" Functions ...

" Jump to last cursor pos when opening a file
" don't do it when writing a commit log entry
function! SetCursorPosition()
  if &filetype !~ 'commit\c'
    if line("'\"") > 0 && line("'\"") <= line("$")
      exe "normal! g`\""
      normal! zz
    endif
  endif
endfunction

" Define :HighlightLongLines cmd to highlight the offending parts of
" lines that are longer than the specified length (default to 80)
command! -nargs=? HighlightLongLines call s:HighlightLongLines('<args>')
function! s:HighlightLongLines(width)
  let targetWidth = a:width != '' ? a:width : 81
  if targetWidth > 0
    exec 'match Todo /\%>' . (targetWidth) . 'v/'
  else
    echomsg "Usage: HighlightLongLines [natural number]"
  endif
endfunction

" Return '[\s]' if trailing white space is detected
" return '' otherwise
function! StatuslineTrailingSpaceWarning()
  if !exists("b:statusline_trailing_space_warning")
    if search('\s\+$', 'nw') != 0
      let b:statusline_trailing_space_warning = '[\s]'
    else
      let b:statusline_trailing_space_warning = ''
    endif
  endif
  return b:statusline_trailing_space_warning
endfunction

" Return syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
  let name = synIDattr(synID(line('.'),col('.'),1),'name')
  if name == ''
    return ''
  else
    return '[' . name . '] '
  endif
endfunction

" Return '[&et]' if &et is set wrong
" return '[mixed-indenting]' if spaces and tabs are used to indent
" return an empty string if everything is fine
function! StatuslineTabWarning()
  if !exists("b:statusline_tab_warning")
    let ntabs = search('^\t', 'nw') != 0
    let nspaces = search('^ ', 'nw') != 0

    if ntabs && nspaces
      let b:statusline_tab_warning = '[mixed-indenting]'
    elseif (nspaces && !&et) || (ntabs && &et)
      let b:statusline_tab_warning = '[&et]'
    else
      let b:statusline_tab_warning = ''
    endif
  endif
  return b:statusline_tab_warning
endfunction

" Return a warning for "long lines" where "long" is either &textwidth or 80
" (if no &textwidth is set)
"
" return '' if no long lines
" return '[#x,my,$z]' if long lines are found, where x is the number of long
" lines, y is the median length of the long lines and z is the length of the
" longest line
function! StatuslineLongLineWarning()
  if !exists("b:statusline_long_line_warning")
    let long_line_lens = s:LongLines()

    if len(long_line_lens) > 0
      let b:statusline_long_line_warning = "[" .
        \ '#' . len(long_line_lens) . "," .
        \ 'm' . s:Median(long_line_lens) . "," .
        \ '$' . max(long_line_lens) . "]"
    else
      let b:statusline_long_line_warning = ""
    endif
  endif
  return b:statusline_long_line_warning
endfunction

" Return a list containing the length of the long lines in this buffer
function! s:LongLines()
  let threshold = (&tw ? &tw : 80)
  let spaces = repeat(" ", &ts)

  let long_line_lens = []

  let i = 1
  while i <= line("$")
    let len = strlen(substitute(getline(i), '\t', spaces, 'g'))
    if len > threshold
      call add(long_line_lens, len)
    endif
    let i += 1
  endwhile

  return long_line_lens
endfunction

" Find the median of the given array of numbers
function! s:Median(nums)
  let nums = sort(a:nums)
  let l = len(nums)

  if l % 2 == 1
    let i = (l-1) / 2
    return nums[i]
  else
    return (nums[l/2] + nums[(l/2)-1]) / 2
  endif
endfunction

" Visual search function
function! s:VSetSearch()
  let temp = @@
  norm! gvy
  let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
  let @@ = temp
endfunction

" ==============================================================================
" Autocmd

" Recalculate the long line warning when idle and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_long_line_warning

" Recalculate the tab warning flag when idle and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_tab_warning

" Jump to last cursor pos when opening a file
autocmd BufReadPost * call SetCursorPosition()

" Recalculate trailing whitespace warning when idle, and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_trailing_space_warning

" ==============================================================================
" Global Variables Settings

" Mark syntax errors with :signs
let g:syntastic_enable_signs=1

" Git branch info settings
let g:git_branch_status_head_current = 1    " just show current head branch name
let g:git_branch_status_text = ""           " text be4 branch
let g:git_branch_status_nogit = "[-na-]"    " message when there's no git repos
let g:git_branch_status_around = "[]"       " puts [] around str
let g:git_branch_status_ignore_remotes = 1  " ignore remote branches

"" Map leader to \
"let mapleader = "\\"

" ==============================================================================
" Mapping settings

" Map ^L to :noh
nnoremap <C-L> :nohls<CR>
inoremap <C-L> <C-O>:nohls<CR>

" Map Q to sth useful
nnoremap Q gq

" Make Y consistent with C and D
nnoremap Y y$

" Map * and # to search selected text
vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>

"imap <Leader>q <C-j>

"" Use camel case completion.
"let g:neocomplcache_enable_camel_case_completion = 1
"" Use underbar completion.
"let g:neocomplcache_enable_underbar_completion = 1


"" Plugin key-mappings.
"imap <C-k>     <Plug>(neocomplcache_snippets_expand)
"smap <C-k>     <Plug>(neocomplcache_snippets_expand)

"" SuperTab like snippets behavior.
""imap <expr><TAB> neocomplcache#sources#snippets_complete#expandable() ? "\<Plug>(neocomplcache_snippets_expand)" : pumvisible() ? "\<C-n>" : "\<TAB>"


"let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
"autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete

"imap <expr> - pumvisible() ? "\<Plug>(neocomplcache_start_unite_quick_match)" : '-'

"python from powerline.vim import setup as powerline_setup
"python powerline_setup()
"python del powerline_setup
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1


au FileType python map <leader>\ :!python % 
au FileType ruby map <leader>\ :!ruby % 

vnoremap <leader>] :!xclip -in -selection clipboard && xclip -out -selection clipboard<CR>
nnoremap <leader>[ :r!xclip -out -selection clipboard<CR>
