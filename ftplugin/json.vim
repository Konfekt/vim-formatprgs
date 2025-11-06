if exists('b:did_ftplugin') | finish | endif
let b:did_ftplugin = 1

if !executable(get(b:, 'formatprg', '')) | let b:formatprg = '' | endif
if !exists('g:json_formatprg')
  if b:formatprg ==# 'jq' || empty(b:formatprg) && executable('jq')
    let g:json_formatprg = 'jq'
  elseif has('win32') || !empty($WSL_DISTRO_NAME)
    if b:formatprg ==# 'jq.exe' || empty(b:formatprg) && executable('jq.exe')
      let g:json_formatprg = 'jq.exe'
    elseif executable('jq-win64.exe')
      let g:json_formatprg = 'jq-win64.exe'
    elseif executable('jq-win32.exe')
      let g:json_formatprg = 'jq-win32.exe'
    else
      let g:json_formatprg = ''
    endif
  else
    let g:json_formatprg = ''
  endif
endif

" see https://stackoverflow.com/questions/21413120/how-can-i-get-gg-g-in-vim-to-ignore-a-comma/21413701#21413701
setlocal cinoptions+=+0

if !empty(g:json_formatprg)
  " For vim9script fallback see https://stackoverflow.com/questions/26214156/how-to-auto-format-json-on-save-in-vim
  augroup formatprgsJSON
    autocmd! * <buffer>
    if exists('##ShellFilterPost')
      autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
    endif
    autocmd BufWinEnter <buffer> ++once let &l:formatprg = g:json_formatprg . ' ' .
          \ get(b:, 'formatprg_args', '') .
          \ (&expandtab ? '' : ' --tab') .
          \ (' --indent ' . shiftwidth()) . ' "."'
  augroup END
elseif b:formatprg ==# 'biome' || empty(b:formatprg) && executable('biome')
  let b:formatprg_cmd = 'biome format ' . get(b:, 'formatprg_args', '--write --format-with-errors=true --colors=off')
  autocmd BufWinEnter <buffer> ++once let &l:formatprg = b:formatprg_cmd . ' ' .
        \ '--stdin-file-path=' . expand('%:p:S') . ' ' .
        \ (&textwidth > 0 ? '--line-width=' . &textwidth . ' ' : '') .
        \ '--indent-width=' . shiftwidth() . ' ' .
        \ '--indent-style=' . (&expandtab ? 'space' : 'tab')
elseif b:formatprg ==# 'prettier' || empty(b:formatprg) && executable('prettier')
  let b:prettier_config = isdirectory(expand('%:p')) ? trim(system('prettier --find-config-path ' .expand('%:p:S'))) : ''
  if v:shell_error | let b:prettier_config = '' | endif
  function! s:PrettierFormatexpr() abort
    let start = v:lnum
    let end   = v:lnum + v:count - 1
    let start_byte = line2byte(start)
    let end_byte   = line2byte(end + 1) - 1
    let cmd = 'prettier ' .
        \ get(b:, 'formatprg_args', '--single-quote --parser=babel-ts') . ' ' .
        \ (filereadable(b:prettier_config) ? '--config ' . shellescape(b:prettier_config) . ' ' : '') .
        \ (&textwidth > 0 ? '--print-width=' . &textwidth . ' ' : '') .
        \ '--tab-width=' . shiftwidth() . ' ' .
        \ (&expandtab ? '' : '--use-tabs ') .
        \ printf(' --range-start %d --range-end %d', start_byte, end_byte)
        \ . ' --stdin-filepath=' . expand('%:p:S')
    let view  = winsaveview()
    try
      " exe start ',' end '!' cmd
      silent exe '%!' cmd
    finally
      call winrestview(view)
    endtry
  endfunction
  setlocal formatexpr=<SID>PrettierFormatexpr()
endif

let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '') .
      \ 'setlocal cinoptions< formatprg< formatexpr< | unlet! b:prettier_config | silent! autocmd! formatprgsJSON * <buffer>'
