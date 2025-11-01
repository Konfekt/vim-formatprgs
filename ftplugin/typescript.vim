if &filetype !=# 'typescript' | finish | endif

augroup formatprgsTypeScript
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

if executable('prettier')
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
elseif executable('clang-format')
  function! s:ClangFormatexpr() abort
    let start = v:lnum
    let end   = v:lnum + v:count - 1
    let cmd = 'clang-format --style=file --fallback-style=Google ' .
          \ '--assume-filename=' . (filereadable(expand('%')) ? expand('%:p:S') : 'stdin.c') .
          \  printf(' --lines=%d-%d -', start, end)
    exe start ',' end '!' cmd
  endfunction
  setlocal formatexpr=<SID>ClangFormatexpr()
elseif executable('biome')
    autocmd BufWinEnter <buffer> ++once let &formatprg = 'biome format ' .
          \ '--stdin-file-path=' . expand('%:p:S') .
          \ (&textwidth > 0 ? '--line-width=' . &textwidth . ' ' : '') .
          \ '--indent-width=' . shiftwidth() . ' ' .
          \ '--indent-style=' . (&expandtab ? 'space' : 'tab') .
endif

let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '') .
      \ 'setlocal formatprg< formatexpr<| unlet! b:formatprg_prettier | silent! autocmd! formatprgsTypeScript * <buffer>'
