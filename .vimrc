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
NeoBundle 'Shougo/unite.vim'

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
colorscheme molokai
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

"clear highlight
nnoremap <Esc><Esc> :nohlsearch<CR><Esc>
 
"unable C-Z and replace as undo
inoremap <C-Z>	<Esc>ui		
nnoremap <C-Z>	u

"use arrow key as gj, gk
nnoremap <Down> gj
nnoremap <Up> gk

"enable move cursor at insert-mode
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-h> <Left>
inoremap <C-l> <Right>

"enable commands at IME
nnoremap あ a
nnoremap い i
nnoremap う u
nnoremap お p
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

