if !exists('g:json_formatprg')
  if executable('jq')
    let g:json_formatprg = 'jq'
  elseif has('win32') || !empty($WSL_DISTRO_NAME)
    if executable('jq-win64.exe')
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
  " for vim9script fallback
  " See https://stackoverflow.com/questions/26214156/how-to-auto-format-json-on-save-in-vim
  augroup formatprgsJSON
    autocmd! * <buffer>
    if exists('##ShellFilterPost')
      autocmd ShellFilterPost <buffer> if v:shell_error | execute 'echom "shell filter returned error " . v:shell_error . ", undoing changes"' | undo | endif
    endif
    autocmd BufWinEnter <buffer> ++once let &l:formatprg = g:json_formatprg . ' --compact-output ' .
          \ (&expandtab ? '' : '--tab') . (' --indent ' . &l:shiftwidth) . ' "."'
  augroup END
endif
