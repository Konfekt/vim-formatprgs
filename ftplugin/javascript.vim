if &filetype !=# 'javascript' | finish | endif

if executable('prettier')
  augroup formatprgsJavaScript
    autocmd! * <buffer>
    if exists('##ShellFilterPost')
      autocmd ShellFilterPost <buffer> if v:shell_error | execute 'echom "shell filter returned error " . v:shell_error . ", undoing changes"' | undo | endif
    endif
    autocmd BufWinEnter <buffer> ++once let &l:formatprg =
                \ 'prettier --stdin-filepath=%:S --parser=javascript --single-quote' .
                \ (&textwidth > 0 ? ' --print-width=' . &textwidth : '') .
                \ ' --tab-width=' . &l:shiftwidth . (&expandtab ? '' : '--use-tabs') . ' --'
  augroup END
endif
