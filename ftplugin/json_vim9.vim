if !has('vim9script') | finish | endif
vim9script

if v:version < 901 | finish | endif

if empty(g:json_formatprg)
  import autoload 'dist/json.vim'
  setlocal formatexpr=json.FormatExpr()
endif
