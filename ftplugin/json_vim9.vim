if !has('vim9script') | finish | endif
vim9script

if !exists('b:found_jq')
  import autoload 'dist/json.vim'
  setlocal formatexpr=json.FormatExpr()
endif
