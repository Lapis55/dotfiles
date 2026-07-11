" .vimrc modified by mine.
" Managed by ~/dotfiles with GNU Stow.

if &compatible
  set nocompatible
endif

" vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  echohl WarningMsg
  echom 'vim-plug is not installed. See ~/dotfiles/README.md.'
  echohl None
else
  call plug#begin('~/.vim/plugged')

  Plug 'tpope/vim-sensible'
  Plug 'easymotion/vim-easymotion'
  Plug 'tomtom/tcomment_vim'
  Plug 'thinca/vim-quickrun'
  Plug 'Shougo/neosnippet.vim'
  Plug 'Shougo/neosnippet-snippets'

  call plug#end()
endif

filetype plugin indent on


"--- Derived from sample ---"
" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set nobackup
set nowritebackup
set undofile
set undodir=~/.vim/undo//
set history=50
set ruler
set showcmd
set incsearch

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors.
if &t_Co > 2 || has('gui_running')
  syntax on
  set hlsearch
endif

" Add optional packages.
packadd matchit


"--- Added by mine ---"
set background=dark
syntax on
set t_Co=256
colorscheme elflord

set directory=~/.vim/swap//
set backupdir=~/.vim/backup//
silent! call mkdir(expand('~/.vim/swap'), 'p')
silent! call mkdir(expand('~/.vim/backup'), 'p')
silent! call mkdir(expand('~/.vim/undo'), 'p')
set fenc=utf-8
set cursorline
highlight CursorLine cterm=NONE ctermfg=none ctermbg=black
set virtualedit=onemore
set relativenumber number
set smartindent
set showmatch
set ignorecase
set smartcase
set title
set clipboard=unnamed,unnamedplus

" clear highlight command
nnoremap <Esc><Esc> :nohlsearch<CR><Esc>

" replace C-Z as undo
inoremap <C-Z> <Esc>ui
nnoremap <C-Z> u

" replace C-S as save
inoremap <C-s> <Esc>:w<CR>
nnoremap <C-s> :w<CR>

" use arrow key as gj, gk
nnoremap <Down> gj
nnoremap <Up> gk

" enable commands at IME
nnoremap あ a
nnoremap い i
nnoremap う u
nnoremap お o
nnoremap ｄｄ dd
nnoremap ｙｙ yy


"" quickrun
" output window: bottom, if no output: window close
let g:quickrun_config = {
\ '_' : {
\   'outputter/buffer/split' : ':botright',
\   'outputter/buffer/close_on_empty' : 1
\ },
\}
" kill quickrun with ctrl+c
nnoremap <expr><silent> <C-c> exists('*quickrun#is_running') && quickrun#is_running() ? quickrun#sweep_sessions() : "\<C-c>"


"" easymotion
let g:EasyMotion_do_mapping = 0
nmap s <Plug>(easymotion-overwin-f2)
xmap s <Plug>(easymotion-bd-f2)
let g:EasyMotion_smartcase = 1
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)


"" neo snippet
imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)
xmap <C-k> <Plug>(neosnippet_expand_target)
imap <expr><TAB> pumvisible() ? "\<C-n>" : exists('*neosnippet#expandable_or_jumpable') && neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
imap <expr><S-TAB> pumvisible() ? "\<C-p>" : exists('*neosnippet#expandable_or_jumpable') && neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<S-TAB>"

" user definition snippet
let g:neosnippet#snippets_directory = '~/.vim/snippet_mine/'

" show second bottom line
set laststatus=2
