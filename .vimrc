" ---------------------------------------------------------------------------
" General
" ---------------------------------------------------------------------------

if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
    set fileencodings=utf-8,latin1
endif


set nocompatible 	" essential
set history=1000 	" lotfs of command line history
set cf 			" error files / jumping
set ffs=unix,dos,mac 	" support these files
set viminfo='1000,f1,:100,@100,/20
set modeline 		" make sure modeline support is enabled

syntax on
filetype plugin indent on

set background=dark

" Only do this part when compiled with support for autocommands
if has("autocmd")
  augroup fedora
  autocmd!
  " In text files, always limit the width of text to 78 characters
  " autocmd BufRead *.txt set tw=78
  " When editing a file, always jump to the last cursor position
  autocmd BufReadPost *
  \ if line("'\"") > 0 && line ("'\"") <= line("$") |
  \   exe "normal! g'\"" |
  \ endif
  " don't write swapfile on most commonly used directories for NFS mounts or USB sticks
  autocmd BufNewFile,BufReadPre /media/*,/mnt/* set directory=~/tmp,/var/tmp,/tmp
  " start with spec file template
  autocmd BufNewFile *.spec 0r /usr/share/vim/vimfiles/template.spec
  augroup END
endif


" ---------------------------------------------------------------------------
" Highlight Trailing Whitespace
" ---------------------------------------------------------------------------
set list listchars=trail:.,tab:>.
highlight SpecialKey ctermfg=DarkGrey ctermbg=Black

" ----------------------------------------------------------------------------
"  Backups
" ----------------------------------------------------------------------------

"set nobackup                           " do not keep backups after close
"set nowritebackup                      " do not keep a backup while working
"set noswapfile                         " don't keep swp files either
set backupdir=$HOME/.vim/backup        " store backups under ~/.vim/backup
set backupcopy=yes                     " keep attributes of original file
"set backupskip=/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*
set directory=$HOME/.vim/swap,.      " keep swp files under ~/.vim/swap

" ---------------------------------------------------------------------------
" UI
" ---------------------------------------------------------------------------
set ruler               " show the cursor position all the time
set nolazyredraw        " turn off lazy redraw
"set number              " line numbers
set backspace=2         " allow backspacing over everything in insert mode
set nostartofline       " don't jump to the start of line when scrolling

" ---------------------------------------------------------------------------
" Visual Cues
" ---------------------------------------------------------------------------

set showmatch           " brackets/braces that is
set mat=5               " duration to show matching brace (1/10 sec)
set ignorecase          " ignore case when searching
set nohlsearch          " don't highlight searches
set visualbell          " shut the fuck up

" ---------------------------------------------------------------------------
" Text Formatting
" ---------------------------------------------------------------------------
set autoindent          " automatic indent new lines
set smartindent         " be smart about it
set nowrap              " do not wrap lines
set softtabstop=4
set shiftwidth=4
set tabstop=4
set expandtab           " expand tabs to spaces
set nosmarttab          " fuck tabs
set textwidth=80        " wrap at 80 chars by default

" ---------------------------------------------------------------------------
" Mappings
" ---------------------------------------------------------------------------

" Toggle line numbers and fold column for easy copying:
nnoremap <F2> :set nonumber!<CR>:set foldcolumn=0<CR>

" Toggle line wrap
nnoremap <F3> :set nowrap!<CR>

" Execute file being edited with <Shift> + e:
map <buffer> <S-e> :w<CR>:!/usr/local/bin/python2.7 % <CR>

" ---------------------------------------------------------------------------
" Stuff
" ---------------------------------------------------------------------------
" Don't wake up system with blinking cursor:
" http://www.linuxpowertop.org/known.php
let &guicursor = &guicursor . ",a:blinkon0"
