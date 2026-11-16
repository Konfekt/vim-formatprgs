augroup formatprgsRuby
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

if s:Use('rubocop')
  " The file name after --stdin is not needed for formatting.
  let &l:formatprg = 'rubocop -x --stdin _ ' .
        \ get(b:, 'formatprg_args', '') .
        \ ' --stderr 2>' . (has('win32') ? 'NUL' : '/dev/null')
endif

let b:undo_ftplugin = (empty(get(b:, 'undo_ftplugin', '')) ? '' : b:undo_ftplugin . ' | ') .
      \ 'setlocal formatprg< | unlet! b:formatprg b:formatprg_args | execute ''silent! autocmd! formatprgsRuby * <buffer>'''
