augroup formatprgsPython
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

" The full path of the current file, escaped for a :! command.
function! s:Path() abort
  return shellescape(expand('%:p'), 1)
endfunction

" Filter the whole buffer through {cmd}, keeping the view.
" While typing, leave automatic wrapping to Vim.
function! s:Filter(cmd) abort
  if mode() =~# '^[iR]'
    return 1
  endif
  let view = winsaveview()
  try
    silent execute '%!' . a:cmd
  finally
    call winrestview(view)
  endtry
  return 0
endfunction

if s:Use('ruff')
  let b:formatprg_cmd = 'ruff format ' . get(b:, 'formatprg_args', '--quiet --preview')
  function! s:RuffFormatexpr() abort
    return s:Filter(b:formatprg_cmd .
          \ (&textwidth > 0 ? ' --line-length=' . &textwidth : '') .
          \ (filereadable(expand('%')) ? ' --stdin-filename ' . s:Path() : '') .
          \ printf(' --range=%d-%d -', v:lnum, v:lnum + v:count - 1))
  endfunction
  setlocal formatexpr=<SID>RuffFormatexpr()
elseif s:Use('black-macchiato')
  let &l:formatprg = 'black-macchiato ' . get(b:, 'formatprg_args', '') . ' -'
elseif s:Use('yapf') || s:Use('yapf3')
  " yapf reads stdin without a file name; --quiet would suppress its output.
  let b:formatprg_cmd = (s:Use('yapf3') ? 'yapf3' : 'yapf') . ' ' . get(b:, 'formatprg_args', '')
  function! s:YapfFormatexpr() abort
    return s:Filter(b:formatprg_cmd . printf(' --lines %d-%d', v:lnum, v:lnum + v:count - 1))
  endfunction
  setlocal formatexpr=<SID>YapfFormatexpr()
elseif s:Use('autopep8')
  let b:formatprg_cmd = 'autopep8 ' . get(b:, 'formatprg_args', '--aggressive --experimental')
  function! s:Autopep8Formatexpr() abort
    return s:Filter(b:formatprg_cmd .
          \ (&textwidth > 0 ? ' --max-line-length ' . &textwidth : '') .
          \ printf(' --line-range %d %d -', v:lnum, v:lnum + v:count - 1))
  endfunction
  setlocal formatexpr=<SID>Autopep8Formatexpr()
endif

let b:undo_ftplugin = (empty(get(b:, 'undo_ftplugin', '')) ? '' : b:undo_ftplugin . ' | ') .
      \ 'setlocal formatprg< formatexpr< | unlet! b:formatprg_cmd | if &filetype !=# ''' . &filetype . ''' | unlet! b:formatprg b:formatprg_args | endif | execute ''silent! autocmd! formatprgsPython * <buffer>'''
