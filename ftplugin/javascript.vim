if &filetype !=# 'javascript' | finish | endif

if !executable('prettier') | finish | endif

augroup formatprgsJavaScript
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | execute 'echom "shell filter returned error " . v:shell_error . ", undoing changes"' | undo | endif
  endif
  let b:prettier_config = trim(system('prettier --find-config-path ' . expand('%:p:S')))
  autocmd BufWinEnter <buffer> ++once let &l:formatprg =
        \ 'prettier --stdin-filepath=%:S --single-quote --parser=' . &filetype . ' ' .
        \ (&textwidth > 0 ? '--print-width=' . &textwidth : '') . ' ' .
        \ '--tab-width=' . &l:shiftwidth . ' ' . (&expandtab ? '' : '--use-tabs') . ' ' .
        \ (filereadable(b:prettier_config) ? '--config ' . b:prettier_config : '') . ' --'
augroup END
