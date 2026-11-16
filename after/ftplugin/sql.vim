call formatprgs#init('formatprgsSQL')

if formatprgs#use('sql-formatter')
  " npm install -g sql-formatter
  " set indent width in a JSON file passed by --config
  " https://github.com/sql-formatter-org/sql-formatter?tab=readme-ov-file#configuration-options
  let &l:formatprg = 'sql-formatter ' . get(b:, 'formatprg_args', '--language postgresql')
elseif formatprgs#use('sqlformat')
  " Ships with sqlparse
  call formatprgs#on_bufwinenter('formatprgsSQL',
        \ "let &l:formatprg = 'sqlformat ' . get(b:, 'formatprg_args', '--reindent_aligned') . ' --indent_width=' . shiftwidth() . ' -'")
elseif formatprgs#use('sleek')
  " From https://github.com/balling-dev/sleek/releases/
  call formatprgs#on_bufwinenter('formatprgsSQL',
        \ "let &l:formatprg = 'sleek ' . get(b:, 'formatprg_args', '') . ' --indent-spaces=' . shiftwidth() . ' -'")
endif

call formatprgs#undo('formatprgsSQL', 'setlocal formatprg< | unlet! b:formatprg b:formatprg_args')
