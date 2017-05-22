" .vimrc modified by mine.
" Delete some options from the sample,
" and add some packages.

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
colorscheme molokai		" color scheme
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

""
"" Vim-LaTeX
""
"filetype plugin on		" change plugin as filetype
"filetype indent on		" change indent as filetype
"set shellbash			" change division of path from \ to /
"set grepprg=grep\ -nH\ *	" searching command
"let g:tex_flavor='latex'	" g ... global
"let g:Imap_UsePlaceHolders = 1
"let g:Imap_DeleteEmptyPlaceHolders = 1
"let g:Imap_StickyPlaceHolders = 0
"let g:Tex_DefaultTargetFormat = 'pdf'
"let g:Tex_MultipleCompileFormats = 'dvi,pdf'

"let g:Tex_FormatDependency_pdf = 'dvi,pdf'

"let g:Tex_FormatDependency_ps = 'dvi,ps'
"let g:Tex_CompoleRule_pdf = 'ptex2pdf -u -l -ot "-kanji=utf8 -no-guess-input-enc -synctex=1 -interaction=nonstopmode -file-line-error-style" $*'

"let g:Tex_CompileRule_ps = 'dvips -Posf -o $*.ps $*.dvi'
"let g:Tex_CompileRule_dvi = 'uplatex -kanji=utf8 -no-guess-input-enc -synctex=1 -interaction=nonstopmode -file-line-error-style $*'
"let g:BibtexFlavor = 'pbibtex %'
"let g:Tex_MakeIndexFlavor = 'upmendex $*.idx'
"let g:Tex_ViewRule_pdf = 'rundll32 shell32,ShellExec_RunDLL SumatraPDF -reuse-instance -inverse-search "\" ' . $VIM . '\gvim.exe\" -n -c \":RemoteOpen +\%l \%f_""'
"let g:Tex_AutoFolding = 0
