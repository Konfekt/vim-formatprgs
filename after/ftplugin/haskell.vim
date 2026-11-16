call formatprgs#init('formatprgsHaskell')

if formatprgs#use('ormolu')
  let &l:formatprg = 'ormolu ' . get(b:, 'formatprg_args', '') . ' --stdin-input-file ' . expand('%:S')
endif

call formatprgs#undo('formatprgsHaskell', 'setlocal formatprg< | unlet! b:formatprg b:formatprg_args')
