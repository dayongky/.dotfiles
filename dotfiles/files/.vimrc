" ======================================
"            Initialize
" ======================================
" vi improved only
set nocompatible
set encoding=utf-8


" ======================================
"         Interface
" ======================================
let mapleader=","

" One less key to hit for commands
nnoremap ; :

" Insert spaces when hitting TABs
set expandtab

" Turn help to escape, no accidental hit
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>


" ======================================
"             Appearance
" ======================================
" Enable 256 colors. Good for statusbar.
set t_Co=256

" Enable sytax highlighting
syntax on

" Show status even without a split
set laststatus=2

" Font selection
set guifont=courier_new

" Absolute line numbering
set number

" Underline current line
set cursorline

" Highlight matching brackets
set showmatch

" Highlight trailing whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/


" ======================================
"              Navigation
" ======================================
" Easier split nagivation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Quick vertical split, then switch to new split.
nnoremap <leader>w <C-w>v<C-w>l

" Unmap arrow keys, no crutch
" nnoremap <up> <nop>
" nnoremap <down> <nop>
" nnoremap <left> <nop>
" nnoremap <right> <nop>
" inoremap <up> <nop>
" inoremap <down> <nop>
" inoremap <left> <nop>
" inoremap <right> <nop>


" ======================================
"              Search
" ======================================
" Incremental searches, refined while typing
set incsearch

" Highlight search result
set hlsearch

" Clear the distracting search highlighting
nnoremap <leader><space> :noh<cr>

" Ignore these file types when searching
set wildignore+=*/tmp/*,*.so,*.swp,*.zip


" ======================================
"            Code Folding
" ======================================
" Initialize all folds
set foldlevel=99  " All open
"set foldlevel=0   " All closed

" space bar folds
nnoremap <space> za

" Fold highlights
"highlight Folded ctermfg=DarkBlue ctermbg=Black


" ======================================
"            File Operations
" ======================================
" Use unix line breaks
set fileformat=unix

" Undo enabled, even after closing (.un~)
set undofile


" ======================================
"           Functions
" ======================================
function! TrimWhiteSpace()
    %s/\s\+$//e
endfunction

" Fix following a symlink when opening a file (ctrlp issue)
" http://inlehmansterms.net/2014/09/04/sane-vim-working-directories/
" --------------------------------------------------------
" follow symlinked file
function! FollowSymlink()
  let current_file = expand('%:p')
  " check if file type is a symlink
  if getftype(current_file) == 'link'
    " if it is a symlink resolve to the actual file path
    "   and open the actual file
    let actual_file = resolve(current_file)
    silent! execute 'file ' . actual_file
  end
endfunction

" Set cwd to directory of npm, if npm project
" or working directory to git project root
" or directory of current file, if not git project
function! SetProjectRoot()

  " default to the current file's directory
  lcd %:p:h
  let current_dir = getcwd()

  " Look for npm on the system
  let npm_present = system("whereis npm | cut -d: -f2 | tr -d '\n'")
  if !empty(npm_present)
    let npm_dir = system("npm bin | sed 's/\\/node_modules\\/\.bin//g' | tr -d '[\n]'")
    let has_node_dir = system("ls | grep node_modules")

    " if cwd has node_modules, stay put
    if !empty(has_node_dir)
      return 0
    endif

    " if a place besides cwd has node_modules, go there
    if (npm_dir != current_dir)
      lcd `=npm_dir`
      return 0
    endif
  endif

  " See if the command output starts with 'fatal' (if it does, not in a git repo)
  let git_dir = system("git rev-parse --show-toplevel")
  let is_not_git_dir = matchstr(git_dir, '^fatal:.*')
  " if git project, change local directory to git project root
  if empty(is_not_git_dir)
    lcd `=git_dir`
  endif

endfunction

" follow symlink and set working directory
autocmd BufRead *
  \ call FollowSymlink()
  \ | call SetProjectRoot()

" F10: Show syntax highlighting group under cursor.
" http://vim.wikia.com/wiki/VimTip99
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>


" ======================================
"            Plugins
" ======================================
" Load vim-plug if not installed
" https://github.com/junegunn/vim-plug#post-update-hooks
if empty(glob("~/.vim/autoload/plug.vim"))
    execute '!curl --create-dirs -fLo ~/.vim/autoload/plug.vim https://raw.github.com/junegunn/vim-plug/master/plug.vim'
endif

filetype off                  " Disable filetype recognition
call plug#begin()

" ------------------------------
" Useful text editing commands
" ------------------------------
Plug 'tpope/vim-unimpaired'  " yo for paste mode
Plug 'tpope/vim-abolish'     " :S for smart substitution
Plug 'tpope/vim-surround'    " ysiw<div> surround in <div> tags
                             " ds{ delete surrounding {}
                             " cs( change surrounding to ()
Plug 'tpope/vim-commentary'  " gc to comment/uncomment lines
autocmd FileType cfg setlocal commentstring=#\ %s
autocmd FileType sls setlocal commentstring=#\ %s


" ------------------------------
" Code completion and generation
" ------------------------------
" TODO: look at vimcompleteme as an alternative
Plug 'ajh17/VimCompletesMe'

" YouCompleteMe code completion
"Plug 'Valloric/YouCompleteMe'  " LARGE download (~200MB)
" let g:ycm_autoclose_preview_window_after_completion=1

" supertab lets YCM and snippets not trip over each other.
" make YCM compatible with UltiSnips (using supertab)
" Plug 'ervandew/supertab'
" let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
" let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
" let g:SuperTabDefaultCompletionType = '<C-n>'

" Snippet engine and library
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
" better key bindings for UltiSnipsExpandTrigger
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"
" Where to find custom snippets, including custom ones
let g:UltiSnipsSnippetDirectories=["UltiSnips", "vimsnips"]

" Emmet
Plug 'mattn/emmet-vim'
let g:user_emmet_leader_key='<Tab>'
let g:user_emmet_settings = {
  \  'javascript.jsx' : {
    \      'extends' : 'jsx',
    \  },
  \}


" -------------
" Language tags
" -------------
" Universal CTags: code tag generation.
" Requires `autoreconf` or `dh-autoreconf` system package to be installed for compilation.
" https://askubuntu.com/questions/796408/installing-and-using-universal-ctags-instead-of-exuberant-ctags#836521
" https://stackoverflow.com/questions/25819649/how-to-exclude-multiple-directories-with-exuberant-ctags#25819720
Plug 'universal-ctags/ctags', {
                        \'dir': '~/.ctags',
                        \'do': './autogen.sh; ./configure --prefix=$HOME; make',
                        \}


" Autotag: automatically regenerate tags for a file when written.
Plug 'craigemery/vim-autotag'

" Tagbar: List of tags in current file, bird's eye view.
" Requires ctags for tag generation
Plug 'majutsushi/tagbar'
" TypeScript support for Tagbar.
" https://github.com/majutsushi/tagbar/wiki#exuberant-ctags-vanilla
let g:tagbar_type_typescript = {
  \ 'ctagstype': 'typescript',
  \ 'kinds': [
    \ 'c:classes',
    \ 'n:modules',
    \ 'f:functions',
    \ 'v:variables',
    \ 'v:varlambdas',
    \ 'm:members',
    \ 'i:interfaces',
    \ 'e:enums',
  \ ]
\ }

" Markdown support for Tagbar.
" https://github.com/majutsushi/tagbar/wiki#markdown
Plug 'jszakmeister/markdown2ctags'
let g:tagbar_type_markdown = {
    \ 'ctagstype': 'markdown',
    \ 'ctagsbin' : '~/.vim/plugged/markdown2ctags/markdown2ctags.py',
    \ 'ctagsargs' : '-f - --sort=yes',
    \ 'kinds' : [
        \ 's:sections',
        \ 'i:images'
    \ ],
    \ 'sro' : '|',
    \ 'kind2scope' : {
        \ 's' : 'section',
    \ },
    \ 'sort': 0,
\ }

" Tagbar hotkeys
nnoremap <C-y> :TagbarToggle<CR>
nmap <C-y> :TagbarToggle<CR>


" ----------
" Navigation
" ----------
" FZF: fuzzy file search
" PlugInstall and PlugUpdate will clone fzf in ~/.fzf and run install script
" https://github.com/junegunn/fzf/wiki/Examples-(vim)
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
" Use the correct file source, based on context
function! ContextualFZF()
    " Determine if inside a git repo
    silent exec "!git rev-parse --show-toplevel"
    redraw!

    if v:shell_error
        " Search in current directory
        call fzf#run({
          \'sink': 'e',
          \'down': '40%',
        \})
    else
        " Search in entire git repo
        call fzf#run({
          \'sink': 'e',
          \'down': '40%',
          \'source': 'git ls-tree --full-tree --name-only -r HEAD',
        \})
    endif
endfunction
map <C-p> :call ContextualFZF()<CR>

" Configure FZF to find ctags
" https://github.com/junegunn/fzf/wiki/Examples-(vim)#jump-to-tags
function! s:tags_sink(line)
  let parts = split(a:line, '\t\zs')
  let excmd = matchstr(parts[2:], '^.*\ze;"\t')
  execute 'silent e' parts[1][:-2]
  let [magic, &magic] = [&magic, 0]
  execute excmd
  let &magic = magic
endfunction
function! s:tags()
  if empty(tagfiles())
    echohl WarningMsg
    echom 'Preparing tags'
    echohl None
    call system('ctags -R --exclude=.git --exclude=node_modules --html-kinds=-ij')
  endif

  call fzf#run({
  \ 'source':  'cat '.join(map(tagfiles(), 'fnamemodify(v:val, ":S")')).
  \            '| grep -v -a ^!',
  \ 'options': '+m -d "\t" --with-nth 1,4.. -n 1 --tiebreak=index',
  \ 'down':    '40%',
  \ 'sink':    function('s:tags_sink')})
endfunction
command! Tags call s:tags()
nnoremap <C-t> :Tags<CR>
nmap <C-t> :Tags<CR>


" NerdTree: file system browser
Plug 'scrooloose/nerdtree'
map <C-n> :NERDTreeToggle<CR>


" ---------------
" Git integration
" ---------------
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'  " Shows git diff info in the gutter
set updatetime=1000  " Check for git diffs every X ms


" ----------------------
" Interface enhancements
" ----------------------
Plug 'Yggdroot/indentLine'


" -------------------------
" Syntax checking (linting)
" -------------------------

" ALE (async lint engine)
Plug 'w0rp/ale'
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_save = 1
let g:ale_lint_on_enter = 0

" Python
" https://blog.landscape.io/using-pylint-on-django-projects-with-pylint-django.html
let g:ale_python_pylint_options = '--load-plugins pylint_django'

" JavaScript
" let g:syntastic_javascript_checkers = ['eslint']
" Plug 'mtscout6/syntastic-local-eslint.vim' " Use local project's eslint.

" TypeScript
"Plug 'Shougo/vimproc.vim'  " tsuquyomi dep. Requires make.
"Plug 'Quramy/tsuquyomi'
"let g:tsuquyomi_disable_quickfix = 1
"let g:tsuquyomi_completion_detail = 0  " Makes completion slow.
"nnoremap <leader>d :TsuDefinition<CR>
"nmap <leader>d :TsuDefinition<CR>
"nnoremap <leader>b :TsuGoBack<CR>
"nmap <leader>b :TsuGoBack<CR>
"nnoremap <leader>r :TsuReferences<CR>
"nmap <leader>r :TsuReferences<CR>

"let g:syntastic_typescript_checkers = ['tsuquyomi'] " !tslint
" let g:syntastic_typescript_checkers = ['tslint'] " !tsuquyomi
" Ignore some HTML linting rules with angular
" TODO: conditionally apply this if an ng tag is present.
" let g:syntastic_html_tidy_ignore_errors=[' proprietary attribute ',
  " \ 'trimming empty <',
  " \ 'unescaped &',
  " \ 'lacks "action',
  " \ 'is not recognized!',
  " \ 'discarding unexpected',
  " \ ' lacks value',
  " \ ' is invalid']

" HTML
" let g:syntastic_html_tidy_exec = 'tidy'

" Autoformatting
Plug 'skywind3000/asyncrun.vim'
autocmd BufWritePost *.js AsyncRun -post=checktime ./node_modules/.bin/eslint --fix %


" --------------
" Python support
" --------------
Plug 'jmcantrell/vim-virtualenv' " Python virtualenv support
Plug 'tmhedberg/SimpylFold'  " Python specific code folding
let g:SimpylFold_docstring_preview = 0  " Don't fold docstrings and imports
let g:SimpylFold_fold_import = 0


" ---------------------
" Status bar
" ---------------------
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'edkolev/tmuxline.vim'
" Default theme
let g:airline_theme = 'term'
" Enable enhanced fonts with unicode
let g:airline_powerline_fonts = 1
" Enable tagbar integration
let g:airline#extensions#tagbar#enabled = 1
" Enable virtualenv integration
let g:airline#extensions#virtualenv#enabled = 1


" --------------------------------------
" Syntax definitions (for highlighting)
" --------------------------------------
Plug 'sheerun/vim-polyglot'
let g:polyglot_disabled = ['python']  " Handled by python-mode
let g:polyglot_disabled += ['html']  " Handled by python-mode
" Plug 'leafgarland/typescript-vim'  " Handled by vim-polyglot
" Plug 'lepture/vim-jinja'  " Handled by vim-polyglot
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
let g:jsx_ext_required = 1 " Only interpret *.jsx
Plug 'posva/vim-vue'
let g:vue_ext_required = 1 " Only interpret *.vue
Plug 'saltstack/salt-vim'

" Python syntax file (for highlighting).
" Also installs redundant features, which are disabled.
Plug 'python-mode/python-mode'
let g:pymode_python = 'python3'
let g:pymode_lint = 0  " ALE
let g:pymode_folding = 0  " SimplyFold
let g:pymode_run = 0
let g:pymode_breakpoint = 0
let g:pymode_options = 0
let g:pymode_doc = 0
let g:pymode_rope = 0
let g:pymode_debug = 0


" ---------------------
" Color scheme
" ---------------------
" colorscheme threshold  " Custom colorscheme file

" Oceanic Next
Plug 'mhartington/oceanic-next'
" for vim 8
if (has("termguicolors"))
  set termguicolors
endif

let g:oceanic_next_terminal_bold = 1
let g:oceanic_next_terminal_italic = 1
colorscheme OceanicNext

" Solarized 8
Plug 'lifepillar/vim-solarized8'
" set background=dark
" colorscheme solarized8_flat


call plug#end()
filetype plugin indent on     " Enable filetype recognition
