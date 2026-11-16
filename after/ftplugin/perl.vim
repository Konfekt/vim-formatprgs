augroup formatprgsPerl
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

" Whether to use formatter {name}: the one chosen by b:formatprg if that is
" executable, otherwise any {name} found on $PATH.
function! s:Use(name) abort
  let choice = get(b:, 'formatprg', '')
  return !empty(choice) && executable(choice) ? choice ==# a:name : executable(a:name)
endfunction

if s:Use('perltidy')
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

  execute 'autocmd formatprgsPerl BufWinEnter <buffer> ++once ' .
        \ 'let &l:formatprg = <SID>PerltidyCmd()'
endif

if exists('#formatprgsPerl#BufWinEnter#<buffer>') && bufwinnr(bufnr('%')) != -1
  doautocmd <nomodeline> formatprgsPerl BufWinEnter <buffer>
endif

let b:undo_ftplugin = (empty(get(b:, 'undo_ftplugin', '')) ? '' : b:undo_ftplugin . ' | ') .
      \ 'setlocal formatprg< | unlet! b:formatprg b:formatprg_args | execute ''silent! autocmd! formatprgsPerl * <buffer>'''
