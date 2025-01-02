if !exists('s:jq')
  if executable('jq')
    let s:jq = 'jq'
  elseif has('win32') || !empty($WSL_DISTRO_NAME)
    if executable('jq-win64.exe')
      let s:jq = 'jq-win64.exe'
    elseif executable('jq-win32.exe')
      let s:jq = 'jq-win32.exe'
    else
      let s:jq = ''
    endif
  else
    let s:jq = ''
  endif
endif

" see https://stackoverflow.com/questions/21413120/how-can-i-get-gg-g-in-vim-to-ignore-a-comma/21413701#21413701
setlocal cinoptions+=+0

if !empty(s:jq)
  " for vim9script fallback
  let b:found_jq = 1
  " See https://stackoverflow.com/questions/26214156/how-to-auto-format-json-on-save-in-vim
  augroup formatprgsJSON
    autocmd! * <buffer>
    if exists('##ShellFilterPost')
      autocmd ShellFilterPost <buffer> if v:shell_error | execute 'echom "shell filter returned error " . v:shell_error . ", undoing changes"' | undo | endif
    endif
    autocmd BufWinEnter <buffer> ++once let &l:formatprg = s:jq . ' --compact-output ' .
          \ (&expandtab ? '' : '--tab') . (' --indent ' . &l:shiftwidth) . ' "."'
  augroup END
endif
