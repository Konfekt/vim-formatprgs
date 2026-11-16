augroup formatprgsBib
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

if executable('bibtex-tidy')
  execute 'autocmd formatprgsBib BufWinEnter <buffer> ++once ' .
        \ "let &l:formatprg = 'bibtex-tidy ' ." .
        \ " get(b:, 'formatprg_args', '--quiet --merge combine --strip-enclosing-braces --drop-all-caps --encode-urls --trailing-commas --tidy-comments --remove-empty-fields --sort --blank-lines') . ' ' ." .
        \ " (&textwidth > 0 ? '--wrap=' . &textwidth : '') . ' ' ." .
        \ " (&expandtab ? '--no-tab' : '--tab') . ' --space=' . shiftwidth()"
elseif executable('prettybib.py') || executable('prettybib')
  let &l:formatprg = (executable('prettybib') ? 'prettybib' : 'prettybib.py') .
        \ (empty(get(b:, 'formatprg_args', '')) ? '' : ' ' . b:formatprg_args)
endif

if exists('#formatprgsBib#BufWinEnter#<buffer>') && bufwinnr(bufnr('%')) != -1
  doautocmd <nomodeline> formatprgsBib BufWinEnter <buffer>
endif

let b:undo_ftplugin = (empty(get(b:, 'undo_ftplugin', '')) ? '' : b:undo_ftplugin . ' | ') .
      \ 'setlocal formatprg< | if &filetype !=# ''' . &filetype . ''' | unlet! b:formatprg_args | endif | execute ''silent! autocmd! formatprgsBib * <buffer>'''
