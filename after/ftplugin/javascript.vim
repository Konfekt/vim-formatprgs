" Other filetypes, such as javascriptreact, source this ftplugin as well.
if &filetype !=# 'javascript' | finish | endif

call formatprgs#init('formatprgsJavaScript')

if formatprgs#use('prettier')
  call formatprgs#prettier_setup('--log-level=error --no-color --no-error-on-unmatched-pattern --single-quote --parser=babel')
elseif formatprgs#use('biome')
  call formatprgs#on_bufwinenter('formatprgsJavaScript',
        \ "let &l:formatprg = formatprgs#biome('--write --format-with-errors=true --colors=off')")
elseif formatprgs#use('clang-format')
  setlocal formatexpr=formatprgs#clang_format('Chromium','stdin.js')
endif

call formatprgs#undo('formatprgsJavaScript', 'setlocal formatprg< formatexpr< | unlet! b:formatprg b:formatprg_cmd b:formatprg_args')
