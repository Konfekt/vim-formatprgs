if !executable('tex-fmt') | finish | endif

augroup formatprgsTex
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

let &l:formatprg = 'tex-fmt ' . get(b:, 'formatprg_args', '--print --quiet --stdin')

let b:undo_ftplugin = (empty(get(b:, 'undo_ftplugin', '')) ? '' : b:undo_ftplugin . ' | ') .
      \ 'setlocal formatprg< | if &filetype !=# ''' . &filetype . ''' | unlet! b:formatprg_args | endif | execute ''silent! autocmd! formatprgsTex * <buffer>'''
