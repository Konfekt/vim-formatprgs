if !executable('biome') | finish | endif

call formatprgs#init('formatprgsSvelte')

call formatprgs#on_bufwinenter('formatprgsSvelte',
      \ "let &l:formatprg = formatprgs#biome('--write --format-with-errors=true --colors=off')")

call formatprgs#undo('formatprgsSvelte', 'setlocal formatprg< | unlet! b:formatprg_args')
