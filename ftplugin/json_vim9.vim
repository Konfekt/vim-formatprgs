if v:version < 901 | finish | endif
vim9script

# Only set a JSON formatter when no external formatter is configured.
if empty(get(g:, 'json_formatprg', ''))
  import autoload 'dist/json.vim'
  setlocal formatexpr=json.FormatExpr()
  b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin .. ' | ' : '') .. 'setlocal formatexpr<'
endif
