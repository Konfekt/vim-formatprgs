call formatprgs#init('formatprgsCMake')

if formatprgs#use('cmake-format')
  call formatprgs#on_bufwinenter('formatprgsCMake', "let &l:formatprg = 'cmake-format '" .
        \ " . get(b:, 'formatprg_args', '') . ' '" .
        \ " . (&textwidth > 0 ? ' --line-width=' . &textwidth : '')" .
        \ " . ' --tab-size=' . shiftwidth()" .
        \ " . (&expandtab ? '' : ' --use-tabchars')" .
        \ " . ' -'")
elseif formatprgs#use('neocmakelsp')
  let &l:formatprg = 'neocmakelsp format ' . get(b:, 'formatprg_args', '')
else
  " No formatter available; ensure we don't inherit a stale formatprg
  setlocal formatprg=
endif

call formatprgs#undo('formatprgsCMake', 'setlocal formatprg< | unlet! b:formatprg b:formatprg_args')
