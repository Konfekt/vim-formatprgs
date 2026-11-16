if !executable('tombi') | finish | endif

call formatprgs#init('formatprgsToml')

" See https://github.com/tombi-toml/tombi/pull/1044#issuecomment-3465851563
let &l:formatprg = printf('tombi format %s%s - %s',
      \ get(b:, 'formatprg_args', ''),
      \ filereadable(expand('%')) ? ' --stdin-filename ' . expand('%:p:S') : '',
      \ has('win32') ? '2>nul' : '2>/dev/null')

call formatprgs#undo('formatprgsToml', 'setlocal formatprg< | unlet! b:formatprg_args')
