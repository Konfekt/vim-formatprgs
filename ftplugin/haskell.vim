augroup formatprgsHaskell
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

if !executable(get(b:, 'formatprg', '')) | let b:formatprg = '' | endif
if b:formatprg ==# 'ormolu' || empty(b:formatprg) && executable('ormolu')
  let &l:formatprg = 'ormolu ' . get(b:, 'formatprg_args', '') . ' --stdin-input-file ' . expand('%:S')
endif

let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '') .
      \ 'setlocal formatprg< | unlet! b:formatprg b:formatprg_args | silent! autocmd! formatprgsHaskell * <buffer>'
