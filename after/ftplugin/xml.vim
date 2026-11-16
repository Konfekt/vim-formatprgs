" Also sourced for XHTML by Vim's xhtml ftplugin.
call formatprgs#init('formatprgsXML')

if formatprgs#use('xmllint')
  " Vim's xml ftplugin sets 'formatexpr', which takes precedence.
  setlocal formatexpr=
  call formatprgs#on_bufwinenter('formatprgsXML', "let &l:formatprg = (has('win32')" .
        \ " ? 'cmd /c \"set XMLLINT_INDENT=' . shiftwidth() . '&&' : 'XMLLINT_INDENT=' . shiftwidth()) ." .
        \ " ' xmllint --output - ' . get(b:, 'formatprg_args', '--format --recover --encode UTF-8 --nonet') ." .
        \ " (has('win32') ? '\"' : '')")
elseif formatprgs#use('tidy')
  setlocal formatexpr=
  call formatprgs#on_bufwinenter('formatprgsXML', "let &l:formatprg = formatprgs#tidy('tidy -xml')")
elseif formatprgs#use('prettier')
  call formatprgs#prettier_setup('--log-level=error --no-color --no-error-on-unmatched-pattern --parser=' . &filetype)
endif

call formatprgs#undo('formatprgsXML', 'setlocal formatprg< formatexpr< | unlet! b:formatprg b:formatprg_cmd b:formatprg_args')
