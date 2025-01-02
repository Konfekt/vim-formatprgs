if !has('vim9script') | finish | endif
vim9script

if empty(g:json_formatprg)
  import autoload 'dist/json.vim'
  setlocal formatexpr=json.FormatExpr()
endif
