scriptencoding utf-8

let g:mapleader = ' '
set runtimepath+=~/.fzf

call plug#begin('~/.vim/plugged')

Plug 'joshdick/onedark.vim'
Plug 'bling/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/nerdcommenter'
"Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-unimpaired'

Plug 'tpope/vim-surround'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
"Plug 'vim-syntastic/syntastic'
Plug 'junegunn/vim-slash'
Plug 'junegunn/gv.vim'
Plug 'junegunn/vim-easy-align'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'dense-analysis/ale'

Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

call plug#end()

" Required:
filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
"if dein#check_install()
"  call dein#install()
"endif

"End dein Scripts-------------------------

if (has('nvim'))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif
"For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
"Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
" < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
if (has('termguicolors'))
""    set termguicolors
endif

" ==============================================================================
" Settings

set backspace=indent,eol,start  " Allow backspacing over everything

set history=1000                " Store 1000 :cmdline history

set showcmd                     " Show imcomplete cmds down the bottom
set noshowmode                    " Show current mode at the bottom

if has('patch-7.4.314')
    set shortmess+=c
endif

set incsearch                   " Incremental searching
set hlsearch                    " Highlight searches by default

set nowrap                        " Don't wrap lines
"set linebreak                  " Wrap lines at convenient points

set number                      " Show linenumber
set ruler                       " Show current cursor position all the time

" Keep backup file
set backup
set backupdir =$HOME/.vimbackup

" default indent settings
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab
set autoindent

" commands
command BD bp|bd #

map <F1> :NERDTreeToggle<CR>

augroup pythonConf
    au FileType python map <leader>\ :!python %
augroup END

augroup rubyConf
    au FileType ruby map <leader>\ :!ruby %
    au FileType ruby set tabstop=2|set shiftwidth=2|set softtabstop=2
augroup END

augroup golangConf
    au FileType go set noexpandtab|set shiftwidth=4|set softtabstop=4|set tabstop=4
    au FileType go nmap <leader>\  <Plug>(go-run)
    au FileType go nmap <leader>tt  <Plug>(go-test)
    au FileType go nmap <leader>tf  <Plug>(go-test-func)
    au FileType go nmap <leader>tc  <Plug>(go-test-compile)
    au FileType go nmap <Leader>i <Plug>(go-info)
    au FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>
    au FileType go nmap <Leader>c <Plug>(go-coverage-toggle)
    au FileType go nmap <F9> :GoCoverageToggle -short<cr>
augroup END

set textwidth=72                 " Set textwidth
set formatoptions=cq
set wrapmargin=0

" Folding settings
set foldmethod=indent           " Fold based on indent
set foldnestmax=7               " Deepest fold is 7 level
set nofoldenable                " Don't fold by default

" Wildmode settings
set wildmode=list:longest,full       " Make cmdline tab completion similar to bash
set wildmenu                    " Make ^n & ^p to scroll through matches
set wildignore=*.o,*.obj,*~     " Stuff to ignore when tab completing

" Display tabs ans trailing spaces
set list
set listchars=tab:▷⋅,trail:⋅,nbsp:⋅

" Vertical/Horizontal scroll off settings
set scrolloff=3
set sidescrolloff=7
set sidescroll=1

" Turn on syntax highlighting
syntax on
"set t_Co=256
set background=dark
"let g:rehash256 = 1
"let g:molokai_original = 1
colorscheme onedark
let g:airline_theme='onedark'

set mouse=a                     " Enable mouse

if !has('nvim')
    set ttymouse=xterm2             " Enable mouse even in screen
    set viminfo=%,'50,\"100,:100,n~/.viminfo
endif

set hidden                      " Allow vim to hide modified buffers

set ignorecase                  " Ignore case searching
set smartcase                   " Only ignore case when all text is lowercase

set grepprg=grep\ -nH\ $*

" ==============================================================================
" Functions ...

" Jump to last cursor pos when opening a file
" don't do it when writing a commit log entry
function! SetCursorPosition()
  if &filetype !~? 'commit\c'
    if line("'\"") > 0 && line("'\"") <= line('$')
      exe "normal! g`\""
      normal! zz
    endif
  endif
endfunction

" Visual search function
function! s:VSetSearch()
  let l:temp = @@
  norm! gvy
  let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
  let @@ = l:temp
endfunction

" ==============================================================================
" Autocmd to run when loading new buffer

" Jump to last cursor pos when opening a file
augroup reloadLastPos
    autocmd BufReadPost * call SetCursorPosition()
augroup END

" Map backspace to switch to previous buffer
nnoremap <BS> <C-^><CR>

" Map Q to sth useful
nnoremap Q gq

" Make Y consistent with C and D
nnoremap Y y$

" Map * and # to search selected text
vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>

nnoremap <leader>ff :FZF<CR>
nnoremap <leader>fb :buffers<CR>
"nnoremap <leader>fw :Windows<CR>
nnoremap <leader><UP> <C-W>k
nnoremap <leader><DOWN> <C-W>j
nnoremap <leader><LEFT> <C-W>h
nnoremap <leader><RIGHT> <C-W>l
nnoremap <leader>w<UP> <C-W>K
nnoremap <leader>w<DOWN> <C-W>J
nnoremap <leader>w<LEFT> <C-W>H
nnoremap <leader>w<RIGHT> <C-W>L
nnoremap <leader><SPACE> :Commands<CR>

"imap <Leader>q <C-j>

" Ale configuration
let g:ale_sign_error = '⤫'
let g:ale_sign_warning = '⚠'
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

" Airline configuration
let g:airline#extensions#tabline#enabled = 1
let g:airline_detect_modified = 1
let g:airline_powerline_fonts = 1
let g:airline#extensions#ale#enabled = 1

" auto save when calling :make
set autowrite

nnoremap <leader>a :cclose<CR>:lclose<CR>
nnoremap <leader>A :cw<CR>:lw<CR>

" run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

let g:go_fmt_command = 'goimports'

let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_generate_tags = 1

"let g:go_metalinter_autosave = 1
let g:go_metalinter_autosave_enabled = ['vet', 'golint']
let g:go_metalinter_deadline = '5s'

autocmd Filetype go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
autocmd Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
autocmd Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')
autocmd Filetype go command! -bang AT call go#alternate#Switch(<bang>0, 'tabe')

let g:go_auto_type_info = 1
let g:go_auto_sameids = 1

