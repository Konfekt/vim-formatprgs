augroup formatprgsCMake
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

if s:Use('cmake-format')
  execute 'autocmd formatprgsCMake BufWinEnter <buffer> ++once ' .
        \ "let &l:formatprg = 'cmake-format '" .
        \ " . get(b:, 'formatprg_args', '') . ' '" .
        \ " . (&textwidth > 0 ? ' --line-width=' . &textwidth : '')" .
        \ " . ' --tab-size=' . shiftwidth()" .
        \ " . (&expandtab ? '' : ' --use-tabchars')" .
        \ " . ' -'"
elseif s:Use('neocmakelsp')
  let &l:formatprg = 'neocmakelsp format ' . get(b:, 'formatprg_args', '')
else
  " No formatter available; ensure we don't inherit a stale formatprg
  setlocal formatprg=
endif

if exists('#formatprgsCMake#BufWinEnter#<buffer>') && bufwinnr(bufnr('%')) != -1
  doautocmd <nomodeline> formatprgsCMake BufWinEnter <buffer>
endif

let b:undo_ftplugin = (empty(get(b:, 'undo_ftplugin', '')) ? '' : b:undo_ftplugin . ' | ') .
      \ 'setlocal formatprg< | unlet! b:formatprg b:formatprg_args | execute ''silent! autocmd! formatprgsCMake * <buffer>'''
