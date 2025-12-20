if !executable(get(b:, 'formatprg', '')) | let b:formatprg = '' | endif

if b:formatprg ==# 'rubocop' || empty(b:formatprg) && executable('rubocop')
  " Note: --stdin FILE ignored, not needed for formatting
  let &l:formatprg = 'rubocop -x --stdin _ ' .
        \ get(b:, 'formatprg_args', '') .
        \ ' --stderr 2>' . (has('win32') ? 'NUL' : '/dev/null')
else
  finish
endif

let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '') .
      \ 'setlocal formatprg<'
