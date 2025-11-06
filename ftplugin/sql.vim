augroup formatprgsSQL
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

if !executable(get(b:, 'formatprg', '')) | let b:formatprg = '' | endif
if b:formatprg ==# 'sql-formatter' || empty(b:formatprg) && executable('sql-formatter')
  " npm install -g sql-formatter
  " set indent width in a JSON file passed by --config
  " https://github.com/sql-formatter-org/sql-formatter?tab=readme-ov-file#configuration-options
  let &l:formatprg='sql-formatter --language postgresql'
" Ships with sqlparse
elseif b:formatprg ==# 'sqlformat' || empty(b:formatprg) && executable('sqlformat')
  autocmd BufWinEnter <buffer> ++once let &l:formatprg='sqlformat --reindent_aligned --indent_width=' . shiftwidth() . ' -'
" From https://github.com/balling-dev/sleek/releases/
elseif b:formatprg ==# 'sleek' || empty(b:formatprg) && executable('sleek')
  autocmd BufWinEnter <buffer> ++once let &l:formatprg='sleek --indent-spaces=' . shiftwidth() . ' -'
endif

let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '') .
    \ 'setlocal formatprg< | silent! autocmd! formatprgsSQL * <buffer>'
