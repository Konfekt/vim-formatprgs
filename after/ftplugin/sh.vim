call formatprgs#init('formatprgsSh')

if executable('shfmt')
  call formatprgs#on_bufwinenter('formatprgsSh', 'let &l:formatprg = formatprgs#shfmt()')
endif

if executable('format_shell_cmd.py')
  " From https://github.com/bbkane/dotfiles/blob/master/bin_common/bin_common/format_shell_cmd.py
  nnoremap <silent> <buffer> gqgq :<C-U>silent .!format_shell_cmd.py<CR>
endif

call formatprgs#undo('formatprgsSh', 'setlocal formatprg< | unlet! b:formatprg_args | silent! nunmap <buffer> gqgq')
