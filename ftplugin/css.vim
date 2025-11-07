augroup formatprgsCss
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

if !executable(get(b:, 'formatprg', '')) | let b:formatprg = '' | endif
if b:formatprg ==# 'prettier' || empty(b:formatprg) && executable('prettier')
  let b:prettier_config = isdirectory(expand('%:p')) ? trim(system('prettier --find-config-path ' . expand('%:p:S'))) : ''
  if v:shell_error | let b:prettier_config = '' | endif
  let b:formatprg_cmd = 'prettier ' . get(b:, 'formatprg_args', '--log-level=error --no-color --no-error-on-unmatched-pattern --single-quote --parser=' . &filetype)
  function! s:PrettierFormatexpr() abort
    let start = v:lnum
    let end   = v:lnum + v:count - 1
    let start_byte = line2byte(start)
    let end_byte   = line2byte(end + 1) - 1
    let cmd = b:formatprg_cmd . ' ' .
        \ (filereadable(b:prettier_config) ? '--config ' . shellescape(b:prettier_config) . ' ' : '') .
        \ (&textwidth > 0 ? '--print-width=' . &textwidth . ' ' : '') .
        \ '--tab-width=' . shiftwidth() . ' ' .
        \ (&expandtab ? '' : '--use-tabs ') .
        \  printf(' --range-start %d --range-end %d', start_byte, end_byte)
        \ . ' --stdin-filepath=' . expand('%:p:S')
    let view  = winsaveview()
    try
      " exe start ',' end '!' cmd
      silent exe '%!' cmd
    finally
      call winrestview(view)
    endtry
  endfunction
  setlocal formatexpr=<SID>PrettierFormatexpr()
elseif b:formatprg ==# 'biome' || empty(b:formatprg) && executable('biome')
  let b:formatprg_cmd = 'biome format ' . get(b:, 'formatprg_args', '--write --format-with-errors=true --colors=off') . ' '
  autocmd BufWinEnter <buffer> ++once let &l:formatprg = b:formatprg_cmd . ' ' .
        \ '--stdin-file-path=' . expand('%:p:S') . ' ' .
        \ (&textwidth > 0 ? '--line-width=' . &textwidth . ' ' : '') .
        \ '--indent-width=' . shiftwidth() . ' ' .
        \ '--indent-style=' . (&expandtab ? 'space' : 'tab')
endif

let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '') .
      \ 'setlocal formatprg< formatexpr< | unlet! b:formatprg b:formatprg_cmd b:formatprg_args b:prettier_config | silent! autocmd! formatprgsCss * <buffer>'
