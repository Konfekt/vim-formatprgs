if exists('b:did_ftplugin') | finish | endif
let b:did_ftplugin = 1

if !exists('g:json_formatprg')
  if executable('jq')
    let g:json_formatprg = 'jq'
  elseif has('win32') || !empty($WSL_DISTRO_NAME)
    if executable('jq.exe')
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
          \ (&expandtab ? '' : '--tab') . (' --indent ' . shiftwidth()) . ' "."'
  augroup END
endif

let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '') . 'setlocal cinoptions< formatprg<'
