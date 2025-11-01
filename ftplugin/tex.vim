if !executable('tex-fmt') | finish | endif

if exists('##ShellFilterPost')
  augroup formatprgsTex
    autocmd! * <buffer>
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  augroup END
endif

setlocal formatprg=tex-fmt\ --print\ --quiet\ --stdin

let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '') .
    \ 'setlocal formatprg< | silent! autocmd! formatprgsTex * <buffer>'
