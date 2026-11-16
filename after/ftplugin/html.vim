" Other filetypes, such as htmldjango, source the html ftplugins as well.
if &filetype !~# '^x\?html$' | finish | endif

call formatprgs#init('formatprgsHTML')

if formatprgs#use('tidy')
  " tidy exits non-zero on mere warnings.
  call formatprgs#on_bufwinenter('formatprgsHTML',
        \ "let &l:formatprg = formatprgs#tidy(&filetype ==# 'xhtml' ? 'tidy -xml' : 'tidy') ." .
        \ " (has('win32') ? ' || exit /b 0' : ' || true')")
elseif formatprgs#use('html-beautify')
  " html-beautify is in js-beautify node package
  " npm -g install js-beautify
  call formatprgs#on_bufwinenter('formatprgsHTML', "let &l:formatprg = 'html-beautify ' ." .
        \ " get(b:, 'formatprg_args', '') . ' ' ." .
        \ " (&expandtab ? '' : '--indent-with-tabs ') . '-s ' . shiftwidth() . ' -f -'")
elseif formatprgs#use('prettier')
  call formatprgs#prettier_setup('--log-level=error --no-color --no-error-on-unmatched-pattern --single-quote --parser=html')
elseif formatprgs#use('biome')
  call formatprgs#on_bufwinenter('formatprgsHTML',
        \ "let &l:formatprg = formatprgs#biome('--write --format-with-errors=true --colors=off')")
endif

call formatprgs#undo('formatprgsHTML', 'setlocal formatprg< formatexpr< | unlet! b:formatprg b:formatprg_cmd b:formatprg_args')
