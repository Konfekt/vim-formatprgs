augroup formatprgsSh
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

" shfmt indents with tabs for --indent 0.
function! s:Shfmt() abort
  return 'shfmt ' . get(b:, 'formatprg_args', '--space-redirects --case-indent --simplify') .
        \ ' --indent ' . (&expandtab ? shiftwidth() : 0)
endfunction

if executable('shfmt')
  execute 'autocmd formatprgsSh BufWinEnter <buffer> ++once ' .
        \ 'let &l:formatprg = s:Shfmt()'
endif

if executable('format_shell_cmd.py')
  " From https://github.com/bbkane/dotfiles/blob/master/bin_common/bin_common/format_shell_cmd.py
  nnoremap <silent> <buffer> gqgq :<C-U>silent .!format_shell_cmd.py<CR>
endif

if exists('#formatprgsSh#BufWinEnter#<buffer>') && bufwinnr(bufnr('%')) != -1
  doautocmd <nomodeline> formatprgsSh BufWinEnter <buffer>
endif

let b:undo_ftplugin = (empty(get(b:, 'undo_ftplugin', '')) ? '' : b:undo_ftplugin . ' | ') .
      \ 'setlocal formatprg< | if &filetype !=# ''' . &filetype . ''' | unlet! b:formatprg_args | endif | execute ''silent! nunmap <buffer> gqgq'' | execute ''silent! autocmd! formatprgsSh * <buffer>'''
