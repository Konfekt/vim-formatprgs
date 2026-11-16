call formatprgs#init('formatprgsPython')

if formatprgs#use('ruff')
  let b:formatprg_cmd = 'ruff format ' . get(b:, 'formatprg_args', '--quiet --preview')
  function! s:RuffFormatexpr() abort
    return formatprgs#filter(b:formatprg_cmd .
          \ (&textwidth > 0 ? ' --line-length=' . &textwidth : '') .
          \ (filereadable(expand('%')) ? ' --stdin-filename ' . formatprgs#path() : '') .
          \ printf(' --range=%d-%d -', v:lnum, v:lnum + v:count - 1))
  endfunction
  setlocal formatexpr=<SID>RuffFormatexpr()
elseif formatprgs#use('black-macchiato')
  let &l:formatprg = 'black-macchiato ' . get(b:, 'formatprg_args', '') . ' -'
elseif formatprgs#use('yapf') || formatprgs#use('yapf3')
  " yapf reads stdin without a file name; --quiet would suppress its output.
  let b:formatprg_cmd = (formatprgs#use('yapf3') ? 'yapf3' : 'yapf') . ' ' . get(b:, 'formatprg_args', '')
  function! s:YapfFormatexpr() abort
    return formatprgs#filter(b:formatprg_cmd . printf(' --lines %d-%d', v:lnum, v:lnum + v:count - 1))
  endfunction
  setlocal formatexpr=<SID>YapfFormatexpr()
elseif formatprgs#use('autopep8')
  let b:formatprg_cmd = 'autopep8 ' . get(b:, 'formatprg_args', '--aggressive --experimental')
  function! s:Autopep8Formatexpr() abort
    return formatprgs#filter(b:formatprg_cmd .
          \ (&textwidth > 0 ? ' --max-line-length ' . &textwidth : '') .
          \ printf(' --line-range %d %d -', v:lnum, v:lnum + v:count - 1))
  endfunction
  setlocal formatexpr=<SID>Autopep8Formatexpr()
endif

call formatprgs#undo('formatprgsPython', 'setlocal formatprg< formatexpr< | unlet! b:formatprg b:formatprg_cmd b:formatprg_args')
