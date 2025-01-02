if !has('vim9script')
  runtime! ftplugin/json_legacy.vim
  finish
endif

vim9script
runtime! ftplugin/json_legacy.vim

if !exists('b:jq')
  import autoload 'dist/json.vim'
  setlocal formatexpr=json.FormatExpr()
endif
