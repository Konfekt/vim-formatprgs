setlocal textwidth=80
setlocal shiftwidth=2
setlocal tabstop=2
setlocal softtabstop=2
setlocal expandtab

if executable('shfmt')
  augroup vimrcFileTypeZsh
    autocmd! * <buffer>
    if exists('##ShellFilterPost')
      autocmd ShellFilterPost <buffer> if v:shell_error | execute 'echom "shell filter returned error " . v:shell_error . ", undoing changes"' | undo | endif
    endif
    autocmd BufWinEnter <buffer> ++once let &l:formatprg =
          \ 'shfmt -ln posix -sr -ci -s -i ' . &l:shiftwidth
  augroup END
endif
if executable('format_shell_cmd.py')
  " From https://github.com/bbkane/dotfiles/blob/master/bin_common/bin_common/format_shell_cmd.py
  nnoremap <buffer> gqqq :<c-u>.!format_shell_cmd.py<cr>
endif
