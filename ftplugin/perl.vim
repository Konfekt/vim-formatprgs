augroup formatprgsPerl
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

if !executable(get(b:, 'formatprg', '')) | let b:formatprg = '' | endif

if b:formatprg ==# 'perltidy' || empty(b:formatprg) && executable('perltidy')
  function! s:PerltidyBuildCmd() abort
    " Detect and prefer a project style file near the current buffer.
    if !exists('b:cfg')
      let b:cfg = findfile('.perltidyrc', '.;')
      if empty(b:cfg) | let b:cfg = findfile('perltidyrc', '.;') | endif
    endif

    let tw = (&textwidth > 0 ? &textwidth : 0)
    let sw = shiftwidth()

    " Base editor-safe flags.
    let args = get(b:, 'formatprg_args', '-q')
    let args .= ' -st'

    " Fallback style derived from Vim options.
    let args .= ' -l=' . tw
    let args .= ' -i=' . sw

    " Optional tab policy aligned with Vim options.
    let args .= ' -dt=' . &tabstop
    if !&expandtab
      let args .= ' -et=' . &tabstop
    endif

    " Project style overrides fallback style by appearing last.
    if !empty(b:cfg) | let args .= ' -pro=' . shellescape(b:cfg) | endif

    return 'perltidy ' . args
  endfunction

  autocmd formatprgsPerl BufWinEnter <buffer> ++once let &formatprg = <SID>PerltidyBuildCmd()
else
  finish
endif

let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '') .
      \ 'setlocal formatprg< formatexpr< | unlet! b:formatprg b:formatprg_args b:cfg | silent! autocmd! formatprgsPerl * <buffer>'
