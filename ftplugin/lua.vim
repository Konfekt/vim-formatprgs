augroup formatprgsLua
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

if executable('stylua')
  function! s:StyluaFormatexpr() abort
    let start = v:lnum
    let end   = v:lnum + v:count - 1
    let start_byte = line2byte(start)
    let end_byte   = line2byte(end + 1) - 1
    let cmd = 'stylua ' .
        \ ( &textwidth > 0 ? ' --column-width ' . &textwidth : '' ) .
        \ ' --indent-type ' . ( &expandtab ? 'Spaces' : 'Tabs' ) .
        \ ' --indent-width ' . shiftwidth() .
        \ ' --stdin-filepath=' . expand('%:p:S') . '' .
        \  printf(' --range-start %d --range-end %d -', start_byte, end_byte)
    let view  = winsaveview()
    try
      " exe start ',' end '!' cmd
      silent exe '%!' cmd
    finally
      call winrestview(view)
    endtry
  endfunction

  setlocal formatexpr=<SID>StyluaFormatexpr()
endif

let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '') . 'setlocal formatprg< | unlet! b:formatprg_prettier | silent! autocmd! formatprgsLua * <buffer>'
