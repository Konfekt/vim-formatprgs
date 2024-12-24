augroup formatprgsSQL
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | execute 'echom "shell filter returned error " . v:shell_error . ", undoing changes"' | undo | endif
  endif
augroup END

if executable('sql-formatter')
  " npm install -g sql-formatter
  " set indent width in a JSON file passed by --config
  " https://github.com/sql-formatter-org/sql-formatter?tab=readme-ov-file#configuration-options
  setlocal formatprg=sql-formatter\ --language\ postgresql
" Ships with sqlparse
elseif executable('sqlformat')
  autocmd formatprgsSQL BufWinEnter <buffer> ++once let &l:formatprg='sqlformat --reindent_aligned --indent_width=' . &shiftwidth . ' -'
" From https://github.com/balling-dev/sleek/releases/
elseif executable('sleek')
  autocmd formatprgsSQL BufWinEnter <buffer> ++once let &l:formatprg='sleek --indent-spaces=' . &shiftwidth . ' -'
endif
