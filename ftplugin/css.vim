if !executable('prettier') | finish | endif

augroup formatprgsCss
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
  let b:prettier_config = isdirectory(expand('%:p')) ? trim(system('prettier --find-config-path ' . expand('%:p:S'))) : ''
  if v:shell_error | let b:prettier_config = '' | endif
  function! s:PrettierFormatexpr() abort
    let start = v:lnum
    let end   = v:lnum + v:count - 1
    let cmd = 'prettier --single-quote --parser=' . &filetype . ' ' .
        \ (filereadable(b:prettier_config) ? '--config ' . shellescape(b:prettier_config) . ' ' : '') .
        \ '--stdin-filepath=%:S ' .
        \ (&textwidth > 0 ? '--print-width=' . &textwidth . ' ' : '') .
        \ '--tab-width=' . shiftwidth() . ' ' .
        \ (&expandtab ? '' : '--use-tabs ') .
          \  printf(' --range-start %d --range-end %d -', start, end)
    exe start ',' end '!' cmd
  endfunction
  setlocal formatexpr=<SID>PrettierFormatexpr()
augroup END

let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '') . 'setlocal formatprg< | unlet! b:prettier_config | silent! autocmd! formatprgsCss * <buffer>'
