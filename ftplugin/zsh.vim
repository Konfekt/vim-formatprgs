if executable('shfmt')
  augroup formatprgsZsh
    autocmd! * <buffer>
    if exists('##ShellFilterPost')
      autocmd ShellFilterPost <buffer> if v:shell_error | execute 'echom "shell filter returned error " . v:shell_error . ", undoing changes"' | undo | endif
    endif
    autocmd BufWinEnter <buffer> ++once let &l:formatprg =
          \ 'shfmt --space-redirects --case-indent --simplify --indent ' . (&expandtab > 0 ? &shiftwidth : 0)
  augroup END
endif
if executable('format_shell_cmd.py')
  " From https://github.com/bbkane/dotfiles/blob/master/bin_common/bin_common/format_shell_cmd.py
  nnoremap <buffer> gqqq :<c-u>.!format_shell_cmd.py<cr>
endif
