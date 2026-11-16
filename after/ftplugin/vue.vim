call formatprgs#init('formatprgsVue')

if formatprgs#use('prettier')
  call formatprgs#prettier_setup('--log-level=error --no-color --no-error-on-unmatched-pattern --single-quote --parser=' . &filetype . ' --vue-indent-script-and-style')
elseif formatprgs#use('biome')
  call formatprgs#on_bufwinenter('formatprgsVue',
        \ "let &l:formatprg = formatprgs#biome('--write --format-with-errors=true --colors=off')")
endif

call formatprgs#undo('formatprgsVue', 'setlocal formatprg< formatexpr< | unlet! b:formatprg b:formatprg_cmd b:formatprg_args')
