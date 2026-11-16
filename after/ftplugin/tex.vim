if !executable('tex-fmt') | finish | endif

call formatprgs#init('formatprgsTex')

let &l:formatprg = 'tex-fmt ' . get(b:, 'formatprg_args', '--print --quiet --stdin')

call formatprgs#undo('formatprgsTex', 'setlocal formatprg< | unlet! b:formatprg_args')
