call formatprgs#init('formatprgsCss')

if formatprgs#use('prettier')
  call formatprgs#prettier_setup('--log-level=error --no-color --no-error-on-unmatched-pattern --single-quote --parser=' . &filetype)
elseif formatprgs#use('biome')
  call formatprgs#on_bufwinenter('formatprgsCss',
        \ "let &l:formatprg = formatprgs#biome('--write --format-with-errors=true --colors=off')")
endif

call formatprgs#undo('formatprgsCss', 'setlocal formatprg< formatexpr< | unlet! b:formatprg b:formatprg_cmd b:formatprg_args')
