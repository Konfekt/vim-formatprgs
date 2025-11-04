augroup formatprgsSh
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

if executable('shfmt')
  autocmd BufWinEnter <buffer> ++once let &l:formatprg = 'shfmt --space-redirects --case-indent --simplify --indent ' . (&expandtab ? shiftwidth() : 0)
endif

if executable('format_shell_cmd.py')
  " From https://github.com/bbkane/dotfiles/blob/master/bin_common/bin_common/format_shell_cmd.py
  nnoremap <silent> <buffer> gqgq :<C-U>silent .!format_shell_cmd.py<CR>
endif

let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '') . 'setlocal formatprg< | silent! autocmd! formatprgsSh * <buffer> | silent! nunmap <buffer> gqgq'
