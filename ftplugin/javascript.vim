if &filetype !=# 'javascript' | finish | endif

augroup formatprgsJavaScript
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

if !executable(get(b:, 'formatprg', '')) | let b:formatprg = '' | endif
if b:formatprg ==# 'prettier' || empty(b:formatprg) && executable('prettier')
  let b:prettier_config = isdirectory(expand('%:p')) ? trim(system('prettier --find-config-path ' .expand('%:p:S'))) : ''
  if v:shell_error | let b:prettier_config = '' | endif
  let b:formatprg_cmd = 'prettier --log-level=error --no-color --no-error-on-unmatched-pattern --single-quote --parser=babel'
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
      exe '%!' cmd
    finally
      call winrestview(view)
    endtry
  endfunction
  setlocal formatexpr=<SID>PrettierFormatexpr()
elseif b:formatprg ==# 'biome' || empty(b:formatprg) && executable('biome')
  let b:formatprg_cmd = 'biome format'
  autocmd BufWinEnter <buffer> ++once let &l:formatprg = b:formatprg_cmd . ' ' .
        \ get(b:, 'formatprg_args', '--write --format-with-errors=true --colors=off') . ' ' .
        \ '--stdin-file-path=' . expand('%:p:S') . ' ' .
        \ (&textwidth > 0 ? '--line-width=' . &textwidth . ' ' : '') .
        \ '--indent-width=' . shiftwidth() . ' ' .
        \ '--indent-style=' . (&expandtab ? 'space' : 'tab')
elseif b:formatprg ==# 'clang-format' || empty(b:formatprg) && executable('clang-format')
  function! s:ClangFormatexpr() abort
    let start = v:lnum
    let end   = v:lnum + v:count - 1
    " Detect and prefer a project style file near the current buffer.
    if !exists('b:cfg')
      let b:cfg = findfile('.clang-format', '.;')
      if empty(b:cfg) | let b:cfg = findfile('_clang-format', '.;') | endif
    endif
    if !empty(b:cfg)
      let default_style = '--style=file --fallback-style=Chromium'
    else
      let default_style =
            \ printf('--style="{BasedOnStyle: Chromium, ColumnLimit: %d, IndentWidth: %d, TabWidth: %d, UseTab: %s}"',
            \        &textwidth, shiftwidth(), &tabstop, (&expandtab ? 'Never' : 'ForIndentation'))
    endif

    let cmd = 'clang-format ' .
          \ get(b:, 'formatprg_args', default_style) . ' ' .
          \ '--assume-filename=' . shellescape(filereadable(expand('%'))
          \     ? expand('%:p') : 'stdin.js') . ' ' .
          \ printf('--lines=%d:%d -', start, end)
    let view  = winsaveview()
    try
      " exe start ',' end '!' cmd
      silent exe '%!' cmd
    finally
      call winrestview(view)
    endtry
  endfunction
  setlocal formatexpr=<SID>ClangFormatexpr()
endif

let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '') .
      \ 'setlocal formatprg< formatexpr< | unlet! b:formatprg_prettier | silent! autocmd! formatprgsJavaScript * <buffer>'
