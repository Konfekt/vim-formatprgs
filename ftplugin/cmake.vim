augroup formatprgsCMake
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

if executable('cmake-format')
  autocmd BufWinEnter <buffer> ++once
        \ let &l:formatprg='cmake-format'
        \ . (&textwidth > 0 ? ' --line-width=' . &textwidth : '')
        \ . ' --tab-size=' . shiftwidth()
        \ . (&expandtab ? '' : ' --use-tabchars')
        \ . ' -'
elseif executable('neocmakelsp')
  setlocal formatprg=neocmakelsp\ format
else
  " No formatter available; ensure we don't inherit a stale formatprg
  setlocal formatprg=
endif

" Ensure settings are undone cleanly if filetype changes
let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '')
      \ . 'setlocal formatprg<'
      \ . ' | silent! autocmd! formatprgsCMake * <buffer>'
