
"dein Scripts-----------------------------
if &compatible
  set nocompatible               " Be iMproved
endif

set rtp+=~/.fzf

" Required:

if has('nvim')
    let deinpath = '~/.cache/ndein'
else
    let deinpath = '~/.cache/dein'
endif


execute "set runtimepath+=".deinpath."/repos/github.com/Shougo/dein.vim"

" Required:
if dein#load_state(deinpath)
  call dein#begin(deinpath)

  " Let dein manage dein
  " Required:
  call dein#add(deinpath.'/repos/github.com/Shougo/dein.vim')

  " Add or remove your plugins here:
  "call dein#add('Shougo/neosnippet.vim')
  "call dein#add('Shougo/neosnippet-snippets')
  call dein#add('taq/vim-git-branch-info')
  call dein#add('ctrlpvim/ctrlp.vim')
  call dein#add('scrooloose/nerdcommenter')
  call dein#add('scrooloose/syntastic')
  call dein#add('tpope/vim-fugitive')
  "call dein#add('davidhalter/jedi-vim')
  call dein#add('tpope/vim-surround')
  call dein#add('Raimondi/delimitMate')
  call dein#add('Shougo/vimproc.vim', {'build' : 'make'})
  call dein#add('bling/vim-airline')
  "call dein#add('junegunn/fzf', { 'build': './install --all', 'merged': 0 })
  call dein#add('junegunn/fzf.vim')
  call dein#add('fatih/vim-go')
  "call dein#add('fatih/molokai')
  call dein#add('joshdick/onedark.vim')
  call dein#add('AndrewRadev/splitjoin.vim')
  call dein#add('SirVer/ultisnips')

  if has('nvim')
      call dein#add('Shougo/deoplete.nvim')
      call dein#add('Shougo/neopairs.vim')
      call dein#add('Shougo/neoinclude.vim')
      call dein#add('zchee/deoplete-go', {'build': 'make'})
  else
  endif


  " Required:
  call dein#end()
  call dein#save_state()
endif

" Required:
filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

"End dein Scripts-------------------------

if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif
"For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
"Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
" < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
if (has("termguicolors"))
    set termguicolors
endif

" ==============================================================================
" Settings

set backspace=indent,eol,start  " Allow backspacing over everything

set history=1000                " Store 1000 :cmdline history

set showcmd                     " Show imcomplete cmds down the bottom
set noshowmode                    " Show current mode at the bottom

if has("patch-7.4.314")
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
set wildmode=list:longest,full       " Make cmdline tab completion similar to bash
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
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

" Display an error if &paste is set
set statusline+=%#error#
set statusline+=%{&paste?'[paste]':''}
set statusline+=%*

set statusline+=%=              " Left/right seperator
"set statusline+=%{GitBranchInfoString()}          " Git branch info
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
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fw :Windows<CR>
nnoremap <leader><UP> <C-W>k
nnoremap <leader><DOWN> <C-W>j
nnoremap <leader><LEFT> <C-W>h
nnoremap <leader><RIGHT> <C-W>l
nnoremap <leader><SPACE> :Commands<CR>

"imap <Leader>q <C-j>

"python from powerline.vim import setup as powerline_setup
"python powerline_setup()
"python del powerline_setup
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

au FileType python map <leader>\ :!python %
au FileType ruby map <leader>\ :!ruby %

vnoremap <leader>] :!xclip -in -selection clipboard && xclip -out -selection clipboard<CR>
nnoremap <leader>[ :r!xclip -out -selection clipboard<CR>

" auto save when calling :make
set autowrite

" Some mappings
map <C-n> :cnext<CR>
map <C-m> :cprevious<CR>
nnoremap <leader>a :cclose<CR>

autocmd FileType go nmap <leader>\  <Plug>(go-run)
autocmd FileType go nmap <leader>tt  <Plug>(go-test)
autocmd FileType go nmap <leader>tf  <Plug>(go-test-func)
autocmd FileType go nmap <leader>tc  <Plug>(go-test-compile)

" run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>
autocmd FileType go nmap <Leader>c <Plug>(go-coverage-toggle)
let g:go_fmt_command = "goimports"

let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_generate_tags = 1

"let g:go_metalinter_autosave = 1
let g:go_metalinter_autosave_enabled = ['vet', 'golint']
let g:go_metalinter_deadline = "5s"

autocmd Filetype go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
autocmd Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
autocmd Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')
autocmd Filetype go command! -bang AT call go#alternate#Switch(<bang>0, 'tabe')

autocmd FileType go nmap <Leader>i <Plug>(go-info)
let g:go_auto_type_info = 1
let g:go_auto_sameids = 1

let g:UltiSnipsExpandTrigger="<S-Tab>"

if has('nvim')
    set completeopt+=noselect

    " Path to python interpreter for neovim
    let g:python3_host_prog  = '/usr/bin/python3'
    " Skip the check of neovim module
    let g:python3_host_skip_check = 1

    " Run deoplete.nvim automatically
    let g:deoplete#enable_at_startup = 1
    " deoplete-go settings
    "let g:deoplete#sources#go#gocode_binary = $GOPATH.'/bin/gocode'
    let g:deoplete#sources#go#sort_class = ['package', 'func', 'type', 'var', 'const']

    call deoplete#custom#set('_', 'converters', ['converter_auto_paren'])

    inoremap <silent><expr> <TAB>
        \ pumvisible() ? "\<C-n>" :
        \ <SID>check_back_space() ? "\<TAB>" :
        \ deoplete#mappings#manual_complete()
        function! s:check_back_space() abort "{{{
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~ '\s'
        endfunction"}}}

    " Close the documentation window when completion is done
    autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif


endif

