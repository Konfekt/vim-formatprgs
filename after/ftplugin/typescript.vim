" Other filetypes, such as typescriptreact, source this ftplugin as well.
if &filetype !=# 'typescript' | finish | endif

call formatprgs#init('formatprgsTypeScript')

if formatprgs#use('biome')
  call formatprgs#on_bufwinenter('formatprgsTypeScript',
        \ "let &l:formatprg = formatprgs#biome('--write --format-with-errors=true --colors=off')")
elseif formatprgs#use('prettier')
  call formatprgs#prettier_setup('--single-quote --parser=babel-ts')
elseif formatprgs#use('clang-format')
  setlocal formatexpr=formatprgs#clang_format('Chromium','stdin.ts')
endif

call formatprgs#undo('formatprgsTypeScript', 'setlocal formatprg< formatexpr< | unlet! b:formatprg b:formatprg_cmd b:formatprg_args')
