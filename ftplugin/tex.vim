if !executable('tex-fmt') | finish | endif

if exists('##ShellFilterPost')
  augroup formatprgsTex
    autocmd! * <buffer>
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  augroup END
endif

let &l:formatprg = 'tex-fmt ' . get(b:, 'formatprg_args', '--print --quiet --stdin')

let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '') .
    \ 'setlocal formatprg< | unlet! b:formatprg_args | silent! autocmd! formatprgsTex * <buffer>'
