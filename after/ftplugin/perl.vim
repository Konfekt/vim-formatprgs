call formatprgs#init('formatprgsPerl')

if formatprgs#use('perltidy')
  function! s:PerltidyCmd() abort
    " Detect and prefer a project style file near the current buffer.
    let cfg = findfile('.perltidyrc', '.;')
    if empty(cfg) | let cfg = findfile('perltidyrc', '.;') | endif

    " Base editor-safe flags, then a style derived from Vim's options.
    let args = get(b:, 'formatprg_args', '-q') . ' -st'
    let args .= ' -l=' . (&textwidth > 0 ? &textwidth : 0)
    let args .= ' -i=' . shiftwidth()
    let args .= ' -dt=' . &tabstop
    if !&expandtab
      let args .= ' -et=' . &tabstop
    endif
    if !empty(cfg) | let args .= ' -pro=' . shellescape(cfg) | endif
    return 'perltidy ' . args
  endfunction

  call formatprgs#on_bufwinenter('formatprgsPerl', 'let &l:formatprg = ' . expand('<SID>') . 'PerltidyCmd()')
endif

call formatprgs#undo('formatprgsPerl', 'setlocal formatprg< | unlet! b:formatprg b:formatprg_args')
