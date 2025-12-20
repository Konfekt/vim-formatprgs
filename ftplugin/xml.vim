augroup formatprgsXML
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

if !executable(get(b:, 'formatprg', '')) | let b:formatprg = '' | endif
if b:formatprg ==# 'xmllint' || empty(b:formatprg) && executable('xmllint')
  autocmd BufWinEnter <buffer> ++once let &l:formatprg = (has('win32')
        \ ? 'cmd /c "set XMLLINT_INDENT=' . shiftwidth() . '&&' : 'XMLLINT_INDENT=' . shiftwidth()) .
        \ ' xmllint --output - ' . get(b:, 'formatprg_args', '--format --recover --encode UTF-8 --nonet') .
        \ (has('win32') ? '"' : '')
elseif b:formatprg ==# 'tidy' || empty(b:formatprg) && executable('tidy')
  " See https://stackoverflow.com/questions/7151180/use-html-tidy-to-just-indent-html-code
  autocmd BufWinEnter <buffer> ++once let &l:formatprg = 'tidy -xml ' .
        \ get(b:, 'formatprg_args', '--quiet --show-errors 0 -bare --show-body-only auto -wrap 0 -utf8') . ' ' .
        \ '-indent ' . (&expandtab ? '' : '--indent-with-tabs ') . '--indent-spaces ' . shiftwidth()
        " \ (has('win32') ? ' 2>nul' : ' 2>/dev/null') .
  compiler tidy
elseif b:formatprg ==# 'prettier' || empty(b:formatprg) && executable('prettier')
  let b:prettier_config = isdirectory(expand('%:p')) ? trim(system('prettier --find-config-path ' .expand('%:p:S'))) : ''
  if v:shell_error | let b:prettier_config = '' | endif
  let b:formatprg_cmd = 'prettier ' .
        \ get(b:, 'formatprg_args', '--log-level=error --no-color --no-error-on-unmatched-pattern --parser=' . &filetype) . ' '
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
        \ printf(' --range-start %d --range-end %d', start_byte, end_byte)
        \ . ' --stdin-filepath=' . expand('%:p:S')
    let view  = winsaveview()
    try
      silent exe '%!' cmd
    finally
      call winrestview(view)
    endtry
  endfunction
  setlocal formatexpr=<SID>PrettierFormatexpr()
endif

let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '') .
      \ 'setlocal formatprg< formatexpr< | silent! autocmd! formatprgsXML * <buffer> | unlet! b:formatprg b:formatprg_cmd b:formatprg_args b:prettier_config'
