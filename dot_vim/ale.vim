let g:ale_completion_enabled = 1
let g:ale_completion_autoimport = 1

set completeopt=menu,menuone,noinsert,noselect
set omnifunc=ale#completion#OmniFunc

let g:ale_fix_on_save = 1

let g:ale_linters = {
\   'python': ['ruff', 'pyright'],
\   'javascript': ['eslint', 'tsserver'],
\   'typescript': ['eslint', 'tsserver'],
\   'c': ['clangd'],
\   'cpp': ['clangd'],
\   'rust': ['rust-analyzer'],
\}

let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'python': ['ruff_format'],
\   'javascript': ['prettier'],
\   'typescript': ['prettier'],
\   'rust': ['rustfmt'],
\}

nnoremap gd :ALEGoToDefinition<CR>
nnoremap gr :ALEFindReferences<CR>
nnoremap K  :ALEHover<CR>
