augroup formatprgsHaskell
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

if s:Use('ormolu')
  let &l:formatprg = 'ormolu ' . get(b:, 'formatprg_args', '') . ' --stdin-input-file ' . shellescape(expand('%'), 1)
endif

let b:undo_ftplugin = (empty(get(b:, 'undo_ftplugin', '')) ? '' : b:undo_ftplugin . ' | ') .
      \ 'setlocal formatprg< | if &filetype !=# ''' . &filetype . ''' | unlet! b:formatprg b:formatprg_args | endif | execute ''silent! autocmd! formatprgsHaskell * <buffer>'''
