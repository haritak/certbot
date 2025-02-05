
" https://github.com/junegunn/vim-plug
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim



call plug#begin()
"https://github.com/tpope/vim-sensible
"[...]
"See the source for the authoritative list of features. (Don't worry, it's mostly :set calls.) Here's a taste:
" 'backspace': Backspace through anything in insert mode.
" 'incsearch': Start searching before pressing enter.
" 'listchars': Makes :set list (visible whitespace) prettier.
" 'scrolloff': Always show at least one line above/below the cursor.
" 'autoread': Autoload file changes. You can undo by pressing u.
"  runtime! macros/matchit.vim: Load the version of matchit.vim that ships with Vim.
"  [...]
Plug 'tpope/vim-sensible'

" https://github.com/neoclide/coc.nvim
" [...]
" Make your Vim/Neovim as smart as VSCode.
" Why?
" rocket Fast: separated NodeJS process that does not block your vim most of the time.
" gem Reliable: typed language, tested with CI.
" star2 Featured: all LSP 3.16 features are supported, see :h coc-lsp.
" heart Flexible: configured like VSCode, extensions work like in VSCode
" [...]
" https://github.com/neoclide/coc.nvim
" (CoC -> Conquer of Completion)
"
" Ruby : https://jamesnewton.com/blog/setting-up-coc-nvim-for-ruby-development [TODO]
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" github.com/tpope/vim-surround
" [...]
" Surround.vim is all about surroundings: 
" parentheses, brackets, quotes, XML tags, and more. The plugin provides mappings to easily delete, change and add such surroundings in pairs.
" Change Surrounding (cs) From - To example cs'<q> to change single quotes to
" double quotes
" Delete Surroundings (ds)
" With visual mode : select and press S<example tag=123> to place selection
" inside <example tag=123>
"
Plug 'tpope/vim-surround'


" not maintained any more ? :  Plug 'scrooloose/nerdtree'
" https://github.com/preservim/nerdtree
" The NERDTree is a file system explorer for the Vim editor. Using this plugin, 
" users can visually browse complex directory hierarchies,
" quickly open files for reading or editing, and perform basic file system operations.
Plug 'preservim/nerdtree'

" https://github.com/vim-airline/vim-airline
" [...]
" Lean & mean status/tabline for vim that's light as air.
" [...]
Plug 'bling/vim-airline'

" [...]
" This is a massive (in a good way) Vim plugin for editing Ruby on Rails applications.
" gf considers context and knows about partials, fixtures, and much more
" :A (alternate) and :R (related) for easy jumping between files
" :Emodel, :Eview, :Econtroller, are provided to :edit
" S, V, and T variants for :split, :vsplit, and :tabedit
Plug 'https://github.com/tpope/vim-rails'

" [...]
" This plugin aims to mimic tmux's display-pane feature, which enables you to
" choose a window interactively.
"
" This plugin should be especially useful when working on high resolution
" displays since with wide displays you are likely to open multiple windows
" and moving around windows with vim is cumbersome.
"
" This plugin simplifies window navigation with the following functionality:
"
"     Displays window label on statusline or middle of each window (overlay).
"         Accepts window selection from user.
"             Navigates to the specified window.
"
Plug 'https://github.com/t9md/vim-choosewin'

Plug 'jlanzarotta/bufexplorer'
Plug 'vim-ruby/vim-ruby'

" Configure tab labels within Terminal Vim with a very succinct output.
" (προσθέτει νούμερα στα tabs για να είναι ευκολώτερη η πρόσβασή τους)
"
" Reminder: {number}gt σε πηγαίνει στο tab νούμερο {number}
Plug 'https://github.com/mkitt/tabline.vim'
call plug#end()

syntax on
set hlsearch
set nowrap
"colorscheme darkblue
map \n :NERDTree<CR>
set guifont=Hack\ 14
set nocompatible
filetype indent on
set tabstop=2
set expandtab
set shiftwidth=2

map <leader>- :colorscheme darkblue<CR>
map <leader>= :colorscheme default<CR>
map <leader>e :Explore<CR>
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
nnoremap <leader>f :NERDTreeFind<CR>

nmap - <Plug>(choosewin)

