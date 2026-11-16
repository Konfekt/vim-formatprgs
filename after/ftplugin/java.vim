call formatprgs#init('formatprgsJava')

if formatprgs#use('clang-format')
  setlocal formatexpr=formatprgs#clang_format('Google','stdin.java')
elseif formatprgs#use('uncrustify')
  call formatprgs#on_bufwinenter('formatprgsJava',
        \ "let &l:formatprg = formatprgs#uncrustify(get(b:, 'formatprg_args', '-q -l JAVA'))")
elseif formatprgs#use('astyle')
  call formatprgs#on_bufwinenter('formatprgsJava',
        \ "let &l:formatprg = formatprgs#astyle('--quiet --mode=java --style=google --pad-oper --pad-header --unpad-paren --align-pointer=name --align-reference=name --add-brackets --suffix=none')")
endif

call formatprgs#undo('formatprgsJava', 'setlocal formatprg< formatexpr< | unlet! b:formatprg b:formatprg_args')
