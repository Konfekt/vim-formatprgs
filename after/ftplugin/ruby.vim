call formatprgs#init('formatprgsRuby')

if formatprgs#use('rubocop')
  " The file name after --stdin is not needed for formatting.
  let &l:formatprg = 'rubocop -x --stdin _ ' .
        \ get(b:, 'formatprg_args', '') .
        \ ' --stderr 2>' . (has('win32') ? 'NUL' : '/dev/null')
endif

call formatprgs#undo('formatprgsRuby', 'setlocal formatprg< | unlet! b:formatprg b:formatprg_args')
