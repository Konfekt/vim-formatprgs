augroup formatprgsZsh
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

if executable('shfmt')
  " Use shfmt as the formatter, tuned to current indentation settings.
  " -i 0 means tabs; otherwise use shiftwidth if set, else tabstop.
  autocmd formatprgsZsh BufWinEnter <buffer> ++once let &l:formatprg =
        \ 'shfmt ' .
        \ get(b:, 'formatprg_args', '--space-redirects --case-indent --simplify') . ' ' .
        \ '--indent ' . shiftwidth()
endif
if exists('#formatprgsZsh#BufWinEnter#<buffer>')
  if bufwinnr(bufnr()) != -1
    doautocmd <nomodeline> formatprgsZsh BufWinEnter <buffer>
  endif
endif

if executable('format_shell_cmd.py')
  " From https://github.com/bbkane/dotfiles/blob/master/bin_common/bin_common/format_shell_cmd.py
  nnoremap <buffer> <silent> gqqq :<c-u>.!format_shell_cmd.py<cr>
endif

let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '')
      \ . ' setlocal formatprg<'
      \ . '|unlet! b:formatprg_args'
      \ . '|silent! autocmd! formatprgsZsh * <buffer>'
      \ . '|silent! nunmap <buffer> gqqq'
