augroup formatprgsPython
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

if !executable(get(b:, 'formatprg', '')) | let b:formatprg = '' | endif
if b:formatprg ==# 'ruff' || empty(b:formatprg) && executable('ruff')
  let s:cmd = 'ruff format --quiet --preview '
  function! s:RuffFormatexpr() abort
    let start = v:lnum
    let end   = v:lnum + v:count - 1
    let cmd = s:cmd .
          \ (&textwidth > 0 ? ' --line-length=' . &textwidth : '' ) .
          \ (filereadable(expand('%')) ? ' --stdin-filename ' . expand('%:p:S') : '') .
          \  printf(' --range=%d-%d -', start, end)
    let view  = winsaveview()
    try
      silent exe '%!' cmd
    finally
      call winrestview(view)
    endtry
  endfunction

  setlocal formatexpr=<SID>RuffFormatexpr()
elseif b:formatprg ==# 'black-macchiato' || empty(b:formatprg) && executable('black-macchiato')
  let &l:formatprg = 'black-macchiato -'
elseif  (b:formatprg ==# 'yapf' || empty(b:formatprg) && executable('yapf'))  ||
      \ (b:formatprg ==# 'yapf3' || empty(b:formatprg) && executable('yapf3'))
  let s:cmd = (executable('yapf3') ? 'yapf3' :'yapf') . ' --quiet'
  function! s:YapfFormatexpr() abort
    let start = v:lnum
    let end   = v:lnum + v:count - 1
    let cmd = s:cmd ..  printf(' --lines %d-%d -', start, end)
    let view  = winsaveview()
    try
      silent exe '%!' cmd
    finally
      call winrestview(view)
    endtry
  endfunction

  setlocal formatexpr=<SID>YapfFormatexpr()
elseif b:formatprg ==# 'autopep8' || empty(b:formatprg) && executable('autopep8')
  let s:cmd = 'autopep8 --quiet --aggressive --experimental '
  function! s:YapfFormatexpr() abort
    let start = v:lnum
    let end   = v:lnum + v:count - 1
    let cmd = s:cmd .
          \ (&textwidth > 0 ? ' --max-line-length ' . &textwidth : '' ) .
          \  printf(' --line-range %d %d -', start, end)
    let view  = winsaveview()
    try
      silent exe '%!' cmd
    finally
      call winrestview(view)
    endtry
  endfunction

  setlocal formatexpr=<SID>YapfFormatexpr()
endif

let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '') .
      \ 'setlocal formatprg< | silent! autocmd! formatprgsPython * <buffer>'
