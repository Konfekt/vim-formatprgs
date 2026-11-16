call formatprgs#init('formatprgsBib')

if executable('bibtex-tidy')
  call formatprgs#on_bufwinenter('formatprgsBib', "let &l:formatprg = 'bibtex-tidy ' ." .
        \ " get(b:, 'formatprg_args', '--quiet --merge combine --strip-enclosing-braces --drop-all-caps --encode-urls --trailing-commas --tidy-comments --remove-empty-fields --sort --blank-lines') . ' ' ." .
        \ " (&textwidth > 0 ? '--wrap=' . &textwidth : '') . ' ' ." .
        \ " (&expandtab ? '--no-tab' : '--tab') . ' --space=' . shiftwidth()")
elseif executable('prettybib.py') || executable('prettybib')
  let &l:formatprg = (executable('prettybib') ? 'prettybib' : 'prettybib.py') .
        \ (empty(get(b:, 'formatprg_args', '')) ? '' : ' ' . b:formatprg_args)
endif

call formatprgs#undo('formatprgsBib', 'setlocal formatprg< | unlet! b:formatprg_args')
