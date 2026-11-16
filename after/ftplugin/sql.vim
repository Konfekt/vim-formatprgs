augroup formatprgsSQL
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

" Whether to use formatter {name}: the one chosen by b:formatprg if that is
" executable, otherwise any {name} found on $PATH.
function! s:Use(name) abort
  let choice = get(b:, 'formatprg', '')
  return !empty(choice) && executable(choice) ? choice ==# a:name : executable(a:name)
endfunction

if s:Use('sql-formatter')
  " npm install -g sql-formatter
  " set indent width in a JSON file passed by --config
  " https://github.com/sql-formatter-org/sql-formatter?tab=readme-ov-file#configuration-options
  let &l:formatprg = 'sql-formatter ' . get(b:, 'formatprg_args', '--language postgresql')
elseif s:Use('sqlformat')
  " Ships with sqlparse
  execute 'autocmd formatprgsSQL BufWinEnter <buffer> ++once ' .
        \ "let &l:formatprg = 'sqlformat ' . get(b:, 'formatprg_args', '--reindent_aligned') . ' --indent_width=' . shiftwidth() . ' -'"
elseif s:Use('sleek')
  " From https://github.com/balling-dev/sleek/releases/
  execute 'autocmd formatprgsSQL BufWinEnter <buffer> ++once ' .
        \ "let &l:formatprg = 'sleek ' . get(b:, 'formatprg_args', '') . ' --indent-spaces=' . shiftwidth() . ' -'"
endif

if exists('#formatprgsSQL#BufWinEnter#<buffer>') && bufwinnr(bufnr('%')) != -1
  doautocmd <nomodeline> formatprgsSQL BufWinEnter <buffer>
endif

let b:undo_ftplugin = (empty(get(b:, 'undo_ftplugin', '')) ? '' : b:undo_ftplugin . ' | ') .
      \ 'setlocal formatprg< | unlet! b:formatprg b:formatprg_args | execute ''silent! autocmd! formatprgsSQL * <buffer>'''
