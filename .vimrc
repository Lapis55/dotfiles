" .vimrc modified by mine.
" Delete some options from the sample,
" and add some packages.


" NeoBundle
" when vim starts, add NeoBundle path into runtimepath
if has('vim_starting')
  if &compatible
    set nocompatible
  endif
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" start NeoBundle config
call neobundle#begin(expand('~/.vim/bundle'))

" maintain NeoBundle version itself
NeoBundleFetch 'Shougo/neobundle.vim'

" list install or using plug-ins
"
NeoBundle 'Shougo/unite.vim'
" auto complete
NeoBundle 'Shougo/neocomplcache.vim'
NeoBundle 'Shougo/neosnippet'
NeoBundle 'Shougo/neosnippet-snippets'
" cursor jump
NeoBundle 'easymotion/vim-easymotion'
" asyncronous exe
NeoBundle 'Shougo/vimproc', {
\ 'build' : {
\     'windows' : 'tools\\update-dll-mingw',
\     'cygwin' : 'make -f make_cygwin.mak',
\     'mac' : 'make',
\     'linux' : 'make',
\     'unix' : 'gmake',
\    },
\ }
" shell on vim
NeoBundleLazy 'Shougo/vimshell', {
  \ 'depends' : 'Shougo/vimproc',
  \ 'autoload' : {
  \   'commands' : [{ 'name' : 'VimShell', 'complete' : 'customlist,vimshell#complete'},
  \                 'VimShellExecute', 'VimShellInteractive',
  \                 'VimShellTerminal', 'VimShellPop'],
  \   'mappings' : ['<Plug>(vimshell_switch)']
  \ }}
" colorscheme
NeoBundle 'Badacadabra/vim-archery'
" status bar
NeoBundle 'vim-airline/vim-airline'

" exit NeoBundle config
call neobundle#end() 

filetype plugin indent on

" install added plug-ins when vim starts
NeoBundleCheck



"--- Derived from the sample ---"
" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set nobackup		" do not keep a backup file, use versions instead
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Add optional packages.
"
" The matchit plugin makes the % command work better, but it is not backwards
" compatible.
packadd matchit



"--- Added by mine ---"
set background=dark
colorscheme archery
syntax on

set noswapfile			" don't make swap file
set fenc=utf-8			" set unicode
set cursorline			" insist the line
highlight CursorLine cterm=NONE ctermfg=none ctermbg=black
set virtualedit=onemore		" enable a cursor to go above the last char
set relativenumber number	" display number
set smartindent			" indent
set showmatch			" show the pair ( )
set ignorecase			" when search c, don't distinguish C and c
set smartcase			" when search C, distinguish C and c
set title			" display title
set clipboard=unnamed,unnamedplus " sync with OS clip board

"clear highlight command
nnoremap <Esc><Esc> :nohlsearch<CR><Esc>
 
"unable C-Z and replace as undo
inoremap <C-Z> <Esc>ui		
nnoremap <C-Z> u

"unable C-S and replace as undo
inoremap <C-s> <Esc>:w<CR>
nnoremap <C-s> :w<CR>

"use arrow key as gj, gk
nnoremap <Down> gj
nnoremap <Up> gk

"enable commands at IME
nnoremap あ a
nnoremap い i
nnoremap う u
nnoremap お o
nnoremap ｄｄ dd
nnoremap ｙｙ yy


""
"" Vim-LaTeX
""
" basic configuration
filetype plugin on
filetype indent on
set shellslash
set grepprg=grep\ -nH\ $*
let g:tex_flavor='latex'
" place holder 
let g:Imap_UsePlaceHolders = 1
let g:Imap_DeleteEmptyPlaceHolders = 1
let g:Imap_StickyPlaceHolders = 0
" disable folding
let g:Tex_Folding = 0
let g:Tex_AutoFolding = 0


""
"" easymotion
""
"map <Leader> <Plug>(easymotion-prefix)
let g:EasyMotion_do_mapping = 0 "disable default mapping
" Jump to anywhere you want with minimal keystrokes, with just one key binding.
" `s{char}{label}`
" nmap s <Plug>(easymotion-overwin-f)
" or
" `s{char}{char}{label}`
" Need one more keystroke, but on average, it may be more comfortable.
nmap s <Plug>(easymotion-overwin-f2)
xmap s <Plug>(easymotion-bd-f2)

" Turn on case insensitive feature
let g:EasyMotion_smartcase = 1

" JK motions: Line motions
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)


""
"" neo snippet
""
" use NeoComplCache
let g:neocomplcache_enable_at_startup = 1
" ignore (A,a) until parent char input
let g:neocomplcache_enable_smart_case = 1
" enable '_' completion
let g:neocomplcache_enable_underbar_completion = 1

" expand and jump
imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)
xmap <C-k> <Plug>(neosnippet_expand_target)
" select with TAB
imap <expr><TAB> pumvisible() ? "\<C-n>" :neosnippet#expandable_or_jumpable() ? "<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
" back with TAB
imap <expr><S-TAB> pumvisible() ? "\<C-p>" :neosnippet#expandable_or_jumpable() ? "<Plug>(neosnippet_expand_or_jump)" : "\<S-TAB>"
" decide with Enter
inoremap <expr><CR> neocomplcache#smart_close_popup() . "\<CR>"
" undo completion 
inoremap <expr><C-l> neocomplcache#undo_completion()

" user definition snippet
let g:neosnippet#snippets_directory='~/.vim/bundle/neosnippet-snippets/snippets/'


" vimshell {{{
nmap <silent> vs :<C-u>VimShell<CR>
nmap <silent> vp :<C-u>VimShellPop<CR>
" }}}

