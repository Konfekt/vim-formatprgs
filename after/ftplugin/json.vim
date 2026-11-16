call formatprgs#init('formatprgsJSON')

" see https://stackoverflow.com/questions/21413120/how-can-i-get-gg-g-in-vim-to-ignore-a-comma/21413701#21413701
setlocal cinoptions+=+0

" g:json_formatprg names a jq-compatible program to use instead of jq.
let s:jq = get(g:, 'json_formatprg', '')
if !exists('g:json_formatprg')
  for s:exe in ['jq'] + (has('win32') || !empty($WSL_DISTRO_NAME) ? ['jq.exe', 'jq-win64.exe', 'jq-win32.exe'] : [])
    if formatprgs#use(s:exe)
      let s:jq = s:exe
      break
    endif
  endfor
  unlet! s:exe
endif

if !empty(s:jq)
  " jq cannot indent by more than 7 spaces; --tab and --indent override each other.
  call formatprgs#on_bufwinenter('formatprgsJSON', 'let &l:formatprg = ' . string(s:jq) . " . ' ' ." .
        \ " get(b:, 'formatprg_args', '') ." .
        \ " (&expandtab ? ' --indent ' . min([shiftwidth(), 7]) : ' --tab') . ' \".\"'")
elseif formatprgs#use('biome')
  call formatprgs#on_bufwinenter('formatprgsJSON',
        \ "let &l:formatprg = formatprgs#biome('--write --format-with-errors=true --colors=off')")
elseif formatprgs#use('prettier')
  call formatprgs#prettier_setup('--single-quote --parser=json')
elseif v:version >= 901 && !has('nvim')
  " Vim's own JSON formatter
  setlocal formatexpr=dist#json#FormatExpr()
endif
unlet s:jq

call formatprgs#undo('formatprgsJSON', 'setlocal cinoptions< formatprg< formatexpr< | unlet! b:formatprg b:formatprg_cmd b:formatprg_args')
