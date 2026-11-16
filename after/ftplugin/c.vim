" Also sourced for C++ by Vim's cpp ftplugin.
call formatprgs#init('formatprgsC')

if formatprgs#use('clang-format')
  setlocal formatexpr=formatprgs#clang_format('LLVM','stdin.c')
elseif formatprgs#use('uncrustify')
  call formatprgs#on_bufwinenter('formatprgsC',
        \ "let &l:formatprg = formatprgs#uncrustify(get(b:, 'formatprg_args', '-q') . ' -l ' . &filetype)")
elseif formatprgs#use('astyle')
  call formatprgs#on_bufwinenter('formatprgsC',
        \ "let &l:formatprg = formatprgs#astyle('--quiet --mode=c --style=google --pad-oper --pad-header --unpad-paren --align-pointer=name --align-reference=name --add-brackets --suffix=none')")
endif

call formatprgs#undo('formatprgsC', 'setlocal formatprg< formatexpr< | unlet! b:formatprg b:formatprg_args')
