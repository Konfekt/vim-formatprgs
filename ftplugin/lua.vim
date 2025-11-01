augroup formatprgsLua
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

if executable('stylua')
  let s:cmd = 'stylua '
  function! s:StyluaFormatexpr() abort
    let start = v:lnum
    let end   = v:lnum + v:count - 1
    let cmd = s:cmd .
        \ ( &textwidth > 0 ? ' --column-width ' . &textwidth : '' ) .
        \ ' --indent-type ' . ( &expandtab ? 'Spaces' : 'Tabs' ) .
        \ ' --indent-width ' . shiftwidth() .
        \ ' --stdin-filepath=%:S' .
        \  printf(' --range-start %d --range-end %d -', start, end)
    exe start ',' end '!' cmd
  endfunction

  setlocal formatexpr=<SID>StyluaFormatexpr()
elseif executable('prettier')
  let b:prettier_config = isdirectory(expand('%:p')) ? trim(system('prettier --find-config-path ' .expand('%:p:S'))) : ''
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
endif

let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '') . 'setlocal formatprg< | unlet! b:formatprg_prettier | silent! autocmd! formatprgsLua * <buffer>'
