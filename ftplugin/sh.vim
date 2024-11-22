

if executable('shfmt')
  if exists('##ShellFilterPost')
    autocmd vimrcFileTypeSh ShellFilterPost <buffer> if v:shell_error | execute 'echom "shell filter returned error " . v:shell_error . ", undoing changes"' | undo | endif
  endif
  autocmd vimrcFileTypeSh BufWinEnter <buffer> ++once let &l:formatprg =
        \ 'shfmt -ln posix -sr -ci -s -i ' . &l:shiftwidth
endif
if executable('format_shell_cmd.py')
  " From https://github.com/bbkane/dotfiles/blob/master/bin_common/bin_common/format_shell_cmd.py
  nnoremap <buffer> gqgq :<c-u>.!format_shell_cmd.py<cr>
endif
